#!/bin/bash

api_key=""
zone_id=""

default_security_level="high"
max_loadavg=2

# Check whether a command exists
for command in bc jq curl
do
    if [[ ! $(type $command 2> /dev/null) ]]; then
        echo "ERROR: ${command} not found."
        exit
    fi
done

if [[ -z $api_key || -z $zone_id ]]; then
    echo "Please set api_key and zone_id."
    exit
fi

if [ ! -e /proc/loadavg ]; then
    echo "This platform is not supported."
    exit
fi

loadavg=`cut -d ' ' -f 1 /proc/loadavg`

# Get Security Level setting
current_security_level=`curl -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/settings/security_level" \
    -H "Authorization: Bearer $api_key" \
    -H "Content-Type: application/json" | jq -r '.result.value' --silent`

if [ `echo "$max_loadavg < $loadavg" | bc` -eq 1 ] && [ $current_security_level = $default_security_level ]; then
    # Enable Under Attack Mode
    result=`curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$zone_id/settings/security_level" \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        --data '{"value": "under_attack"}' --silent
        | jq -r '.success'`
    if [ $result = "true" ]; then
        echo "Under Attack mode enabled."
    fi
elif [ `echo "$max_loadavg < $loadavg" | bc` -ne 1 ] && [ $current_security_level = "under_attack" ]; then
    # Disable Under Attack Mode
    result=`curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$zone_id/settings/security_level" \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        --data "{\"value\": \"$default_security_level\"}" --silent
        | jq -r '.success'`
    if [ $result = "true" ]; then
        echo "Under Attack mode disabled."
    fi
else
    echo "No changes."
fi

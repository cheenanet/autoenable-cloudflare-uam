#!/bin/bash

api_key=""
zone_id=""

default_security_level="high"
max_uptime=2

if [ "$api_key" = "" ] || [ "$zone_id" = "" ]; then
    echo "Please set api_key and zone_id."
    exit
fi

uptime=`uptime | awk '{ print $8 }' | head -c -2`

# Get Security Level setting
current_security_level=`curl -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/settings/security_level" \
    -H "Authorization: Bearer $api_key" \
    -H "Content-Type: application/json" | jq -r '.result.value'`

if [ `echo "$max_uptime < $uptime" | bc` = 1 ] && [ $current_security_level = $default_security_level ]; then
    # Enable Under Attack Mode
    result=`curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$zone_id/settings/security_level" \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        --data '{"value": "under_attack"}'
        | jq -r '.success'`
    if [ $result = "true" ]; then
        echo "Under Attack mode enabled."
    fi
elif [ `echo "$max_uptime < $uptime" | bc` != 1 ] && [ $current_security_level = "under_attack" ]; then
    # Disable Under Attack Mode
    result=`curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$zone_id/settings/security_level" \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        --data "{\"value\": \"$default_security_level\"}"
        | jq -r '.success'`
    if [ $result = "true" ]; then
        echo "Under Attack mode disabled."
    fi
else
    echo "No changes."
fi

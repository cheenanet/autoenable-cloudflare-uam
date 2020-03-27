# Autoenable Cloudflare UAM
Auto-enable Cloudflare "Under Attack" mode when CPU load is high.

## Installation
1. Clone script.  
`$ git clone https://github.com/cheenanet/autoenable-cloudflare-uam.git`
2. Install `bc`, `jq`, and `curl` before run script.  
Debian/Ubuntu: `$ sudo apt install bc jq curl`  
Fedora/CentOS: `$ sudo yum install bc jq curl`

## Configuration
1. Create a new API token from [Cloudflare dashboard](https://dash.cloudflare.com/).
2. Set API token and Zone ID.
```
api_key=""
zone_id=""
```
3. Set default security level and CPU load limit.
```
default_security_level="high"
max_loadavg=2
```
4. Add to crontab.  
`*/20 * * * * /var/www/cloudflare-uam.sh`

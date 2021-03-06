#!/bin/bash

HOSTNAME=<domain to be updated>
PASSWORD=<generated from HE control panel>
IPPROVIDER=https://api.ipify.org
IP=`curl -sS $IPPROVIDER`

function valid_ip()
{
    local  ip=$IP
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOGFILE="$DIR/update-ip.log"
IPFILE="$DIR/update-ip.ip"
DATE=`date`
if ! valid_ip $IP; then
    echo "Invalid IP address: $IP" >> "$LOGFILE"
    exit 1
fi

# Check if the IP file exists
if [ ! -f "$IPFILE" ]
    then
  touch "$IPFILE"
fi

if grep -Fx "$IP" "$IPFILE"; then
    echo "$DATE IP is still $IP. Exiting" >> "$LOGFILE"
    exit 0
else
    echo "$DATE IP has changed to $IP" >> "$LOGFILE"
    echo "$IP" > "$IPFILE"
    wget --no-check-certificate -qO- "https://dyn.dns.he.net/nic/update?hostname=$HOSTNAME&password=$PASSWORD&myip=$IP"
    echo "$DATE updated IP address to $IP" >> "$LOGFILE"

fi

exit 0


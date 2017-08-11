#!/bin/bash

# Rocket.Chat incoming web-hook URL and user name
url='url for the incoming webhook'
username='zabbix'
icon_emoji=':grinning:'
LOGFILE="/var/log/zabbix/zabbix-rocketchat.log"

## Values received by this script:
# To = $1 (RocketChat channel or user to send the message to, specified in the Zabbix web interface; "@username" or "#channel")
# Subject = $2 (usually either OK or PROBLEM)
# Message = $3 (whatever message the Zabbix action sends, preferably something like "Zabbix server is unreachable for 5 minutes - Zabbix server (127.0.0.1)")

# Get the Mattermost channel or user ($1) and Zabbix subject ($2 - hopefully either PROBLEM or RECOVERY)
to="$1"
subject="$2"

# Change color emoji depending on the subject - Green (RECOVERY), Red (PROBLEM)
if [[ "$subject" == *"OK"* ]]; then
        color="#00ff33"
elif [[ "$subject" == *"PROBLEM"* ]]; then
        color="#ff2a00"
fi


if [[ "$subject" == *"OK"* ]]; then
        icon_emoji=':grinning:'
elif  [[ "$subject" == *"PROBLEM"* ]]; then
        icon_emoji=':slight_frown:'
fi

# The message that we want to send to Mattermost  is the "subject" value ($2 / $subject - that we got earlier)
#  followed by the message that Zabbix actually sent us ($3)
message="${subject}: $3"

# Build our JSON payload and send it as a POST request to the Mattermost incoming web-hook URL
payload='{"username":"'$username'","emoji":"'$icon_emoji'","attachments":[{"color":"'${color}'","title":"'${subject}'","text":"'${message}'"}]}'

# Send Payload to the Rocket.Chat Server
curl -X POST -H 'Content-Type: application/json' --data "${payload}" $url

# Write errors to log
echo "curl -X POST -H 'Content-Type: application/json' --data "${payload}" $url" 1>>${LOGFILE} 2>&1

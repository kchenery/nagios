#!/bin/bash

usage_warn="$1"
usage_error="$2"
username="$3"
password="$4"

if [ "${usage_warn}" == "" ]; then
        usage_warn=90
fi

if [ "${usage_error}" == "" ]; then
        usage_error=100
fi

if [ "${username}" == "" ]; then
        username=YourUsername
fi
if [ "${password}" == "" ]; then
        password=YourPassword
fi

#Get the usage from slingshot into a variable
usage_url="https://myaccount.slingshot.co.nz/api/?username=${username}&pwd=${password}"

rawusage=$( wget  "${usage_url}"  -q -O - )

# Convert the file to a pipe delimited list with each item on a single line
usage=$( echo "$rawusage" | sed 's/,/\
/g' | sed 's/=/\|/g' | grep DataUsedGB | sed 's/DataUsedGB|//')

todaysent=$( echo "$rawusage" | sed 's/,/\
/g' | sed 's/=/\|/g' | grep TodayDataSentTotalGB | sed 's/TodayDataSentTotalGB|//')

todayreceived=$( echo "$rawusage" | sed 's/,/\
/g' | sed 's/=/\|/g' | grep TodayDataRcvdTotalGB | sed 's/TodayDataRcvdTotalGB|//')

usage_int=$( printf "%.0f" $usage )


# Work out the return values
if [ ${usage_error} -lt ${usage_int} ]; then
        status=2
        statustxt=CRITICAL
elif [ "${usage_warn}" -lt "${usage_int}" ]; then
        status=1
        statustxt=WARNING
else
        status=0
        statustxt=OK
fi

echo "Data usage $statustxt - used = ${usage}GB | Monthly=${usage}GB;${usage_warn};${usage_error}; DailyUpload=${todaysent}GB; DailyDownload=${todayreceived}GB;"


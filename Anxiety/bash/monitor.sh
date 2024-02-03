#!/bin/bash

### mpstat
#############
if [ -n "$1" ]; then
    cache="$1"
else
    cache="$HOME/.cache/conky/Anxiety/mpstat"
fi
mpstat=$(mpstat -P ALL 1 1)

if [ -n "$mpstat" ]; then
    json="["
    IFS=$'\n' read -a lines -d '' <<< "$mpstat"
    for line in "${lines[@]}"; do
        if [[ "$line" =~ ^Average ]]; then
            cpu=$(echo "$line" | awk '{print $2}')
            idle=$(echo "$line" | awk '{print $NF}')
            if [[ "$cpu" != "CPU" && "$idle" != "%idle" ]]; then
                idle="${idle//,/\.}"
                usage=$(awk "BEGIN { print 100 - $idle }")
                json+="\n { \"cpu\": \"$cpu\", \"usage\": \"$usage\" },"
            fi
            
            
        fi
    done
    json="${json%,}"
    json+="\n]"

    echo -e "$json" > "$cache"
fi
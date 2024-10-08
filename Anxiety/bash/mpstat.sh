#!/bin/bash

#############
### mpstat
#############
if [ -n "$1" ]; then
    cache="$1"
else
    cache="$HOME/.cache/conky/Anxiety/mpstat"
fi
mpstat=$(mpstat -P ALL 1 1)

current_time=$(date +%s)
modulus=$((current_time % 5))
tmp="${cache}${modulus}"

if [ -n "$mpstat" ]; then
    json="["
    IFS=$'\n' read -a lines -d '' <<< "$mpstat"
    avg_found=false
    for line in "${lines[@]}"; do
        first=$(echo "$line" | awk '{print $1}')
        if [[ $first == *":" ]]; then
            cpu=$(echo "$line" | awk '{print $2}')
            idle=$(echo "$line" | awk '{print $NF}')
            if [[ "$cpu" != "CPU" && "$idle" != "%idle" ]]; then
                idle="${idle//,/\.}"
                usage=$(awk "BEGIN { print 100 - $idle }")
                json+=" { \"cpu\": \"$cpu\", \"usage\": \"$usage\" },"
            fi
        fi
    done
    json="${json%,}"
    json+=" ]"

    echo "$json" > "$tmp"
    if [ -f "$tmp" ]; then
        mv -f "$tmp" "$cache"
    fi
fi

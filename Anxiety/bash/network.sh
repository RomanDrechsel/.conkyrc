#!/bin/bash

#############
### network
#############

if [ -n "$2" ]; then
    cache="$2"
else
    cache="$HOME/.cache/conky/Anxiety/network"
fi
tmp="${cache}_tmp}"

function get_bytes()
{
    line=$(cat /proc/net/dev | grep $1 | cut -d ':' -f 2 | awk '{print "received_bytes="$1, "transmitted_bytes="$9}')
    eval $line
}

if [ -n $1 ] && [ -f "/proc/net/dev" ]; then
    get_bytes "$1"
    if [ -n "$received_bytes" ] && [ -n "$transmitted_bytes" ]; then
        old_received_bytes=$received_bytes
        old_transmitted_bytes=$transmitted_bytes
        sleep 1
        get_bytes "$1"

        vel_recv=$((received_bytes - old_received_bytes))
        vel_trans=$((transmitted_bytes - old_transmitted_bytes))

        json+="{ \"speed_down\": \"$vel_recv\", \"speed_up\": \"$vel_trans\", \"total_down\": \"$received_bytes\", \"total_up\": \"$transmitted_bytes\" }"

        echo -e "$json" > "$tmp"
        mv -f "$tmp" "$cache"
    fi
fi
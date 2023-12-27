#!/bin/bash

conky_cmd="conky -D -c .conkyrc_new"

killcmd=false
killopt=true

for var in "$@" 
do
    if [ "$var" = "-l" ]; then
        conky_cmd="conky"
    elif [ "$var" = "-k" ]; then
        killcmd=true
    elif [ "$var" = "-d" ]; then
        killopt=false
    fi
done

if [ "$killcmd" = true ]; then
    pid=$(pgrep -o -f "$conky_cmd")
    if [ -n "$pid" ]; then
        echo "Terminate '$conky_cmd' ($pid) ..."
        kill "$pid"
    else
        echo "Process '$conky_cmd'" not found
    fi
    exit
fi

pid=$(pgrep -o -f "$conky_cmd")

if [ -n "$pid" ]; then
    kill "$pid"
fi

if [ killopt = true ]; then
    output_file="tmp" 
    $conky_cmd &> "$output_file" &

    sleep 1
    file_size_before=$(wc -c < "$output_file")
    sleep 1
    file_size_after=$(wc -c < "$output_file")

    pid=$(pgrep -o -f "$conky_cmd")

    if [ "$file_size_after" -gt "$file_size_before" ]; then
        echo "Conky ($pid) was terminated :("
        echo " "
        echo "----"
        tail -n 5 "$output_file"
        echo "----"
        echo " "
        kill "$pid"
    else
        echo "Conky ($pid)  seems OK :)"
    fi
else
    $conky_cmd
fi
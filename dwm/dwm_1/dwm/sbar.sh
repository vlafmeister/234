#!/usr/bin/bash

layout(){
    # Get the LED value for the current layout
    # Run in the terminal to see the values for each layout.
    # The values in this example are valid for the us layout.
    t=$(xset -q | grep LED)
    code=${t##*mask:  }
    if [[ $code -eq "00000002" ]]; then
            result="EN"
    fi
    echo $result
}


# Date output in the format dd.MM.YYYY HH:MM
fdate(){
    date +"%H:%M"
}


# Current volume
volume(){
    full_str=$(amixer sget Master | grep Left: )
    state=${full_str##*\[}
    if [[ $state == "off]" ]]; then
            echo off
    else
            state=${full_str#*\[}
            echo ${state%%\]*}
    fi
}


# generate a line for the status bar and decorate it with emoji
generate_content(){
        echo "  |  VOL $(volume)  |  $(layout)  |  $(fdate)  |  "
}


# Display and update the status bar once a minute
while true; do
    xsetroot -name "$(generate_content)"
    sleep 0,1m
done

#!/bin/bash
SCRIPTNAME=$(basename $0)

tolog() {
    /usr/bin/logger -p local0.info -t $SCRIPTNAME "$@"
}

# Get out of town if something errors
set -e

DP_STATUS=$(cat /sys/class/drm/card0/card0-DP-2/status)

tolog "Card Status '$DP_STATUS'"
if [[ "connected" == "$DP_STATUS" ]]; then
    tolog "start"
    /usr/bin/xrandr 2>&1 | tolog
    /usr/bin/xrandr --output DP2 --off 2>&1 | tolog
    tolog "DP2 off"
    /usr/bin/xrandr 2>&1 | tolog
    /usr/bin/xrandr --output DP2 --auto 2>&1 | tolog
    tolog "DP2 auto"
    /usr/bin/xrandr 2>&1 | tolog
    tolog "Display Port plugged in"
    /usr/bin/notify-send --urgency=low -t 5000 "Graphics Update" "Display Port plugged in"
else
    /usr/bin/xrandr --output DP1 --off
    tolog "Display Port disconnected"
    /usr/bin/notify-send --urgency=low -t 5000 "Graphics Update" "Display Port disconnected"
    exit
fi

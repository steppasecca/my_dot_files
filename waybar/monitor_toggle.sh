#!/bin/bash
# Waybar custom module: shows On/Off for one output. Prints nothing (module hidden) if the
# output is not connected.   usage: monitor_toggle.sh DP-3
monitor=${1:-}
[ -n "$monitor" ] || exit 1

state=$(swaymsg -t get_outputs 2>/dev/null | jq -r --arg m "$monitor" '.[] | select(.name == $m) | .active')
[ -n "$state" ] || exit 0

icon=$'\uf108'
if [ "$state" = "true" ]; then
    printf '{"text": "%s %s: On", "class": "connected", "tooltip": "Monitor collegato e acceso\\nClicca per spegnere"}\n' "$icon" "$monitor"
else
    printf '{"text": "%s %s: Off", "class": "disconnected", "tooltip": "Monitor collegato ma spento\\nClicca per accendere"}\n' "$icon" "$monitor"
fi

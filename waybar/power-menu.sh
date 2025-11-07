#!/usr/bin/env bash

chosen=$(printf "  Blocca\n󰤄  Sospendi\n󰗼  Riavvia\n  Spegni\n󰗼  Esci da Sway" | \
    wofi --dmenu --prompt "Power Menu" --width 220 --height 250)

case "$chosen" in
    "  Blocca") swaylock ;;
    "󰤄  Sospendi") systemctl suspend ;;
    "󰗼  Riavvia") systemctl reboot ;;
    "  Spegni") systemctl poweroff ;;
    "󰗼  Esci da Sway") swaymsg exit ;;
esac

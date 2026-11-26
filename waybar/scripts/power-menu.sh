#!/usr/bin/env bash
# Power menu on rofi. Destructive actions ask for confirmation.
theme='window { width: 320px; } listview { lines: 5; }'
ask()     { rofi -dmenu -i -p "$1" -theme-str "$theme"; }
confirm() { [ "$(printf 'No\nSi\n' | rofi -dmenu -i -p "$1?" -theme-str 'window { width: 320px; } listview { lines: 2; }')" = "Si" ]; }

choice=$(printf '%s\n' "Blocca" "Sospendi" "Riavvia" "Spegni" "Esci da Sway" | ask "power")

case "$choice" in
    "Blocca")        swaylock -f ;;
    "Sospendi")      loginctl suspend ;;
    "Riavvia")       confirm "Riavviare" && loginctl reboot ;;
    "Spegni")        confirm "Spegnere"  && loginctl poweroff ;;
    "Esci da Sway")  confirm "Uscire"    && swaymsg exit ;;
esac

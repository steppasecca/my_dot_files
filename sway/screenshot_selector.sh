#!/bin/bash
# Screenshot menu on rofi + grim/slurp. Copies to clipboard or saves to ~/Pictures/Screenshots.
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
TEMP_FILE=$(mktemp --suffix=.png)
trap 'rm -f "$TEMP_FILE"' EXIT

pick() { rofi -dmenu -i -p "$1"; }

CAPTURE_TYPE=$(printf '%s\n' "Area" "Schermo Intero" "Annulla" | pick "Cattura")

case "$CAPTURE_TYPE" in
    "Area")
        GEOMETRY=$(slurp) || exit 0          # Esc during selection = cancel
        grim -g "$GEOMETRY" "$TEMP_FILE"
        ;;
    "Schermo Intero")
        grim "$TEMP_FILE"
        ;;
    *)
        exit 0
        ;;
esac

if [ ! -s "$TEMP_FILE" ]; then
    notify-send "Screenshot" "Cattura fallita."
    exit 1
fi

ACTION=$(printf '%s\n' "Copia negli Appunti" "Salva" "Annulla" | pick "Azione")

case "$ACTION" in
    "Copia negli Appunti")
        wl-copy --type image/png < "$TEMP_FILE"
        notify-send "Screenshot" "Copiato negli appunti."
        ;;
    "Salva")
        FILENAME="screenshot_${CAPTURE_TYPE// /_}_$(date +%Y-%m-%d_%H-%M-%S).png"
        mv "$TEMP_FILE" "$SAVE_DIR/$FILENAME"
        notify-send "Screenshot" "Salvato in: $FILENAME"
        ;;
    *)
        notify-send "Screenshot" "Operazione annullata."
        ;;
esac

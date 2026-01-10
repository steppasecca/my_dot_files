#!/bin/bash

# --- CONFIGURAZIONE ---
SAVE_DIR="$HOME/Pictures/Screenshots"
# Comando Rofi ottimizzato: dmenu mode, case-insensitive, con titolo personalizzato
ROFI_CMD="rofi -dmenu -i -p"

# Crea la directory di salvataggio se non esiste
mkdir -p "$SAVE_DIR"

# 1. MENU DI SCELTA INIZIALE
CAPTURE_TYPE=$(echo -e "Area\nSchermo Intero\nAnnulla" | $ROFI_CMD "Scegli Cattura")

TEMP_FILE="$(mktemp --suffix=.png)"

case "$CAPTURE_TYPE" in
    "Area")
        notify-send "Grimshot" "Seleziona l'area da catturare..."
        # Utilizziamo slurp e grim. Se slurp viene annullato (Esc), grim fallirà.
        grim -g "$(slurp)" "$TEMP_FILE"
        CAPTURE_STATUS=$?
        ;;
    "Schermo Intero")
        grim "$TEMP_FILE"
        CAPTURE_STATUS=$?
        ;;
    *)
        rm -f "$TEMP_FILE"
        exit 0
        ;;
esac

# 2. Verifica se la cattura è riuscita
if [ $CAPTURE_STATUS -ne 0 ] || [ ! -s "$TEMP_FILE" ]; then
    rm -f "$TEMP_FILE"
    notify-send "Grimshot" "Cattura annullata o fallita."
    exit 0
fi

# 3. MENU DI SCELTA FINALE
ACTION_CHOICE=$(echo -e "Copia negli Appunti\nSalva\nAnnulla" | $ROFI_CMD "Azione per lo screenshot")

case "$ACTION_CHOICE" in
    "Copia negli Appunti")
        wl-copy --type image/png < "$TEMP_FILE"
        notify-send "📋 Screenshot" "Copiato negli Appunti."
        ;;
    "Salva")
        TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
        FILENAME="screenshot_${CAPTURE_TYPE// /_}_$TIMESTAMP.png"
        mv "$TEMP_FILE" "$SAVE_DIR/$FILENAME"
        notify-send "📷 Screenshot" "Salvato in: $FILENAME"
        ;;
    *)
        rm -f "$TEMP_FILE"
        notify-send "Grimshot" "Operazione annullata."
        exit 0
        ;;
esac

# Pulizia finale (se non già spostato o rimosso)
rm -f "$TEMP_FILE"

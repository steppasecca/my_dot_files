#!/bin/bash

# --- CONFIGURAZIONE ---
# Percorso di salvataggio predefinito
SAVE_DIR="$HOME/Pictures/Screenshots"
# Tool per il menu di selezione 
MENU_SELECTOR="wofi --show dmenu -i -p 'Scegli Cattura: ' -H 200"
# Tool per il menu di azione
ACTION_SELECTOR="wofi --show dmenu -i -p 'Scegli Azione: ' -H 200"
# ----------------------

# Crea la directory di salvataggio se non esiste
mkdir -p "$SAVE_DIR"

# 1. MENU DI SCELTA INIZIALE: Tipo di Cattura
CAPTURE_TYPE=$(echo -e "Area\nSchermo Intero\nAnnulla" | eval "$MENU_SELECTOR")

TEMP_FILE="$(mktemp --suffix=.png)"

case "$CAPTURE_TYPE" in
    "Area")
        # Cattura l'area selezionata con slurp
        notify-send "Grimshot" "Seleziona l'area da catturare con il mouse..."
        grim -g "$(slurp)" "$TEMP_FILE"
        CAPTURE_STATUS=$?
        ;;
    "Schermo Intero")
        # Cattura l'intero schermo
        grim "$TEMP_FILE"
        CAPTURE_STATUS=$?
        ;;
    *)
        # Annulla l'intera operazione
        rm -f "$TEMP_FILE"
        notify-send "Grimshot" "Cattura annullata."
        exit 0
        ;;
esac

# 2. Verifica se la cattura (Area/Intero) è riuscita/annullata dall'utente
if [ $CAPTURE_STATUS -ne 0 ]; then
    rm -f "$TEMP_FILE"
    notify-send "Grimshot" "Cattura annullata o fallita."
    exit 0
fi

# 3. MENU DI SCELTA FINALE: Azione da Eseguire
ACTION_CHOICE=$(echo -e "Copia negli Appunti\nSalva\nAnnulla" | eval "$ACTION_SELECTOR")

case "$ACTION_CHOICE" in
    "Copia negli Appunti")
        # Copia l'immagine negli appunti 
        cat "$TEMP_FILE" | wl-copy --type image/png
        notify-send "📋 Screenshot" "$CAPTURE_TYPE copiato negli Appunti."
        ;;
    "Salva")
        # Salva in una directory con un nome basato sul timestamp
        FINAL_PATH="$SAVE_DIR/screenshot-${CAPTURE_TYPE// /_}-$(date +%Y-%m-%d_%H-%M-%S).png"
        mv "$TEMP_FILE" "$FINAL_PATH"
        notify-send "📷 Screenshot" "$CAPTURE_TYPE salvato in $SAVE_DIR"
        ;;
    *)
        # Annulla l'azione (il file temporaneo viene eliminato)
        notify-send "Grimshot" "Azione annullata. Screenshot non salvato."
        ;;
esac

# Pulisci il file temporaneo
rm -f "$TEMP_FILE"

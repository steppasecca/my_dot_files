#!/bin/bash

MONITOR="$1"

if [ -z "$MONITOR" ]; then
    exit 1
fi

# Recupera la lista di tutti gli output visti da Sway
OUTPUTS=$(swaymsg -t get_outputs)

# Verifica se il monitor specificato esiste nell'elenco (è collegato fisicamente)
EXISTS=$(echo "$OUTPUTS" | jq -r "any(.[]; .name == \"$MONITOR\")")

# Se il monitor non è collegato (EXISTS è diverso da "true"), esce senza stampare nulla.
# Questo comunicherà a Waybar di nascondere il riquadro.
if [ "$EXISTS" != "true" ]; then
    exit 0
fi

# Se arriviamo qui, il monitor è collegato. Verifichiamo se è acceso (active) o spento.
ACTIVE=$(echo "$OUTPUTS" | jq -r ".[] | select(.name==\"$MONITOR\") | .active")

# Stampa il JSON formattato per Waybar
if [ "$ACTIVE" = "true" ]; then
    echo "{\"text\": \" $MONITOR: On\", \"class\": \"connected\", \"tooltip\": \"Monitor collegato e acceso\\nClicca per spegnere\"}"
else
    echo "{\"text\": \" $MONITOR: Off\", \"class\": \"disconnected\", \"tooltip\": \"Monitor collegato ma spento\\nClicca per accendere\"}"
fi

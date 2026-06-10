#!/usr/bin/env bash
# =================================================================================
# analizza_metriche.sh
# Lo script calcola la media di utilizzo delle CPU per ogni server in metriche.txt
# =================================================================================

FILE="metriche.txt"

# Controllo prima che il file esista:
if [[ ! -f "$FILE" ]]; then
    echo "Errore: file '$FILE' non trovato."
    exit 1
fi

#  Gestisco le STRUTTURE DATI 
# Ho generato degli Array associativi per accumulare somma e conteggio per ogni server:
declare -A somma_cpu     # somma_cpu["srv-web01"] = somma totale CPU
declare -A conteggio     # conteggio["srv-web01"] = numero di misurazioni
declare -a server_unici  # array ordinato dei server (per ordine di apparizione)

#  FASE 1: LETTURA RIGA PER RIGA 
# 'while read' consuma il file riga per riga
# IFS=' ' separa ogni riga nei campi: server e valore CPU
while IFS=' ' read -r server cpu; do
    # Accumulo la CPU per questo server
    somma_cpu["$server"]=$(( ${somma_cpu["$server"]:-0} + cpu ))
    # Incremento il contatore delle occorrenze
    conteggio["$server"]=$(( ${conteggio["$server"]:-0} + 1 ))
    # Aggiungo il server alla lista degli unici (solo la prima volta)
    if [[ ${conteggio["$server"]} -eq 1 ]]; then
        server_unici+=("$server")
    fi
done < "$FILE"

# FASE 2: CALCOLO E STAMPA 
echo "=== REPORT UTILIZZO MEDIO CPU ==="

# Ciclo for sull'array dei server unici individuati
for server in "${server_unici[@]}"; do
    # Faccio fare la divisione intera (comportamento standard di Bash)
    media=$(( somma_cpu["$server"] / conteggio["$server"] ))
    echo "$server: $media%"
done

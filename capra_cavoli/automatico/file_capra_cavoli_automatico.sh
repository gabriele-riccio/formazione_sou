#!/usr/bin/env bash
# ============================================================
# file_capra_cavoli.sh — Versione Semplificata
# ============================================================

set -e

# Colori base per i log
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Stato iniziale: usiamo stringhe semplici e leggibili
RIVA1="lupo capra cavolo"
RIVA2=""
BARCA_POS="vm1"
BARCA_CARGO=""
STEPS=0

# ─────────────────────────────────────────────
# VISUALIZZAZIONE STATO (Molto più lineare)
# ─────────────────────────────────────────────
stampa_sistema() {
    echo -e "\n[Stato del Cluster]"
    echo -e "  vm1: $RIVA1"
    if [[ "$BARCA_POS" == "vm1" ]]; then
        echo -e "        🚣 BARCA [${BARCA_CARGO:-vuota}] @ vm1"
    else
        echo -e "        🚣 BARCA [${BARCA_CARGO:-vuota}] @ vm2"
    fi
    echo -e "  vm2: $RIVA2"
    echo ""
}

# ─────────────────────────────────────────────
# CONTROLLO DEI CONFLITTI (Facile da leggere)
# ─────────────────────────────────────────────
controlla_pericoli() {
    local dove="$1" # Riceve il contenuto della riva da controllare

    # Controllo Lupo + Capra
    if [[ "$dove" =~ "lupo" && "$dove" =~ "capra" ]]; then
        echo -e "${RED}[ERR] Il lupo ha inviato SIGTERM alla capra!${RESET}"
        exit 1
    fi

    # Controllo Capra + Cavolo
    if [[ "$dove" =~ "capra" && "$dove" =~ "cavolo" ]]; then
        echo -e "${RED}[ERR] La capra ha inviato SIGTERM al cavolo!${RESET}"
        exit 1
    fi
}

# ─────────────────────────────────────────────
# SPOSTAMENTO EFFETTIVO (Senza costrutti astratti)
# ─────────────────────────────────────────────
sposta() {
    local elemento="$1"

    # 1. CARICAMENTO: Togliamo l'elemento dalla riva attuale
    if [[ "$BARCA_POS" == "vm1" ]]; then
        if [[ -n "$elemento" ]]; then
            # Sostituiamo il nome dell'elemento con il vuoto nella stringa
            RIVA1=$(echo "$RIVA1" | sed "s/$elemento//g" | xargs)
            BARCA_CARGO="$elemento"
        fi
        # La barca si sposta su vm2
        BARCA_POS="vm2"
        # Scarichiamo l'elemento su vm2
        RIVA2="$RIVA2 $BARCA_CARGO"
        RIVA2=$(echo "$RIVA2" | xargs) # Pulisce gli spazi in più
        BARCA_CARGO=""

        # Controlliamo la riva che abbiamo appena LASCIATO (vm1)
        controlla_pericoli "$RIVA1"
    else
        # Se la barca era su vm2, facciamo l'esatto contrario
        if [[ -n "$elemento" ]]; then
            RIVA2=$(echo "$RIVA2" | sed "s/$elemento//g" | xargs)
            BARCA_CARGO="$elemento"
        fi
        BARCA_POS="vm1"
        RIVA1="$RIVA1 $BARCA_CARGO"
        RIVA1=$(echo "$RIVA1" | xargs)
        BARCA_CARGO=""

        # Controlliamo la riva che abbiamo appena LASCIATO (vm2)
        controlla_pericoli "$RIVA2"
    fi

    STEPS=$((STEPS + 1))
    echo -e "${GREEN}Step $STEPS: Traghettato [${elemento:-vuoto}]${RESET}"
    stampa_sistema
}

# ─────────────────────────────────────────────
# ESECUZIONE AUTOMATICA (I 7 passi classici)
# ─────────────────────────────────────────────
echo -e "${CYAN}=== INIZIO MIGRAZIONE PROCESSI ===${RESET}"
stampa_sistema

sposta "capra"   # Passo 1: la capra va su vm2
sposta ""        # Passo 2: la barca torna vuota
sposta "lupo"    # Passo 3: il lupo va su vm2
sposta "capra"   # Passo 4: la capra torna indietro su vm1
sposta "cavolo"  # Passo 5: il cavolo va su vm2
sposta ""        # Passo 6: la barca torna vuota
sposta "capra"   # Passo 7: la capra torna su vm2

echo -e "${GREEN}=== MIGRAZIONE COMPLETATA IN $STEPS PASSI! ===${RESET}"

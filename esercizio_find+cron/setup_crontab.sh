#!/usr/bin/env/ bash
# =============================================================================
# setup_crontab.sh
# =============================================================================
# Descrizione:
#   Script di installazione che aggiunge automaticamente il job cron
#   per cleanup_old_files.sh nel crontab di root.
#
#   Job schedulato: ogni lunedì alle 6:30
#   Formato cron:   30 6 * * 1
#
# Utilizzo:
#   sudo ./setup_crontab.sh [--uninstall]
# =============================================================================

# Colori
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'

# ---------------------------------------------------------------------------
# Configurazione
# ---------------------------------------------------------------------------

# Percorso assoluto dello script principale (adatta al tuo ambiente)
SCRIPT_PATH="/opt/find-cron-cleanup/scripts/cleanup_old_files.sh"

# Output del cron (log aggiuntivo cron-specifico)
CRON_LOG="/var/log/cleanup_cron.log"

# Identificatore unico nel crontab per trovare/rimuovere il job
CRON_TAG="# cleanup_old_files_job"

# Espressione cron: min ora giorno_mese mese giorno_settimana
#   30  = minuto 30
#   6   = ora 6 (06:30)
#   *   = ogni giorno del mese
#   *   = ogni mese
#   1   = lunedì (0=dom, 1=lun, ..., 7=dom)
CRON_SCHEDULE="30 6 * * 1"

# Linea completa da aggiungere al crontab
CRON_LINE="$CRON_SCHEDULE $SCRIPT_PATH >> $CRON_LOG 2>&1 $CRON_TAG"

# ---------------------------------------------------------------------------
# Verifica root
# ---------------------------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERRORE]${NC} Esegui come root: sudo $0"
    exit 1
fi

# ---------------------------------------------------------------------------
# Funzione: installa il cron job
# ---------------------------------------------------------------------------
install_cron() {
    echo -e "${BOLD}=== Installazione cron job ===${NC}"

    # Controlla se lo script esiste
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}[ATTENZIONE]${NC} Script non trovato in $SCRIPT_PATH"
        echo "             Copia prima lo script o modifica SCRIPT_PATH in questo file."
        echo ""
        echo "  Comando rapido:"
        echo "  sudo mkdir -p $(dirname $SCRIPT_PATH)"
        echo "  sudo cp scripts/cleanup_old_files.sh $SCRIPT_PATH"
        echo "  sudo chmod +x $SCRIPT_PATH"
        echo ""
        read -r -p "Vuoi continuare comunque? [s/N]: " resp
        [[ "$resp" =~ ^[Ss]$ ]] || exit 0
    else
        # Assicura che lo script sia eseguibile
        chmod +x "$SCRIPT_PATH"
        echo -e "${GREEN}[OK]${NC} Script trovato: $SCRIPT_PATH"
    fi

    # Controlla se il job è già presente
    if crontab -l 2>/dev/null | grep -qF "$CRON_TAG"; then
        echo -e "${YELLOW}[WARN]${NC} Il cron job è già installato."
        echo "       Usa --uninstall per rimuoverlo prima."
        exit 0
    fi

    # Aggiunge il job al crontab di root
    # Tecnica: leggi il crontab esistente, aggiungi la nuova riga, reimpostalo
    (
        # Ottieni crontab corrente (ignora errore se vuoto)
        crontab -l 2>/dev/null
        echo ""
        echo "# ---------------------------------------------------------------"
        echo "# Cleanup automatico file vecchi > 30 giorni"
        echo "# Eseguito ogni LUNEDI alle 06:30"
        echo "# Aggiunto da setup_crontab.sh il $(date '+%Y-%m-%d %H:%M')"
        echo "# ---------------------------------------------------------------"
        echo "$CRON_LINE"
    ) | crontab -

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[OK]${NC} Cron job installato con successo!"
        echo ""
        echo -e "${BOLD}Dettagli del job:${NC}"
        echo "  Schedule  : $CRON_SCHEDULE  (ogni lunedì alle 06:30)"
        echo "  Script    : $SCRIPT_PATH"
        echo "  Output    : $CRON_LOG"
        echo ""
        echo -e "${BOLD}Crontab di root aggiornato:${NC}"
        crontab -l | grep -A1 -B1 "$CRON_TAG"
    else
        echo -e "${RED}[ERRORE]${NC} Impossibile aggiornare il crontab."
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Funzione: rimuovi il cron job
# ---------------------------------------------------------------------------
uninstall_cron() {
    echo -e "${BOLD}=== Rimozione cron job ===${NC}"

    if ! crontab -l 2>/dev/null | grep -qF "$CRON_TAG"; then
        echo -e "${YELLOW}[INFO]${NC} Nessun job trovato con tag '$CRON_TAG'."
        exit 0
    fi

    # Rimuovi le righe che contengono il tag (incluse le righe di commento sopra)
    crontab -l 2>/dev/null | grep -v "$CRON_TAG" | crontab -

    echo -e "${GREEN}[OK]${NC} Cron job rimosso con successo."
}

# ---------------------------------------------------------------------------
# Funzione: mostra il crontab corrente
# ---------------------------------------------------------------------------
show_crontab() {
    echo -e "${BOLD}=== Crontab corrente di root ===${NC}"
    crontab -l 2>/dev/null || echo "(crontab vuoto)"
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------
case "${1:-}" in
    --uninstall) uninstall_cron ;;
    --show)      show_crontab ;;
    --help|-h)
        echo "Uso: sudo $0 [--uninstall | --show | --help]"
        echo "  (nessun argomento)  Installa il cron job"
        echo "  --uninstall         Rimuove il cron job"
        echo "  --show              Mostra il crontab corrente"
        ;;
    "")          install_cron ;;
    *)
        echo "Opzione sconosciuta: $1"
        echo "Usa --help per il manuale."
        exit 1
        ;;
esac


#!/usr/bin/env bash
# =============================================================================
# cleanup_old_files.sh
# Descrizione: Trova e cancella i file più vecchi di 30 giorni in /var/log
# Schedulato in crontab di root ogni lunedì alle 06:30
#
# Crontab entry (eseguire: sudo crontab -e):
#   30 6 * * 1 /path/to/cleanup_old_files.sh
# =============================================================================

TARGET_DIR="/var/log"
DAYS=30
LOG_FILE="$HOME/cleanup_script.log"
echo "========================================"  >> "$LOG_FILE"
echo "Esecuzione: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "Directory target: $TARGET_DIR"            >> "$LOG_FILE"
echo "Eliminazione file più vecchi di $DAYS giorni..." >> "$LOG_FILE"

# Trova e cancella i file più vecchi di 30 giorni
find "$TARGET_DIR" -type f -mtime +$DAYS -print -delete >> "$LOG_FILE" 2>&1

echo "Operazione completata." >> "$LOG_FILE"
echo "========================================"  >> "$LOG_FILE"

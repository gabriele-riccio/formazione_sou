#!/usr/bin/env bash
# =============================================================================
# file_5XX_esercizio.sh 
# Dimostra 500 Internal Server Error — avvia server_500.py e testa crash reali
#
# Dipendenze: python3, pip install flask
# =============================================================================

BASE="http://127.0.0.1:5000"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED="\e[31m"; GREEN="\e[32m"; BOLD="\e[1m"; RESET="\e[0m"

sep() {
  echo ""
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${BOLD}  $1${RESET}"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
}

pausa() {
  echo -e "  ${BOLD}>>> Premi INVIO per continuare...${RESET}"
  read -r
}

# =============================================================================
# AVVIO SERVER
# =============================================================================
clear
sep "AVVIO SERVER FLASK (solo per i 500)"

# Controlla flask
if ! python3 -c "import flask" 2>/dev/null; then
  echo -e "  ${RED}Flask non trovato. Installa con:${RESET}"
  echo -e "  pip install flask"
  exit 1
fi

# Controlla che server_500.py esista
if [[ ! -f "$SCRIPT_DIR/server_500.py" ]]; then
  echo -e "  ${RED}File server_500.py non trovato in $SCRIPT_DIR${RESET}"
  echo -e "  Assicurati che sia nella stessa cartella di questo script."
  exit 1
fi

# Avvia in background
python3 "$SCRIPT_DIR/server_500.py" &
SERVER_PID=$!
echo -e "  Server avviato (PID: ${BOLD}$SERVER_PID${RESET})"

# Attendi che risponda
sleep 1
for i in {1..10}; do
  if curl -s "$BASE/crash-gestito" > /dev/null 2>&1; then
    echo -e "  ${GREEN}Server pronto!${RESET}"
    break
  fi
  sleep 0.5
done

# Cleanup automatico all'uscita
cleanup() {
  echo ""
  echo -e "  ${BOLD}Fermo il server Flask (PID $SERVER_PID)...${RESET}"
  kill "$SERVER_PID" 2>/dev/null
  wait "$SERVER_PID" 2>/dev/null
  echo -e "  ${GREEN}Server fermato.${RESET}"
}
trap cleanup EXIT

pausa

# =============================================================================
# PASSO 1 — 500 da ZeroDivisionError (crash non gestito)
# =============================================================================
sep "500 — ZeroDivisionError (crash non gestito)"

echo -e "  Il codice Python fa letteralmente: ${BOLD}risultato = 1 / 0${RESET}"
echo -e "  Flask intercetta l'eccezione e risponde 500 tramite l'handler globale."
echo ""
echo -e "  La tua richiesta era corretta. Il bug è nel SERVER."
echo ""
echo -e "  ${GREEN}curl -s -w '\\n  → Status: %{http_code}\\n' $BASE/crash${RESET}"
echo ""
curl -s -w "\n  → Status: %{http_code}\n" "$BASE/crash" | python3 -m json.tool 2>/dev/null
echo ""

pausa

# =============================================================================
# PASSO 2 — 500 da ConnectionError (DB non raggiungibile)
# =============================================================================
sep "500 — ConnectionError (database non raggiungibile)"

echo -e "  Il server prova a connettersi a un DB che non esiste."
echo -e "  Simula il caso reale più comune in produzione:"
echo -e "  il DB è giù, sovraccarico, o la stringa di connessione è sbagliata."
echo ""
echo -e "  ${GREEN}curl -s -w '\\n  → Status: %{http_code}\\n' $BASE/crash-db${RESET}"
echo ""
curl -s -w "\n  → Status: %{http_code}\n" "$BASE/crash-db" | python3 -m json.tool 2>/dev/null
echo ""

pausa

# =============================================================================
# PASSO 3 — 500 gestito (TypeError catturato nel codice)
# =============================================================================
sep "500 — TypeError gestito dal codice"

echo -e "  Il server cattura l'eccezione lui stesso e costruisce"
echo -e "  una risposta 500 con un messaggio chiaro per il client."
echo ""
echo -e "  Buona pratica: non esporre mai lo stack trace al client,"
echo -e "  ma loggarlo internamente e dare un messaggio generico."
echo ""
echo -e "  ${GREEN}curl -s -w '\\n  → Status: %{http_code}\\n' $BASE/crash-gestito${RESET}"
echo ""
curl -s -w "\n  → Status: %{http_code}\n" "$BASE/crash-gestito" | python3 -m json.tool 2>/dev/null
echo ""

pausa

# =============================================================================
# PASSO 4 — Differenza tra crash gestito e non gestito
# =============================================================================
sep "Gestito vs Non gestito — a confronto"

echo -e "  ${BOLD}Non gestito${RESET} (/crash):"
echo -e "  → L'eccezione sale fino all'handler globale di Flask"
echo -e "  → Il tipo di errore è visibile nella risposta (ZeroDivisionError)"
echo -e "  → In produzione con debug=False, Flask nasconde i dettagli"
echo ""
echo -e "  ${BOLD}Gestito${RESET} (/crash-gestito):"
echo -e "  → try/except nel codice — il server controlla cosa esporre"
echo -e "  → Messaggio human-readable, nessun leak di info interne"
echo -e "  → Puoi loggare il dettaglio senza inviarlo al client"
echo ""

echo -e "  Risposta /crash (non gestito):"
curl -s "$BASE/crash" | python3 -m json.tool 2>/dev/null
echo ""
echo -e "  Risposta /crash-gestito:"
curl -s "$BASE/crash-gestito" | python3 -m json.tool 2>/dev/null
echo ""

pausa

# =============================================================================
# RIEPILOGO
# =============================================================================
sep "RIEPILOGO — 5xx"

echo -e "  I 5xx indicano sempre un errore dal lato SERVER."
echo -e "  La richiesta del client era corretta."
echo ""
echo -e "  ${RED}500 Internal Server Error${RESET}  → crash generico, bug nel codice"
echo -e "  ${RED}502 Bad Gateway${RESET}            → il reverse proxy non raggiunge il backend"
echo -e "  ${RED}503 Service Unavailable${RESET}    → server sovraccarico o in manutenzione"
echo -e "  ${RED}504 Gateway Timeout${RESET}        → il backend ha impiegato troppo tempo"
echo ""
echo -e "  Risultati reali delle route testate:"
echo ""

declare -A LABEL=(
  ["/crash"]="ZeroDivisionError (non gestito)"
  ["/crash-db"]="ConnectionError — DB irraggiungibile"
  ["/crash-gestito"]="TypeError gestito nel codice"
)

for route in "/crash" "/crash-db" "/crash-gestito"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE$route")
  echo -e "    ${RED}$status${RESET}  $route  —  ${LABEL[$route]}"
done

echo ""
echo -e "${BOLD}  Fine simulazione 5xx.${RESET}"
echo ""


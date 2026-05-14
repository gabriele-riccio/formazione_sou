#!/usr/bin/env bash
# migrate.sh — gira sull'HOST, non dentro i nodi
# Fa migrare il container echo-server tra node1 e node2 ogni 60 secondi

set -e

CONTAINER_NAME="echo-server"
INTERVAL=60
NODES=("node1" "node2")
CURRENT=0  # indice del nodo attivo (0 = node1, 1 = node2)

# Colori per output leggibile
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

run_on_node() {
    local node=$1
    local cmd=$2
    vagrant ssh "$node" -c "$cmd" 2>/dev/null
}

stop_container() {
    local node=$1
    log "${RED}STOP${NC} $CONTAINER_NAME su $node"
    run_on_node "$node" "docker stop $CONTAINER_NAME 2>/dev/null || true"
    run_on_node "$node" "docker rm $CONTAINER_NAME 2>/dev/null || true"
}

start_container() {
    local node=$1
    log "${GREEN}START${NC} $CONTAINER_NAME su $node"
    run_on_node "$node" \
        "docker run -d --name $CONTAINER_NAME -p 80:80 ealen/echo-server"
    log "Echo server raggiungibile su: http://$(node_ip $node)"
}

node_ip() {
    case $1 in
        node1) echo "192.168.56.10" ;;
        node2) echo "192.168.56.11" ;;
    esac
}

cleanup() {
    echo ""
    log "${YELLOW}Interruzione rilevata — fermo il container ovunque...${NC}"
    stop_container "node1"
    stop_container "node2"
    log "Fatto. Uscita."
    exit 0
}

trap cleanup SIGINT SIGTERM

# Verifica che vagrant sia disponibile
if ! command -v vagrant &>/dev/null; then
    echo "Errore: vagrant non trovato. Esegui questo script dalla cartella del progetto."
    exit 1
fi

log "Avvio migrazione ping pong ogni ${INTERVAL}s"
log "Premi Ctrl+C per fermare"
echo ""

# Pulizia iniziale
stop_container "node1"
stop_container "node2"

while true; do
    ACTIVE_NODE=${NODES[$CURRENT]}
    NEXT=$(( 1 - CURRENT ))
    NEXT_NODE=${NODES[$NEXT]}

    start_container "$ACTIVE_NODE"

    log "Prossima migrazione verso $NEXT_NODE tra ${INTERVAL}s..."
    sleep "$INTERVAL"

    stop_container "$ACTIVE_NODE"
    CURRENT=$NEXT
done

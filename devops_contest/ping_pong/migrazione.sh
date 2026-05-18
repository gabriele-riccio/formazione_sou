#!/usr/bin/env bash

#Questo script chiamato appunto migrazione.sh  fa in breve quello che andremo a studiare con kubernates(in maniera molto basilare),
#ovvero l'orchestratore di container direttamente dal mio compter senza entrare nei nodi.
# In breve migrate.sh gira sull'HOST (non dentro i nodi) e sfrutta Vagrant per entrare e uscire dalle macchine,
#accendendo e spegnendo i container e facendo migrare l'immagine di docker (echo-server) tra il nodo 1 e il nodo 2 ogni 60 secondi.

# Prima inserisco la shebang e il set-e per far bloccare lo script in caso di errore.
#Poi nomino una variabile per il container per non doverlo scrivere ogni volta, stabilisco un intervallo in secondi, i nodi(le due VM)
#e indico il nodo attivo iniziale '(0 = node1, 1 = node2)'

#Definisco poi dei codici speciali che dicono al terminale di cambiare colore al testo 
#per un output leggibile, con NC per tornare al colore normale.


#Poi dichiaro delle funzioni:
#log() per stampare messaggi formattati con -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1" per 
#stampare a schermo l'orario attuale in blu, seguito da un messaggio (rappresentato da $1).

#run_on_node() che esegue dei comandi sulle 2 VM con 2 parametri nodo e comando
#Funziona così: vagrant ssh "$node" -c "$cmd" 2>/dev/null
#Usa il comando vagrant ssh per entrare nel nodo scelto, esegue il comando passato con l'opzione -c 
#e poi esce subito, con 2>/dev/null che serve a nascondere eventuali avvisi tecnici superflui di Vagrant.

#Le due funzioni di start e stop: 

#La prima stampa un messaggio in verde di start, usa run_on_node per fare 
#docker_run distaccato (-d),mappando la porta 80 e usando l'immagine ealen/echo-server.
#Infine, stampa un link con log() con l'IP per cliccarci. 

#La seconda Stampa un messaggio rosso di STOP e usa run_on_node per inviare due comandi Docker alla VM: 
#docker stop (ferma il container) e docker rm (lo cancella).
#Il || true alla fine fa sì che se il container non c'è, lo script non vada in errore.

#La funzione node_ip restituisce 192.168.56.10 se si chiede l'IP del "node1"
#e 192.168.56.11 se si chiede il "node2".

#Poi c'è la funzine cleanup che ho già usato in altri esercizi per chiudere lo script(pulendo),
#restituendo un messaggio giallo fermando i container sui nodi; integrata con trap cleanup SIGINT SIGTERM
#in modo che anche se si blocca l'esecuzione dello script per qualsiasi motivo fa prima la funzione cleanup.

#Inizio adesso con l'avvio con un if che effettua una verifica che vagrant sia disponibile stampando 
#un messaggio di errore altrimenti.

#Ora il bello, dopo una pulizia iniziale con la funzione cleanup, 





set -e

CONTAINER_NAME="echo-server"
INTERVAL=60
NODES=("node1" "node2")
CURRENT=0  # indice del nodo attivo (0 = node1, 1 = node2)


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

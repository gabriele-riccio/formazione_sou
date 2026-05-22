#!/usr/bin/env bash
# ==========================================================================================================================================
# file_capra_cavoli.sh — ESERCIZIO: lupo, capra e cavolo
# ==========================================================================================================================================
# Il classico indovinello medievale reinterpretato in chiave DevOps/Sysadmin.
# Gli attori sono reali processi di sistema Linux (lupo, capra, cavolo), le sponde del fiume sono
# due Macchine Virtuali (vm1 e vm2) e il fiume stesso è un canale di comunicazione di rete (network bridge).


# Uso:
#   chmod +x file_capra_cavoli.sh
#   ./file_capra_cavoli.sh o bash file_capra_cavoli.sh  → esegue la soluzione automatica attraverso la funzione run_auto.
#   ./file_capra_cavoli.sh --play o bash file_capra_cavoli.sh --play → esegue la modalità interattiva passo per passo
# ===========================================================================================================================================

set -e #Fa in modo di interrompere lo script immediatamente se un qualsiasi comando fallisce, per evitare problemi.

# ─────────────────────────────────────────────────────────────────────────────────────────────
# COLORI per il terminale(uso i codici di escape ANSI per la formattazione del terminale)
#li uso ormai per ogni esercizio.
# ─────────────────────────────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'

# ─────────────────────────────────────────────────────────────────────────────────────────────
# Variabili di STATO — variabili globali che rappresentano lo stato iniziale del sistema 
# Inoltre introduco BARCA_POS come posizione corrente del vettore di migrazione e 
# Barca_Cargo che funge da registro di transito (o buffer temporaneo)che impedisce 
# che un processo svanisca nel nulla durante lo spostamento.
# ─────────────────────────────────────────────────────────────────────────────────────────────
VM1="lupo capra cavolo" # Stato iniziale della prima macchina virtuale (sorgente)
VM2=""                  # Stato iniziale della seconda macchina virtuale (target)

BARCA_POS="vm1"         # Posizione corrente del vettore di migrazione (il traghetto/barca)
BARCA_CARGO=""          # Buffer temporaneo per il processo attualmente in transito

STEPS=0                 # Contatore incrementale dei passaggi effettuati

# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# Inserisco poi una funzione che vada a rilevare i conflitti nella modalità interattiva:
#mi definisco la variabile locale vm_content con valore $1(ci andranno i vari processi)
#il primo if prende il valore della variabile e lo passa al grep che silentemente se il processo lupo e vm_content=capra sono 
#insieme da errore(dato che il lupo e la capra non possono stare insieme, quindi lupo sigterm capra)
#il secoondo if prende il valore della variabile e lo passa al grep che silentemente se il processo capra e
#vm_content=cavolo stanno insieme da errore(dato che la capra e il cavolo non possono stare insieme, quindi capra sigterm cavolo)
#altrimenti non da errori, è tutto giusto ritorna 0.
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
check_conflicts() {
    local vm_content="$1"

    if echo "$vm_content" | grep -q "lupo" && echo "$vm_content" | grep -q "capra"; then
        echo "lupo consuma capra → SIGTERM capra:PID-002"
        return 1
    fi

    if echo "$vm_content" | grep -q "capra" && echo "$vm_content" | grep -q "cavolo"; then
        echo "capra consuma cavolo → SIGTERM cavolo:PID-003"
        return 1
    fi

    return 0
}

# ───────────────────────────────────────────────────────────────────────────────────────────────────────────
# DISPLAY: Sarebbe la parte visiva dell'output
#La prima funzione print_state() è quella che esegue la visione dell'output mentre vm_display() è di supporto
#l'ho usata solo per l'output delle VM(infatti uso -z "$content"che controlla se la stringa  è vuota.
#se lo è stampa la scritta (vuota) in grigio e interrompe la funzione con return.(l'ho visto da internet per
#abbellire l'output.
# La funzione principale print_state() invece è una funzione che stampa passo dopo passo ad ogni azione dell'
#indovinello l'otput come se fossero le due Vm le sponde(che possono avere dei processi) il fiume in mezzo che le
#divide e la barca con il traghettatore(admin).
#Infatti stampo la vm1 prima(con le azioni della funzione supporto, con i processi presenti) 
#poi mi definisco una variabile locale che mi rappresenta l'unione tra barca e fiume
#Se la barca sta su Vm1 allora disegna prima la barca e poi la linea che rappresenta il network river 
#Viceversa se la barca sta su Vm2
# ───────────────────────────────────────────────────────────────────────────────────────────────────────────
print_state() {
    echo ""
    echo -e "  ${BOLD}vm1${RESET}  $(vm_display "$VM1")"

    local cargo_str=""
    [[ -n "$BARCA_CARGO" ]] && cargo_str=" [${BARCA_CARGO}]"

    if [[ "$BARCA_POS" == "vm1" ]]; then
        echo -e "        ${CYAN}barca${cargo_str}${RESET}  ${GRAY}@ vm1${RESET}"
        echo -e "        ${GRAY}────── network bridge ──────${RESET}"
    else
        echo -e "        ${GRAY}────── network bridge ──────${RESET}"
        echo -e "        ${CYAN}barca${cargo_str}${RESET}  ${GRAY}@ vm2${RESET}"
    fi

    echo -e "  ${BOLD}vm2${RESET}  $(vm_display "$VM2")"
    echo ""
}

vm_display() {
    local content="$1"
    if [[ -z "$content" ]]; then
        echo -e "${GRAY}(vuota)${RESET}"
        return
    fi
    local out=""
    for proc in $content; do
        out+="${proc}  "
    done
    echo -e "$out"
}

# ─────────────────────────────────────────────────────────────────────────────────────────────────────
# LOGGER: Come ho fatto in altri esercizi uso la funzione di testo per stampare dei messaggi 
# ─────────────────────────────────────────────────────────────────────────────────────────────────────
log_info()    { echo -e "${BLUE}\$${RESET} $*"; }
log_ok()      { echo -e "${GREEN}[OK]${RESET} $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
log_error()   { echo -e "${RED}[ERR]${RESET} $*"; }
log_step()    { echo -e "\n${BOLD}── step $STEPS ─────────────────────────────${RESET}"; }

# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# MIGRATE:
#Funzione principale per la migrazione dei processi da una VM all'altra:
#prima cosa mi genero una varibile locale process che prende il nome del processo passato come argomento (es. migrate "capra") e 
#se  non passo nulla, con la sintassi ${1:-} assegno una stringa vuota (viaggio vuoto).
#Poi la variabile origin che prende la posizione della barca, cambiando ogni volta la varibile destinazione se origin cambia(se 
#origin è vm1 la destination 

# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
migrate() {
    local process="${1:-}"

    local origin="$BARCA_POS"
    local destination
    [[ "$origin" == "vm1" ]] && destination="vm2" || destination="vm1"

    local origin_var
    [[ "$origin" == "vm1" ]] && origin_var="VM1" || origin_var="VM2"
    local dest_var
    [[ "$destination" == "vm1" ]] && dest_var="VM1" || dest_var="VM2"

    if [[ -n "$process" ]]; then
        if ! echo "${!origin_var}" | grep -qw "$process"; then
            log_error "Errore: $process non trovato su $origin"
            exit 1
        fi
        local new_list
        new_list=$(echo "${!origin_var}" | tr ' ' '\n' | grep -v "^${process}$" | tr '\n' ' ' | xargs || true)
        eval "$origin_var=\"$new_list\""
        BARCA_CARGO="$process"
    fi

    BARCA_POS="$destination"

    if [[ -n "$BARCA_CARGO" ]]; then
        eval "$dest_var=\"${!dest_var:+${!dest_var} }${BARCA_CARGO}\""
        BARCA_CARGO=""
    fi

    STEPS=$((STEPS + 1))
    log_step

    local cargo_label="${process:-vuoto}"
    log_info "Migrazione  ${cargo_label}  ${origin} → ${destination}"

    local conflict
    if ! conflict=$(check_conflicts "${!origin_var}" 2>&1); then
        log_error "CONFLITTO su ${origin}: ${conflict}"
        log_error "Sistema instabile — fare il rollback"
        print_state
        exit 1
    fi

    [[ -n "$process" ]] && log_ok "${process} deployed su ${destination}" \
                        || log_warn "Vuoto — solo admin"

    print_state
}

# ─────────────────────────────────────────────
# MODALITÀ INTERATTIVA
# ─────────────────────────────────────────────
play_interactive() {
    echo -e "\n${BOLD}Modalità Interattiva — Risolvi l'indovinello!${RESET}"
    echo -e "Digita il nome del processo da caricare sulla barca insieme al traghettatore."
    echo -e "Comandi disponibili: ${CYAN}lupo${RESET} | ${CYAN}capra${RESET} | ${CYAN}cavolo${RESET} | ${CYAN}invio${RESET} (viaggia vuoto) | ${CYAN}q${RESET} (esci)\n"

    print_state

    while true; do
        # Condizione di vittoria: VM1 è vuota e non c'è nulla in transito
        if [[ -z "$VM1" && -z "$BARCA_CARGO" ]]; then
            echo -e "${GREEN}${BOLD}[SUCCESS] Fantastico! Migrazione completata in ${STEPS} step!${RESET}\n"
            log_ok "Tutti i processi attivi e salvi su vm2"
            log_ok "E vm1 offline — nessun processo residuo"
            exit 0
        fi

        echo -ne "${CYAN}→ Inserisci processo da migrare [Riva attuale: ${BARCA_POS}]: ${RESET}"
        read -r input

        # Uscita volontaria
        [[ "$input" == "q" ]] && echo "Uscita dal gioco." && exit 0

        # Esegue la migrazione (se fallisce perché il processo non esiste sulla sponda, il ciclo continua)
        migrate "$input" || true
    done
}


# ─────────────────────────────────────────────
# SOLUZIONE
# ─────────────────────────────────────────────
run_auto() {
    echo -e "\n${BOLD}Indovinello Capra Cavolo Lupo ${RESET}"
    log_ok "Tutti i processi attivi su vm1"
    log_ok "Mentre vm2 offline — nessun processo attivo"
    echo -e "${GREEN}${BOLD}[Inizio Migrazione]${RESET}\n"

    log_info "TRACCIA"
    log_info "Processi tutti su vm1: [lupo:PID-001, capra:PID-002, cavolo:PID-003]"
    log_info "Barca pronta su vm1"
    log_info "Obiettivo: migrare tutti i processi su vm2"
    log_warn "CONSTRAINT: lupo e capra non possono coesistere senza admin"
    log_warn "CONSTRAINT: capra e cavolo non possono coesistere senza admin"
    log_warn "SUDOERS:    lupo → sudo kill -15 <PID>  (SIGTERM su capra)"
    log_warn "SUDOERS:    capra → sudo kill -15 <PID>  (SIGTERM su cavolo)"

    print_state

    migrate "capra"
    migrate ""
    migrate "cavolo"
    migrate "capra"
    migrate "lupo"
    migrate ""
    migrate "capra"

    echo -e "${GREEN}${BOLD}[SUCCESS] Migrazione completata in ${STEPS} step!${RESET}\n"
    log_ok "Tutti i processi attivi su vm2"
    log_ok "E vm1 offline — nessun processo residuo"
}


# ─────────────────────────────────────────────────────────────────────────────
# ENTRYPOINT (Gestione dei parametri di avvio) 
# ─────────────────────────────────────────────────────────────────────────────
case "${1:-}" in
    --play|-p)  play_interactive ;;
    *)          run_auto ;;
esac























































































































































































































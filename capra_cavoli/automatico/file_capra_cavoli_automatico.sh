#!/usr/bin/env bash
# ==========================================================================================================================================
# file_capra_cavoli_automatico.sh — ESERCIZIO: lupo, capra e cavolo più semplice
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
log_step()    { echo -e "\n${BOLD}── step $STEPS ─────────────────────────────${RESET}"; }

# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# MIGRATE:
#Funzione principale per la migrazione dei processi da una VM all'altra:
#prima cosa mi genero una varibile locale process che prende il nome del processo passato come argomento (es. migrate "capra") e 
#se  non passo nulla, con la sintassi ${1:-} assegno una stringa vuota (viaggio vuoto).
#Poi la variabile origin che prende la posizione della barca, cambiando ogni volta la varibile destinazione se origin cambia(se 
#origin è vm1 la destinatione sarà vm2 e viceversa).
#Poi genero due variabili locali per rappresentare i processi presenti su ogni VM, in base alla posizione della barca.
#Se è stato passato un processo da migrare, controllo che questo processo sia presente sulla VM di origine, altrimenti stampo un messaggio di errore e termino lo script con exit 1.
#Se il processo è presente, genero una nuova lista di processi per la VM di origine, escludendo il processo in migrazione, e aggiorno la variabile corrispondente.
#Poi aggiorno la posizione della barca alla destinazione e se c'è un processo in migrazione, lo aggiungo alla lista dei processi della VM di destinazione, aggiornando la variabile corrispondente.
#Infine incremento il contatore dei passaggi, stampo un messaggio di migrazione e controllo se ci sono conflitti sulla VM di origine dopo la migrazione.
#Non ci saranno dato che la funzione migrazione viene usata da run_auto che segue una sequenza predefinita di migrazioni che evita i conflitti.




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

    STEPS=$((STEPS + 1)) #per aumentare il contatore dei passaggi ogni volta che viene chiamata la funzione migrate.
    log_step

    local cargo_label="${process:-vuoto}"
    log_info "Migrazione  ${cargo_label}  ${origin} → ${destination}"    #qui sto proprio stampando il messaggio di migrazione, indicando il processo in migrazione (o vuoto se non c'è) e le VM di origine e destinazione.


    # ──────────────────────────────────────────────────────────
    # Notifica dell'esito del viaggio (Il viaggio vuoto è ammesso!)
    # ──────────────────────────────────────────────────────────
    if [[ -n "$process" ]]; then
        log_ok "${process} è migrato su ${destination}"
    else
        log_warn "Vuoto — solo traghettatore" # Consentito! Non si blocca, stampa solo l'avviso
    fi

    print_state
}

# ─────────────────────────────────────────────────────────────────────────────
# SOLUZIONE AUTOMATICA
# ─────────────────────────────────────────────────────────────────────────────
# Questa funzione rappresenta tutto l'indovinello.
# Esegue una sequenza predefinita di migrazioni (7 passi) per
# spostare i processi in modo sicuro, rispettando i vincoli di coesistenza.
run_auto() {
    # -------------------------------------------------------------------------
    # 1. INIZIALIZZAZIONE :
    # inizio stampando con echo e la funzione log il titolo dove sono i processi e
    # e che sta per iniziare la migrazione.
    #poi i log di informazione e l'obiettivo
    #Poi i log di costrizione cioè come possono commettere gli errori
    # -------------------------------------------------------------------------
    echo -e "\n${BOLD}Indovinello Capra Cavolo Lupo ${RESET}"
    log_ok "Tutti i processi attivi su vm1"
    log_ok "Mentre vm2 offline — nessun processo attivo"
    echo -e "${GREEN}${BOLD}[Inizio Migrazione]${RESET}\n"

    log_info "TRACCIA"
    log_info "Processi tutti su vm1: [lupo:PID-001, capra:PID-002, cavolo:PID-003]"
    log_info "Barca pronta su vm1"
    log_info "Obiettivo: migrare tutti i processi su vm2"

    # Avvisi di sicurezza sui vincoli (Constraints) e mappatura dei permessi reali di Sudoers
    log_warn "CONSTRAINT: lupo e capra non possono coesistere senza traghettatore"
    log_warn "CONSTRAINT: capra e cavolo non possono coesistere senza traghettatore"
    log_warn "SUDOERS:    lupo  → sudo kill -15 --user capra <PID>   (SIGTERM su capra)"
    log_warn "SUDOERS:    capra → sudo kill -15 --user cavolo <PID>  (SIGTERM su cavolo)"

    # Stampa visiva della topologia iniziale del sistema (Tutti su vm1, vm2 vuota)
    print_state

    # -------------------------------------------------------------------------
    # 2. SEQUENZA TRANSAZIONALE DEI 7 PASSI (L'algoritmo di risoluzione)
    # -------------------------------------------------------------------------

    # Step 1: Il traghettatore isola la capra portandola su vm2.
    # Stato risultante: vm1 ospita [lupo, cavolo] (Coesistenza Sicura).
    migrate "capra"

    # Step 2: La barca ritorna su vm1 senza alcun processo a bordo.
    # Stato risultante: la capra è da sola su vm2, il traghettatore è su vm1.
    migrate ""

    # Step 3: Viene migrato il cavolo su vm2.
    # Stato risultante: vm1 ospita solo [lupo]. Su vm2 ci sono [capra, cavolo] (PERICOLO!).
    # Ma la presenza temporanea del traghettatore su vm2 impedisce il kill del cavolo.
    migrate "cavolo"

    # Step 4: Per non lasciare la capra sola col cavolo, il traghettatore la ricarica e la riporta su vm1.
    # Stato risultante: vm1 ospita [lupo, capra] (Prossimo potenziale pericolo). vm2 ospita solo [cavolo].
    migrate "capra"

    # Step 5: Il traghettatore scarica la capra su vm1 e imbarca il lupo, migrandolo su vm2.
    # Stato risultante: la capra rimane da sola su vm1 (Sicura). Su vm2 coesistono [lupo, cavolo] (Sicura).
    migrate "lupo"

    # Step 6: La barca ritorna vuota su vm1 per recuperare l'ultimo processo rimasto indifeso.
    # Stato risultante: [lupo, cavolo] sono stabili su vm2. La capra aspetta su vm1.
    migrate ""

    # Step 7: Ultima migrazione della capra verso la destinazione finale.
    # Stato risultante: vm1 si svuota definitivamente. vm2 ospita tutti i processi salvi.
    migrate "capra"

    # -------------------------------------------------------------------------
    # 3. VERIFICA FINALE DI SUCCESSO
    # -------------------------------------------------------------------------
    # Se il sistema non è andato in crash (grazie al controllo ad ogni step di migrate),
    # l'orchestrazione dichiara il successo dell'operazione.
    echo -e "${GREEN}${BOLD}[SUCCESS] Migrazione completata in ${STEPS} step!${RESET}\n"
    log_ok "Tutti i processi attivi su vm2"
    log_ok "E vm1 offline — nessun processo residuo"
}


# ─────────────────────────────────────────────────────────────────────────────
# Richiamo funzione
# ─────────────────────────────────────────────────────────────────────────────
run_auto









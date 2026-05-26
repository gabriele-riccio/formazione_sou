#!/usr/bin/env bash
# ==============================================================================
# file_capra_cavoli_docker.sh — ESERCIZIO: lupo, capra e cavolo
# VERSIONE DOCKER — gli attori sono container, le sponde sono reti Docker
# ==============================================================================
# Gli attori (lupo, capra, cavolo) sono container Ubuntu in sleep infinity.
# Le sponde del fiume sono due Docker bridge network:
#   - sponda_vm1  →  riva di partenza
#   - sponda_vm2  →  riva di destinazione
# La migrazione avviene tramite docker network disconnect + connect.
# Il conflitto viene rilevato ispezionando le reti reali con docker inspect.
#
# Uso:
#   bash file_capra_cavoli_docker.sh          → soluzione automatica
#   bash file_capra_cavoli_docker.sh --play   → modalità interattiva
#   bash file_capra_cavoli_docker.sh --clean  → rimuove container e reti
# ==============================================================================
set -e

# ─────────────────────────────────────────────────────────────────────────────
# COLORI
# ─────────────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'

# ─────────────────────────────────────────────────────────────────────────────
# COSTANTI — nomi delle reti e dei container
# Non uso più variabili di stato bash: lo stato reale è nei container Docker
# ─────────────────────────────────────────────────────────────────────────────
NET_VM1="sponda_vm1"
NET_VM2="sponda_vm2"
ATTORI=("lupo" "capra" "cavolo")
BARCA_POS="vm1"   # Unica variabile di stato bash rimasta: posizione della barca
STEPS=0

# ─────────────────────────────────────────────────────────────────────────────
# LOGGER
# ─────────────────────────────────────────────────────────────────────────────
log_info()  { echo -e "${BLUE}\$${RESET} $*"; }
log_ok()    { echo -e "${GREEN}[OK]${RESET}   $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }
log_error() { echo -e "${RED}[ERR]${RESET}  $*"; }
log_step()  { echo -e "\n${BOLD}── step $STEPS ─────────────────────────────${RESET}"; }

# ─────────────────────────────────────────────────────────────────────────────
# SETUP — crea le reti Docker e avvia i container su sponda_vm1
# Ogni attore è un container Ubuntu in sleep infinity connesso a sponda_vm1
# ─────────────────────────────────────────────────────────────────────────────
setup() {
    echo -e "\n${BOLD}==> Setup ambiente Docker${RESET}"

    # Crea le due reti (le sponde del fiume)
    for net in "$NET_VM1" "$NET_VM2"; do
        if ! docker network inspect "$net" &>/dev/null; then
            docker network create "$net" > /dev/null
            log_ok "Rete '$net' creata"
        else
            log_warn "Rete '$net' già esistente — la riuso"
        fi
    done

    # Avvia i container degli attori su sponda_vm1
    for attore in "${ATTORI[@]}"; do
        if docker inspect "$attore" &>/dev/null; then
            log_warn "Container '$attore' già esistente — lo rimuovo e lo ricreo"
            docker rm -f "$attore" > /dev/null
        fi
        # Container Ubuntu minimale in sleep infinity = processo sempre attivo
        docker run -d \
            --name "$attore" \
            --network "$NET_VM1" \
            --label "esercizio=capra_cavoli" \
            ubuntu sleep infinity > /dev/null
        log_ok "Container '${attore}' avviato su ${NET_VM1}"
    done

    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# CLEANUP — rimuove container e reti create dall'esercizio
# ─────────────────────────────────────────────────────────────────────────────
cleanup() {
    echo -e "\n${BOLD}==> Cleanup ambiente Docker${RESET}"
    for attore in "${ATTORI[@]}"; do
        if docker inspect "$attore" &>/dev/null; then
            docker rm -f "$attore" > /dev/null
            log_ok "Container '$attore' rimosso"
        fi
    done
    for net in "$NET_VM1" "$NET_VM2"; do
        if docker network inspect "$net" &>/dev/null; then
            docker network rm "$net" > /dev/null
            log_ok "Rete '$net' rimossa"
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# GET_ACTORS_ON_NET — legge lo stato REALE da Docker (non da variabili bash)
# Usa docker network inspect per ottenere i container connessi a una rete
# ─────────────────────────────────────────────────────────────────────────────
get_actors_on_net() {
    local network="$1"
    # Estrae i nomi dei container connessi alla rete, filtrando solo i nostri attori
    docker network inspect "$network" \
        --format '{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null \
        | tr ' ' '\n' \
        | grep -E "^(lupo|capra|cavolo)$" \
        | tr '\n' ' ' \
        | xargs || true
}

# ─────────────────────────────────────────────────────────────────────────────
# CHECK_CONFLICTS — rileva conflitti ispezionando la rete Docker reale
# Un conflitto è: lupo + capra sulla stessa rete, oppure capra + cavolo
# Se c'è conflitto, Docker stop simula il SIGTERM tra i processi
# ─────────────────────────────────────────────────────────────────────────────
check_conflicts() {
    local network="$1"
    local actors
    actors=$(get_actors_on_net "$network")

    if echo "$actors" | grep -q "lupo" && echo "$actors" | grep -q "capra"; then
        echo "lupo consuma capra → docker stop capra (SIGTERM capra)"
        return 1
    fi
    if echo "$actors" | grep -q "capra" && echo "$actors" | grep -q "cavolo"; then
        echo "capra consuma cavolo → docker stop cavolo (SIGTERM cavolo)"
        return 1
    fi
    return 0
}

# ─────────────────────────────────────────────────────────────────────────────
# VM_DISPLAY — formatta la lista dei container su una rete per l'output visivo
# ─────────────────────────────────────────────────────────────────────────────
vm_display() {
    local network="$1"
    local actors
    actors=$(get_actors_on_net "$network")
    if [[ -z "$actors" ]]; then
        echo -e "${GRAY}(vuota)${RESET}"
    else
        echo -e "$actors"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# PRINT_STATE — visualizza lo stato reale letto da Docker
# Mostra vm1 (sponda_vm1), il network bridge, e vm2 (sponda_vm2)
# ─────────────────────────────────────────────────────────────────────────────
print_state() {
    echo ""
    echo -e "  ${BOLD}vm1${RESET}  $(vm_display "$NET_VM1")"
    if [[ "$BARCA_POS" == "vm1" ]]; then
        echo -e "       ${CYAN}barca${RESET}  ${GRAY}@ vm1${RESET}"
        echo -e "       ${GRAY}────── network bridge ──────${RESET}"
    else
        echo -e "       ${GRAY}────── network bridge ──────${RESET}"
        echo -e "       ${CYAN}barca${RESET}  ${GRAY}@ vm2${RESET}"
    fi
    echo -e "  ${BOLD}vm2${RESET}  $(vm_display "$NET_VM2")"
    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# MIGRATE — sposta un container da una rete Docker all'altra
#
# La migrazione reale avviene con:
#   docker network disconnect <rete_origine> <container>
#   docker network connect    <rete_dest>    <container>
#
# Se il container viene lasciato senza nessuna rete (viaggio vuoto),
# solo la barca si sposta — nessun docker network command sui container.
# ─────────────────────────────────────────────────────────────────────────────
migrate() {
    local process="${1:-}"
    local origin_net dest_net

    # Determina origine e destinazione in base alla posizione della barca
    if [[ "$BARCA_POS" == "vm1" ]]; then
        origin_net="$NET_VM1"
        dest_net="$NET_VM2"
    else
        origin_net="$NET_VM2"
        dest_net="$NET_VM1"
    fi

    # Se c'è un processo da migrare, esegui il movimento reale Docker
    if [[ -n "$process" ]]; then
        # Verifica che il container esista sulla rete di origine
        if ! get_actors_on_net "$origin_net" | grep -qw "$process"; then
            log_error "Container '$process' non trovato su $origin_net"
            exit 1
        fi

        # Migrazione reale: disconnetti dalla rete origine, connetti alla rete dest
        docker network disconnect "$origin_net" "$process"
        docker network connect    "$dest_net"   "$process"
        log_info "docker network disconnect ${origin_net} ${process}"
        log_info "docker network connect    ${dest_net}   ${process}"
    fi

    # Sposta la barca (solo variabile bash — la barca non è un container)
    [[ "$BARCA_POS" == "vm1" ]] && BARCA_POS="vm2" || BARCA_POS="vm1"

    STEPS=$((STEPS + 1))
    log_step

    local cargo_label="${process:-vuoto}"
    log_info "Migrazione  ${cargo_label}  ${origin_net} → ${dest_net}"

    # Controlla conflitti sulla rete di origine dopo la migrazione
    local conflict
    if ! conflict=$(check_conflicts "$origin_net" 2>&1); then
        log_error "CONFLITTO su ${origin_net}: ${conflict}"
        log_error "Sistema instabile — eseguire rollback"
        print_state
        exit 1
    fi

    [[ -n "$process" ]] \
        && log_ok "${process} migrato su ${dest_net}" \
        || log_warn "Viaggio vuoto — solo admin (barca)"

    print_state
}

# ─────────────────────────────────────────────────────────────────────────────
# PLAY_INTERACTIVE — modalità interattiva per risolvere l'indovinello
# ─────────────────────────────────────────────────────────────────────────────
play_interactive() {
    echo -e "\n${BOLD}Modalità Interattiva — Risolvi l'indovinello!${RESET}"
    echo -e "Digita il nome del container da caricare sulla barca."
    echo -e "Comandi: ${CYAN}lupo${RESET} | ${CYAN}capra${RESET} | ${CYAN}cavolo${RESET} | ${CYAN}invio${RESET} (viaggio vuoto) | ${CYAN}q${RESET} (esci)\n"
    print_state

    while true; do
        # Condizione di vittoria: sponda_vm1 vuota
        local vm1_actors
        vm1_actors=$(get_actors_on_net "$NET_VM1")
        if [[ -z "$vm1_actors" ]]; then
            echo -e "${GREEN}${BOLD}[SUCCESS] Migrazione completata in ${STEPS} step!${RESET}\n"
            log_ok "Tutti i container attivi su sponda_vm2"
            log_ok "sponda_vm1 offline — nessun container residuo"
            exit 0
        fi

        echo -ne "${CYAN}→ Container da migrare [Barca su: ${BARCA_POS}]: ${RESET}"
        read -r input
        [[ "$input" == "q" ]] && echo "Uscita." && exit 0
        migrate "$input" || true
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# RUN_AUTO — soluzione automatica in 7 passi
# ─────────────────────────────────────────────────────────────────────────────
run_auto() {
    echo -e "\n${BOLD}Indovinello Capra Cavolo Lupo — Versione Docker${RESET}"
    log_ok "Container lupo, capra, cavolo attivi su sponda_vm1"
    log_ok "sponda_vm2 offline — nessun container attivo"
    echo -e "${GREEN}${BOLD}[Inizio Migrazione]${RESET}\n"

    log_info "Container su sponda_vm1: [lupo, capra, cavolo]"
    log_info "Obiettivo: migrare tutti su sponda_vm2"
    log_warn "CONSTRAINT: lupo e capra non possono stare sulla stessa rete"
    log_warn "CONSTRAINT: capra e cavolo non possono stare sulla stessa rete"
    log_warn "CONFLITTO  → docker stop <container>  (equivale a SIGTERM)"
    print_state

    migrate "capra"   # Step 1: isola capra su vm2
    migrate ""        # Step 2: barca torna vuota su vm1
    migrate "cavolo"  # Step 3: porta cavolo su vm2 (traghettatore presente = no conflitto)
    migrate "capra"   # Step 4: riporta capra su vm1 per non lasciarla col cavolo
    migrate "lupo"    # Step 5: porta lupo su vm2 (capra resta sola su vm1)
    migrate ""        # Step 6: barca torna vuota su vm1
    migrate "capra"   # Step 7: ultima migrazione — capra su vm2

    echo -e "${GREEN}${BOLD}[SUCCESS] Migrazione completata in ${STEPS} step!${RESET}\n"
    log_ok "Tutti i container attivi su sponda_vm2"
    log_ok "sponda_vm1 offline — nessun container residuo"
}

# ─────────────────────────────────────────────────────────────────────────────
# ENTRYPOINT
# ─────────────────────────────────────────────────────────────────────────────
case "${1:-}" in
    --clean|-c)
        cleanup
        ;;
    --play|-p)
        setup
        play_interactive
        ;;
    *)
        setup
        run_auto
        ;;
esac

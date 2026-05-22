#!/usr/bin/env bash
# ============================================================
# file_capra_cavoli.sh — Container Ferry: lupo, capra e cavolo
# ============================================================
# Il classico indovinello reinterpretato come migrazione di
# processi tra due VM attraverso un network bridge.

# Uso:
#   chmod +x file_capra_cavoli.sh
#   ./file_capra_cavoli.sh          → esegue la soluzione automatica
#   ./file_capra_cavoli.sh --play   → modalità interattiva passo per passo
# ============================================================

set -e

# ─────────────────────────────────────────────
# COLORI per il terminale
# ─────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'

# ─────────────────────────────────────────────
# STATO — variabili globali che rappresentano il sistema
# ─────────────────────────────────────────────
VM1="lupo capra cavolo"
VM2=""

BARCA_POS="vm1"
BARCA_CARGO=""

STEPS=0

# ─────────────────────────────────────────────
# CONFLICT CHECKER
# ─────────────────────────────────────────────
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

# ─────────────────────────────────────────────
# DISPLAY
# ─────────────────────────────────────────────
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

# ─────────────────────────────────────────────
# LOGGER
# ─────────────────────────────────────────────
log_info()    { echo -e "${BLUE}\$${RESET} $*"; }
log_ok()      { echo -e "${GREEN}[OK]${RESET} $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
log_error()   { echo -e "${RED}[ERR]${RESET} $*"; }
log_step()    { echo -e "\n${BOLD}── step $STEPS ─────────────────────────────${RESET}"; }

# ─────────────────────────────────────────────
# MIGRATE
# ─────────────────────────────────────────────
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
# ENTRYPOINT
# #Per farlo partire in maniera automatica metto la funzione run_auto:
# ─────────────────────────────────────────────────────────────────────────────
run_auto























































































































































































































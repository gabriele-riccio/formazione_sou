#!/usr/bin/env bash
# ==============================================================================
# file_script_container.sh — ESERCIZIO: lupo, capra e cavolo
# VERSIONE MULTI-VM — migrazione reale tra vm1 e vm2
# ==============================================================================
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; GRAY='\033[0;90m'
BOLD='\033[1m'; RESET='\033[0m'

VM1_IP="192.168.56.10"
VM2_IP="192.168.56.11"
SSH_USER="vagrant"
SSH_KEY="/vagrant/.vagrant/machines/vm2/virtualbox/private_key"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${SSH_KEY} -q"
TMP_DIR="/tmp/migrazione"
ATTORI=("lupo" "capra" "cavolo")
BARCA_POS="vm1"
STEPS=0

log_info()  { echo -e "${BLUE}\$${RESET} $*"; }
log_ok()    { echo -e "${GREEN}[OK]${RESET}   $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }
log_error() { echo -e "${RED}[ERR]${RESET}  $*"; }
log_step()  { echo -e "\n${BOLD}── step $STEPS ─────────────────────────────${RESET}"; }

ssh_vm2() { ssh $SSH_OPTS ${SSH_USER}@${VM2_IP} "$@"; }

setup() {
    echo -e "\n${BOLD}==> Setup ambiente Docker${RESET}"
    mkdir -p "$TMP_DIR"
    ssh_vm2 "mkdir -p ${TMP_DIR}"
    for attore in "${ATTORI[@]}"; do
        if docker inspect "$attore" &>/dev/null; then
            docker rm -f "$attore" > /dev/null
            log_warn "Container '$attore' rimosso da vm1 (pulizia)"
        fi
        if ssh_vm2 "docker inspect $attore" &>/dev/null; then
            ssh_vm2 "docker rm -f $attore > /dev/null"
            log_warn "Container '$attore' rimosso da vm2 (pulizia)"
        fi
    done
    for attore in "${ATTORI[@]}"; do
        docker run -d --name "$attore" --label "esercizio=capra_cavoli" \
            ubuntu sleep infinity > /dev/null
        log_ok "Container '${attore}' avviato su vm1"
    done
    echo ""
}

cleanup() {
    echo -e "\n${BOLD}==> Cleanup${RESET}"
    for attore in "${ATTORI[@]}"; do
        docker rm -f "$attore" 2>/dev/null && log_ok "Rimosso '$attore' da vm1" || true
        ssh_vm2 "docker rm -f $attore 2>/dev/null || true"
        log_ok "Rimosso '$attore' da vm2 (se esisteva)"
    done
    rm -rf "$TMP_DIR"
    ssh_vm2 "rm -rf ${TMP_DIR}"
}

get_actors_on_vm() {
    local vm="$1"
    local result=""
    for attore in "${ATTORI[@]}"; do
        if [[ "$vm" == "vm1" ]]; then
            docker inspect "$attore" &>/dev/null && result+="$attore "
        else
            ssh_vm2 "docker inspect $attore" &>/dev/null && result+="$attore "
        fi
    done
    echo "$result" | xargs || true
}

check_conflicts() {
    local actors
    actors=$(get_actors_on_vm "$1")
    if echo "$actors" | grep -q "lupo" && echo "$actors" | grep -q "capra"; then
        echo "lupo consuma capra → docker stop capra (SIGTERM)"; return 1
    fi
    if echo "$actors" | grep -q "capra" && echo "$actors" | grep -q "cavolo"; then
        echo "capra consuma cavolo → docker stop cavolo (SIGTERM)"; return 1
    fi
    return 0
}

vm_display() {
    local actors
    actors=$(get_actors_on_vm "$1")
    [[ -z "$actors" ]] && echo -e "${GRAY}(vuota)${RESET}" || echo -e "$actors"
}

print_state() {
    echo ""
    echo -e "  ${BOLD}vm1${RESET} [${VM1_IP}]  $(vm_display "vm1")"
    if [[ "$BARCA_POS" == "vm1" ]]; then
        echo -e "       ${CYAN}barca${RESET}  ${GRAY}@ vm1${RESET}"
        echo -e "       ${GRAY}────── rete privata ──────${RESET}"
    else
        echo -e "       ${GRAY}────── rete privata ──────${RESET}"
        echo -e "       ${CYAN}barca${RESET}  ${GRAY}@ vm2${RESET}"
    fi
    echo -e "  ${BOLD}vm2${RESET} [${VM2_IP}]  $(vm_display "vm2")"
    echo ""
}

transfer() {
    local process="$1" origin="$2" dest="$3"
    local img="${process}_img"
    local tar="${TMP_DIR}/${process}.tar"

    log_info "Trasferimento reale: ${process}  ${origin} → ${dest}"

    if [[ "$origin" == "vm1" ]]; then
        log_info "1/6 docker commit ${process} → ${img}"
        docker commit "$process" "$img" > /dev/null

        log_info "2/6 docker save ${img} → ${process}.tar"
        docker save "$img" -o "$tar"

        log_info "3/6 scp ${process}.tar → vm2"
        scp $SSH_OPTS "$tar" ${SSH_USER}@${VM2_IP}:"$tar"

        log_info "4/6 docker load su vm2"
        ssh_vm2 "docker load -i ${tar} > /dev/null"

        log_info "5/6 docker run ${process} su vm2"
        ssh_vm2 "docker run -d --name ${process} --label esercizio=capra_cavoli ${img} sleep infinity > /dev/null"

        log_info "6/6 docker rm ${process} da vm1"
        docker rm -f "$process" > /dev/null

        # pulizia
        docker rmi "$img" > /dev/null 2>&1 || true
        ssh_vm2 "docker rmi ${img} > /dev/null 2>&1 || true"
        rm -f "$tar"; ssh_vm2 "rm -f ${tar}"

    else
        log_info "1/6 docker commit ${process} → ${img} su vm2"
        ssh_vm2 "docker commit ${process} ${img} > /dev/null"

        log_info "2/6 docker save ${img} su vm2"
        ssh_vm2 "docker save ${img} -o ${tar}"

        log_info "3/6 scp vm2:${process}.tar → vm1"
        scp $SSH_OPTS ${SSH_USER}@${VM2_IP}:"$tar" "$tar"

        log_info "4/6 docker load su vm1"
        docker load -i "$tar" > /dev/null

        log_info "5/6 docker run ${process} su vm1"
        docker run -d --name "$process" --label esercizio=capra_cavoli \
            "$img" sleep infinity > /dev/null

        log_info "6/6 docker rm ${process} da vm2"
        ssh_vm2 "docker rm -f ${process} > /dev/null"

        # pulizia
        docker rmi "$img" > /dev/null 2>&1 || true
        ssh_vm2 "docker rmi ${img} > /dev/null 2>&1 || true"
        rm -f "$tar"; ssh_vm2 "rm -f ${tar}"
    fi
}

migrate() {
    local process="${1:-}"
    local origin="$BARCA_POS"
    local destination
    [[ "$origin" == "vm1" ]] && destination="vm2" || destination="vm1"

    if [[ -n "$process" ]]; then
        if [[ -z "$(get_actors_on_vm "$origin" | grep -w "$process" || true)" ]]; then
            log_error "Container '$process' non trovato su $origin"; exit 1
        fi
        transfer "$process" "$origin" "$destination"
    fi

    BARCA_POS="$destination"
    STEPS=$((STEPS + 1))
    log_step
    log_info "Migrazione  ${process:-vuoto}  ${origin} → ${destination}"

    local conflict
    if ! conflict=$(check_conflicts "$origin" 2>&1); then
        log_error "CONFLITTO su ${origin}: ${conflict}"
        print_state; exit 1
    fi

    [[ -n "$process" ]] \
        && log_ok "${process} migrato su ${destination}" \
        || log_warn "Viaggio vuoto — solo admin (barca)"
    print_state
}

play_interactive() {
    echo -e "\n${BOLD}Modalità Interattiva — Risolvi l'indovinello!${RESET}"
    echo -e "Comandi: ${CYAN}lupo${RESET} | ${CYAN}capra${RESET} | ${CYAN}cavolo${RESET} | ${CYAN}invio${RESET} (vuoto) | ${CYAN}q${RESET} (esci)\n"
    print_state
    while true; do
        [[ -z "$(get_actors_on_vm "vm1")" ]] && {
            echo -e "${GREEN}${BOLD}[SUCCESS] Migrazione completata in ${STEPS} step!${RESET}\n"
            log_ok "Tutti i container su vm2 (${VM2_IP})"
            log_ok "vm1 offline — nessun container residuo"
            exit 0
        }
        echo -ne "${CYAN}→ Container da migrare [Barca su: ${BARCA_POS}]: ${RESET}"
        read -r input
        [[ "$input" == "q" ]] && echo "Uscita." && exit 0
        migrate "$input" || true
    done
}

run_auto() {
    echo -e "\n${BOLD}Indovinello Capra Cavolo Lupo — Migrazione Multi-VM${RESET}"
    log_ok "Container lupo, capra, cavolo su vm1 (${VM1_IP})"
    log_ok "vm2 (${VM2_IP}) vuota"
    log_warn "CONSTRAINT: lupo e capra non possono coesistere"
    log_warn "CONSTRAINT: capra e cavolo non possono coesistere"
    print_state
    migrate "capra"
    migrate ""
    migrate "cavolo"
    migrate "capra"
    migrate "lupo"
    migrate ""
    migrate "capra"
    echo -e "${GREEN}${BOLD}[SUCCESS] Migrazione completata in ${STEPS} step!${RESET}\n"
    log_ok "Tutti i container su vm2 (${VM2_IP})"
    log_ok "vm1 offline — nessun container residuo"
}

case "${1:-}" in
    --clean|-c)  cleanup ;;
    --play|-p)   setup && play_interactive ;;
    *)           setup && run_auto ;;
esac
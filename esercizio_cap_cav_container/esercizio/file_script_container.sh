#!/usr/bin/env bash
# ==============================================================================
# file_script_container.sh — ESERCIZIO: lupo, capra e cavolo
# VERSIONE MULTI-VM — migrazione reale tra vm1 (192.168.56.10) e vm2 (192.168.56.11)
# ==============================================================================
# La migrazione avviene così:
#   1. docker commit  → salva lo stato del container in un'immagine
#   2. docker save    → esporta l'immagine in un file .tar
#   3. scp            → copia il .tar su vm2 via rete privata
#   4. docker load    → carica l'immagine su vm2
#   5. docker run     → avvia il container su vm2
#   6. docker rm      → rimuove il container da vm1
#
# Uso:
#   bash file_script_container.sh          → soluzione automatica
#   bash file_script_container.sh --play   → modalità interattiva
#   bash file_script_container.sh --clean  → rimuove tutto
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
# CONFIGURAZIONE RETE
# ─────────────────────────────────────────────────────────────────────────────
VM1_IP="192.168.56.10"
VM2_IP="192.168.56.11"
SSH_USER="vagrant"
SSH_KEY="/vagrant/.vagrant/machines/vm2/virtualbox/private_key"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${SSH_KEY}"
TMP_DIR="/tmp/migrazione"

# ─────────────────────────────────────────────────────────────────────────────
# COSTANTI
# ─────────────────────────────────────────────────────────────────────────────
ATTORI=("lupo" "capra" "cavolo")
BARCA_POS="vm1"
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
# SETUP — avvia i container su vm1 e prepara la cartella temporanea
# ─────────────────────────────────────────────────────────────────────────────
setup() {
    echo -e "\n${BOLD}==> Setup ambiente Docker${RESET}"
    mkdir -p "$TMP_DIR"

    # Pulisce eventuali container rimasti da esecuzioni precedenti
    for attore in "${ATTORI[@]}"; do
        # Rimuove da vm1 se esiste
        if docker inspect "$attore" &>/dev/null; then
            docker rm -f "$attore" > /dev/null
            log_warn "Container '$attore' rimosso da vm1 (pulizia)"
        fi
        # Rimuove da vm2 se esiste
        ssh $SSH_OPTS ${SSH_USER}@${VM2_IP} \
            "docker inspect $attore &>/dev/null && docker rm -f $attore > /dev/null || true" 2>/dev/null
    done

    # Avvia i container su vm1
    for attore in "${ATTORI[@]}"; do
        docker run -d \
            --name "$attore" \
            --label "esercizio=capra_cavoli" \
            ubuntu sleep infinity > /dev/null
        log_ok "Container '${attore}' avviato su vm1"
    done

    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# CLEANUP — rimuove tutti i container da entrambe le VM
# ─────────────────────────────────────────────────────────────────────────────
cleanup() {
    echo -e "\n${BOLD}==> Cleanup${RESET}"
    for attore in "${ATTORI[@]}"; do
        docker rm -f "$attore" 2>/dev/null && log_ok "Rimosso '$attore' da vm1" || true
        ssh $SSH_OPTS ${SSH_USER}@${VM2_IP} \
            "docker rm -f $attore 2>/dev/null" 2>/dev/null \
            && log_ok "Rimosso '$attore' da vm2" || true
    done
    rm -rf "$TMP_DIR"
}

# ─────────────────────────────────────────────────────────────────────────────
# GET_ACTORS — legge i container attivi su una VM tramite docker ps
# ─────────────────────────────────────────────────────────────────────────────
get_actors_on_vm() {
    local vm="$1"   # "vm1" o "vm2"
    local result=""

    for attore in "${ATTORI[@]}"; do
        if [[ "$vm" == "vm1" ]]; then
            if docker inspect "$attore" &>/dev/null; then
                result+="$attore "
            fi
        else
            if ssh $SSH_OPTS ${SSH_USER}@${VM2_IP} \
                "docker inspect $attore &>/dev/null" 2>/dev/null; then
                result+="$attore "
            fi
        fi
    done
    echo "$result" | xargs || true
}

# ─────────────────────────────────────────────────────────────────────────────
# CHECK_CONFLICTS — rileva conflitti su una VM
# ─────────────────────────────────────────────────────────────────────────────
check_conflicts() {
    local vm="$1"
    local actors
    actors=$(get_actors_on_vm "$vm")

    if echo "$actors" | grep -q "lupo" && echo "$actors" | grep -q "capra"; then
        echo "lupo consuma capra → docker stop capra (SIGTERM)"
        return 1
    fi
    if echo "$actors" | grep -q "capra" && echo "$actors" | grep -q "cavolo"; then
        echo "capra consuma cavolo → docker stop cavolo (SIGTERM)"
        return 1
    fi
    return 0
}

# ─────────────────────────────────────────────────────────────────────────────
# VM_DISPLAY — mostra i container presenti su una VM
# ─────────────────────────────────────────────────────────────────────────────
vm_display() {
    local vm="$1"
    local actors
    actors=$(get_actors_on_vm "$vm")
    if [[ -z "$actors" ]]; then
        echo -e "${GRAY}(vuota)${RESET}"
    else
        echo -e "$actors"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# PRINT_STATE — mostra lo stato reale di entrambe le VM
# ─────────────────────────────────────────────────────────────────────────────
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

# ─────────────────────────────────────────────────────────────────────────────
# TRANSFER — migra fisicamente un container da una VM all'altra
#
# Passaggi reali:
#   1. docker commit  → crea immagine dal container
#   2. docker save    → esporta immagine in .tar
#   3. scp            → copia .tar sulla VM di destinazione
#   4. docker load    → carica immagine sulla VM di destinazione
#   5. docker run     → avvia il container sulla VM di destinazione
#   6. docker rm      → rimuove il container dalla VM di origine
# ─────────────────────────────────────────────────────────────────────────────
transfer() {
    local process="$1"
    local origin="$2"   # "vm1" o "vm2"
    local dest="$3"     # "vm1" o "vm2"
    local tar_file="${TMP_DIR}/${process}.tar"

    log_info "Trasferimento reale: ${process}  ${origin} → ${dest}"

    if [[ "$origin" == "vm1" ]]; then
        # Commit + save su vm1
        log_info "docker commit ${process} ${process}_img"
        docker commit "$process" "${process}_img" > /dev/null
        log_info "docker save ${process}_img → ${process}.tar"
        docker save "${process}_img" -o "$tar_file"

        # Copia su vm2
        log_info "scp ${process}.tar → vm2"
        scp $SSH_OPTS "$tar_file" ${SSH_USER}@${VM2_IP}:${TMP_DIR}/${process}.tar 2>/dev/null

        # Load e run su vm2
        log_info "docker load + docker run su vm2"
        ssh $SSH_OPTS ${SSH_USER}@${VM2_IP} "
            mkdir -p ${TMP_DIR}
            docker load -i ${TMP_DIR}/${process}.tar > /dev/null
            docker run -d --name ${process} --label esercizio=capra_cavoli \
                ${process}_img sleep infinity > /dev/null
        " 2>/dev/null

        # Rimuove da vm1
        log_info "docker rm ${process} da vm1"
        docker rm -f "$process" > /dev/null
        docker rmi "${process}_img" > /dev/null 2>&1 || true

    else
        # Commit + save su vm2
        log_info "docker commit ${process} su vm2"
        ssh $SSH_OPTS ${SSH_USER}@${VM2_IP} "
            docker commit ${process} ${process}_img > /dev/null
            docker save ${process}_img -o ${TMP_DIR}/${process}.tar
        " 2>/dev/null

        # Copia su vm1
        log_info "scp ${process}.tar → vm1"
        scp $SSH_OPTS ${SSH_USER}@${VM2_IP}:${TMP_DIR}/${process}.tar "$tar_file" 2>/dev/null

        # Load e run su vm1
        log_info "docker load + docker run su vm1"
        docker load -i "$tar_file" > /dev/null
        docker run -d --name "$process" --label esercizio=capra_cavoli \
            "${process}_img" sleep infinity > /dev/null
        docker rmi "${process}_img" > /dev/null 2>&1 || true

        # Rimuove da vm2
        log_info "docker rm ${process} da vm2"
        ssh $SSH_OPTS ${SSH_USER}@${VM2_IP} \
            "docker rm -f ${process} > /dev/null && \
             docker rmi ${process}_img > /dev/null 2>&1 || true" 2>/dev/null
    fi

    # Pulizia tar
    rm -f "$tar_file" 2>/dev/null || true
}

# ─────────────────────────────────────────────────────────────────────────────
# MIGRATE — orchestra la migrazione di un container tra le due VM reali
# ─────────────────────────────────────────────────────────────────────────────
migrate() {
    local process="${1:-}"
    local origin="$BARCA_POS"
    local destination
    [[ "$origin" == "vm1" ]] && destination="vm2" || destination="vm1"

    # Migrazione reale del container
    if [[ -n "$process" ]]; then
        # Verifica che il container esista sulla VM di origine
        if [[ -z "$(get_actors_on_vm "$origin" | grep -w "$process" || true)" ]]; then
            log_error "Container '$process' non trovato su $origin"
            exit 1
        fi
        transfer "$process" "$origin" "$destination"
    fi

    # Sposta la barca
    BARCA_POS="$destination"
    STEPS=$((STEPS + 1))
    log_step

    local cargo_label="${process:-vuoto}"
    log_info "Migrazione  ${cargo_label}  ${origin} → ${destination}"

    # Controlla conflitti sulla VM di origine
    local conflict
    if ! conflict=$(check_conflicts "$origin" 2>&1); then
        log_error "CONFLITTO su ${origin}: ${conflict}"
        log_error "Sistema instabile — fare rollback"
        print_state
        exit 1
    fi

    [[ -n "$process" ]] \
        && log_ok "${process} migrato su ${destination}" \
        || log_warn "Viaggio vuoto — solo admin (barca)"

    print_state
}

# ─────────────────────────────────────────────────────────────────────────────
# PLAY_INTERACTIVE
# ─────────────────────────────────────────────────────────────────────────────
play_interactive() {
    echo -e "\n${BOLD}Modalità Interattiva — Risolvi l'indovinello!${RESET}"
    echo -e "Comandi: ${CYAN}lupo${RESET} | ${CYAN}capra${RESET} | ${CYAN}cavolo${RESET} | ${CYAN}invio${RESET} (vuoto) | ${CYAN}q${RESET} (esci)\n"
    print_state

    while true; do
        local vm1_actors
        vm1_actors=$(get_actors_on_vm "vm1")
        if [[ -z "$vm1_actors" ]]; then
            echo -e "${GREEN}${BOLD}[SUCCESS] Migrazione completata in ${STEPS} step!${RESET}\n"
            log_ok "Tutti i container attivi su vm2 (${VM2_IP})"
            log_ok "vm1 offline — nessun container residuo"
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
    log_ok "Tutti i container attivi su vm2 (${VM2_IP})"
    log_ok "vm1 offline — nessun container residuo"
}

# ─────────────────────────────────────────────────────────────────────────────
# ENTRYPOINT
# ─────────────────────────────────────────────────────────────────────────────

# Crea la cartella tmp su vm2 all'avvio
ssh $SSH_OPTS ${SSH_USER}@${VM2_IP} "mkdir -p ${TMP_DIR}" 2>/dev/null || true

case "${1:-}" in
    --clean|-c)  cleanup ;;
    --play|-p)   setup && play_interactive ;;
    *)           setup && run_auto ;;
esac

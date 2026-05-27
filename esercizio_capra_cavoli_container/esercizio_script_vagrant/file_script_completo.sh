#!/usr/bin/env bash
# ==============================================================================
# file_script_completo.sh — Indovinello Lupo, Capra e Cavolo
# VERSIONE DOCKER INDOVINELLO
# ==============================================================================
#
# ATTORI (container Docker):
#   - lupo, capra, cavolo  → i tre processi dell'indovinello
#   - traghettatore        → il container "barca" che si sposta sempre
#
# REGOLE:
#   - lupo e capra NON possono stare sulla stessa VM senza traghettatore
#   - capra e cavolo NON possono stare sulla stessa VM senza traghettatore
#
# MIGRAZIONE:
#   - Migrazione di un processo: il processo + traghettatore si spostano insieme
#   - Migrazione vuota (solo barca): solo traghettatore si sposta
#   - Dopo ogni migrazione si controlla la VM appena lasciata dal traghettatore
#
# COMUNICAZIONE vm1 → vm2:
#   - Chiave SSH: /home/vagrant/.ssh/vm1_to_vm2 (generata dal provisioning)
#   - Il provisioning si occupa di distribuire la chiave pubblica su vm2
#
# ==============================================================================
set -e # per chiudere lo script in caso di errore

# ─────────────────────────────────────────────────────────────
# COLORI: me li genero come ogni esercizio
# ─────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'

# ─────────────────────────────────────────────────────────────
# CONFIGURAZIONE
# ─────────────────────────────────────────────────────────────
VM2_IP="192.168.56.11"
SSH_USER="vagrant"
SSH_KEY="/home/vagrant/.ssh/vm1_to_vm2"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${SSH_KEY} -q"
TMP_DIR="/tmp/migrazione"

# Tutti gli attori: i 3 processi + il traghettatore
PROCESSI=("lupo" "capra" "cavolo")
TUTTI=("lupo" "capra" "cavolo" "traghettatore")

# Stato iniziale
BARCA_POS="vm1"   # posizione del traghettatore
STEPS=0

# ─────────────────────────────────────────────────────────────
# LOGGER
# ─────────────────────────────────────────────────────────────
log_info()    { echo -e "${BLUE}\$${RESET} $*"; }
log_ok()      { echo -e "${GREEN}[OK]${RESET}   $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }
log_error()   { echo -e "${RED}[ERR]${RESET}  $*"; }
log_step()    { echo -e "\n${BOLD}── step ${STEPS} ─────────────────────────────────${RESET}"; }
log_conflict(){ echo -e "${RED}${BOLD}[CONFLICT]${RESET} $*"; }

# ─────────────────────────────────────────────────────────────
# SSH_VM2 — esegue un comando su vm2 tramite chiave SSH
# ─────────────────────────────────────────────────────────────
ssh_vm2() {
    ssh $SSH_OPTS ${SSH_USER}@${VM2_IP} "$@"
}

scp_to_vm2() {
    scp $SSH_OPTS "$1" ${SSH_USER}@${VM2_IP}:"$2"
}

scp_from_vm2() {
    scp $SSH_OPTS ${SSH_USER}@${VM2_IP}:"$1" "$2"
}

# ─────────────────────────────────────────────────────────────
# INIT_SSH — verifica che SSH funzioni, copia la chiave con i
# permessi corretti (necessario perché /vagrant è VBOXSF e non
# preserva i permessi Unix — SSH richiede chmod 600)
# ─────────────────────────────────────────────────────────────
init_ssh() {
    if [[ ! -f "$SSH_KEY" ]]; then
        log_error "Chiave SSH non trovata: ${SSH_KEY}"
        log_warn  "Esegui 'vagrant destroy -f && vagrant up' per rigenerarla"
        exit 1
    fi

    # Assicura permessi corretti sulla chiave (VBOXSF non preserva chmod)
    chmod 600 "$SSH_KEY"

    # Test connessione
    if ! ssh_vm2 "exit" 2>/dev/null; then
        log_error "Impossibile connettersi a vm2 (${VM2_IP})"
        log_warn  "Verifica che vm2 sia accesa e il provisioning sia completato"
        log_warn  "Prova: vagrant up vm2 && vagrant provision vm2"
        exit 1
    fi

    log_ok "Connessione SSH a vm2 (${VM2_IP}) verificata"
}

# ─────────────────────────────────────────────────────────────
# SETUP — crea i 4 container su vm1 (stato iniziale)
# ─────────────────────────────────────────────────────────────
setup() {
    echo -e "\n${BOLD}==> Setup: creazione container su vm1${RESET}"

    mkdir -p "$TMP_DIR"
    ssh_vm2 "mkdir -p ${TMP_DIR}"

    # Pulizia container esistenti su entrambe le VM
    for nome in "${TUTTI[@]}"; do
        if docker inspect "$nome" &>/dev/null; then
            docker rm -f "$nome" > /dev/null
            log_warn "Container '$nome' rimosso da vm1 (pulizia precedente)"
        fi
        if ssh_vm2 "docker inspect $nome &>/dev/null" 2>/dev/null; then
            ssh_vm2 "docker rm -f $nome > /dev/null"
            log_warn "Container '$nome' rimosso da vm2 (pulizia precedente)"
        fi
    done

    # Avvia i 4 container su vm1
    for nome in "${TUTTI[@]}"; do
        docker run -d \
            --name "$nome" \
            --label "esercizio=capra_cavoli" \
            ubuntu sleep infinity > /dev/null
        log_ok "Container '${CYAN}${nome}${RESET}' avviato su vm1"
    done

    BARCA_POS="vm1"
    echo ""
}

# ─────────────────────────────────────────────────────────────
# CLEANUP — rimuove tutti i container da entrambe le VM, serve 
# per la pulizia finale.
# ─────────────────────────────────────────────────────────────
cleanup() {
    echo -e "\n${BOLD}==> Cleanup container${RESET}"
    for nome in "${TUTTI[@]}"; do
        docker rm -f "$nome" 2>/dev/null && log_ok "Rimosso '$nome' da vm1" || true
        ssh_vm2 "docker rm -f $nome 2>/dev/null || true" 2>/dev/null
        log_ok "Rimosso '$nome' da vm2 (se esisteva)"
    done
    rm -rf "$TMP_DIR"
    ssh_vm2 "rm -rf ${TMP_DIR}" 2>/dev/null || true
    log_ok "Cleanup completato"
}

# ─────────────────────────────────────────────────────────────
# GET_ACTORS_ON_VM — restituisce i container attivi su una VM
# (esclude il traghettatore dalla lista dei processi)
# ─────────────────────────────────────────────────────────────
get_procs_on_vm() {
    local vm="$1"
    local result=""
    for nome in "${PROCESSI[@]}"; do
        if [[ "$vm" == "vm1" ]]; then
            docker inspect "$nome" &>/dev/null && result+="$nome "
        else
            ssh_vm2 "docker inspect $nome &>/dev/null" 2>/dev/null && result+="$nome "
        fi
    done
    echo "$result" | xargs || true
}

has_container_on_vm() {
    local vm="$1"
    local nome="$2"
    if [[ "$vm" == "vm1" ]]; then
        docker inspect "$nome" &>/dev/null
    else
        ssh_vm2 "docker inspect $nome &>/dev/null" 2>/dev/null
    fi
}

# ─────────────────────────────────────────────────────────────
# CHECK_CONFLICTS — verifica se ci sono conflitti su una VM
# Un conflitto esiste se lupo+capra o capra+cavolo sono sulla
# stessa VM SENZA il traghettatore
# ─────────────────────────────────────────────────────────────
check_conflicts() {
    local vm="$1"
    local procs
    procs=$(get_procs_on_vm "$vm")

    # Se il traghettatore è su questa VM non ci sono conflitti
    if has_container_on_vm "$vm" "traghettatore" 2>/dev/null; then
        return 0
    fi

    if echo "$procs" | grep -q "lupo" && echo "$procs" | grep -q "capra"; then
        echo "lupo e capra insieme senza traghettatore → SIGTERM capra"
        return 1
    fi
    if echo "$procs" | grep -q "capra" && echo "$procs" | grep -q "cavolo"; then
        echo "capra e cavolo insieme senza traghettatore → SIGTERM cavolo"
        return 1
    fi
    return 0
}

# ─────────────────────────────────────────────────────────────
# TRANSFER_CONTAINER — migra fisicamente UN container tra VM
#
# Sequenza reale comandi docker:
#   1. docker commit  → snapshot in immagine
#   2. docker save    → esporta in .tar
#   3. scp            → copia sulla VM di destinazione
#   4. docker load    → carica l'immagine
#   5. docker run     → avvia il container
#   6. docker rm      → rimuove dalla VM di origine
# ─────────────────────────────────────────────────────────────
transfer_container() {
    local nome="$1"
    local origin="$2"   # "vm1" o "vm2"
    local dest="$3"     # "vm1" o "vm2"
    local img="${nome}_img"
    local tar="${TMP_DIR}/${nome}.tar"

    log_info "  Trasferimento ${CYAN}${nome}${RESET}: ${origin} → ${dest}"

    if [[ "$origin" == "vm1" ]]; then
        docker commit "$nome" "$img" > /dev/null
        docker save "$img" -o "$tar"
        scp_to_vm2 "$tar" "$tar"
        ssh_vm2 "docker load -i ${tar} > /dev/null && \
                 docker run -d --name ${nome} --label esercizio=capra_cavoli ${img} sleep infinity > /dev/null"
        docker rm -f "$nome" > /dev/null
        docker rmi "$img" > /dev/null 2>&1 || true
        ssh_vm2 "docker rmi ${img} > /dev/null 2>&1 || true"
        rm -f "$tar"
        ssh_vm2 "rm -f ${tar}" 2>/dev/null || true
    else
        ssh_vm2 "docker commit ${nome} ${img} > /dev/null && \
                 docker save ${img} -o ${tar}"
        scp_from_vm2 "$tar" "$tar"
        docker load -i "$tar" > /dev/null
        docker run -d --name "$nome" --label esercizio=capra_cavoli \
            "$img" sleep infinity > /dev/null
        ssh_vm2 "docker rm -f ${nome} > /dev/null"
        docker rmi "$img" > /dev/null 2>&1 || true
        ssh_vm2 "docker rmi ${img} > /dev/null 2>&1 || true"
        rm -f "$tar"
        ssh_vm2 "rm -f ${tar}" 2>/dev/null || true
    fi
}

# ─────────────────────────────────────────────────────────────
# DISPLAY — visualizzazione stato attuale delle due VM
# ─────────────────────────────────────────────────────────────
display_vm() {
    local vm="$1"
    local procs
    procs=$(get_procs_on_vm "$vm")
    local has_barca=""
    has_container_on_vm "$vm" "traghettatore" 2>/dev/null && has_barca=" ${CYAN}[traghettatore]${RESET}"

    if [[ -z "$procs" ]]; then
        echo -e "${GRAY}(vuota)${RESET}${has_barca}"
    else
        echo -e "$procs${has_barca}"
    fi
}

print_state() {
    echo ""
    echo -e "  ${BOLD}vm1${RESET} [192.168.56.10]  $(display_vm "vm1")"
    if [[ "$BARCA_POS" == "vm1" ]]; then
        echo -e "        ${CYAN}  barca${RESET}  ${GRAY}@ vm1${RESET}"
        echo -e "        ${GRAY}═══════ fiume (rete VisualStudioCode) ═══════${RESET}"
    else
        echo -e "        ${GRAY}═══════ fiume (rete VisualStudioCode) ═══════${RESET}"
        echo -e "        ${CYAN}  barca${RESET}  ${GRAY}@ vm2${RESET}"
    fi
    echo -e "  ${BOLD}vm2${RESET} [192.168.56.11]  $(display_vm "vm2")"
    echo ""
}

# ─────────────────────────────────────────────────────────────
# MIGRATE — gestisce una mossa del giocatore
#
# Se process è vuoto → migrazione vuota (solo traghettatore)
# Se process ha un nome → processo + traghettatore si spostano
# ─────────────────────────────────────────────────────────────
migrate() {
    local process="${1:-}"
    local origin="$BARCA_POS"
    local destination
    [[ "$origin" == "vm1" ]] && destination="vm2" || destination="vm1"

    # Verifica che il processo da migrare sia sulla VM di origine
    if [[ -n "$process" ]]; then
        if ! has_container_on_vm "$origin" "$process" 2>/dev/null; then
            log_error "Il container '${process}' non si trova su ${origin}"
            return 1
        fi
    fi

    echo ""
    if [[ -n "$process" ]]; then
        log_info "Migrazione di ${CYAN}${process}${RESET} + traghettatore: ${origin} → ${destination}"
    else
        log_info "Migrazione vuota — solo traghettatore: ${origin} → ${destination}"
    fi

    # Sposta il processo (se presente)
    if [[ -n "$process" ]]; then
        transfer_container "$process" "$origin" "$destination"
    fi

    # Sposta sempre il traghettatore
    transfer_container "traghettatore" "$origin" "$destination"

    # Aggiorna posizione barca
    BARCA_POS="$destination"
    STEPS=$((STEPS + 1))
    log_step

    # Controllo conflitti sulla VM appena lasciata dal traghettatore
    local conflict
    if ! conflict=$(check_conflicts "$origin" 2>&1); then
        log_conflict "DISASTRO su ${origin}: ${conflict}"
        log_error "Il viaggio è da rifare, ritorna indietro!"
        print_state
        # Offro il riavvio
        echo -ne "${YELLOW}Vuoi annullare questa mossa? [s/N]: ${RESET}"
        read -r ans
        if [[ "${ans,,}" == "s" ]]; then
            # Rollback: torna alla mossa precedente
            if [[ -n "$process" ]]; then
                transfer_container "$process" "$destination" "$origin"
            fi
            transfer_container "traghettatore" "$destination" "$origin"
            BARCA_POS="$origin"
            STEPS=$((STEPS - 1))
            log_warn "Mossa annullata — ritornato allo stato precedente"
        else
            log_error "Gioco terminato — conflitto non risolto!"
            print_state
            exit 1
        fi
    else
        if [[ -n "$process" ]]; then
            log_ok "${CYAN}${process}${RESET} è migrato su ${destination}"
        else
            log_warn "Traghettatore tornato su ${destination} (viaggio vuoto)"
        fi
    fi

    print_state
}

# ─────────────────────────────────────────────────────────────
# PLAY_INTERACTIVE — il game loop principale
# ─────────────────────────────────────────────────────────────
play_interactive() {
    clear
    echo -e "\n${BOLD}${CYAN} ════════════════════════════════════════════════ ${RESET}"
    echo -e "${BOLD}${CYAN}           Indovinello: Lupo, Capra e Cavolo        ${RESET}"
    echo -e "${BOLD}${CYAN}               Versione Docker Multi-VM             ${RESET}"
    echo -e "${BOLD}${CYAN}   ════════════════════════════════════════════════ ${RESET}\n"

    echo -e "${BOLD}Regole:${RESET}"
    echo -e "    Sposta tutti i container da vm1 a vm2"
    echo -e "    ${RED}Lupo + Capra${RESET} non possono stare sulla stessa VM senza il traghettatore"
    echo -e "    ${RED}Capra + Cavolo${RESET} non possono stare sulla stessa VM senza il traghettatore"
    echo -e "    Il traghettatore si sposta SEMPRE con te (in ogni mossa)"
    echo -e "    Puoi tornare indietro con '${YELLOW}annulla${RESET}' se commetti un errore\n"

    echo -e "${BOLD}Comandi disponibili:${RESET}"
    echo -e "  ${CYAN}lupo${RESET}      # porta il lupo sulla sponda opposta"
    echo -e "  ${CYAN}capra${RESET}     # porta la capra sulla sponda opposta"
    echo -e "  ${CYAN}cavolo${RESET}    # porta il cavolo sulla sponda opposta"
    echo -e "  ${CYAN}invio${RESET}     # viaggio vuoto (torna indietro da solo)"
    echo -e "  ${CYAN}q${RESET}         # esci\n"

    print_state

    while true; do
        # ── CONDIZIONE DI VITTORIA ──────────────────────────────
        local vm1_procs
        vm1_procs=$(get_procs_on_vm "vm1")
        # Vittoria: vm1 vuota E traghettatore su vm2
        if [[ -z "$vm1_procs" && "$BARCA_POS" == "vm2" ]]; then
            echo -e "${GREEN}${BOLD}"
            echo -e " ══════════════════════════════════════════════════ "
            echo -e " VITTORIA! Migrazione completata in ${STEPS} mosse!"
            echo -e "   Tutti i container sono su vm2 in sicurezza!"
            echo -e " ══════════════════════════════════════════════════ "
            echo -e "${RESET}"
            log_ok "lupo, capra, cavolo e traghettatore → tutti su vm2"
            print_state
            exit 0
        fi

        # ── INPUT UTENTE ────────────────────────────────────────────────
        echo -ne "${CYAN}→ Mossa fatta [barca su ${BARCA_POS}]: ${RESET}"
        read -r input

        case "${input,,}" in
            q|quit|esci)
                echo "Uscita dal gioco."
                exit 0
                ;;
            ""|invio|vuoto)
                migrate ""
                ;;
            lupo|capra|cavolo)
                migrate "$input"
                ;;
            *)
                log_warn "Comando non riconosciuto: '${input}'"
                echo -e "  Usa: ${CYAN}lupo${RESET} | ${CYAN}capra${RESET} | ${CYAN}cavolo${RESET} | ${CYAN}invio${RESET} | ${CYAN}q${RESET}"
                ;;
        esac
    done
}

# ─────────────────────────────────────────────────────────────────
# ENTRYPOINT: ho cercato su internet un modo per pulire il tutto 
# dopo aver giocato e lo fa con questo entrypoint mettendo 
# dopo aver giocato il richiamo dello script seguito da --clean.
# ─────────────────────────────────────────────────────────────────
case "${1:-}" in
    --clean|-c)
        echo -e "\n${BOLD}==> Pulizia completa${RESET}"
        init_ssh 2>/dev/null || true
        cleanup
        ;;
    *)
        init_ssh
        setup
        play_interactive
        ;;
esac

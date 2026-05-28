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
set -e # interrompe lo script immediatamente se un qualsiasi comando fallisce

# ─────────────────────────────────────────────────────────────
# COLORI: codici di escape ANSI per colorare l'output nel terminale.
# Li uso in ogni esercizio per rendere l'output più leggibile.
# ─────────────────────────────────────────────────────────────
RED='\033[0;31m'     # errori e conflitti
GREEN='\033[0;32m'   # successi e conferme
YELLOW='\033[1;33m'  # avvisi
BLUE='\033[0;34m'    # informazioni generali
CYAN='\033[0;36m'    # nomi dei container e comandi
MAGENTA='\033[0;35m' # non usato, disponibile per estensioni future
GRAY='\033[0;90m'    # testo secondario (es. VM vuota)
BOLD='\033[1m'       # testo in grassetto per titoli e step
RESET='\033[0m'      # resetta tutti i colori al default del terminale

# ─────────────────────────────────────────────────────────────────────────────────
# CONFIGURAZIONE
# Mi salvo tutte le variabili di configurazione centralizzate qui,
# così da poterle modificare facilmente senza toccare il resto dello script
# ─────────────────────────────────────────────────────────────────────────────────
VM2_IP="192.168.56.11"                          # IP della seconda VM sulla rete privata VirtualBox
SSH_USER="vagrant"                              # utente SSH sulle VM Vagrant
SSH_KEY="/home/vagrant/.ssh/vm1_to_vm2"         # chiave privata generata dal provisioning
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${SSH_KEY} -q"
# StrictHostKeyChecking=no  → non chiede conferma alla prima connessione
# UserKnownHostsFile=/dev/null → non salva l'host nei known_hosts (VM temporanee)
# -i ${SSH_KEY}             → usa la mia chiave privata dedicata
# -q                        → quiet mode, sopprime i messaggi informativi di SSH
TMP_DIR="/tmp/migrazione"                       # cartella temporanea per i file .tar durante i trasferimenti

# Mi genero gli Array degli attori del gioco:
# PROCESSI contiene solo lupo/capra/cavolo (escluso traghettatore)
# perché il traghettatore ha una logica separata (si sposta sempre)
PROCESSI=("lupo" "capra" "cavolo")
TUTTI=("lupo" "capra" "cavolo" "traghettatore") # usato per setup e cleanup

# Mi genero le variabili di stato del gioco:
# BARCA_POS tiene traccia di dove si trova il traghettatore (vm1 o vm2)
# STEPS conta il numero di mosse effettuate dal giocatore
BARCA_POS="vm1"
STEPS=0

# ─────────────────────────────────────────────────────────────
# LOGGER: funzioni di stampa con prefisso colorato per categoria
# Uso $* per passare tutti gli argomenti come stringa unica
# ─────────────────────────────────────────────────────────────
log_info()    { echo -e "${BLUE}\$${RESET} $*"; }           # info generica
log_ok()      { echo -e "${GREEN}[OK]${RESET}   $*"; }      # operazione riuscita
log_warn()    { echo -e "${YELLOW}[WARN]${RESET} $*"; }     # avviso non bloccante
log_error()   { echo -e "${RED}[ERR]${RESET}  $*"; }        # errore bloccante
log_step()    { echo -e "\n${BOLD}── step ${STEPS} ─────────────────────────────────${RESET}"; } # separatore visivo tra le mosse
log_conflict(){ echo -e "${RED}${BOLD}[CONFLICT]${RESET} $*"; } # conflitto tra animali(lupo mangia pecora e capra mangiata dal cavolo)

# ─────────────────────────────────────────────────────────────
# SSH_VM2 — funzioni wrapper per SSH e SCP verso vm2
# Incapsulo le opzioni SSH in queste funzioni per non ripeterle
# ogni volta e per rendere il codice più leggibile
# ─────────────────────────────────────────────────────────────
ssh_vm2() {
    # Esegue un comando remoto su vm2 tramite SSH con la chiave dedicata
    ssh $SSH_OPTS ${SSH_USER}@${VM2_IP} "$@"
}

scp_to_vm2() {
    # Copia un file locale ($1) su vm2 al percorso ($2)
    scp $SSH_OPTS "$1" ${SSH_USER}@${VM2_IP}:"$2"
}

scp_from_vm2() {
    # Copia un file da vm2 ($1) in locale ($2)
    scp $SSH_OPTS ${SSH_USER}@${VM2_IP}:"$1" "$2"
}

# ─────────────────────────────────────────────────────────────
# INIT_SSH — verifica che la chiave SSH esista e che vm2 sia
# raggiungibile prima di iniziare il gioco.
#
# Nota importante: /vagrant è una cartella VBOXSF (VirtualBox
# Shared Folder) che NON preserva i permessi Unix. SSH rifiuta
# chiavi con permessi troppo aperti (es. 644 o 777).
# Per questo motivo applichiamo chmod 600 ogni volta che lo
# script parte, anche se la chiave è già nella home di vagrant.
# ─────────────────────────────────────────────────────────────
init_ssh() {
    # Controlla che la chiave privata esista
    if [[ ! -f "$SSH_KEY" ]]; then
        log_error "Chiave SSH non trovata: ${SSH_KEY}"
        log_warn  "Esegui 'vagrant destroy -f && vagrant up' per rigenerarla"
        exit 1
    fi

    # Forza i permessi corretti sulla chiave privata
    # SSH richiede esattamente 600 (lettura/scrittura solo per il proprietario)
    chmod 600 "$SSH_KEY"

    # Verifica la connessione a vm2 con un comando innocuo (exit)
    if ! ssh_vm2 "exit" 2>/dev/null; then
        log_error "Impossibile connettersi a vm2 (${VM2_IP})"
        log_warn  "Verifica che vm2 sia accesa e il provisioning sia completato"
        log_warn  "Prova: vagrant up vm2 && vagrant provision vm2"
        exit 1
    fi

    log_ok "Connessione SSH a vm2 (${VM2_IP}) verificata"
}

# ─────────────────────────────────────────────────────────────
# SETUP — crea i 4 container Docker su vm1 (stato iniziale)
# Prima fa pulizia di eventuali container rimasti da esecuzioni
# precedenti, poi avvia tutto da zero su vm1
# ─────────────────────────────────────────────────────────────
setup() {
    echo -e "\n${BOLD}==> Setup: creazione container su vm1${RESET}"

    # Crea le cartelle temporanee su entrambe le VM
    mkdir -p "$TMP_DIR"
    ssh_vm2 "mkdir -p ${TMP_DIR}"

    # Pulizia container esistenti su entrambe le VM
    # Necessario se lo script viene riavviato senza --clean
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

    # Avvia i 4 container su vm1:
    # - ubuntu: immagine base minimale (già disponibile dopo il provisioning)
    # - sleep infinity: processo che tiene il container vivo senza fare nulla
    # - --label: etichetta per identificare i container di questo esercizio
    for nome in "${TUTTI[@]}"; do
        docker run -d \
            --name "$nome" \
            --label "esercizio=capra_cavoli" \
            ubuntu sleep infinity > /dev/null
        log_ok "Container '${CYAN}${nome}${RESET}' avviato su vm1"
    done

    BARCA_POS="vm1" # reset della posizione della barca
    echo ""
}

# ─────────────────────────────────────────────────────────────
# CLEANUP — rimuove tutti i container da entrambe le VM e
# cancella i file temporanei. Viene chiamata con --clean oppure
# automaticamente in caso di errore grave.
# ─────────────────────────────────────────────────────────────
cleanup() {
    echo -e "\n${BOLD}==> Cleanup container${RESET}"
    for nome in "${TUTTI[@]}"; do
        # "|| true" impedisce che lo script si interrompa se il container non esiste
        docker rm -f "$nome" 2>/dev/null && log_ok "Rimosso '$nome' da vm1" || true
        ssh_vm2 "docker rm -f $nome 2>/dev/null || true" 2>/dev/null
        log_ok "Rimosso '$nome' da vm2 (se esisteva)"
    done
    # Rimuove i file .tar temporanei usati per i trasferimenti
    rm -rf "$TMP_DIR"
    ssh_vm2 "rm -rf ${TMP_DIR}" 2>/dev/null || true
    log_ok "Cleanup completato"
}

# ─────────────────────────────────────────────────────────────
# GET_PROCS_ON_VM — restituisce la lista dei processi (lupo,
# capra, cavolo) attivi su una VM. Il traghettatore è escluso
# perché ha una logica separata nella funzione check_conflicts
# ─────────────────────────────────────────────────────────────
get_procs_on_vm() {
    local vm="$1"
    local result=""
    for nome in "${PROCESSI[@]}"; do
        # Controlla se il container esiste sulla VM specificata
        # docker inspect restituisce 0 se esiste, 1 se non esiste
        if [[ "$vm" == "vm1" ]]; then
            docker inspect "$nome" &>/dev/null && result+="$nome "
        else
            # Per vm2 usiamo SSH per eseguire docker inspect remotamente
            ssh_vm2 "docker inspect $nome &>/dev/null" 2>/dev/null && result+="$nome "
        fi
    done
    # xargs rimuove gli spazi bianchi iniziali/finali dalla stringa
    echo "$result" | xargs || true
}

has_container_on_vm() {
    # Controlla se un container specifico ($2) è presente su una VM ($1)
    # Restituisce 0 (true) o 1 (false) — usato negli if
    local vm="$1"
    local nome="$2"
    if [[ "$vm" == "vm1" ]]; then
        docker inspect "$nome" &>/dev/null
    else
        ssh_vm2 "docker inspect $nome &>/dev/null" 2>/dev/null
    fi
}

# ─────────────────────────────────────────────────────────────
# CHECK_CONFLICTS — verifica se la VM specificata ha un conflitto
# Un conflitto si verifica quando:
#   - lupo e capra sono sulla stessa VM SENZA traghettatore, oppure
#   - capra e cavolo sono sulla stessa VM SENZA traghettatore
# Se il traghettatore è presente non ci sono conflitti perché
# "supervisiona" gli animali e impedisce che si mangino
# ─────────────────────────────────────────────────────────────
check_conflicts() {
    local vm="$1"
    local procs
    procs=$(get_procs_on_vm "$vm")

    # Se il traghettatore è su questa VM → nessun conflitto possibile
    if has_container_on_vm "$vm" "traghettatore" 2>/dev/null; then
        return 0 # 0 = nessun errore = nessun conflitto
    fi

    # Controlla coppia lupo + capra
    if echo "$procs" | grep -q "lupo" && echo "$procs" | grep -q "capra"; then
        echo "lupo e capra insieme senza traghettatore → SIGTERM capra"
        return 1 # 1 = errore = conflitto trovato
    fi

    # Controlla coppia capra + cavolo
    if echo "$procs" | grep -q "capra" && echo "$procs" | grep -q "cavolo"; then
        echo "capra e cavolo insieme senza traghettatore → SIGTERM cavolo"
        return 1
    fi

    return 0 # nessun conflitto
}

# ─────────────────────────────────────────────────────────────
# TRANSFER_CONTAINER — migra fisicamente UN singolo container
# da una VM all'altra tramite la sequenza:
#
#   1. docker commit → crea uno snapshot del container come immagine
#   2. docker save   → esporta l'immagine in un archivio .tar
#   3. scp           → copia il .tar sulla VM di destinazione via SSH
#   4. docker load   → carica l'immagine dal .tar sulla VM di destinazione
#   5. docker run    → avvia il container sulla VM di destinazione
#   6. docker rm     → rimuove il container dalla VM di origine
#
# Infine fa pulizia delle immagini temporanee e del file .tar
# ─────────────────────────────────────────────────────────────
transfer_container() {
    local nome="$1"
    local origin="$2"   # "vm1" o "vm2"
    local dest="$3"     # "vm1" o "vm2"
    local img="${nome}_img"         # nome dell'immagine temporanea
    local tar="${TMP_DIR}/${nome}.tar" # percorso del file tar temporaneo

    log_info "  Trasferimento ${CYAN}${nome}${RESET}: ${origin} → ${dest}"

    if [[ "$origin" == "vm1" ]]; then
        # ── DA VM1 A VM2 ──────────────────────────────────────
        docker commit "$nome" "$img" > /dev/null          # 1. snapshot
        docker save "$img" -o "$tar"                       # 2. esporta in .tar
        scp_to_vm2 "$tar" "$tar"                           # 3. copia su vm2
        ssh_vm2 "docker load -i ${tar} > /dev/null && \
                 docker run -d --name ${nome} --label esercizio=capra_cavoli ${img} sleep infinity > /dev/null"
                                                           # 4. carica + 5. avvia su vm2
        docker rm -f "$nome" > /dev/null                   # 6. rimuove da vm1
        # Pulizia immagini temporanee su entrambe le VM
        docker rmi "$img" > /dev/null 2>&1 || true
        ssh_vm2 "docker rmi ${img} > /dev/null 2>&1 || true"
        # Pulizia file tar su entrambe le VM
        rm -f "$tar"
        ssh_vm2 "rm -f ${tar}" 2>/dev/null || true
    else
        # ── DA VM2 A VM1 ──────────────────────────────────────
        ssh_vm2 "docker commit ${nome} ${img} > /dev/null && \
                 docker save ${img} -o ${tar}"             # 1+2. snapshot + export su vm2
        scp_from_vm2 "$tar" "$tar"                         # 3. copia su vm1
        docker load -i "$tar" > /dev/null                  # 4. carica su vm1
        docker run -d --name "$nome" --label esercizio=capra_cavoli \
            "$img" sleep infinity > /dev/null              # 5. avvia su vm1
        ssh_vm2 "docker rm -f ${nome} > /dev/null"         # 6. rimuove da vm2
        # Pulizia immagini temporanee su entrambe le VM
        docker rmi "$img" > /dev/null 2>&1 || true
        ssh_vm2 "docker rmi ${img} > /dev/null 2>&1 || true"
        # Pulizia file tar su entrambe le VM
        rm -f "$tar"
        ssh_vm2 "rm -f ${tar}" 2>/dev/null || true
    fi
}

# ─────────────────────────────────────────────────────────────
# DISPLAY — funzioni per visualizzare lo stato grafico del gioco
# display_vm() costruisce la stringa per una singola VM
# print_state() stampa il quadro completo con entrambe le VM
# e il simbolo della barca sul lato corretto del fiume
# ─────────────────────────────────────────────────────────────
display_vm() {
    local vm="$1"
    local procs
    procs=$(get_procs_on_vm "$vm")
    local has_barca=""
    # Aggiunge l'indicatore del traghettatore se presente su questa VM
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
    # La barca appare sopra o sotto il fiume a seconda di BARCA_POS
    if [[ "$BARCA_POS" == "vm1" ]]; then
        echo -e "        ${CYAN}  barca${RESET}  ${GRAY}@ vm1${RESET}"
        echo -e "        ${GRAY}═══════ fiume (rete privata) ═══════${RESET}"
    else
        echo -e "        ${GRAY}═══════ fiume (rete privata) ═══════${RESET}"
        echo -e "        ${CYAN}  barca${RESET}  ${GRAY}@ vm2${RESET}"
    fi
    echo -e "  ${BOLD}vm2${RESET} [192.168.56.11]  $(display_vm "vm2")"
    echo ""
}

# ─────────────────────────────────────────────────────────────
# MIGRATE — orchestratore principale di ogni mossa del giocatore
#
# Riceve il nome del processo da spostare (o stringa vuota per
# viaggio vuoto). Coordina i trasferimenti e controlla i conflitti.
#
# Logica:
#   1. Verifica che il processo sia sulla VM corretta
#   2. Trasferisce il processo (se presente)
#   3. Trasferisce SEMPRE il traghettatore
#   4. Aggiorna BARCA_POS e STEPS
#   5. Controlla conflitti sulla VM appena lasciata
#   6. In caso di conflitto offre il rollback automatico
# ─────────────────────────────────────────────────────────────
migrate() {
    local process="${1:-}"  # nome del processo, vuoto = viaggio vuoto
    local origin="$BARCA_POS"
    local destination
    # La destinazione è sempre l'opposto della posizione attuale della barca
    [[ "$origin" == "vm1" ]] && destination="vm2" || destination="vm1"

    # Controlla che il processo richiesto sia effettivamente sulla VM di origine
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

    # Trasferisce il processo scelto (se non è viaggio vuoto)
    if [[ -n "$process" ]]; then
        transfer_container "$process" "$origin" "$destination"
    fi

    # Il traghettatore si sposta SEMPRE, in ogni tipo di mossa
    transfer_container "traghettatore" "$origin" "$destination"

    # Aggiorna lo stato del gioco
    BARCA_POS="$destination"
    STEPS=$((STEPS + 1))
    log_step

    # Controlla conflitti sulla VM che il traghettatore ha appena lasciato
    # (è quella senza supervisione ora)
    local conflict
    if ! conflict=$(check_conflicts "$origin" 2>&1); then
        log_conflict "DISASTRO su ${origin}: ${conflict}"
        log_error "Il viaggio è da rifare, ritorna indietro!"
        print_state
        # Offre il rollback: riporta tutto com'era prima della mossa
        echo -ne "${YELLOW}Vuoi annullare questa mossa? [s/N]: ${RESET}"
        read -r ans
        if [[ "${ans,,}" == "s" ]]; then
            # Rollback: inverte la direzione di ogni transfer appena fatto
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
        # Nessun conflitto: stampa conferma della mossa
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
# Gestisce il ciclo di input/output del gioco:
#   1. Mostra schermata iniziale con regole e comandi
#   2. Entra nel loop infinito (while true)
#   3. Ad ogni iterazione:
#      - Controlla la condizione di vittoria
#      - Legge l'input del giocatore con read
#      - Smista l'input con case/esac
#      - Chiama migrate() con il processo scelto
# ─────────────────────────────────────────────────────────────
play_interactive() {
    clear
    echo -e "\n${BOLD}${CYAN} ════════════════════════════════════════════════════  ${RESET}"
    echo -e "${BOLD}${CYAN}            Indovinello: Lupo, Capra e Cavolo            ${RESET}"
    echo -e "${BOLD}${CYAN}                Versione Docker Multi-VM                 ${RESET}"
    echo -e "${BOLD}${CYAN}   ════════════════════════════════════════════════════  ${RESET}\n"

    echo -e "${BOLD}Regole:${RESET}"
    echo -e "    Sposta tutti i container da vm1 a vm2"
    echo -e "    ${RED}Lupo + Capra${RESET} non possono stare sulla stessa VM senza il traghettatore"
    echo -e "    ${RED}Capra + Cavolo${RESET} non possono stare sulla stessa VM senza il traghettatore"
    echo -e "    Il traghettatore si sposta SEMPRE con te (in ogni mossa)"
    echo -e "    Puoi tornare indietro con '${YELLOW}s${RESET}' se commetti un errore\n"

    echo -e "${BOLD}Comandi disponibili:${RESET}"
    echo -e "  ${CYAN}lupo${RESET}      # porta il lupo sulla sponda opposta"
    echo -e "  ${CYAN}capra${RESET}     # porta la capra sulla sponda opposta"
    echo -e "  ${CYAN}cavolo${RESET}    # porta il cavolo sulla sponda opposta"
    echo -e "  ${CYAN}invio${RESET}     # viaggio vuoto (torna indietro da solo)"
    echo -e "  ${CYAN}q${RESET}         # esci\n"

    print_state

    while true; do
        # ── CONDIZIONE DI VITTORIA ──────────────────────────────
        # Vince quando vm1 è completamente vuota (nessun processo)
        # E il traghettatore è già su vm2 (tutti migrati)
        local vm1_procs
        vm1_procs=$(get_procs_on_vm "vm1")
        if [[ -z "$vm1_procs" && "$BARCA_POS" == "vm2" ]]; then
            echo -e "${GREEN}${BOLD}"
            echo -e " ══════════════════════════════════════════════════════  "
            echo -e "  VITTORIA! Migrazione completata in ${STEPS} mosse!"
            echo -e "    Tutti i container sono su vm2 in sicurezza!"
            echo -e " ══════════════════════════════════════════════════════  "
            echo -e "${RESET}"
            log_ok "lupo, capra, cavolo e traghettatore → tutti su vm2"
            print_state
            exit 0
        fi

        # ── ACQUISIZIONE INPUT ──────────────────────────────────
        # -n evita il newline finale, così il cursore rimane sulla stessa riga
        echo -ne "${CYAN}→ Mossa [barca su ${BARCA_POS}]: ${RESET}"
        read -r input  # -r impedisce l'interpretazione dei backslash

        # ── GESTIONE COMANDI ────────────────────────────────────
        # ${input,,} converte l'input in minuscolo per case-insensitive
        case "${input,,}" in
            q|quit|esci)
                # Uscita pulita dal gioco
                echo "Uscita dal gioco."
                exit 0
                ;;
            ""|invio|vuoto)
                # Stringa vuota (solo Invio) = viaggio vuoto
                migrate ""
                ;;
            lupo|capra|cavolo)
                # Nome di un processo valido → lo migra
                migrate "$input"
                ;;
            *)
                # Qualsiasi altro input non riconosciuto
                log_warn "Comando non riconosciuto: '${input}'"
                echo -e "  Usa: ${CYAN}lupo${RESET} | ${CYAN}capra${RESET} | ${CYAN}cavolo${RESET} | ${CYAN}invio${RESET} | ${CYAN}q${RESET}"
                ;;
        esac
    done
}

# ─────────────────────────────────────────────────────────────
# ENTRYPOINT — punto di ingresso dello script
# Uso case/esac per gestire i parametri passati da riga di comando:
#   --clean / -c  → rimuove tutti i container e file temporanei
#   (nessun param) → avvia il gioco normalmente
#
# Il pattern ${1:-} restituisce $1 se presente, stringa vuota altrimenti
# Questo evita errori se lo script viene chiamato senza argomenti
# ─────────────────────────────────────────────────────────────
case "${1:-}" in
    --clean|-c)
        echo -e "\n${BOLD}==> Pulizia completa${RESET}"
        init_ssh 2>/dev/null || true  # tenta SSH ma non blocca se fallisce
        cleanup
        ;;
    *)
        # Flusso normale: verifica SSH → crea container → avvia il gioco
        init_ssh
        setup
        play_interactive
        ;;
esac

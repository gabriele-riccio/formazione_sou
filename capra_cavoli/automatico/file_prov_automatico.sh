#!/usr/bin/env bash
# ==============================================================================================================================
# file_prov_automatico.sh — Classico esercizio che riprende l'indovinello del lupo,capra e cavolo
# e lo riporta in informatica trasformando gli attori in processi le rive in vm1 e vm2 e il fiume 
# che rappresenta un canale di rete tra le due VM.

#questo è più semplice dato che riguarda solo la parte automatica.

# Questo è un file di provisioning per configurare automaticamente l'ambiente di sistema dopo
# l'avvio delle Macchine Virtuali.
# =============================================================================================================================
# Con questo file faccio in modo che :
# 1. Si installino le  dipendenze minime
# 2. Si creino gli utenti lupo, capra, cavolo
# 3. Si configura 'sudoers' in modo sicuro da avere:
#      - lupo che può inviare SIGTERM SOLO ai processi di capra
#      - capra che può inviare SIGTERM SOLO ai processi di cavolo
#      - traghettatore che gestisce l'orchestratore senza password
# =========================================================================================================================
# ========================================================================================================================
# Per prima cosa aggiorno silenziosamente (-qq) l'elenco dei pacchetti installabili
# e installo alcuni strumenti base(come procps per il comando kill(SIGTERM))
#Faccio poi un ciclo for per creare gli utenti(processi): esso controlla
#se esistono già(in tal caso passa avanti).
#Crea una variabile user che varrà lupo,capra,cavolo e poi a parte traghettatorecambia ogni volta,
#Controlla se lupo,capra etc esistono (controllato con id "$user" che controlla
#se un utente esiste controllando i suoi dati(uid gruppi etc) con il ! nego quindi se non esiste
#procede all'interno del blocco useradd --system --no-create-home --shell "$user":
#che crea un nuovo user di sistema senza cartella home assegnandogli come shell /usr/sbin/nologin in modo
#che nessuno ci faccia l'accesso, e quindi lo salva nell $user cioè il nome dell'utente(lupo,capra,cavolo,).
#Poi faccio la creazione dell'utente admin traghetttatore che invece deve avere una shell reale per lanciare lo script,
#per cui uso shell bin/bash
#Poi configuro 'sudoers' in modo che gli utenti abbiano dei permessi:
#Creo un file di configurazione dentro /etc/sudoers.d con cat
#/etc/sudoers.d/capra_lupo(per cambiare nome, non tocco /etc/sudoers.d direttamente).
#Con questo file dico al sistema chi può "killare" chi senza inserire una password (NOPASSWD).
#In questo modo permetto al lupo di terminare(con kill -15) l'user capra senza password(NOPASSWD),
#all'utente capra di terminare il cavolo (con kill -15 che è Sigterm) senza password(NOPASSWD) e
#all'utente traghettatore di eseguire lo script e controllare tutto da root.

# Imposto poi i permessi corretti per il file sudoers ( altrimenti sudo lo ignora:
#lettura consentita solo al proprietario e al gruppo proprietario e
#faccio un riepilogo finale.

# ================================================================================================================

set -e #Fa in modo di interrompere lo script immediatamente se un qualsiasi comando fallisce, per evitare problemi.

echo "==> [provision] Aggiornamento pacchetti..."
apt-get update -qq
apt-get install -y -qq procps curl vim bash

# ──────────────────────────────────────────────────────────
# Ciclo for per creare i processi
# ──────────────────────────────────────────────────────────

echo "==> [provision] Creazione utenti lupo / capra / cavolo/ traghettatore"


for user in lupo capra cavolo; do
    if ! id "$user" &>/dev/null; then
        # Per il traghettatore potresti volere una shell valida se devi usarlo per lanciare lo script
        useradd --system --no-create-home --shell /usr/sbin/nologin "$user"
        echo "  utente '$user' creato"
    fi
done

if ! id "traghettatore" &>/dev/null; then
    useradd --system --no-create-home --shell /bin/bash traghettatore
    echo "  utente 'traghettatore' creato "
fi


# ──────────────────────────────────────────────────────────
# Permessi sudoers (Configurazione Sicura)
# ──────────────────────────────────────────────────────────
echo "==> [provision] Configurazione sudoers..."

# File dedicato in /etc/sudoers.d/
cat > /etc/sudoers.d/capra_lupo << 'SUDOERS'

#lupo può mandare SIGTERM (kill -15) SOLO ai processi dell'utente 'capra'
lupo ALL=(root) NOPASSWD: /bin/kill -15 --user capra *, /bin/kill -s 15 --user capra *
lupo ALL=(root) NOPASSWD: /usr/bin/kill -15 --user capra *, /usr/bin/kill -s 15 --user capra *

#capra può mandare SIGTERM (kill -15) SOLO ai processi dell'utente 'cavolo'
capra ALL=(root) NOPASSWD: /bin/kill -15 --user cavolo *, /bin/kill -s 15 --user cavolo *
capra ALL=(root) NOPASSWD: /usr/bin/kill -15 --user cavolo *, /usr/bin/kill -s 15 --user cavolo *

# Traghettatore (admin / orchestratore) può eseguire lo script e usare kill liberamente
traghettatore ALL=(ALL) NOPASSWD: /vagrant/file_capra_cavoli.sh
traghettatore ALL=(ALL) NOPASSWD: /bin/kill *, /usr/bin/kill *
SUDOERS

# Imposto poi i permessi corretti per il file sudoers (obbligatorio, altrimenti sudo lo ignora)
chmod 0440 /etc/sudoers.d/capra_lupo

# ──────────────────────────────────────────────────────────
# Riepilogo finale
# ──────────────────────────────────────────────────────────
echo ""
echo "==> [provision] Riepilogo permessi configurati:"
echo "    lupo    → sudo kill -15 --user capra <PID>   (SIGTERM solo su capra)"
echo "    capra   → sudo kill -15 --user cavolo <PID> (SIGTERM solo su cavolo)"
echo "    traghettatore → sudo /vagrant/file_capra_cavoli_automatico.sh (orchestratore)"
echo ""
echo "==> [provision] Completato con successo."


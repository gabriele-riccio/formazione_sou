#!/usr/bin/env bash
# ==========================================================================================================================================
# file_prov_container.sh
# Provisioning: installa Docker e configura la chiave SSH per far comunicare e far migrare i container tra vm1 e vm2.
# Viene eseguito su entrambe le VM (vm1 e vm2) durante il provisioning
# Requisiti:
# - Vagrantfile configurato per condividere la cartella /vagrant tra le VM
# - vm1 genera una coppia di chiavi SSH e salva la pubblica in /vagrant/vm1_pub_key
# - vm2 legge la chiave pubblica da /vagrant/vm1_pub_key e la aggiunge agli authorized_keys
# Note:
# - Assicurarsi che il provisioning sia idempotente (può essere eseguito più volte senza errori)
# - Il provisioning deve essere eseguito con privilegi di root (sudo) per installare pacchetti e configurare SSH

# Dichiarazione variabili per i percorsi della chiave ssh e l'archivio per salvare la chiave.
# poi c'è il classico aggiotnamento dei pacchetti(ca-certificates,curl,gnupg,lsb-release e openssh)
# Poi rimuovo(dopo tante prove)il file che bloccava la comunicazione tra le 2 vm,
# che blocca PasswordAuthentication e PubkeyAuth (presente sulle immagini Ubuntu cloud) con rm -f etc
# Mi riscrivo la configutazione SSH pulita e riavvio la configurazione.

# Dopo ciò installo Docker e tutti i suoi pacchetti che servoni per la creazione e la migrazione dei pacchetti, impostando che
# venga eseguito con i privilegi da root(per scaricarli) con usermod -aG docker vagrant per consentire a un utente 
# di gestire Docker senza dover digitare ogni volta sudo.

# Poi ho gestito la configurazione della comunicazione SSH tra le due macchine virtuali.
# Il provisioning viene eseguito su entrambe le VM con lo stesso script, quindi la prima cosa che facco è preparare 
# la cartella .ssh nella home dell'utente vagrant, assegnandole i permessi corretti con chmod 700 "$SSH_DIR" sa root.

# Su vm1 genero una coppia di chiavi crittografiche di tipo ED25519 (un algoritmo moderno basato su curve ellittiche che ho trovato
# su internet, più sicuro e compatto rispetto al classico RSA(che usa la fattorizzazione in dei numeri primi).
# La chiave viene generata senza passphrase perché deve funzionare in modo automatico all'interno degli script, senza intervento umano.
# La chiave privata rimane su vm1, mentre la chiave pubblica viene copiata nella cartella /vagrant che è condivisa tra l'host Mac e le VM,
# creata automaticamente da Vagrant tramite VirtualBox.
# Essa è visibile sia da vm1 che da vm2 come se fosse un disco comune, il che mi permette di usarla come canale sicuro per trasferire 
# la chiave pubblica senza dover aprire connessioni di rete prima che SSH sia configurato.

# Inserisco su vm2 un piccolo loop di attesa: aspettiamo fino a 30 secondi che la chiave pubblica appaia nella cartella condivisa.
# Questo serve a gestire eventuali casi in cui il provisioning delle due VM avvenga quasi in parallelo. 

# Una volta che il file è disponibile, lo aggiunge al file authorized_keys di vagrant che è la lista delle chiavi pubbliche che SSH su vm2 considera fidate. 
# Da quel momento in poi, ogni volta che vm1 si connette a vm2 presentando la propria chiave privata, vm2 la confronta con la pubblica che ha in authorized_keys
# e se corrispondono la connessione viene accettata senza nessuna password.
# Il tutto si chiude con un riavvio di sshd per caricare la nuova configurazione.
# Il risultato finale è una comunicazione completamente automatica e sicura tra le due VM, basata su crittografia asimmetrica, 
# che è esattamente quello che serve per far migrare i container Docker da una sponda all'altra del fiume.
# ==========================================================================================================================================
set -e #Per fare in modo che se ci sono errori lo script si interrompa.

HOSTNAME_CURR=$(hostname)
SSH_DIR="/home/vagrant/.ssh"
SHARED_KEY="/vagrant/vm1_pub_key"

echo "==> [provision] [$HOSTNAME_CURR] Aggiornamento pacchetti..."
apt-get update -qq
apt-get install -y -qq \
    ca-certificates curl gnupg lsb-release \
    openssh-client openssh-server

# ─────────────────────────────────────────────────────────────
# FIX SSH: rimuove il file cloud-img che blocca l'autenticazione
# e abilita esplicitamente PubkeyAuthentication
# ─────────────────────────────────────────────────────────────
echo "==> [provision] [$HOSTNAME_CURR] Configurazione SSH..."

# Rimuove il file che blocca PasswordAuthentication e PubkeyAuth
# (presente sulle immagini Ubuntu cloud)
rm -f /etc/ssh/sshd_config.d/60-cloudimg-settings.conf

# Scrive configurazione SSH pulita
cat > /etc/ssh/sshd_config.d/99-vagrant.conf << 'SSHCFG'
PubkeyAuthentication yes
PasswordAuthentication no
AuthorizedKeysFile .ssh/authorized_keys
SSHCFG

systemctl restart sshd
echo "==> [provision] [$HOSTNAME_CURR] SSH configurato"

# ─────────────────────────────────────────────────────────────
# INSTALLAZIONE DOCKER
# ─────────────────────────────────────────────────────────────
echo "==> [provision] [$HOSTNAME_CURR] Installazione Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -qq
apt-get install -y -qq \
    docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin

usermod -aG docker vagrant
systemctl enable docker
systemctl start docker

# ─────────────────────────────────────────────────────────────
# SETUP SSH KEY vm1 → vm2
# vm1 genera la coppia di chiavi e salva la pubblica in /vagrant
# vm2 legge la pubblica da /vagrant e la aggiunge agli authorized_keys
# ─────────────────────────────────────────────────────────────
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown vagrant:vagrant "$SSH_DIR"

if [[ "$HOSTNAME_CURR" == "vm1" ]]; then
    echo "==> [provision] [vm1] Generazione coppia di chiavi SSH..."

    # Genera chiave ED25519 dedicata per vm1→vm2
    sudo -u vagrant ssh-keygen \
        -t ed25519 \
        -f "${SSH_DIR}/vm1_to_vm2" \
        -N "" \
        -C "vm1_to_vm2_capra_cavoli" \
        -q

    # Salva la pubblica nella cartella condivisa /vagrant
    cp "${SSH_DIR}/vm1_to_vm2.pub" "$SHARED_KEY"
    chmod 644 "$SHARED_KEY"

    echo "==> [provision] [vm1] Chiave pubblica salvata in /vagrant/vm1_pub_key"

elif [[ "$HOSTNAME_CURR" == "vm2" ]]; then
    echo "==> [provision] [vm2] Aggiunta chiave pubblica di vm1..."

    # Aspetta che vm1 abbia creato il file (al massimo 30 secondi)
    for i in $(seq 1 30); do
        [[ -f "$SHARED_KEY" ]] && break
        echo "  Attendo /vagrant/vm1_pub_key... ($i/30)"
        sleep 1
    done

    if [[ -f "$SHARED_KEY" ]]; then
        # Aggiunge la chiave agli authorized_keys di vagrant
        cat "$SHARED_KEY" >> "${SSH_DIR}/authorized_keys"
        chmod 600 "${SSH_DIR}/authorized_keys"
        chown vagrant:vagrant "${SSH_DIR}/authorized_keys"
        # Riavvia sshd per caricare la nuova configurazione
        systemctl restart sshd
        echo "==> [provision] [vm2] Chiave di vm1 aggiunta agli authorized_keys"
    else
        echo "==> [provision] [vm2] WARN: /vagrant/vm1_pub_key non trovata!"
    fi
fi

# ─────────────────────────────────────────────────────────────
# CARTELLE DI LAVORO
# ─────────────────────────────────────────────────────────────
mkdir -p /tmp/migrazione
chmod 777 /tmp/migrazione

# Copia lo script nella home di vagrant
if [[ -f /vagrant/file_script_completo.sh ]]; then
    cp /vagrant/file_script_completo.sh /home/vagrant/
    chmod +x /home/vagrant/file_script_completo.sh
    chown vagrant:vagrant /home/vagrant/file_script_completo.sh
fi

echo ""
echo "==> [provision] [$HOSTNAME_CURR] Docker $(docker --version)"
echo "==> [provision] [$HOSTNAME_CURR] Completato."

#!/usr/bin/env bash
# ==============================================================================
# file_prov_container.sh — Provisioning: installa Docker e configura SSH tra VM
# ==============================================================================
set -e

echo "==> [provision] Aggiornamento pacchetti..."
apt-get update -qq
apt-get install -y -qq ca-certificates curl gnupg lsb-release openssh-client

echo "==> [provision] Installazione Docker..."
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

# ─────────────────────────────────────────────────────────────────────────────
# CONFIGURAZIONE SSH VM1 → VM2
#
# Strategia: vm1 genera una coppia di chiavi durante il provisioning e
# salva la chiave pubblica in /vagrant (cartella condivisa).
# vm2 legge la chiave pubblica dalla cartella condivisa e la aggiunge
# ai propri authorized_keys.
#
# Vagrant esegue il provisioning nell'ordine: vm1 prima, vm2 dopo.
# Quindi quando vm2 viene provisionata, la chiave pubblica di vm1 è già
# disponibile in /vagrant/vm1_pub_key.
# ─────────────────────────────────────────────────────────────────────────────

HOSTNAME_CURR=$(hostname)
SSH_DIR="/home/vagrant/.ssh"
SHARED_PUB_KEY="/vagrant/vm1_pub_key"

if [[ "$HOSTNAME_CURR" == "vm1" ]]; then
    echo "==> [provision] vm1: generazione chiave SSH per comunicazione con vm2..."

    # Genera coppia di chiavi RSA dedicata per vm1→vm2
    sudo -u vagrant ssh-keygen \
        -t rsa -b 2048 \
        -f "${SSH_DIR}/vm2_key" \
        -N "" \
        -C "vm1_to_vm2_esercizio" \
        -q

    # Salva la chiave pubblica nella cartella condivisa /vagrant
    # così vm2 può leggerla durante il proprio provisioning
    cp "${SSH_DIR}/vm2_key.pub" "$SHARED_PUB_KEY"
    chmod 644 "$SHARED_PUB_KEY"

    echo "==> [provision] vm1: chiave SSH generata e condivisa"

elif [[ "$HOSTNAME_CURR" == "vm2" ]]; then
    echo "==> [provision] vm2: aggiunta chiave pubblica di vm1..."

    # Legge la chiave pubblica che vm1 ha salvato in /vagrant
    if [[ -f "$SHARED_PUB_KEY" ]]; then
        cat "$SHARED_PUB_KEY" >> "${SSH_DIR}/authorized_keys"
        chmod 600 "${SSH_DIR}/authorized_keys"
        chown vagrant:vagrant "${SSH_DIR}/authorized_keys"
        echo "==> [provision] vm2: chiave pubblica di vm1 aggiunta agli authorized_keys"
    else
        echo "==> [provision] WARN: chiave pubblica di vm1 non trovata in /vagrant"
        echo "==> [provision] Assicurati che vm1 venga provisionata prima di vm2"
    fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# Copia lo script e crea cartella tmp
# ─────────────────────────────────────────────────────────────────────────────
mkdir -p /tmp/migrazione
chmod 777 /tmp/migrazione

cp /vagrant/file_script_container.sh /home/vagrant/
chmod +x /home/vagrant/file_script_container.sh
chown vagrant:vagrant /home/vagrant/file_script_container.sh

echo ""
echo "==> [provision] Docker installato con successo!"
docker --version
echo "==> [provision] Completato su ${HOSTNAME_CURR}."
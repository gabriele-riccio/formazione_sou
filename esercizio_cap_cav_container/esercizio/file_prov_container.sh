#!/usr/bin/env bash
# ==============================================================================
# file_prov_capra_cavoli.sh — Provisioning: installa Docker sulle VM
# ==============================================================================
set -e

echo "==> [provision] Aggiornamento pacchetti..."
apt-get update -qq
apt-get install -y -qq \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "==> [provision] Installazione Docker..."
# Aggiunge la chiave GPG ufficiale Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Aggiunge il repository Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -qq
apt-get install -y -qq \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Aggiunge l'utente vagrant al gruppo docker (per usarlo senza sudo)
usermod -aG docker vagrant

# Avvia e abilita Docker
systemctl enable docker
systemctl start docker

# Copia lo script dell'esercizio nella VM
cp /vagrant/file_script_container.sh /home/vagrant/
chmod +x /home/vagrant/file_script_container.sh

echo ""
echo "==> [provision] Docker installato con successo!"
docker --version
echo "==> [provision] Completato."
mkdir -p /tmp/migrazione
chmod 777 /tmp/migrazione

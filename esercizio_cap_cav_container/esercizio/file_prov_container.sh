#!/usr/bin/env bash
# ==============================================================================
# file_prov_container.sh — Provisioning: installa Docker sulle VM
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
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Aggiunge vagrant al gruppo docker (niente sudo)
usermod -aG docker vagrant

# Avvia Docker
systemctl enable docker
systemctl start docker

# Copia la chiave SSH di vm2 in una posizione locale con permessi corretti
# (la cartella /vagrant è condivisa ma non preserva i permessi Unix)
mkdir -p /tmp/migrazione

# Copia lo script nella home di vagrant
cp /vagrant/file_script_container.sh /home/vagrant/
chmod +x /home/vagrant/file_script_container.sh
chown vagrant:vagrant /home/vagrant/file_script_container.sh

echo ""
echo "==> [provision] Docker installato con successo!"
docker --version
echo "==> [provision] Completato."

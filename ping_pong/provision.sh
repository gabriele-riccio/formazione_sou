#Questo è il file di provisioning
#Attraverso questo file l ho inserito come path per ogni VM che ho creato tramite il vagrantfile.
#Questo file ha il compito generale di far installare Docker nelle due VM al momento del Vagrant Up e poi
#scarica in anticipo l'immagine DOCKER ealen/echo-server per non avere ritardi nella prima migrazione.
#
#!/usr/bin/env bash
set -e

echo "==> Installazione Docker"

apt-get update -qq
apt-get install -y -qq \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -qq
apt-get install -y -qq docker-ce docker-ce-cli containerd.io

usermod -aG docker vagrant

echo "==> Pull immagine echo-server"
docker pull ealen/echo-server

echo "==> Docker installato: $(docker --version)"


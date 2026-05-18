#!/usr/bin/env bash

#Questo è il file di provisioning
#Attraverso questo file che ho inserito come path per ogni VM che ho creato tramite il vagrantfile, faccio installare.
#Docker nelle due VM al momento del Vagrant up e poi scarica in anticipo l'immagine DOCKER ealen/echo-server 
#da DockerHub per non avere ritardi nella prima migrazione.

#Prima cosa ,come ogni script bash, inserisco lo shebang iniziale.
#Stampo il messaggio per l'inizio dell'installazione di Docker nelle due macchine, dopo aver messo una sorta di sicurezza 
#con set -e che fa in modo che lo script si fermi appena incontra un errore.
#apt-get update -qq aggiorna la lista dei pacchetti disponibili, e lo fa in maniera silente qq in modo da non riempire il terminale
#apt-get install -y -qq  installa i pacchetti di base che servono a Ubuntu per scaricare file da internet 
#in modo sicuro e gestire le chiavi crittografiche( ca-certificates \curl \gnupg \lsb-releasecon) con -y che risponde direttamente
#yes alle conferme di installazione.

#Poi dico ad ubuntu di installare la versione più recente di Docker fidandosi dei server Docker, creando prima con
#install -m 0755 -d /etc/apt/keyrings una nuova cartella di sistema /etc/apt/keyrings con permessi di accesso per file e directory 
#0755(cioè di lettura scrittura ed esecuzione per proprietario e gruppo e sola lettura ed esecuzione per gli altri)
#Inoltre scrivo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \ | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 
#dicendo di usare curl per scaricare la chiave crittografica ufficiale di Docker 
#e passarla al programma gpg per decodificarla e salvarla nella cartella creata prima.
#Con chmod a+r /etc/apt/keyrings/docker.gpg mi assicuro che la chiave appena salvata nella cartella sia leggibile a tutti gli utenti(a+r).

#Poi attraverso echo "deb etc ho creato il link giusto per scaricare docker sulla mia distribuzione ubuntu, e lo salvo su un
#file di testo docker.list.

#Dopodichè avviene l'effettiva installazione di Docker sulle VM, installando i componenti principali di Docker 
#(il motore Community Edition, l'interfaccia a riga di comando e il gestore dei container).

#N.B Con 'usermod usermod -aG docker vagrant' aggiungo l'utente vagrant al gruppo di sistema docker. 
#Questo permetterà quando entrerò nella macchina di lanciare i comandi Docker normalmente, 
#senza dover scrivere 'sudo' ogni singola volta.

#Poi non mi resta che preparare l'esercizio con una stampa di avviso che appunto avvisa che sta scaricando 
#in anticipo l'immagine ealen/echo-server del container da Docker Hub.
#In questo modo avendola già salvata sul disco, la migrazione da un nodo all'altro sarà istantanea.


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


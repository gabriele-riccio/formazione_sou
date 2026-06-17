# 🚀 DevOps Academy 6 - SOURCESENSE
Benvenuto/a nella mia repository dedicata all'Academy DevOps 6!
Questa repo è il mio diario di bordo: qui raccolgo tutti gli appunti, gli script, gli esercizi pratici e i progetti che sto sviluppando durante il mio percorso di formazione per diventare DevOps Engineer.

## 🎯 Obiettivo del Progetto
L'obiettivo di questa repository è documentare la mia progressione tecnica, partendo dalle basi dell'amministrazione di sistema (Linux/Bash), passando per il versioning (Git), fino ad arrivare alle tecnologie di containerizzazione, automazione e Cloud.

## 📂 Struttura della Repository
La repository è organizzata in cartelle tematiche per facilitare la navigazione. Ogni cartella contiene i propri esercizi e, dove necessario, un README specifico.

* **`/linux-bash`** 🐧
    * Comandi di base del terminale.
    * Scripting Bash (es. automazione task, cicli, variabili).
    * Filtri e manipolazione testo avanzata (`grep`, `awk`, `sed`, `cut`).

* **`/git-github`** 🐙
    * Esercizi sulla gestione del versioning.
    * Risoluzione di conflitti (Merge Conflicts).

* **`/vagrant`** 📦
    * Basi di Vagrant: Vagrantfile, box, `vagrant up/ssh/halt/destroy`.
    * Provisioning automatico delle VM (script bash) all'avvio.
    * Setup mono-VM (Rocky Linux 9, box `generic/rocky9`) per i laboratori Ansible.
    * Setup multi-VM (2 VM Ubuntu in rete privata con IP statici) per gli esercizi di migrazione Docker tra macchine diverse.

* **`/docker`** 🐳
    * Esercizi di livello base: immagini, networking, volumi, stack multi-container.
    * Livello intermedio: stack con Docker Compose (Flask + Nginx + Redis).
    * Livello avanzato (in corso): healthcheck, resource limits, utenti non-root.
    * **Esercizio "Ping Pong"**: migrazione di un'immagine Docker avanti e indietro tra due VM (`docker commit` → `docker save` → `scp` → `docker load` → `docker run`), usando Vagrant per orchestrare le 2 macchine.
    * **Esercizio "Capra e Cavoli"**: variante del celebre rompicapo logico, applicata alla migrazione reale di container tra due VM collegate in rete privata, rispettando i vincoli del puzzle originale ad ogni spostamento.

* **`/jenkins`** ⚙️
    * Concetti di CI/CD, architettura master/agent.
    * Scrittura di Jenkinsfile e pipeline.
    * Integrazione Jenkins + Ansible (credenziali SSH, Ansible Vault, inventory dinamici).
    * Integrazione Jenkins + Kubernetes (deploy con Helm, Pod Template, pattern GitOps).

* **`/ansible`** 🤖
    * Corso da zero su Control Node (Mac) + Managed Node (VM Rocky Linux 9).
    * Lezioni 1-7 completate (playbook, inventory, variabili, facts, handler, condizioni, loop, template, ruoli).
    * Prossimi argomenti: Ansible + Docker, livello avanzato (Vault, error handling) e Ansible + Jenkins.

* **`/kubernetes`** ☸️
    * **Step 0** Setup locale di un cluster con MiniKube, Kind e K3s (MacBook + VM Ubuntu).
    * Creazione di un namespace dedicato (`formazione-sou`) su K3s.

* **`/progetto-integrato` Ansible-Docker-Jenkins** 🎯 *(in corso...)*
    * **Step 1**: provisioning di una VM Rocky Linux 9 con Vagrant, installazione di Docker/Podman via Ansible, creazione di una rete Docker/Podman con IP statici, deploy di un Jenkins Master e di un Jenkins Agent (collegato via JNLP) interamente automatizzato con Ansible.
    * Esercizio riepilogativo che unisce Vagrant, Ansible, Docker e Jenkins in un'unica pipeline di automazione.

## 🛠️ Strumenti e Tecnologie Utilizzate
Attualmente sto lavorando e facendo pratica con:
- **OS:** Ubuntu / Linux / Bash
- **VCS:** Git & GitHub
- **Scripting & CLI:** Bash, Vim/Nano/Joe
- **Virtualizzazione:** Vagrant, VirtualBox
- **Containerizzazione:** Docker, Docker Compose
- **CI/CD:** Jenkins
- **Automazione/Configuration Management:** Ansible
- **Orchestrazione:** Kubernetes (MiniKube, Kind, K3s)
- *(Aggiungerò man mano altro: Podman, AWS, Terraform...)*

---
*Nota: Questa repository è un cantiere aperto ("Work in Progress"). Alcuni argomenti (es. Docker avanzato, lo Step 1 del progetto integrato Vagrant+Ansible+Docker+Jenkins) sono ancora in fase di completamento. I file e le strutture verranno aggiornati costantemente parallelamente all'avanzamento dell'Academy.*


# Capra e Cavoli — DevOps Edition

Reinterpretazione del classico indovinello medievale in chiave DevOps/Sysadmin.
Lupo, capra e cavolo diventano processi Linux. Le sponde del fiume diventano macchine virtuali. Il fiume diventa un network bridge TCP.

![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-21%20alle%2010.09.49.png)

---

## Indovinello originale

Un traghettatore deve portare **lupo**, **capra** e **cavolo** dall'altra parte di un fiume. La barca regge solo lui più un elemento alla volta. Il lupo mangia la capra se lasciati soli; la capra mangia il cavolo se lasciata sola con lui.

**Soluzione classica:**
1. Porta la pecora sull'altra sponda, torna solo.
2. Porta il cavolo, riporta indietro la capra.
3. Porta il lupo, torna solo.
4. Porta la capra.

---

## Idea di fondo

Ogni elemento dell'indovinello diventa un'entità informatica reale:

| Elemento storia | Ruolo | Tipo | Comportamento |
|---|---|---|---|
| **Lupo** | `lupo` `PID-001` | Processo | Invia `SIGTERM` a `capra` se lasciato solo con lei |
| **Capra** | `capra` `PID-002` | Processo | Invia `SIGTERM` a `cavolo`; viene terminata da `lupo` |
| **Cavolo** | `cavolo` `PID-003` | Processo | Passivo — convive con `lupo` senza problemi |
| **Riva di partenza** | `vm1` | Virtual Machine | Nodo sorgente, ospita i processi inizialmente |
| **Riva di arrivo** | `vm2` | Virtual Machine | Nodo destinazione, riceve i processi migrati |
| **Fiume** | Network bridge `TCP/river` | Infrastruttura | Canale che separa le due VM |
| **Barca** | Ferry container | Container Docker | Trasporta un processo alla volta |
| **Traghettatore** | Admin / orchestratore | Supervisore | Sempre presente col ferry; la sua presenza neutralizza qualsiasi conflitto |

### Vincoli di runtime

```
SIGTERM: lupo  →  capra    (se soli sulla stessa VM senza admin)
SIGTERM: capra →  cavolo   (se soli sulla stessa VM senza admin)
OK:      lupo  +  cavolo   (nessun conflitto, possono coesistere)
```

> La presenza dell'admin (dentro il ferry) su una VM la rende sicura per qualunque coppia di processi.

---

## Struttura del progetto

├── Vagrantfile         # configurazione VM (Ubuntu 20.04, porta 8080)
├── provisioner_Ansible.yml        # provisioner Ansible(playbook)
├── index_file/
│   └── Screenshoot 2026-05....png      # Screenshoot per le immagini di output
│   └── Screenshoot 2026-05....png      # Screenshoot per le immagini di output
│   └── Screenshoot 2026-05....png      # Screenshoot per le immagini di output
│
├── files/
│   └── index.html      # portfolio personale stile Sourcesense
│
└── README.md          #Readme di spiegazione generale

├── Vagrantfile                        # Vagrantfile per la modalità interattiva (usa file_prov_capra_cavoli.sh)
├── Vagrantfile_automatico             # Vagrantfile per la modalità automatica (usa file_prov_automatico.sh)
│
├── file_capra_cavoli.sh               # Script principale — modalità automatica + interattiva
├── file_capra_cavoli_automatico.sh    # Script solo automatico (senza modalità --play)
│
├── file_prov_capra_cavoli.sh          # Provisioning per lo script completo
└── file_prov_automatico.sh            # Provisioning per lo script automatico

---
## Architettura

```
┌────────────────────────────────────────────────────────────────────┐
│                      ORCHESTRATORE / ADMIN                         │
│            (supervisore presente dove si trova il ferry)           │
└────────────────────────┬───────────────────────────────────────────┘
                         │ gestisce
           ┌─────────────┼─────────────┐
           ▼             ▼             ▼
     ┌──────────┐  ┌──────────────────┐  ┌──────────┐
     │   vm1    │  │      Barca       │  │   vm2    │
     │ (Nodo di │  │    capienza: 1   │  │ (Nodo di │
     │ partenza)│  │                  │  │  arrivo) │
     └──────────┘  └──────────────────┘  └──────────┘
           │                                   │
           └──────────── TCP/river ────────────┘
                       (network bridge)
```

---


## Algoritmo di migrazione — 7 step

La strategia usa la **capra come zavorra**: viene spostata per prima, poi riportata indietro ogni volta che si carica uno degli altri due, per non lasciarla mai sola con un altro processo.

### Stato iniziale

```
vm1: [lupo, capra, cavolo]
vm2: []
```

### Step 1 — capra → vm2

```
vm1: [lupo, cavolo]     ✓ lupo + cavolo: nessun conflitto
vm2: [capra]
```

### Step 2 — ferry vuoto → vm1

```
vm1: [lupo, cavolo]     admin torna a vm1
vm2: [capra]
```

### Step 3 — cavolo → vm2

```
vm1: [lupo]             processo isolato, ok
vm2: [cavolo, capra]    admin presente, nessun conflitto
```

### Step 4 — capra → vm1  

```
vm1: [capra, lupo]      admin presente
vm2: [cavolo]           processo isolato, ok
```

> Se la capra restasse con cavolo su vm2 e il ferry tornasse vuoto → scatta `SIGTERM`. La soluzione è riportarla su vm1.

### Step 5 — lupo → vm2

```
vm1: [capra]            processo isolato, ok
vm2: [lupo, cavolo]     nessun conflitto
```

### Step 6 — ferry vuoto → vm1

```
vm1: [capra]            admin sta tornando
vm2: [lupo, cavolo]     nessun conflitto
```

### Step 7 — capra → vm2 — migrazione completata

```
vm1: []
vm2: [lupo, cavolo, capra]   ✓ tutti i processi su vm2
```

---
## Avvio rapido

```bash
# Creo la cartella per l'esercizio e due sottocartelle per le 2 modalità

mkdir capra_cavoli
cd capra_cavoli
mkdir automatico
mkdir manuale
```
**Modalità automatica**

Lo script esegue in autonomia la sequenza ottimale di 7 passi.  
Viene stampato ad ogni step lo stato delle due VM, la posizione della barca e il processo in transito.

```bash
# Passo nella cartella automatico
cd automatico

# Rendo lo script eseguibile
chmod +x file_capra_cavoli_automatico.sh

# Avvia le VM con provisioning automatico
vagrant up

# Entra nella vm1 e lancia lo script
vagrant ssh vm1
bash /vagrant/file_capra_cavoli_automatico.sh

```
**OUTPUT**
![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-22%20alle%2016.59.54.png)
![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-22%20alle%2017.00.08.png)

**Modalità interattiva**

Disponibile **solo** in `file_capra_cavoli.sh` tramite il flag `--play` (o `-p`).  
L'utente sceglie a ogni turno quale processo caricare sulla barca. Se la mossa genera un conflitto, lo script stampa un errore e chiede di correggere.

```bash

#Passo in modalità manuale
cd manuale

# Avvia le VM
vagrant up

# Entra nella vm1
vagrant ssh vm1

# Avvia lo script in modalità automatica
bash /vagrant/file_capra_cavoli.sh

# Oppure in modalità interattiva
bash /vagrant/file_capra_cavoli.sh --play
```

**OUTPUT**

![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-22%20alle%2017.01.35.png)
![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-22%20alle%2017.01.53.png)
![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-22%20alle%2017.02.04.png)
![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-22%20alle%2017.02.14.png)
![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-22%20alle%2017.02.27.png)
![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-22%20alle%2017.02.40.png)
![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-22%20alle%2017.02.48.png)
![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-22%20alle%2017.02.57.png)
![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-22%20alle%2017.03.04.png)


Comandi disponibili durante il gioco:

| Input      | Effetto                                  |
|------------|------------------------------------------|
| `lupo`     | Carica il lupo sulla barca               |
| `capra`    | Carica la capra sulla barca              |
| `cavolo`   | Carica il cavolo sulla barca             |
| *(invio)*  | Viaggia vuoto (solo traghettatore)       |
| `q`        | Esce dal gioco                           |

In caso di mossa errata lo script segnala il conflitto con `[ERR]` e blocca l'esecuzione richiedendo un rollback.

![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-22%20alle%2017.03.21.png)
![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-22%20alle%2017.03.28.png)
![prima parte terminale](capra_cavoli_img/Screenshot%202026-05-22%20alle%2017.03.49.png)


---


## Provisioning

Entrambi i file di provisioning (`file_prov_capra_cavoli.sh` e `file_prov_automatico.sh`) eseguono le stesse operazioni su ogni VM al primo avvio:

1. **Aggiornamento pacchetti** — installa `procps`, `curl`, `vim`, `bash`
2. **Creazione utenti di sistema** — `lupo`, `capra`, `cavolo` (nologin) e `traghettatore` (shell bash)
3. **Configurazione sudoers** — permessi granulari in `/etc/sudoers.d/capra_lupo`:

```
lupo        → sudo kill -15 --user capra   (SIGTERM solo su capra)
capra       → sudo kill -15 --user cavolo  (SIGTERM solo su cavolo)
traghettatore → sudo /vagrant/file_capra_cavoli.sh (orchestratore completo)
```

---

## Vincoli di runtime e conflitti

| Coppia sulla stessa VM | Supervisore presente | Esito         |
|------------------------|----------------------|---------------|
| `lupo` + `capra`       | No                   | ❌ SIGTERM → capra  |
| `capra` + `cavolo`     | No                   | ❌ SIGTERM → cavolo |
| `lupo` + `cavolo`      | No                   | ✅ Sicuro     |
| qualsiasi coppia       | Sì (admin/ferry)     | ✅ Sicuro     |

Nella modalità interattiva, ogni mossa viene validata da `check_conflicts()` prima di essere applicata. In caso di conflitto viene stampato `[ERR] CONFLITTO su <vm>` e lo script richiede un rollback(ripetere da capo).



---

## Rete

| VM | Hostname | IP |
|---|---|---|
| vm1 | vm1 | 192.168.56.10 |
| vm2 | vm2 | 192.168.56.11 |

Le due VM comunicano tramite rete privata host-only (VirtualBox). Il network bridge `TCP/river` rappresenta il canale di trasporto del ferry container tra i due nodi.

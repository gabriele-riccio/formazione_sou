# Capra e Cavoli — Container Ferry Puzzle

> Il classico indovinello del lupo, della capra e del cavolo reinterpretato come migrazione di processi tra due virtual machine attraverso un network bridge.

![Shell](https://img.shields.io/badge/Shell-Bash-blue) ![Vagrant](https://img.shields.io/badge/IaC-Vagrant-orange) ![Docker](https://img.shields.io/badge/Container-Docker-green)

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
| **Lupo** | `lupo` `PID-001` | Processo | Invia `SIGKILL` a `capra` se lasciato solo con lei |
| **Capra** | `capra` `PID-002` | Processo | Invia `SIGTERM` a `cavolo`; viene terminata da `lupo` |
| **Cavolo** | `cavolo` `PID-003` | Processo | Passivo — convive con `lupo` senza problemi |
| **Riva di partenza** | `vm1` | Virtual Machine | Nodo sorgente, ospita i processi inizialmente |
| **Riva di arrivo** | `vm2` | Virtual Machine | Nodo destinazione, riceve i processi migrati |
| **Fiume** | Network bridge `TCP/river` | Infrastruttura | Canale che separa le due VM |
| **Barca** | Ferry container | Container Docker | Trasporta un processo alla volta |
| **Traghettatore** | Admin / orchestratore | Supervisore | Sempre presente col ferry; la sua presenza neutralizza qualsiasi conflitto |

### Vincoli di runtime

```
SIGKILL: lupo  →  capra    (se soli sulla stessa VM senza admin)
SIGTERM: capra →  cavolo   (se soli sulla stessa VM senza admin)
OK:      lupo  +  cavolo   (nessun conflitto, possono coesistere)
```

> La presenza dell'admin (dentro il ferry) su una VM la rende sicura per qualunque coppia di processi.

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
     │   vm1    │  │  ferry container │  │   vm2    │
     │ (Nodo di │  │    capienza: 1   │  │ (Nodo di │
     │ partenza)│  │                  │  │  arrivo) │
     └──────────┘  └──────────────────┘  └──────────┘
           │                                   │
           └──────────── TCP/river ────────────┘
                       (network bridge)
```

---

## Struttura dei file

```
.
├── Vagrantfile                  — definisce vm1 e vm2 (Ubuntu 20.04, rete host-only)
├── file_capra_cavoli.sh         — script principale: migrazione automatica o interattiva
└── file_prov_capra_cavoli.sh    — provisioning: utenti, sudoers, dipendenze
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

### Step 4 — capra → vm1 ⚠️ la mossa chiave

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

## Permessi sudoers

Il provisioning configura i kill-rights in `/etc/sudoers.d/ferry-puzzle`, replicando i conflitti dell'indovinello a livello di sistema:

```bash
# lupo può mandare SIGKILL solo ai processi dell'utente capra
lupo  ALL=(root) NOPASSWD: /bin/kill -9  --user capra  *

# capra può mandare SIGTERM solo ai processi dell'utente cavolo
capra ALL=(root) NOPASSWD: /bin/kill -15 --user cavolo *

# vagrant (admin/orchestratore) può eseguire lo script e usare kill liberamente
vagrant ALL=(ALL) NOPASSWD: /vagrant/file_capra_cavoli.sh
vagrant ALL=(ALL) NOPASSWD: /bin/kill *
```

---

## Utilizzo

### 1. Avvio delle VM

```bash
vagrant up
```

Crea e provisiona `vm1` e `vm2` con Ubuntu 20.04, rete privata host-only (`192.168.56.10` / `192.168.56.11`), utenti di sistema e regole sudoers.

### 2. Connessione al nodo di partenza

```bash
vagrant ssh vm1
```

### 3. Esecuzione

```bash
# Soluzione automatica in 7 step con log colorato
sudo /vagrant/file_capra_cavoli.sh

# Modalità interattiva passo per passo
sudo /vagrant/file_capra_cavoli.sh --play

# Aiuto
sudo /vagrant/file_capra_cavoli.sh --help
```

### Output atteso (modalità automatica)

```
Container Ferry — River Crossing Puzzle
Migrazione automatica in 7 step

$ orchestrator init -- puzzle v1.0
$ processes spawned on vm1: [lupo:PID-001, capra:PID-002, cavolo:PID-003]
...
── step 1 ──────────────────────────────
$ docker run --migrate capra  vm1 → vm2
[OK] capra deployed su vm2

  vm1  lupo  cavolo
        ferry  @ vm2
        ────── network bridge ──────
  vm2  capra

...

[SUCCESS] Migrazione completata in 7 step!
[OK] tutti i processi attivi su vm2
[OK] vm1 offline — nessun processo residuo
```

---

## Rilevamento conflitti

Lo script verifica lo stato di ogni VM dopo ogni spostamento. Se una coppia incompatibile si trova sola (senza admin), il sistema emette un errore e termina:

```
[ERR] CONFLITTO su vm1: capra consuma cavolo → SIGTERM cavolo:PID-003
[ERR] Sistema instabile — eseguire rollback
```

---

## Rete

| VM | Hostname | IP |
|---|---|---|
| vm1 | vm1 | 192.168.56.10 |
| vm2 | vm2 | 192.168.56.11 |

Le due VM comunicano tramite rete privata host-only (VirtualBox). Il network bridge `TCP/river` rappresenta il canale di trasporto del ferry container tra i due nodi.

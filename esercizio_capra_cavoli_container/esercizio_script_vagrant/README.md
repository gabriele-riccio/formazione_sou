# 🐺🐐🥦 Indovinello: Lupo, Capra e Cavolo — Versione Docker Multi-VM

## Descrizione

Reinterpretazione in chiave DevOps del classico indovinello medievale.  
Gli attori dell'indovinello sono **container Docker reali** che migrano fisicamente tra due macchine virtuali Vagrant, che rappresentano le due sponde del fiume.

| Elemento | Versione classica | Versione Docker |
|---|---|---|
| Lupo, Capra, Cavolo | Animali/oggetti | Container Docker (`ubuntu sleep infinity`) |
| Traghettatore | Il contadino con la barca | Container Docker che si sposta sempre |
| Sponde del fiume | Due rive | vm1 (`192.168.56.10`) e vm2 (`192.168.56.11`) |
| Fiume | L'acqua | Rete privata VirtualBox |
| Migrazione | Attraversare il fiume | `docker commit → save → scp → load → run → rm` |

---

## Regole

- Sposta tutti i container da **vm1** a **vm2**
- **Lupo + Capra** non possono stare sulla stessa VM senza il traghettatore
- **Capra + Cavolo** non possono stare sulla stessa VM senza il traghettatore
- Il **traghettatore si sposta sempre** con ogni mossa (rappresenta la barca)
- Se si viaggia vuoti, si sposta solo il traghettatore

---

## Struttura del Progetto

```
esercizio_script_vagrant/
├── Vagrantfile                   # Definisce vm1 e vm2 con Ubuntu Focal
├── file_provision_container.sh   # Provisioning: Docker + SSH key setup
├── file_script_completo.sh       # Script interattivo del gioco
└── README.md                     # Questo file
```

---

## Requisiti

- [Vagrant](https://www.vagrantup.com/) >= 2.x
- [VirtualBox](https://www.virtualbox.org/) >= 6.x
- Connessione internet (per scaricare la box e Docker)

---

## Installazione e Avvio

### 1. Clona il repository e posizionati nella cartella

```bash
cd esercizio_script_vagrant
```

### 2. Dai i permessi agli script

```bash
chmod +x file_script_completo.sh
chmod +x file_provision_container.sh
```

### 3. Avvia le VM (installa Docker e configura SSH automaticamente)

```bash
vagrant up
```

> Il provisioning installa Docker su entrambe le VM e configura la comunicazione SSH tramite chiave pubblica/privata tra vm1 e vm2. Richiede qualche minuto.

### 4. Entra in vm1 ed esegui lo script

```bash
vagrant ssh vm1
bash /vagrant/file_script_completo.sh
```

### 5. (Opzionale) Monitora vm2 in tempo reale

Apri un secondo terminale nella stessa cartella:

```bash
vagrant ssh vm2
watch -n 1 docker ps
```

Vedrai i container apparire e sparire su vm2 ad ogni migrazione.

---

## Come si Gioca

All'avvio lo script mostra lo stato iniziale: tutti i container su vm1.

```
  vm1 [192.168.56.10]  lupo capra cavolo [traghettatore]
        ⛵ barca  @ vm1
        ═══════ fiume (rete privata) ═══════
  vm2 [192.168.56.11]  (vuota)
```

### Comandi disponibili

| Comando | Effetto |
|---|---|
| `lupo` | Porta il lupo sulla sponda opposta (+ traghettatore) |
| `capra` | Porta la capra sulla sponda opposta (+ traghettatore) |
| `cavolo` | Porta il cavolo sulla sponda opposta (+ traghettatore) |
| `invio` (tasto Invio vuoto) | Viaggio vuoto — sposta solo il traghettatore |
| `stato` | Mostra lo stato attuale senza fare mosse |
| `q` | Esci dal gioco |

### Gestione degli errori

Se si tenta una mossa che crea un conflitto, lo script lo segnala e offre la possibilità di **annullare la mossa** (rollback automatico).

---

## Come Funziona la Migrazione

Ogni volta che un container viene spostato, avviene questa sequenza reale tra le due VM:

```
1. docker commit <container> <img>     → snapshot del container in un'immagine
2. docker save <img> -o <file>.tar     → esporta l'immagine in un archivio
3. scp <file>.tar → vm2                → copia l'archivio via SSH sulla VM di destinazione
4. docker load -i <file>.tar           → carica l'immagine sulla VM di destinazione
5. docker run -d --name <container>... → avvia il container sulla VM di destinazione
6. docker rm -f <container>            → rimuove il container dalla VM di origine
```

---

## Come Funziona la Comunicazione SSH

Il provisioning risolve automaticamente il problema della comunicazione tra VM:

1. **vm1** genera una coppia di chiavi SSH (`ed25519`) durante il provisioning
2. La chiave pubblica viene salvata in `/vagrant/vm1_pub_key` (cartella condivisa)
3. **vm2**, provisionata dopo vm1, legge la chiave pubblica e la aggiunge ai propri `authorized_keys`
4. Lo script usa `/home/vagrant/.ssh/vm1_to_vm2` per autenticarsi su vm2

> **Nota**: viene rimosso il file `/etc/ssh/sshd_config.d/60-cloudimg-settings.conf` presente nelle immagini Ubuntu Cloud, che per default blocca l'autenticazione con chiave pubblica.

---

## Soluzione dell'Indovinello (Spoiler)

<details>
<summary>Clicca per vedere la soluzione in 7 mosse</summary>

| Mossa | Azione | vm1 | vm2 |
|---|---|---|---|
| Inizio | — | lupo, capra, cavolo, traghettatore | — |
| 1 | Porta **capra** | lupo, cavolo | capra, traghettatore |
| 2 | Torna **vuoto** | lupo, cavolo, traghettatore | capra |
| 3 | Porta **cavolo** | lupo | cavolo, capra, traghettatore |
| 4 | Riporta **capra** | lupo, capra, traghettatore | cavolo |
| 5 | Porta **lupo** | capra | lupo, cavolo, traghettatore |
| 6 | Torna **vuoto** | capra, traghettatore | lupo, cavolo |
| 7 | Porta **capra** | — | tutti ✅ |

</details>

---

## Pulizia

Per rimuovere tutti i container senza distruggere le VM:

```bash
vagrant ssh vm1
bash /vagrant/file_script_completo.sh --clean
```

Per distruggere completamente le VM:

```bash
vagrant destroy -f
```

---

## Autore

Esercizio realizzato come progetto pratico per il corso di formazione DevOps. 
Stack: **Vagrant** · **VirtualBox** · **Docker** · **Bash** · **Ubuntu 20.04 LTS**

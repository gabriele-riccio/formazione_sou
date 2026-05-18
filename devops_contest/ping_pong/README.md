# Ping Pong tra due nodi Vagrant

L'esercizio simula la **migrazione live di un container Docker** tra due macchine virtuali, alternandolo ogni 60 secondi(per questo viene denominato PingPong).

---

## Requisiti

| Strumento | Versione minima |
|-----------|----------------|
| Vagrant   | 2.x            |
| VirtualBox | 6.x           |
| Bash      | qualsiasi      |

---
## Struttura

```
.
├── Vagrantfile       # due nodi Ubuntu con Docker.
├── provision.sh      # installa Docker su ogni nodo e scarica l'immagine Docker.
├── migrazione.sh        # script di migrazione (gira sull'host).
├── files/migrazione     #cartella di immagini output per il README.
│   └── Screenshoot 2026-05....png      # Screenshoot per le immagini di output
│   └── Screenshoot 2026-05....png      # Screenshoot per le immagini di output
│   └── Screenshoot 2026-05....png      # Screenshoot per le immagini di output
└── README.md

```
---

## Descrizione dei file

### Vagrantfile

Il `Vagrantfile` è il file di configurazione di Vagrant che automatizza
la creazione e la configurazione delle due macchine virtuali.

Utilizza la sintassi in versione 2 (lo standard attuale di Vagrant) e
imposta **Ubuntu 20.04 LTS (Focal Fossa) a 64 bit** come sistema operativo
per entrambe le VM.

Vengono definiti due nodi:

| Nodo  | Hostname | IP              |
|-------|----------|-----------------|
| node1 | node1    | 192.168.56.10   |
| node2 | node2    | 192.168.56.11   |

Ogni nodo è collegato a una **rete privata host-only**: le VM possono
comunicare tra loro e con il PC host, ma non sono raggiungibili da Internet.
Gli IP sono statici, così i comandi `curl` e `vagrant ssh` funzionano sempre
agli stessi indirizzi.

Al momento del primo `vagrant up`, Vagrant esegue automaticamente su ciascun
nodo lo script `provision.sh` tramite la direttiva:

```ruby
node.vm.provision "shell", path: "provision.sh"
```

---

### provision.sh

Lo script di provisioning viene eseguito **una sola volta** su ogni VM,
in automatico durante il `vagrant up`. Il suo compito è preparare
l'ambiente installando Docker e pre-scaricando l'immagine del container.

Le operazioni svolte in sequenza sono:

**1. Installazione di Docker (metodo ufficiale)**

- Aggiorna i pacchetti e installa le dipendenze necessarie
  (`ca-certificates`, `curl`, `gnupg`, `lsb-release`)
- Aggiunge la chiave GPG ufficiale di Docker e il repository Docker CE
  alle sorgenti di `apt`
- Installa i pacchetti `docker-ce`, `docker-ce-cli` e `containerd.io`
- Aggiunge l'utente `vagrant` al gruppo `docker`, in modo che possa
  eseguire i comandi Docker senza `sudo`

**2. Pre-download dell'immagine**

```bash
docker pull ealen/echo-server
```

L'immagine viene scaricata in anticipo così la prima migrazione avviene
senza ritardi: il container parte immediatamente senza dover attendere
il download.

**3. Verifica**

Stampa la versione di Docker installata come conferma che tutto sia
andato a buon fine.

---


### migrate.sh

Lo script di migrazione è il cuore dell'esercizio. Gira **sull'host**
(il tuo PC), non dentro le VM, e usa `vagrant ssh` per inviare comandi
Docker ai due nodi a distanza.

**Variabili principali**

```bash
CONTAINER_NAME="echo-server"   # nome del container Docker
INTERVAL=60                    # secondi tra una migrazione e l'altra
NODES=("node1" "node2")        # i due nodi disponibili
CURRENT=0                      # indice del nodo attivo (0 = node1)
```

**Funzioni**

| Funzione         | Descrizione                                                  |
|------------------|--------------------------------------------------------------|
| `run_on_node`    | Esegue un comando shell su un nodo tramite `vagrant ssh`     |
| `stop_container` | Ferma (`docker stop`) e rimuove (`docker rm`) il container   |
| `start_container`| Avvia il container in background sulla porta 80              |
| `node_ip`        | Restituisce l'IP del nodo passato come argomento             |
| `cleanup`        | Intercetta Ctrl+C, ferma il container su entrambi i nodi ed esce pulito |

**Loop principale**

Il loop `while true` esegue indefinitamente questo ciclo:

1. Avvia il container sul nodo attivo
2. Attende `INTERVAL` secondi (60s)
3. Ferma il container sul nodo attivo
4. Passa all'altro nodo
5. Ripete

L'alternanza tra i nodi è gestita con un semplice calcolo:

```bash
NEXT=$(( 1 - CURRENT ))   # se CURRENT=0 → NEXT=1, e viceversa
```

**Schema temporale**

```
t=0s    node1 [ON]   node2 [off]
t=60s   node1 [off]  node2 [ON]
t=120s  node1 [ON]   node2 [off]
...
```

In ogni momento **un solo nodo risponde** alle richieste HTTP sulla
porta 80; l'altro restituisce "connection refused".

---
## Come funziona:


**1. Avviare i due nodi** (la prima volta scarica la box e installa Docker):

```bash
vagrant up
```

![prima parte terminale](files/migrazione/Screenshot%202026-05-18%20alle%2016.59.55.png)

**2. Avvia la migrazione:**

```bash
chmod +x migrate.sh
bash migrate.sh
```
![seconda parte terminale](files/migrazione/Screenshot%202026-05-18%20alle%2017.00.17.png)

![terza parte terminale](files/migrazione/Screenshot%202026-05-18%20alle%2017.01.43.png)

**3. Per fermare tutto:**

```bash
Ctrl+C          # ferma la migrazione e il container
vagrant halt    # spegne le VM
```
---



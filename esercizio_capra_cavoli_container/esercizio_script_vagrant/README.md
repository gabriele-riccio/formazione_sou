# 🐺🐐🥦 Indovinello: Lupo, Capra e Cavolo — Versione Docker, migrazione Container tra le 2 VM.

## Descrizione

Reinterpretazione in chiave DevOps del classico indovinello medievale: 
Gli attori dell'indovinello sono **container Docker reali** che migrano fisicamente tra due macchine virtuali Vagrant, che rappresentano le due sponde del fiume.

| Elemento | Versione classica | Versione Docker |
|---|---|---|
| Lupo, Capra, Cavolo | Animali | Container Docker (`ubuntu sleep infinity`) |
| Traghettatore | Il contadino con la barca | Container Docker migra sempre |
| Sponde del fiume | Due rive | vm1 (`192.168.56.10`) e vm2 (`192.168.56.11`) |
| Fiume | L'acqua | Rete privata VirtualBox |
| Migrazione | Attraversare il fiume | `docker commit → save → scp → load → run → rm` |

---

## Regole

- Sposta tutti i container da **vm1** a **vm2**
- **Lupo e Capra** non possono stare sulla stessa VM senza il traghettatore(lupo mangia la capra)
- **Capra e Cavolo** non possono stare sulla stessa VM senza il traghettatore(capra mangia cavolo)
- Il **traghettatore si sposta sempre** con ogni mossa (rappresenta la barca)
- Se si viaggia vuoti, si sposta solo il traghettatore
- Far migrare tutti i container, da Vm1 a Vm2( senza che il **lupo mangi la capra** e/o che **il cavolo venga mangiato dalla capra** ).

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

> Questa cosa l'ho aggiunta in un secondo momento ed è assente nella prima versione dove gli attori sono processi

---

## Come Funziona la Migrazione(comandi Docker che vengono eseguiti nello script)

Ogni volta che un container viene spostato, avviene questa sequenza reale tra le due VM:

```
1. docker commit <container> <img>     # viene effettuto lo snapshot del container in un'immagine
2. docker save <img> -o <file>.tar     # viene esportata l'immagine in un archivio
3. scp <file>.tar → vm2                # viene copiato l'archivio via SSH sulla VM di destinazione(da Vm1 a Vm2 o viceversa)
4. docker load -i <file>.tar           # viene caricata l'immagine sulla VM di destinazione
5. docker run -d --name <container>...  # viene avviato il container sulla VM di destinazione
6. docker rm -f <container>            # viene rimosso il container dalla VM di origine
```

---

## Come Funziona la Comunicazione SSH

Ho avuto dei problemi per far comunicare le due VM per cui ho modificato il provisioning per risolvere automaticamente il 
problema della comunicazione tra le 2 VM:

1. **Vm1** genera una coppia di chiavi SSH (`ed25519`) durante il provisioning
2. La chiave pubblica viene salvata in *`/vagrant/vm1_pub_key`* (cartella condivisa)
3. **Vm2**, provisionata dopo vm1, legge la chiave pubblica e la aggiunge ai propri *`authorized_keys`*
4. Infine lo script usa *`/home/vagrant/.ssh/vm1_to_vm2`* per autenticarsi su vm2

> **Nota**: Ho rimosso il file `/etc/ssh/sshd_config.d/60-cloudimg-settings.conf` presente nelle immagini Ubuntu Cloud, che per default blocca l'autenticazione con chiave pubblica.

---

## Soluzione dell'Indovinello (Soluzione che dovrebbe uscire)

<details>
<summary>Clicca per vedere la soluzione in 7 mosse</summary>

| Mossa | Azione | vm1 | vm2 |
|---|---|---|---|
| Inizio | — | lupo, capra, cavolo, traghettatore | — |
| 1 | Porta **capra** su vm2 | lupo, cavolo | capra, traghettatore |
| 2 | Torna **vuoto** su vm1| lupo, cavolo, traghettatore | capra |
| 3 | Porta **cavolo** su vm2 | lupo | cavolo, capra, traghettatore |
| 4 | Riporta **capra** su vm1 | lupo, capra, traghettatore | cavolo |
| 5 | Porta **lupo** su vm2 | capra | lupo, cavolo, traghettatore |
| 6 | Torna **vuoto** su vm1 | capra, traghettatore | lupo, cavolo |
| 7 | Porta **capra** su vm2 | — | lupo, capra, cavolo, traghettatore |

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


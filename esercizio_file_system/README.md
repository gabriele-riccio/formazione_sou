# I Filesystem in Linux — Teoria ed Esercizi

---

## Cos'è un Filesystem?

Un **filesystem** è il sistema con cui il sistema operativo organizza, archivia e recupera i dati su un dispositivo di memorizzazione (disco rigido, SSD, chiavetta USB, ecc.).

Senza un filesystem, i dati sul disco sarebbero una sequenza di bit senza struttura: il filesystem fornisce la logica per organizzarli in file e cartelle.

---

## Come è strutturato un disco

Ecco come è organizzato fisicamente un disco:

```
[ Disco fisico ]
      |
      ├── Partizione 1  →  Filesystem ext4  →  /
      ├── Partizione 2  →  Filesystem swap  →  [swap]
      └── Partizione 3  →  Filesystem ext4  →  /home
```

Ogni partizione può avere un filesystem diverso, e viene **montata** in un punto specifico dell'albero delle directory.

---

## I componenti fondamentali

### 1. Blocchi (Blocks)

Il disco è diviso in **blocchi** di dimensione fissa (tipicamente 4 KB). Ogni file occupa uno o più blocchi. È l'unità minima di memorizzazione dei dati.

### 2. Inode

Ogni file ha un **inode**, una struttura dati che contiene i **metadati** del file:

| Metadato             | Descrizione                              |
|----------------------|------------------------------------------|
| Numero di inode      | Identificatore univoco del file          |
| Permessi             | Chi può leggere/scrivere/eseguire        |
| Proprietario         | Utente e gruppo                          |
| Dimensione           | In byte                                  |
| Timestamp            | Data creazione, modifica, accesso        |
| Puntatori ai blocchi | Dove si trovano i dati sul disco         |

> **Importante:** il nome del file **non** è nell'inode — è nella directory che lo contiene. Il sistema trova i file tramite inode, non tramite nome.

### 3. Directory

Una directory è un file speciale che contiene una **tabella** di coppie:

```
nome_file  →  numero_inode
```

### 4. Superblock

È una struttura dati che contiene le **informazioni generali del filesystem**: dimensione totale, numero di blocchi liberi, numero di inode liberi, tipo di filesystem, ecc. È così importante che ne esistono copie di backup sul disco.

---

## I principali Filesystem Linux

### ext4 — il più usato

Il filesystem standard di quasi tutte le distribuzioni Linux moderne.

**Caratteristiche:**
- **Journaling**: tiene un registro delle operazioni prima di eseguirle, permettendo il ripristino in caso di crash
- Supporta file fino a **16 TB** e volumi fino a **1 Exabyte**
- Compatibile a ritroso con ext2 e ext3
- Ottimo equilibrio tra prestazioni e affidabilità

```bash
mkfs.ext4 /dev/sdb1     # formatta una partizione in ext4
```

### XFS

Filesystem ad alte prestazioni, usato spesso in ambienti server e per grandi volumi di dati.

**Caratteristiche:**
- Eccellente con **file di grandi dimensioni**
- Journaling avanzato
- Supporta volumi fino a **8 Exabyte**
- Usato di default in Red Hat / CentOS / Rocky Linux

### Btrfs (B-Tree Filesystem)

Il filesystem "moderno" di Linux, con funzionalità avanzate.

**Caratteristiche:**
- **Snapshot**: fotografie istantanee del filesystem in un certo momento
- **RAID software** integrato
- Compressione trasparente dei dati
- Checksum per rilevare corruzione dei dati
- Usato di default in openSUSE e Fedora

### FAT32 / exFAT

Filesystem storici di Windows, molto usati per la compatibilità.

|                | FAT32             | exFAT                       |
|----------------|-------------------|-----------------------------|
| File massimo   | 4 GB              | 16 Exabyte                  |
| Uso tipico     | Chiavette vecchie | Chiavette moderne, SD card  |
| Compatibilità  | Universale        | Windows, Mac, Linux moderni |

### NTFS

Il filesystem nativo di Windows. Linux può leggerlo e scriverci tramite il driver `ntfs-3g`.

### tmpfs

Un filesystem **virtuale in memoria RAM**. I dati spariscono al riavvio. Usato per `/tmp` e `/run`.

### proc e sysfs

Filesystem virtuali che **non memorizzano dati su disco**, ma espongono informazioni del kernel:

```bash
/proc    # informazioni sui processi in esecuzione
/sys     # informazioni sull'hardware e i driver
```

---

## Montare un Filesystem

In Linux **tutto è un file**, e ogni filesystem deve essere **montato** in un punto dell'albero delle directory per essere accessibile.

```bash
# Montaggio manuale
mount /dev/sdb1 /mnt/miadisk

# Smontaggio
umount /mnt/miadisk

# Vedere i filesystem montati
mount
df -h       # mostra spazio usato/disponibile
lsblk       # mostra la struttura dei dischi
```

### Il file `/etc/fstab`

Contiene i filesystem da montare **automaticamente** all'avvio:

```
# dispositivo    punto_mount   tipo    opzioni   dump  pass
/dev/sda1        /             ext4    defaults  0     1
/dev/sda2        /home         ext4    defaults  0     2
/dev/sda3        none          swap    sw        0     0
UUID=xxxx-xxxx   /mnt/dati     ntfs    defaults  0     0
```

> È buona pratica usare l'**UUID** invece di `/dev/sdaX` perché i nomi dei dispositivi possono cambiare; l'UUID è sempre univoco.

---

## Operazioni comuni sui Filesystem

### Creare un filesystem

```bash
mkfs.ext4 /dev/sdb1     # ext4
mkfs.xfs  /dev/sdb2     # XFS
mkfs.vfat /dev/sdb3     # FAT32
```

### Controllare e riparare

```bash
fsck /dev/sdb1      # controlla e ripara errori
fsck -n /dev/sdb1   # solo controllo, senza modifiche
```

> ⚠️ `fsck` va eseguito solo su filesystem **non montati**.

### Informazioni sul filesystem

```bash
dumpe2fs /dev/sda1      # info dettagliate (ext2/3/4)
tune2fs -l /dev/sda1    # parametri del filesystem
df -h                   # spazio usato/libero
du -sh /home/utente     # spazio occupato da una cartella
```

---

## Permessi e Filesystem

I permessi dei file sono memorizzati nell'**inode** e sono strettamente legati al filesystem. Un filesystem FAT32, ad esempio, **non supporta i permessi Unix** — ecco perché una chiavetta FAT non può avere file con `chmod`.

---

## Riepilogo visivo

```
DISCO
 └── Partizione (es. /dev/sda1)
       └── Filesystem (es. ext4)
             ├── Superblock    →  info generali del FS
             ├── Inode Table   →  metadati di ogni file
             ├── Data Blocks   →  contenuto reale dei file
             └── Journal       →  registro operazioni
```

| Concetto    | Ruolo                           |
|-------------|---------------------------------|
| Blocco      | Unità minima di storage         |
| Inode       | Metadati del file (senza nome)  |
| Directory   | Collega nomi → inode            |
| Superblock  | Info generali del filesystem    |
| Journal     | Protegge da crash e corruzione  |
| Mount       | Rende accessibile un filesystem |
| /etc/fstab  | Mount automatico all'avvio      |

---

---

# Esercizi — Filesystem (con soluzioni)

*Lezione 15 — Sistemi Operativi, Università di Modena e Reggio Emilia*

---

## Esercizio 1 — Metadati di file diversi

**Testo:** Stampare l'insieme dei metadati per i seguenti file: `$HOME`, `/tmp/.X11-unix/X0`, `/dev/sda1`, `/dev/tty0`. Notare le differenze.

**Soluzione:** Si usa il comando `stat` su ciascun file:

```bash
stat $HOME
stat /tmp/.X11-unix/X0
stat /dev/sda1
stat /dev/tty0
```

**Osservazioni chiave:**

| File                  | Tipo rilevato              |
|-----------------------|----------------------------|
| `$HOME`               | `directory`                |
| `/tmp/.X11-unix/X0`   | `socket`                   |
| `/dev/sda1`           | `file speciale a blocchi`  |
| `/dev/tty0`           | `file speciale a caratteri`|

In Linux tutto è un file: directory, socket, dispositivi a blocchi e a caratteri sono tutti rappresentati con un inode e accessibili con le stesse interfacce.

---

## Esercizio 2 — Impostare un timestamp arbitrario

**Testo:** Creare un file vuoto e impostare i suoi timestamp al 1/1/1970, ore 00:00.

**Soluzione:** Il comando `touch` con l'opzione `-t` accetta un timestamp arbitrario nel formato `[[CC]YY]MMDDhhmm[.ss]`:

```bash
touch -t 197001010000.00 file.txt
stat file.txt
```

> **Nota:** il timestamp di *cambio* (campo `Cambio` nell'output di `stat`), gestito direttamente dal kernel, non viene modificato da `touch`.

---

## Esercizio 3 — Creare una gerarchia di directory

**Testo:** Creare la gerarchia `dir1/dir2/dir3`.

**Soluzione:** Il comando `mkdir dir1/dir2/dir3` fallisce perché `mkdir` richiede che le directory intermedie esistano già.

Si può procedere manualmente:

```bash
mkdir dir1
cd dir1
mkdir dir2
cd dir2
mkdir dir3
```

Oppure, molto meglio, con l'opzione `-p`:

```bash
mkdir -p dir1/dir2/dir3
```

---

## Esercizio 4 — Cancellazione forzata in batch

**Testo:** Trovare un modo per forzare la cancellazione di file in maniera non interattiva (batch).

**Soluzione:** Il comando `rm` con l'opzione `-f` forza la cancellazione senza chiedere conferma:

```bash
rm -f file.txt
```

---

## Esercizio 5 — `cp -a` vs `--preserve=all`

**Testo:** Cosa fa in più l'opzione `-a` di `cp` rispetto a `--preserve=all`?

**Soluzione:** Leggendo `man cp`, si scopre che `-a` equivale a una combinazione di tre opzioni:

- `--preserve=all` — copia integralmente tutti i metadati del file sorgente (permessi, timestamp, proprietario, ecc.)
- `-d` — ricrea tutti i **collegamenti simbolici** senza sostituirli con i file puntati
- `-R` — discende **ricorsivamente** nelle directory

---

## Esercizio 6 — Stampare un file al contrario

**Testo:** Trovare un modo per stampare un file dall'ultima alla prima riga. Applicarlo al file `mkfs.trace`.

**Soluzione:** La pagina `man cat` non offre questa funzionalità, ma in fondo alla pagina la sezione `SEE ALSO` menziona il comando `tac` (cat al contrario):

```bash
tac mkfs.trace
```

---

## Esercizio 7 — I cinque file più recenti

**Testo:** Visualizzare in formato lungo i cinque file più recenti nella directory corrente.

**Soluzione:**

```bash
ls -lt | head -n 6
```

> ⚠️ `ls` stampa una riga iniziale con `Totale: ...`, quindi si richiedono **6 righe** per ottenere 5 file.

---

## Esercizio 9 — Estrarre username e shell da `/etc/passwd`

**Testo:** Produrre un file contenente gli username e le shell usate dagli utenti.

**Soluzione:** Il file `/etc/passwd` ha campi separati da `:`. Username è la colonna 1, shell è la colonna 7:

```bash
cut -f1,7 -d: /etc/passwd > users-shells.txt
```

---

## Esercizio 10 — Ordinare `/etc/passwd` per GID

**Testo:** Ordinare il file `/etc/passwd` in modo numerico crescente per campo GID.

**Soluzione:** GID è la colonna 4 di `/etc/passwd`:

```bash
sort -n -k 4 -t : /etc/passwd
```

| Opzione | Significato                        |
|---------|------------------------------------|
| `-n`    | Ordinamento numerico               |
| `-k 4`  | Chiave di ordinamento: campo 4     |
| `-t :`  | Separatore di campo: `:`           |

---

## Esercizio 11 — Trovare i file di log

**Testo:** Individuare tutti i file di log nel sistema (pattern `*.log`).

**Soluzione:**

```bash
find / -name "*.log"
```

---

## Esercizio 12 — Trovare i file HTML

**Testo:** Individuare tutti i file HTML nel sistema.

**Soluzione base:**

```bash
find / -regex "^.*\.html$"
```

**Soluzione migliorata** (gestisce anche `.htm` e maiuscole/minuscole):

```bash
find / -iregex "^.*\.html?$"
```

| Elemento  | Significato                              |
|-----------|------------------------------------------|
| `^`       | Inizio riga                              |
| `.*`      | Sequenza arbitraria di caratteri         |
| `\.html`  | La sequenza letterale `.html`            |
| `?`       | Il carattere precedente (`l`) è opzionale|
| `$`       | Fine riga                                |
| `-iregex` | Ricerca case-insensitive                 |

---

## Esercizio 13 — File più grandi di 1 MB

**Testo:** Individuare tutti i file più grandi di 1 MB nel sistema.

**Soluzione:**

```bash
find / -size +1M
```

> Il prefisso `+` indica *strettamente maggiore di*. Le unità supportate includono `k` (KB), `M` (MB), `G` (GB).

---

## Esercizio 14 — Top 10 dei file più grandi

**Testo:** Produrre un elenco di tutti i file nel sistema con relativa dimensione, ordinato per dimensione, estraendo la top 10.

**Soluzione:**

```bash
find / -printf "%p %s\n" | sort -nrk 2 | head -n 10
```

| Parte             | Significato                                     |
|-------------------|-------------------------------------------------|
| `-printf "%p %s"` | Stampa nome file (`%p`) e dimensione in byte (`%s`) |
| `sort -nrk 2`     | Ordina numericamente (`-n`), in ordine inverso (`-r`), sul campo 2 |
| `head -n 10`      | Prende solo le prime 10 righe                   |

---

## Esercizio 15 — Cancellare file per estensione

**Testo:** Individuare tutti i file di estensione `.trace` o `.strace` e cancellarli forzatamente.

**Soluzione:**

```bash
find / -regex '^.*\.s?trace$' -exec rm -f '{}' \;
```

| Elemento    | Significato                                    |
|-------------|------------------------------------------------|
| `\.s?trace` | La `s` è opzionale (fa match con `.trace` e `.strace`) |
| `-exec`     | Esegue un comando per ogni file trovato        |
| `'{}'`      | Placeholder sostituito col nome del file       |
| `\;`        | Chiude il blocco `-exec`                       |

---

## Esercizio 16 — Trovare le chiamate di sistema in `/usr/include`

**Testo:** Individuare all'interno di `/usr/include` i numeri interi che rappresentano le chiamate di sistema.

**Soluzione:**

```bash
grep -nRHi syscall /usr/include
```

I risultati mostrano le definizioni con pattern `__NR_nome` (es. `__NR_read`, `__NR_write`, `__NR_open`), dove `nome` è il nome della syscall. Le definizioni si trovano in:

| File                                              | Architettura              |
|---------------------------------------------------|---------------------------|
| `.../asm/unistd_32.h`                             | Sistemi a 32 bit          |
| `.../asm/unistd_64.h`                             | Sistemi a 64 bit          |
| `.../asm/unistd_X32.h`                            | 32 bit su sistemi a 64 bit|

---

*"I think the major good idea in UNIX was its clean and simple interface: open, close, read and write." — Ken Thompson*

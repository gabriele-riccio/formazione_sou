# Esercizitazione 7 -- Esercizio sul cambio di gruppo dopo la creazione di un file log

## Descrizione

Esercizio pratico su una VM Linux Ubuntu che copre la creazione di file, la gestione dei permessi con `chmod` e la gestione di gruppi con `groupadd` e `chown`. Si lavora direttamente da terminale come utente con privilegi `sudo`.

---

## Prerequisiti

- Una VM Linux attiva (Ubuntu, Debian, CentOS o simile)
- Accesso al terminale
- Privilegi `sudo`

---

## Step 1 — Creare il file `foo.log` con `touch`

```bash
touch foo.log
```

**Cos'è `touch`?**  
Il comando `touch` crea un file vuoto se non esiste. Se il file esiste già, aggiorna i timestamp di ultimo accesso e ultima modifica senza modificarne il contenuto. → `man touch`

**Verifica:**
```bash
ls -l foo.log
```
Output atteso:
```
-rw-rw-r-- 1 gabriele-riccio gabriele-riccio 0 May  6 10:00 foo.log
```

---

## Step 2 — Assegnare permessi di lettura, scrittura ed esecuzione al proprietario

```bash
chmod u+rwx foo.log
```

**Cos'è `chmod`?**  
Il comando `chmod` (change mode) modifica i permessi di accesso a un file o directory. → `man chmod`

**Spiegazione della sintassi:**

| Simbolo | Significato |
|---|---|
| `u` | User — il proprietario del file |
| `g` | Group — il gruppo proprietario |
| `o` | Others — tutti gli altri |
| `a` | All — tutti (u+g+o) |
| `+` | Aggiunge il permesso |
| `-` | Rimuove il permesso |
| `=` | Imposta esattamente quei permessi |
| `r` | Read — lettura |
| `w` | Write — scrittura |
| `x` | Execute — esecuzione |

**Alternativa con notazione ottale:**
```bash
chmod 700 foo.log
# r=4, w=2, x=1 → rwx = 4+2+1 = 7
# 700 = rwx per il proprietario, nessun permesso per gruppo e altri
```

**Verifica:**
```bash
ls -l foo.log
```
Output atteso:
```
-rwxrw-r -- 1 tuoutente tuogruppo 0 May  6 10:00 foo.log
```

La stringa `-rwxrw-r` si legge così:

```
- rwx rwx r
│  │    │   └── altri: lettura
│  │    └─────── gruppo: lettura + scrittura + esecuzione
│  └──────────── proprietario: lettura + scrittura + esecuzione
└─────────────── tipo file (- = file normale, d = directory)
```

---

## Step 3 — Creare il gruppo `foobar`

```bash
sudo groupadd foobar
```

**Cos'è `groupadd`?**  
Il comando `groupadd` crea un nuovo gruppo nel sistema. Richiede privilegi di amministratore (`sudo`) perché modifica i file di sistema `/etc/group` e `/etc/gshadow`. → `man groupadd`


## Step 4 — Cambiare il gruppo proprietario di `foo.log` in `foobar`

```bash
sudo chown :foobar foo.log
```

**Cos'è `chown`?**  
Il comando `chown` (change owner) cambia il proprietario e/o il gruppo di un file. → `man chown`

**Sintassi:**
```bash
chown utente:gruppo file    # cambia entrambi
chown utente file           # cambia solo il proprietario
chown :gruppo file          # cambia solo il gruppo
```


**Verifica finale:**
```bash
ls -l foo.log
```
Output atteso:
```
-rwxrw-r -- 1 gabriele-riccio foobar 0 May  6 10:00 foo.log
```

---

## Riepilogo — tutti i comandi in sequenza

```bash
# Step 1 — Crea il file
touch foo.log

# Step 2 — Assegna rwx al proprietario
chmod u+rwx foo.log

# Step 3 — Crea il gruppo foobar
sudo groupadd foobar

# Step 4 — Cambia il gruppo proprietario
sudo chown :foobar foo.log

# Verifica tutto insieme
ls -l foo.log
```

---

## Tabella dei comandi usati

| Comando | Scopo | Richiede sudo |
|---|---|---|
| `touch` | Crea un file vuoto | No |
| `chmod` | Modifica i permessi di un file | No (se proprietario) |
| `groupadd` | Crea un nuovo gruppo | Sì |
| `chown` | Cambia proprietario e/o gruppo | Sì |
| `ls -l` | Mostra permessi e proprietà del file | No |

---

# La Shell di Linux

## Indice

1. [Elencare i contenuti di una directory](#1-elencare-i-contenuti-di-una-directory)
2. [Creare e cancellare directory](#2-creare-e-cancellare-directory)
3. [Creare e cancellare file](#3-creare-e-cancellare-file)
4. [Copiare file](#4-copiare-file)
5. [Spostare e rinominare](#5-spostare-e-rinominare)
6. [Mostrare i contenuti di un file](#6-mostrare-i-contenuti-di-un-file)
7. [Ricerca dei file (find)](#7-ricerca-dei-file-find)
8. [Filtrare i file](#8-filtrare-i-file)
9. [Altri comandi utili](#9-altri-comandi-utili)
10. [Standard Input, Output ed Error](#10-standard-input-output-ed-error)
11. [Redirezionare Input e Output](#11-redirezionare-input-e-output)
12. [Pipes](#12-pipes)
13. [Esercizi di fine capitolo](#13-esercizi-di-fine-capitolo)

---

## 1. Elencare i contenuti di una directory

```bash
ls              # elenca i contenuti della working directory
ls dir_name     # elenca i contenuti di dir_name
```

### Opzioni di `ls`

| Opzione | Descrizione |
|---|---|
| `-a` | Tutti i file, compresi quelli nascosti (che iniziano con `.`) |
| `-F` | Aggiunge `/` per le directory, `*` per gli eseguibili, `@` per i link simbolici |
| `-l` | Formato completo — mostra dettagli per ogni file |
| `-m` | Elenca i file separati da virgola |
| `-r` | Inverte l'ordine alfabetico |
| `-R` | Ricorsivo — include anche le sottodirectory |
| `-s` | Mostra le dimensioni dei file in blocchi |
| `-t` | Ordina per data di ultima **modifica** |
| `-u` | Ordina per data di ultimo **accesso** |
| `-i` | Mostra l'inode di ciascun file |

→ `man ls`

---

## 2. Creare e cancellare directory

```bash
mkdir dir_name              # crea una directory
mkdir appunti               # esempio
mkdir {appunti,lucidi}      # crea più directory in un colpo solo
```

```bash
rmdir dir_name              # cancella una directory VUOTA (no warning!)
rmdir appunti
```

> ⚠️ `rmdir` funziona solo su directory vuote. Per directory con contenuto:

```bash
rm -r dir_name              # cancella la directory e tutto il suo contenuto
rm -r appunti
```

→ `man mkdir` | `man rmdir` | `man rm`

---

## 3. Creare e cancellare file

### Creare un file con `cat`

```bash
cat > file_name     # scrive l'input da tastiera nel file
cat > prova
# scrivi il testo, poi premi Ctrl+D per terminare
```

### Cancellare un file con `rm`

```bash
rm file_name        # cancella il file (no warning!)
rm pippo
```

### Opzioni di `rm`

| Opzione | Descrizione |
|---|---|
| `-r` | Ricorsivo — rimuove il contenuto delle directory |
| `-i` | Interattivo — chiede conferma prima di ogni cancellazione |
| `-f` | Force — forza la cancellazione ignorando errori e avvisi |

> ⚠️ `rm` è irreversibile. Non esiste cestino. Usare `-i` se si è incerti.

→ `man rm`

---

## 4. Copiare file

```bash
cp file1 file2              # copia file1 in file2
cp /etc/passwd pass         # copia /etc/passwd nella directory corrente come "pass"
cp problemi/* ~/backup      # copia tutto il contenuto di "problemi" in "backup"
cp pippo /articoli          # copia pippo nella directory /articoli
cp /etc/passwd .            # copia in "." (directory corrente)
```

- Se `file2` non esiste, viene creato
- Se `file2` esiste già, viene sovrascritto
- Se `file2` è una directory, `cp` copia `file1` dentro quella directory

### Opzioni di `cp`

| Opzione | Descrizione |
|---|---|
| `-i` | Chiede conferma prima di sovrascrivere un file esistente |
| `-p` | Conserva i permessi originali del file |
| `-r` | Copia ricorsivamente file e sottodirectory |

→ `man cp`

---

## 5. Spostare e rinominare

```bash
mv oldname newname              # rinomina il file
mv olddirectory newdirectory    # rinomina la directory
mv file path                    # sposta il file nella directory indicata da path
mv chap[1,3,7] book             # sposta chap1, chap3, chap7 nella directory book
mv chap[1-5] book               # sposta da chap1 a chap5 nella directory book
```

- Se `newname` esiste già, viene sovrascritto
- Se `newdirectory` esiste già, `olddirectory` viene spostata **dentro** quella directory

### Opzioni di `mv`

| Opzione | Descrizione |
|---|---|
| `-i` | Chiede conferma prima di sovrascrivere |
| `-f` | Forza l'operazione indipendentemente dai permessi |

→ `man mv`

---

## 6. Mostrare i contenuti di un file

### `cat` — concatena e stampa

```bash
cat filename                        # mostra il contenuto di filename
cat file1.txt file2.txt file3.txt   # concatena più file e li mostra
```

| Opzione | Descrizione |
|---|---|
| `-n` | Numera tutte le righe |
| `-v` | Mostra i caratteri non stampabili |
| `-e` | Mostra `$` alla fine di ogni riga |

→ `man cat`

---

### `more` — visualizza una schermata alla volta

```bash
more filename                   # mostra il file una schermata alla volta
more [-cs] [+startline] [+/pattern] [filename]
```

| Opzione | Descrizione |
|---|---|
| `-c` | Mostra le schermate successive dall'alto della pagina |
| `-s` | Sostituisce più righe vuote consecutive con una sola |
| `+/pattern` | Apre il file dalla prima occorrenza di "pattern" |

**Comandi interattivi durante la visualizzazione:**

| Tasto | Azione |
|---|---|
| `Spazio` | Schermata successiva |
| `Invio` | Riga successiva |
| `q` | Esce |
| `h` | Aiuto |
| `v` | Apre il file in `vi` |
| `/pattern` | Cerca il pattern nel testo |
| `:n` | Salta al file successivo |
| `:p` | Salta al file precedente |

→ `man more`

---

### `less` — come `more` ma con più funzionalità

```bash
less filename
```

| Opzione | Descrizione |
|---|---|
| `-o` | Copia l'output su file quando l'input proviene da una pipe |
| `-p` | Apre il file dalla prima occorrenza di "pattern" |

**Comandi interattivi:**

| Tasto | Azione |
|---|---|
| `Spazio` | Schermata successiva |
| `Invio` | Riga successiva |
| `↑ ↓` | Su/giù di una riga |
| `q` o `Q` | Esce |
| `/pattern` | Cerca il pattern |
| `:n` | File successivo |
| `:p` | File precedente |

→ `man less`

---

### `head` — mostra le prime righe

```bash
head filename           # mostra le prime 10 righe (default)
head -n filename        # mostra le prime n righe
head -20 /etc/passwd    # mostra le prime 20 righe
```

→ `man head`

---

### `tail` — mostra le ultime righe

```bash
tail filename           # mostra le ultime 10 righe (default)
tail -n filename        # mostra le ultime n righe
tail -5 /var/log/syslog # mostra le ultime 5 righe
```

→ `man tail`

---

## 7. Ricerca dei file (`find`)

```bash
find <path> <condizioni> <azione>
```

`find` scende ricorsivamente nel percorso indicato e applica le condizioni di ricerca a ogni file trovato.

### Condizioni di ricerca

| Opzione | Descrizione |
|---|---|
| `-name "name"` | Trova tutti i file di nome "name" (es. `"*.c"`) |
| `-type c` | Tipo di file: `f`=file, `d`=directory, `l`=link |
| `-mtime n` | File modificati n giorni fa |
| `-atime n` | File acceduti n giorni fa |
| `-amin n` | File acceduti n minuti fa |
| `-size n` | File di dimensione n (b=blocchi 512B, c=byte, k=KB, w=parole 2B) |
| `-user nome` | File di proprietà dell'utente "nome" |
| `-newer file` | File più recenti del file indicato |
| `-maxdepth n` | Limita la ricerca a n livelli di profondità |

### Azioni

| Opzione | Descrizione |
|---|---|
| `-print` | Mostra i file trovati sullo schermo |
| `-exec comando {} \;` | Esegue il comando su ogni file trovato (`{}` = percorso del file) |
| `-ok comando {} \;` | Come `-exec` ma chiede conferma per ogni file |

### Esempi pratici

```bash
# Trovare un file chiamato "kernel" in /usr/src
find /usr/src -name "kernel"

# Trovare tutti i file PDF nel sistema
find / -name "*.pdf"

# File modificati negli ultimi 2 giorni nella home
find ~ -mtime -2

# File visitati nelle ultime 2 ore
find ~ -amin -120

# File tra 1MB e 2MB
find / -size +1024 -size -2048

# File nella directory corrente più recenti del file "test"
find . -newer test

# Trovare e cancellare file .tmp con conferma
find / -name "*.tmp" -ok rm {} \;

# Cancellare file più vecchi di 30 giorni in /tmp
find /tmp -mtime +30 -exec rm {} \;

# Trovare file dell'utente lferrari
find / -user lferrari

# File che iniziano con "pr", dimensione < 10KB, salvare risultato
find . -name "pr*" -maxdepth 1 -size -10k -print > risultato
```

→ `man find`

---

## 8. Filtrare i file

### `grep` — cerca un pattern nei file

```bash
grep <opzioni> <pattern> <file>
grep Italy /usr/src/linux/CREDITS
grep pippo ~/prova.txt
```

| Opzione | Descrizione |
|---|---|
| `-n` | Mostra anche il numero di riga |
| `-c` | Conta il numero di righe che contengono il pattern |
| `-i` | Non distingue maiuscole/minuscole |
| `-w` | Trova solo parole intere |
| `-q` | Silenzioso: restituisce 0 se trovato, 1 altrimenti |
| `-l` | Mostra solo i nomi dei file che contengono il pattern |

```bash
grep -n Italy /usr/src/linux/CREDITS      # con numero di riga
grep -c Italy /usr/src/linux/CREDITS      # conta le occorrenze
grep -i italy /usr/src/linux/CREDITS      # case insensitive
```

→ `man grep`

---

### `sort` — ordina righe di testo

```bash
sort file               # ordina alfanumericamente e mostra
sort -r file            # ordine inverso
```

| Opzione | Descrizione |
|---|---|
| `-u` | Elimina le righe duplicate |
| `-f` | Non distingue maiuscole/minuscole |
| `-r` | Ordine inverso |
| `-n` | Ordine numerico |
| `-k chiave` | Usa una porzione della riga come chiave di ordinamento |

→ `man sort`

---

### `uniq` — elimina righe duplicate consecutive

```bash
uniq file               # elimina le righe duplicate consecutive
```

> ⚠️ `uniq` funziona solo su righe **consecutive** identiche. Va usato quasi sempre dopo `sort`.

| Opzione | Descrizione |
|---|---|
| `-c` | Precede ogni riga col numero di ripetizioni consecutive |
| `-d` | Mostra solo le righe che si ripetono |

```bash
sort file | uniq        # combinazione classica per eliminare tutti i duplicati
```

→ `man uniq`

---

### `wc` — conta parole, righe e caratteri

```bash
wc file                 # mostra righe, parole e byte
```

| Opzione | Descrizione |
|---|---|
| `-l` | Solo il numero di righe |
| `-w` | Solo il numero di parole |
| `-c` | Solo il numero di byte |
| `-m` | Solo il numero di caratteri |
| `-L` | Lunghezza della riga più lunga |

→ `man wc`

---

## 9. Altri comandi utili

### `history` — cronologia dei comandi

```bash
history             # mostra tutti i comandi digitati in precedenza
```

→ `man history`

---

### `ps` — stato dei processi

```bash
ps                  # mostra i processi in corso nel sistema
```

→ `man ps`

---

### `kill` — termina un processo

```bash
kill PID            # termina il processo con il PID indicato
kill -9 PID         # forza la terminazione immediata
```

→ `man kill`

---

### `wget` — scarica file da Internet

```bash
wget URL            # scarica il file dall'URL indicato
```

Supporta HTTP, HTTPS e FTP. Download non interattivo.

→ `man wget`

---

## 10. Standard Input, Output ed Error

Ogni programma eseguito dalla shell apre automaticamente tre file:

| File | Numero | Default | Descrizione |
|---|---|---|---|
| **stdin** (standard input) | `0` | Tastiera | Fonte dei dati in ingresso al programma |
| **stdout** (standard output) | `1` | Schermo | Destinazione dell'output normale |
| **stderr** (standard error) | `2` | Schermo | Destinazione dei messaggi di errore |

```bash
ls 1> pippo         # redirige lo stdout nel file "pippo"
ls > pippo          # equivalente (1> è il default)
list 2> pippo       # redirige lo stderr nel file "pippo"
```

---

## 11. Redirezionare Input e Output

### `<` — redirige l'input

Legge l'input da un file invece che dalla tastiera:
```bash
more < /etc/passwd
```

### `>` — redirige l'output (sovrascrive)

Salva l'output in un file invece di mostrarlo a schermo. Se il file esiste, viene sovrascritto:
```bash
ls /tmp > ~/ls.out
sort pippo > pippo.ordinato
```

### `>>` — redirige l'output (accoda)

Aggiunge l'output alla fine di un file esistente. Se il file non esiste, viene creato:
```bash
ls /bin > ~/bin
ls /usr/sbin >> ~/bin       # accoda al file già creato
wc -l ~/bin
```

### `>&` — redirige stdout e stderr insieme

Invia sia l'output normale che gli errori nello stesso file:
```bash
ls abcdef >& lserror        # salva sia output che errori in lserror
mkdir /bin/miei >& ~/miei   # salva l'eventuale errore in ~/miei
```

---

## 12. Pipes

Una **pipe** (`|`) connette lo stdout di un comando allo stdin del successivo, senza scrivere file intermedi su disco.

```bash
comando1 | comando2         # l'output di comando1 diventa input di comando2
```

Una sequenza di comandi connessi da pipe si chiama **pipeline**.

```bash
cat /etc/passwd | sort > ~/pass_ord     # ordina passwd e salva
sort < pippo | lpr                      # ordina pippo e lo manda alla stampante
ls /bin | wc -l                         # conta i file in /bin
ls | grep "string" | wc -l             # conta i file con "string" nel nome
```

---

## 13. Esercizi di fine capitolo

Applicare i concetti appresi nei paragrafi precedenti (pipe, redirezione, `ls`, `grep`, `head`, `tail`, `wc`, `sort`).

---

### Esercizio 1 — File in `/bin` che iniziano con "c"

Determinare il numero di file nella directory `/bin` la cui prima lettera è `c`.

```bash
ls /bin/c* | wc -l
```

**Spiegazione:** `ls /bin/c*` elenca tutti i file che iniziano con "c" usando il glob `*`; `wc -l` conta le righe risultanti.

---

### Esercizio 2 — Primi 7 file di `/etc` in un file

Creare un file contenente i nomi dei primi 7 file della directory `/etc`.

```bash
ls /etc | head -7 > primi7_etc.txt
```

**Spiegazione:** `ls /etc` elenca in ordine alfabetico; `head -7` prende le prime 7 righe; `>` salva il risultato nel file.

---

### Esercizio 3 — File nella directory corrente con "snap" nel nome

Determinare il numero di file della directory corrente nel cui nome compare la stringa `snap`.

```bash
ls | grep "snap" | wc -l
```

**Spiegazione:** `ls` elenca i file correnti; `grep "snap"` filtra solo quelli che contengono "snap"; `wc -l` conta quanti sono.

---

### Esercizio 4 — 10 comandi di `/bin` ordinati per ultimo accesso

Creare un file con una lista di 10 comandi di `/bin` ordinati per momento dell'ultimo accesso.

```bash
ls -tu /bin | head -10 > ultimi10_accesso.txt
```

**Spiegazione:** `ls -t` ordina per tempo, `-u` usa il tempo di ultimo **accesso** invece della modifica; `head -10` prende i 10 più recenti.

---

### Esercizio 5 — Primi 7 e ultimi 6 file di `/etc` in un file

Creare un file contenente i nomi dei primi 7 e degli ultimi 6 file (in ordine alfabetico) della directory `/etc`.

```bash
{ ls /etc | head -7; ls /etc | tail -6; } > primi7_ultimi6.txt
```

**Spiegazione:** `{ }` raggruppa i due comandi; `head -7` prende i primi 7, `tail -6` prende gli ultimi 6; tutto viene salvato insieme nel file.

---

### Esercizio 6 — 8 file di `/usr/sbin` ordinati per ultima modifica

Creare un file con una lista di 8 file in `/usr/sbin` ordinati per momento dell'ultima modifica.

```bash
ls -t /usr/sbin | head -8 > top8_modifica_usrsbin.txt
```

**Spiegazione:** `ls -t` ordina per tempo di ultima **modifica** (dal più recente); `head -8` prende i primi 8; `>` salva nel file.

---

## Tabella riepilogativa dei comandi

| Comando | Funzione principale |
|---|---|
| `ls` | Elenca contenuto directory |
| `mkdir` | Crea directory |
| `rmdir` | Cancella directory vuota |
| `rm` | Cancella file o directory |
| `cp` | Copia file o directory |
| `mv` | Sposta o rinomina |
| `cat` | Mostra/concatena file |
| `more` | Visualizza file pagina per pagina |
| `less` | Visualizza file pagina per pagina (avanzato) |
| `head` | Mostra le prime N righe |
| `tail` | Mostra le ultime N righe |
| `find` | Ricerca file nel filesystem |
| `grep` | Filtra righe per pattern |
| `sort` | Ordina righe di testo |
| `uniq` | Elimina righe duplicate consecutive |
| `wc` | Conta righe, parole, caratteri |
| `history` | Cronologia comandi |
| `ps` | Stato processi |
| `kill` | Termina un processo |
| `wget` | Download da Internet |

---

## Riferimenti

- `man <comando>` — manuale del comando
- [The Linux Documentation Project](https://tldp.org)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)

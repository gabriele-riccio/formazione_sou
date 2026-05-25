# ESERCITAZIONE 8 - Commentare gli script

**Obiettivo**
Creare un repo GitHub con i seguenti script versioni in appositi repo GIT.
Per ogni script creare un file con spiegazione del codice.

---

## Indice

| Script | Argomento principale |
|---|---|
| file_script_1.sh | Pulizia dei log di sistema |
| file_script_2.sh | Verifica utente root |
| file_script_3.sh | Parametri da riga di comando |
| file_script_4.sh | Variabili e assegnazione |
| file_script_5.sh | Exit status e codici di uscita |
| file_script_6.sh | Array associativi |
| file_script_7.sh | Barra di avanzamento con processi in background |

---

## file_script_1.sh — Pulizia dei log (Cleanup)

### Cosa fa
Svuota due file di log di sistema (`/var/log/messages` e `/var/log/wtmp`) redirigendo su di essi il contenuto vuoto di `/dev/null`.
Al termine stampa un messaggio di conferma.

### Concetti trattati
- Navigazione nel filesystem con `cd`
- Utilizzo di `/dev/null` come sorgente vuota
- Redirezione dell'output con `>`
- Operazioni che richiedono privilegi di root

### Note importanti
> ⚠️ Lo script **deve essere eseguito come root**. Modificare i log di sistema su macchine in produzione può causare perdita di dati diagnostici importanti. Usare solo in ambienti di test.

### Esempio di esecuzione
```bash
sudo bash file_script_1.sh
# Output: Log files cleaned up.
```

---

## file_script_2.sh — Verifica utente root

### Cosa fa
Controlla se l'utente che esegue lo script è `root`, confrontando la variabile d'ambiente `$UID` con il valore `0` (che corrisponde sempre all'utente root). Stampa un messaggio diverso a seconda del risultato. Una seconda verifica (mai eseguita, dopo `exit 0`) mostra un metodo alternativo usando il comando `id`.

### Concetti trattati
- Istruzione condizionale `if/then/else/fi`
- Variabile speciale `$UID`
- Operatori di confronto numerico (`-eq`)
- Comando `exit` e codici di uscita
- Codice irraggiungibile dopo `exit`
- Sostituzione di comando con i backtick `` `comando` ``

### Esempio di esecuzione
```bash
bash file_script_2.sh
# Output (utente normale): You are just an ordinary user (but mom loves you just the same).

sudo bash file_script_2.sh
# Output (root): You are root.
```

---

## file_script_3.sh — Gestione dei parametri

### Cosa fa
Mostra il nome dello script (`$0`) e i parametri passati da riga di comando (`$1`, `$2`, ..., `${10}`). Stampa poi tutti i parametri insieme con `$*` e, se ne sono stati passati meno di 10, avvisa l'utente.

### Concetti trattati
- Variabili speciali: `$0` (nome script), `$1`–`$9` (parametri posizionali), `${10}` (parametri oltre il nono, con parentesi graffe obbligatorie), `$*` (tutti i parametri), `$#` (numero di parametri)
- Comando `basename` per estrarre solo il nome del file dal percorso
- Test su stringhe con `-n` (stringa non vuota)
- Confronto numerico con `-lt` (less than)

### Esempio di esecuzione
```bash
bash file_script_3.sh 1 2 3 4 5 6 7 8 9 10
# Output:
# The name of this script is "file_script_3.sh".
# Parameter #1 is 1
# ...
# Parameter #10 is 10
# All the command-line parameters are: 1 2 3 4 5 6 7 8 9 10
```

---

## file_script_4.sh — Variabili e assegnazione

### Cosa fa
Illustra i diversi modi in cui una variabile può essere assegnata in Bash: assegnazione diretta, tramite `let`, in un ciclo `for` e tramite `read` (input da tastiera). Mostra anche la distinzione tra variabile "nuda" (usata nell'assegnazione, senza `$`) e variabile referenziata (con `$`).

### Concetti trattati
- Assegnazione diretta (`a=879`)
- Assegnazione aritmetica con `let`
- Ciclo `for` con lista di valori
- Input interattivo con `read`
- Differenza tra `a=valore` (assegnazione) e `$a` (riferimento)
- Opzione `-n` di `echo` per non andare a capo

### Esempio di esecuzione
```bash
bash file_script_4.sh
# Output:
# The value of "a" is 879.
# The value of "a" is now 21.
# Values of "a" in the loop are: 7 8 9 11
# Enter "a": [attende input]
# The value of "a" is now [valore inserito].
```

---

## file_script_5.sh — Exit status

### Cosa fa
Dimostra il funzionamento della variabile speciale `$?`, che contiene il codice di uscita dell'ultimo comando eseguito. Esegue prima un comando valido (`echo hello`) e poi uno inesistente (`lskdf`), mostrando come `$?` valga `0` in caso di successo e un valore diverso da zero in caso di errore. Lo script termina con `exit 113`.

### Concetti trattati
- Variabile speciale `$?` (exit status dell'ultimo comando)
- Convenzione: `0` = successo, valore non-zero = errore
- Comando `exit` con codice personalizzato
- Comportamento in caso di comando non riconosciuto

### Esempio di esecuzione
```bash
bash file_script_5.sh
# Output:
# hello
# 0
# file_script_5.sh: line 5: lskdf: command not found
# 127

echo $?   # Dopo la terminazione dello script
# Output: 113
```

---

## file_script_6.sh — Array associativi

### Cosa fa
Crea un array associativo (dizionario chiave→valore) che mappa nomi di persone ai rispettivi indirizzi. Stampa i valori accedendovi tramite chiave e infine elenca tutti gli indici (chiavi) dell'array.

### Concetti trattati
- Dichiarazione di array associativi con `declare -A`
- Assegnazione di valori: `array[chiave]="valore"`
- Accesso ai valori: `${array[chiave]}`
- Stampa di tutte le chiavi con `${!array[*]}`

> ⚠️ L'array associativo richiede **Bash 4 o superiore** (lo shebang usa `#!/bin/bash4`). Su macOS la versione di default di Bash potrebbe essere la 3.x; in quel caso è necessario installare una versione aggiornata.

### Esempio di esecuzione
```bash
bash file_script_6.sh
# Output:
# Charles's address is 414 W. 10th Ave., Baltimore, MD 21236.
# Wilma's address is 1854 Vermont Ave, Los Angeles, CA 90023.
# John's address is 202 E. 3rd St., New York, NY 10009.
#
# Charles John Wilma
```

---

## file_script_7.sh — Barra di avanzamento

### Cosa fa
Simula una barra di avanzamento testuale (a punti) mentre un processo "lungo" è in esecuzione. La barra viene avviata come processo in background e stampa un punto ogni secondo; al termine del processo principale viene fermata inviandole il segnale `SIGUSR1`. Gestisce anche l'interruzione manuale con `Ctrl+C` tramite una trap sul segnale `EXIT`.

### Concetti trattati
- Esecuzione di processi in background con `&`
- Recupero del PID dell'ultimo processo in background con `$!`
- Segnali Unix e comando `kill` (con `SIGUSR1` e `-USR1`)
- `trap` per intercettare segnali e l'evento `EXIT`
- `wait` per attendere la terminazione di un processo
- Ciclo `while true` per esecuzione indefinita
- Subshell con `{ ... } &`

### Esempio di esecuzione
```bash
bash file_script_7.sh
# Output:
# Long-running process ..........  Finished!
```

> ⚠️ Lo script deve essere eseguito con `bash` (non con `sh`), come indicato anche nel commento iniziale.

---

## Requisiti

- Sistema operativo: Linux o macOS
- Shell: **Bash 4+** (obbligatorio per `file_script_6.sh`; consigliato per tutti)
- Permessi di root: richiesti solo per `file_script_1.sh`

## Come eseguire gli script

```bash
# Rendere eseguibile uno script
chmod +x file_script_N.sh

# Eseguirlo direttamente
./file_script_N.sh

# Oppure passarlo esplicitamente a bash
bash file_script_N.sh
```



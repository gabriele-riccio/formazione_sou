# 🔍 TCP Port Scanner — `portscanner.sh`

Semplice **TCP Port Scanner** scritto in Bash che utilizza **Netcat** per rilevare le porte aperte su un host remoto.

---

## 🚀 Utilizzo

```bash
chmod +x portscanner.sh
./portscanner.sh <IP_TARGET> <PORTA_INIZIO> <PORTA_FINE>
```

### Esempio
```bash
./portscanner.sh 192.168.56.10 1 1024
```

### Output
```
---------------------------------
Inizio scansione su 192.168.56.10
Range: 1 - 1024
---------------------------------
Porta 22: APERTA
Porta 80: APERTA
---------------------------------
Scansione completa
```

---

## 🧠 Spiegazione del Codice

### Shebang
```bash
#!/bin/bash
```
La prima riga di ogni script Bash. Dice al sistema operativo quale interprete usare per eseguire il file. Senza di essa, lo script potrebbe essere eseguito con una shell diversa e comportarsi in modo inatteso.

---

### Funzione
```bash
usage() {
    echo "..."
    exit 1
}
```
In Bash le funzioni si dichiarano con `nome() { ... }` e si chiamano semplicemente scrivendone il nome. `exit 1` termina lo script restituendo un codice di errore: per convenzione `0` indica successo, qualsiasi altro valore indica un errore.

---

### Variabile speciale `$#`
```bash
if [ "$#" -ne 3 ]; then
    usage
fi
```
`$#` è una **variabile speciale** di Bash che contiene il numero di argomenti passati allo script. L'operatore `-ne` significa *not equal*. Se il numero di argomenti è diverso da 3, viene chiamata la funzione `usage()`.

---

### Variabili posizionali
```bash
TARGET_IP=$1
START_PORT=$2
END_PORT=$3
```
`$1`, `$2`, `$3` sono le **variabili posizionali**: contengono gli argomenti passati allo script dalla riga di comando nell'ordine in cui vengono scritti. Vengono salvati in variabili con nomi significativi per rendere il codice più leggibile.

---

### Regex e operatore `=~`
```bash
if [[ ! $TARGET_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
```
L'operatore `=~` permette di confrontare una stringa con una **espressione regolare** all'interno delle doppie parentesi `[[ ]]`. Il `!` nega la condizione. La regex usata verifica che la stringa abbia il formato `xxx.xxx.xxx.xxx`:

| Elemento | Significato |
|---|---|
| `^` | Inizio della stringa |
| `[0-9]{1,3}` | Da 1 a 3 cifre consecutive |
| `\.` | Punto letterale (`\` lo rende un carattere, non un metacarattere) |
| `$` | Fine della stringa |

---

### Operatore logico `||`
```bash
if ! [[ "$START_PORT" =~ ^[0-9]+$ ]] || ! [[ "$END_PORT" =~ ^[0-9]+$ ]]; then
```
`||` è l'operatore logico **OR**: la condizione è vera se **almeno uno** dei due confronti è vero. La regex `^[0-9]+$` verifica che la variabile contenga solo cifre.

---

### Loop C-style
```bash
for ((port=START_PORT; port<=END_PORT; port++)); do
    ...
done
```
Bash supporta un ciclo `for` in **stile C** con la sintassi `(( ))`. È composto da tre parti separate da `;`:
- `port=START_PORT` → valore iniziale
- `port<=END_PORT` → condizione di continuazione
- `port++` → incremento di 1 ad ogni iterazione

---

### Netcat e ridirezione
```bash
nc -w 1 "$TARGET_IP" "$port" < /dev/null > /dev/null 2>&1
```
Ogni elemento ha un ruolo preciso:

| Elemento | Significato |
|---|---|
| `nc` | Netcat: apre una connessione TCP verso host e porta specificati |
| `-w 1` | Timeout: abbandona la connessione dopo 1 secondo se non risponde |
| `< /dev/null` | Redirige STDIN da `/dev/null` (file sempre vuoto): netcat riceve subito EOF e chiude la connessione senza aspettare input |
| `> /dev/null` | Redirige STDOUT a `/dev/null`: scarta qualsiasi output a schermo |
| `2>&1` | Redirige STDERR (`2`) verso lo stesso destinatario di STDOUT (`&1`): anche i messaggi di errore vengono scartati |

`/dev/null` è un file speciale di Linux che scarta tutto ciò che riceve e restituisce EOF in lettura.

---

### Variabile speciale `$?`
```bash
if [ $? -eq 0 ]; then
    echo "Porta $port: APERTA"
fi
```
`$?` contiene il **codice di uscita dell'ultimo comando eseguito**. Se `nc` riesce ad aprire la connessione TCP restituisce `0` (successo), altrimenti restituisce un valore diverso da `0` (porta chiusa o irraggiungibile). L'operatore `-eq` significa *equal*.

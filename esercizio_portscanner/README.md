#Port Scanner in Bash con Vagrant

Questo progetto implementa un **Port Scanner** personalizzato scritto in Bash. L'esercizio simula un ambiente di rete reale composto da due macchine virtuali (VM) che comunicano tra loro, utilizzando **Vagrant** come orchestratore di virtualizzazione.

## 🎯 Obiettivo dell'Esercizio
L'obiettivo è analizzare una macchina target per identificare quali porte TCP siano in stato di ascolto (*listening*). 

### Vincoli Tecnici:
- Utilizzo del comando `nc` (Netcat).
- Divieto di utilizzare le funzioni di scansione integrate di Netcat (es. non è permesso passare un range di porte direttamente al comando).
- Implementazione di un ciclo `for` per la scansione sequenziale.
- Sanificazione degli input (IP e range porte).
- Personalizzazione tramite argomenti da linea di comando.

---

## 🏗️ Architettura di Rete (Vagrant)
L'ambiente è composto da due macchine virtuali Ubuntu 20.04 collegate tramite una rete privata:

| Macchina | Hostname | IP Privato | Ruolo |
| :--- | :--- | :--- | :--- |
| **VM 1** | `scanner` | `192.168.50.10` | Esegue lo script Bash |
| **VM 2** | `target` | `192.168.50.11` | Riceve i tentativi di connessione |

---

## 🚀 Installazione e Utilizzo

### 1. Avvio delle Macchine Virtuali
Assicurati di avere Vagrant e un provider (nel mio caso VirtualBox) installati. Dalla cartella del progetto, esegui:

```bash
vagrant up
#così da far partire vagrant e le due macchine

#--Accesso alla macchina Scanner--
Una volta avviate le VM, entro nella macchina che effettuerà la scansione con il comando:
vagrant ssh scanner

#--Esecuzione dello script--
#Ho creato lo script in bash che è presente nella cartella condivisa.
#Per avviarlo basta eseguire:
./portscanner.sh <IP_TARGET> <PORTA_INIZIO> <PORTA_FINE>
es:./portscanner.sh 192.168.50.11 20 25

#Partirà il tutto e avrò come output:
--------------------------------------
Inizio scansione su 192.168.50.11
Range: 20 - 25
--------------------------------------
Porta 22: APERTA
-------------------------------------- 
#mi dirà che si è aperta la porta 22, quella del SSH.
```

---

## 🔍 Test con Range di Porte Più Ampi

Per verificare il funzionamento dello scanner su più porte, ho installato **nginx** sulla VM target, in modo da mettere in ascolto anche la porta 80 (HTTP). Questo ha permesso di testare la scansione su un range più ampio:

```bash
./portscanner.sh 192.168.50.11 20 100
```

Output ottenuto:
```
--------------------------------------
Inizio scansione su 192.168.50.11
Range: 20 - 100
--------------------------------------
Porta 22: APERTA
Porta 80: APERTA
Porta 443: APERTA
--------------------------------------
Scansione completa
```

Per attivare la porta 80 sulla VM target è stato sufficiente:
```bash
vagrant ssh target
sudo apt update && sudo apt install -y nginx
sudo systemctl start nginx
```
Per attivare la porta 80 sulla VM target è stato sufficiente:
```bash
sudo nc -lk -p 433 &
#Vale per ogni porta
```


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


## ⚙️ Vincolo dell'Esercizio: Ho usato `/dev/null` al posto di `-z`

Netcat supporta il flag `-z` (zero I/O mode) che permette di testare le connessioni senza inviare dati — esattamente quello che serve per un port scanner. Tuttavia, **l'esercizio ne vietava esplicitamente l'utilizzo**, richiedendo di implementare la scansione senza ricorrere alle funzionalità integrate di Netcat.

Come da requisiti, è stata quindi usata la seguente tecnica:

```bash
nc -w 1 "$TARGET_IP" "$port" < /dev/null > /dev/null 2>&1
```

| Parte | Significato |
| :--- | :--- |
| `< /dev/null` | Redirige l'input da `/dev/null`: nc non riceve nulla da inviare e chiude subito la connessione |
| `> /dev/null` | Scarta l'output standard (nessun testo a schermo) |
| `2>&1` | Scarta anche gli errori |
| `-w 1` | Timeout di 1 secondo per non bloccarsi su porte chiuse |

In questo modo si ottiene lo stesso comportamento di `-z` — testare se la porta è aperta senza trasmettere dati reali — rispettando il vincolo imposto dall'esercizio.

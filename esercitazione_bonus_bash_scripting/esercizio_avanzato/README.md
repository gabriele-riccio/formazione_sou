# Esercizio AVANZATO 

# Modulo: Scripting Bash, Strutture Dati (Array) e Controllo di Flusso. 

---

## Descrizione del Problema

L'azienda deve analizzare l'efficienza dei propri sistemi partendo da un file `metriche.txt` generato da uno script apposito. Ogni riga del file contiene il nome di un server e la percentuale di utilizzo CPU registrata in quel momento, separati da uno spazio.

L'obiettivo è scrivere uno script `analizza_metriche.sh` che calcoli la **media di utilizzo CPU per ogni server** presente nel file.

---

## Fase 1 — Generazione del File di Log

Prima di poter analizzare i dati, è necessario generare il file `metriche.txt` tramite lo script `generatore_log.sh` fornito nella consegna.

### Errore Individuato nel Generatore Originale

Analizzando il codice dello script fornito, ho individuato un **bug critico** prima ancora di eseguirlo.

![prima parte terminale](immagini_esercizio_facile/Screenshot%202026-06-10%20alle%2017.11.42.png)

La riga incriminata è la seguente:

```bash
done ; > "$FILE_OUTPUT"
```

In Bash, il `;` è un separatore di comandi: i due comandi vengono eseguiti in sequenza. Questo significa che:

1. `done` — chiude regolarmente il ciclo `for`, scrivendo 100 righe nel file(infatti nel terminale da che lo script da 100 righe è stato eseguito con successo)
2. `> "$FILE_OUTPUT"` — **svuota immediatamente il file** con un redirect vuoto.

Il risultato è che `metriche.txt` viene sempre creato ma vuoto, rendendo lo script inutilizzabile.

![seconda parte terminale](immagini_esercizio_facile/Screenshot%202026-06-10%20alle%2017.25.28.png)

### Correzione Applicata

La riga è stata corretta rimuovendo il redirect superfluo:

```bash
# PRIMA (errato)
done ; > "$FILE_OUTPUT"

# DOPO (corretto)
done
```

### Script Generatore Corretto — `generatore_log_giusto.sh`

![terza parte terminale](immagini_esercizio_facile/Screenshot%202026-06-10%20alle%2017.14.03.png)

Una volta corretta la riga, lo script l'ho reso eseguibile e lanciato:

![quarta parte terminale](immagini_esercizio_facile/Screenshot%202026-06-10%20alle%2017.03.35.png)

---

## Fase 2 — Analisi delle Metriche

### Struttura del file `metriche.txt`

Il file generato contiene 100 righe:

![quinta parte terminale](immagini_esercizio_facile/Screenshot%202026-06-10%20alle%2017.27.12.png)

Ogni riga rappresenta una singola misurazione: nome del server e percentuale CPU.

### Script di Analisi — `analizza_metriche.sh`

```bash
#!/usr/bin/env bash
# =================================================================================
# analizza_metriche.sh
# Lo script calcola la media di utilizzo delle CPU per ogni server in metriche.txt
# =================================================================================

FILE="metriche.txt"

# Controllo prima che il file esista:
if [[ ! -f "$FILE" ]]; then
    echo "Errore: file '$FILE' non trovato."
    exit 1
fi

#  Gestisco le STRUTTURE DATI 
# Ho generato degli Array associativi per accumulare somma e conteggio per ogni server e i server unici:
declare -A somma_cpu     # somma_cpu["srv-web01"] = somma totale CPU
declare -A conteggio     # conteggio["srv-web01"] = numero di misurazioni
declare -a server_unici  # array ordinato dei server (per ordine di apparizione)

#  FASE 1: LETTURA RIGA PER RIGA 
# 'while read' consuma il file riga per riga
# IFS=' ' separa ogni riga nei campi: server e valore CPU
while IFS=' ' read -r server cpu; do
    # Accumulo la CPU per questo server
    somma_cpu["$server"]=$(( ${somma_cpu["$server"]:-0} + cpu ))
    # Incremento il contatore delle occorrenze
    conteggio["$server"]=$(( ${conteggio["$server"]:-0} + 1 ))
    # Aggiungo il server alla lista degli unici (solo la prima volta)
    if [[ ${conteggio["$server"]} -eq 1 ]]; then
        server_unici+=("$server")
    fi
done < "$FILE"

# FASE 2: CALCOLO E STAMPA 
echo "=== REPORT UTILIZZO MEDIO CPU ==="

# Ciclo for sull'array dei server unici individuati
for server in "${server_unici[@]}"; do
    # Faccio fare la divisione intera (comportamento standard di Bash)
    media=$(( somma_cpu["$server"] / conteggio["$server"] ))
    echo "$server: $media%"
done
```

---

## Logica dello Script

### Strutture dati utilizzate

Ho usato nello script tre array (2 associativi e uno indicizzato (normale)) distinti:

| Array | Tipo | Contenuto |
|---|---|---|
| `somma_cpu` | Associativo (`-A`) | Somma totale della CPU per ogni server |
| `conteggio` | Associativo (`-A`) | Numero di misurazioni per ogni server |
| `server_unici` | Indicizzato (`-a`) | Elenco dei server nell'ordine in cui compaiono |

Gli array associativi usano il **nome del server come chiave**, permettendo di accumulare i valori senza dover cercare manualmente l'indice corretto(aggiungendo cicli for o while allo script).

### Ciclo `while` + `read` — Lettura del file

```bash
while IFS=' ' read -r server cpu; do
    somma_cpu["$server"]=$(( ${somma_cpu["$server"]:-0} + cpu ))
    ...
done < "$FILE"
```
- `while read -r ` legge il file riga per riga dall'inizio alla fine.
- ` IFS=' ' ` imposta lo spazio come separatore  campo (Internal Field Separator).
  Significa che Bash prenderà ogni riga, la "taglierà" dove c'è uno spazio e assegnerà i pezzi alle variabili
  successive.
- `server cpu`,attraverso `read -r`, fa in modo che il primo blocco di testo (il nome del server) finisce nella variabile $server,
  il secondo blocco (il valore della CPU) finisce in $cpu.
- `< "$FILE"` redirige il file come input del `while`, senza usare `cat` (più efficiente)
- `${somma_cpu["$server"]:-0}` è un'**espansione con valore di default**: prende il valore attualmente salvato per questo server; se l'array è ancora
  vuoto (perché è la prima volta che incontriamo questo server), usa 0 come valore di partenza".
  Senza questo controllo, Bash darebbe un errore matematico al primo giro.
  Inoltre `+ cpu` somma il valore corrente di CPU a quello vecchio e aggiorna l'array.
- `conteggio["$server"]=$(( ${conteggio["$server"]:-0} + 1 ))` invece fa come sopra, ma invece di sommare il valore della CPU,
  lo script incrementa il contatore di 1.
- Poi c'è un if che controlla il contatore appena incrementato.
  Se il valore è esattamente uguale a 1 (-eq 1), significa che questo server è stato appena   scoperto. In questo caso, lo aggiunge in coda a un array
  indicizzato chiamato server_unici.

### Ciclo `for` — Calcolo e stampa

```bash
for server in "${server_unici[@]}"; do
    media=$(( somma_cpu["$server"] / conteggio["$server"] ))
    echo "$server: $media%"
done
```

- `for server in "${server_unici[@]}"; do` scorriamo tutti gli elementi dell'array che ho appena riempito.
- Con `media=$(( somma_cpu["$server"] / conteggio["$server"] ))` faccio l'operazione matematica della media
  prendendo il totale della CPU per ogni server dal dizionario `somma_cpu` e lo divido (/) per il numero di rilevazioni pescate da `conteggio`.
  > La divisione `$((...))` è **divisione intera** nativa di Bash,come richiesto dalla consegna, infatti bash non riesce a
    gestire nativamente numeri non interi.
- Infine stampo il risultato tramite l'unione del server e la sua media tra virgolette doppie.


# In breve:
Lo script si basa su tre strutture dati principali: due array associativi e un array indicizzato. Il primo array associativo è dedicato alla somma progressiva dei valori di utilizzo CPU per ciascun server, il secondo tiene traccia del numero di misurazioni registrate per ogni server, mentre l'array indicizzato raccoglie i nomi dei server unici incontrati durante la lettura del file.

La lettura dei dati avviene tramite un ciclo while, che elabora il file riga per riga: per ogni riga, il valore di utilizzo CPU viene accumulato nel rispettivo array delle somme, e il contatore delle misurazioni per quel server viene incrementato. Se il server non era ancora stato incontrato, viene aggiunto all'array dei server unici.

Al termine della lettura, un ciclo for scorre tutti i server unici e calcola la media effettiva dividendo la somma totale dei valori CPU per il numero di misurazioni corrispondenti, ottenendo così la media di utilizzo per ciascun server.

### Output terminale
![sesta parte terminale](immagini_esercizio_facile/Screenshot%202026-06-10%20alle%2017.05.39.png)

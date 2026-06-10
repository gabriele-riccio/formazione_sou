# Esercizio AVANZATO — Analisi Metriche CPU Server

**Modulo:** Scripting Bash, Strutture Dati (Array) e Controllo di Flusso  
**Academy:** #6-#7 — Prova Pratica

---

## Descrizione del Problema

L'azienda deve analizzare l'efficienza dei propri sistemi partendo da un file `metriche.txt` generato da uno script apposito. Ogni riga del file contiene il nome di un server e la percentuale di utilizzo CPU registrata in quel momento, separati da uno spazio.

L'obiettivo è scrivere uno script `analizza_metriche.sh` che calcoli la **media di utilizzo CPU per ogni server** presente nel file.

---

## Fase 1 — Generazione del File di Log

Prima di poter analizzare i dati, è necessario generare il file `metriche.txt` tramite lo script `generatore_log.sh` fornito nella consegna.

### Errore Individuato nel Generatore Originale

Analizzando il codice dello script fornito, è stato individuato un **bug critico** prima ancora di eseguirlo.

La riga incriminata è la seguente:

```bash
done ; > "$FILE_OUTPUT"
```

In Bash, il `;` è un separatore di comandi: i due comandi vengono eseguiti in sequenza. Questo significa che:

1. `done` — chiude regolarmente il ciclo `for`, scrivendo 100 righe nel file
2. `> "$FILE_OUTPUT"` — **svuota immediatamente il file** con un redirect vuoto

Il risultato è che `metriche.txt` viene sempre creato vuoto, rendendo lo script inutilizzabile.

### Correzione Applicata

La riga è stata corretta rimuovendo il redirect superfluo:

```bash
# PRIMA (errato)
done ; > "$FILE_OUTPUT"

# DOPO (corretto)
done
```

### Script Generatore Corretto — `generatore_log.sh`

```bash
#!/bin/bash
# Esegui questo script per generare il file metriche.txt di 100 righe
SERVER_LIST=("srv-web01" "srv-db02" "srv-auth01" "srv-cache03")
FILE_OUTPUT="metriche.txt"
# Svuota il file se esiste già
> "$FILE_OUTPUT"
echo "Generazione di 100 righe in corso..."
for i in {1..100}; do
    # Seleziona un server casuale dall'array
    rand_server=${SERVER_LIST[$((RANDOM % 4))]}
    # Genera un valore di CPU casuale tra 10 e 99
    rand_cpu=$((RANDOM % 90 + 10))
    # Scrive nel file
    echo "$rand_server $rand_cpu" >> "$FILE_OUTPUT"
done
echo "File '$FILE_OUTPUT' generato con successo!"
```

Una volta corretta la riga, lo script è stato reso eseguibile e lanciato:

```bash
chmod +x generatore_log.sh
bash generatore_log.sh
```

---

## Fase 2 — Analisi delle Metriche

### Struttura del file `metriche.txt`

Il file generato contiene 100 righe nel formato:

```
srv-web01 54
srv-db02 78
srv-auth01 23
...
```

Ogni riga rappresenta una singola misurazione: nome del server e percentuale CPU.

### Script di Analisi — `analizza_metriche.sh`

```bash
#!/bin/bash
# =============================================================
# analizza_metriche.sh
# Calcola la media di utilizzo CPU per ogni server in metriche.txt
# =============================================================

FILE="metriche.txt"

# Controlla che il file esista
if [[ ! -f "$FILE" ]]; then
    echo "Errore: file '$FILE' non trovato."
    exit 1
fi

# --- STRUTTURE DATI ---
# Array associativi per accumulare somma e conteggio per ogni server
declare -A somma_cpu    # somma_cpu["srv-web01"] = somma totale CPU
declare -A conteggio    # conteggio["srv-web01"] = numero di misurazioni
declare -a server_unici # array ordinato dei server (per ordine di apparizione)

# --- FASE 1: LETTURA RIGA PER RIGA ---
# 'while read' consuma il file riga per riga
# IFS=' ' separa ogni riga nei campi: server e valore cpu
while IFS=' ' read -r server cpu; do

    # Accumula la CPU per questo server
    somma_cpu["$server"]=$(( ${somma_cpu["$server"]:-0} + cpu ))

    # Incrementa il contatore delle occorrenze
    conteggio["$server"]=$(( ${conteggio["$server"]:-0} + 1 ))

    # Aggiunge il server alla lista degli unici (solo la prima volta)
    if [[ ${conteggio["$server"]} -eq 1 ]]; then
        server_unici+=("$server")
    fi

done < "$FILE"

# --- FASE 2: CALCOLO E STAMPA ---
echo "=== REPORT UTILIZZO MEDIO CPU ==="

# Ciclo for sull'array dei server unici individuati
for server in "${server_unici[@]}"; do
    # Divisione intera (comportamento standard di Bash)
    media=$(( somma_cpu["$server"] / conteggio["$server"] ))
    echo "$server: $media%"
done
```

---

## Logica dello Script

### Strutture dati utilizzate

Lo script usa tre array distinti:

| Array | Tipo | Contenuto |
|---|---|---|
| `somma_cpu` | Associativo (`-A`) | Somma totale della CPU per ogni server |
| `conteggio` | Associativo (`-A`) | Numero di misurazioni per ogni server |
| `server_unici` | Indicizzato (`-a`) | Elenco dei server nell'ordine in cui compaiono |

Gli array associativi usano il **nome del server come chiave**, permettendo di accumulare i valori senza dover cercare manualmente l'indice corretto.

### Ciclo `while` + `read` — Lettura del file

```bash
while IFS=' ' read -r server cpu; do
    somma_cpu["$server"]=$(( ${somma_cpu["$server"]:-0} + cpu ))
    ...
done < "$FILE"
```

- `IFS=' '` imposta lo spazio come separatore: `read` popola automaticamente `$server` e `$cpu`
- `< "$FILE"` redirige il file come input del `while`, senza usare `cat` (più efficiente)
- `${somma_cpu["$server"]:-0}` è un'**espansione con valore di default**: se la chiave non esiste ancora nell'array, restituisce `0` invece di dare errore

### Ciclo `for` — Calcolo e stampa

```bash
for server in "${server_unici[@]}"; do
    media=$(( somma_cpu["$server"] / conteggio["$server"] ))
    echo "$server: $media%"
done
```

- `"${server_unici[@]}"` espande tutti gli elementi dell'array mantenendo l'ordine di apparizione
- La divisione `$((...))` è **divisione intera** nativa di Bash — come richiesto dalla consegna

### Output atteso

```
=== REPORT UTILIZZO MEDIO CPU ===
srv-web01: 54%
srv-db02: 48%
srv-auth01: 61%
srv-cache03: 50%
```

I valori numerici variano ad ogni esecuzione perché il file `metriche.txt` viene generato con dati casuali.

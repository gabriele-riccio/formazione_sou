# Esercizio AVANZATO 

**Modulo:** Scripting Bash, Strutture Dati (Array) e Controllo di Flusso  

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
# Ho generato degli Array associativi per accumulare somma e conteggio per ogni server:
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

# gestione_processi.sh

Script Bash didattico per la gestione di processi simulati, con cicli iterativi, gestione degli errori, contatori e logging.

---

## Obiettivo

Dimostrare i concetti fondamentali della programmazione Bash attraverso uno script che simula l'esecuzione di N processi, traccia successi ed errori, e gestisce la pulizia dell'ambiente in modo automatico.

---

## Struttura del progetto

```
esercizio_processi/
├── gestione_processi.sh   # script principale
├── processi.log           # generato a runtime
└── README.md
```

---

## Concetti coperti

| Concetto | Implementazione |
|---|---|
| Variabili | `NUM_PROCESSI`, `LOG_FILE`, `count_success`, `count_error` |
| Ciclo iterativo | `for ((i=1; i<=NUM_PROCESSI; i++))` |
| Gestione errori | `if comando; then ... else ... fi` |
| Status code | `$?` — 0 = successo, diverso da 0 = errore |
| Contatori | `((count_success++))`, `((count_error--))` |
| Errore forzato | Eliminazione file + tentativo di lettura al processo 3 |
| Funzioni di supporto | `log_message()`, `cleanup()` |
| Pulizia automatica | `trap cleanup EXIT` |
| Uscita semantica | `exit 0` (successo) / `exit 1` (errore) |

---

## Come funziona

### 1. Variabili
Definite in cima allo script in MAIUSCOLO (convenzione per le costanti):
```bash
LOG_FILE="processi.log"
NUM_PROCESSI=5
```

### 2. Funzioni
`log_message` stampa un messaggio formattato su schermo e lo aggiunge al file di log:
```bash
log_message "SUCCESS" "Processo 1 completato."
# output → [SUCCESS] - Processo 1 completato.
```

`cleanup` rimuove i file temporanei ed è agganciata all'evento `EXIT` tramite `trap`, quindi viene eseguita sempre, anche in caso di interruzione con `Ctrl+C`.

### 3. Ciclo
Per ogni processo viene creato un file temporaneo. Se la creazione va a buon fine, `count_success` viene incrementato; in caso contrario, `count_error`.

### 4. Errore forzato al processo 3
Al terzo giro il file appena creato viene eliminato e si tenta di leggerlo — il comando fallisce, restituisce un status code diverso da 0, e lo script:
- decrementa `count_success` (il successo precedente era falso)
- incrementa `count_error`

### 5. Report finale
```
-------------------------------------
Totale  : 5
Successi: 4
Errori  : 1
-------------------------------------
```

---

## Esecuzione

```bash
# Dai i permessi di esecuzione
chmod +x gestione_processi.sh

# Esegui lo script
./gestione_processi.sh

# Controlla il log generato
cat processi.log
```

---

## Versioni sviluppate

| Versione | Contenuto |
|---|---|
| v1 | Variabili + ciclo base |
| v2 | Simulazione processo con creazione file |
| v3 | Gestione errori e status code |
| v4 | Contatori + report finale |
| v5 | Errore forzato al processo 3 |
| v6 | Funzione `log_message` e file di log |
| v7 | `cleanup` + `trap EXIT` + `exit 0/1` ✅ |

---

## Note

- Le virgolette nei file Bash devono essere sempre **dritte** `"` — mai tipografiche `"` `"`, che causano errori di sintassi.
- `local` dentro una funzione limita la visibilità della variabile a quella funzione.
- `tee -a` scrive su schermo e in append sul file di log contemporaneamente.
- In Bash non ci sono spazi attorno a `=` nelle assegnazioni: `var="valore"` ✅ — `var = "valore"` ❌


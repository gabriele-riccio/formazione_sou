# ESERCIZIO PROCESSI ERRORE

Script Bash didattico per la gestione di processi simulati, con cicli iterativi, gestione degli errori, contatori ed errore forzato.

---

## Obiettivo

L'esercizio aveva come scopo la realizzazione di uno script Bash ,che gestisse processi ed eventuali errori, coprendo i seguenti requisiti:
— Definizione di variabili
— Ciclo for
— Gestione degli errori e degli status code
— Contatori di successi ed errori
— Simulazione di un errore forzato con status code diverso da zero
— Codice pulito e leggibile attraverso le funzioni di supporto

Ho realizzato uno script Bash che simula l'esecuzione di N processi(5), traccia successi ed errori degli stessi e gestisce la pulizia dell'ambiente in modo automatico.

---

## Struttura del progetto

```
esercizio_processi/
├──file_parte_solo_variabili.sh
├──file_parte_simualazione_processo.sh
├──file_gestione_errore.sh
├──file_gestione_errori_contatori.sh
├──file_gestione_errori_conerrori.sh
├──file_funzione.sh
├──file_gestione_errori_completo.sh  # script principale           
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
Per ogni processo viene creato un file temporaneo. Se la creazione va a buon fine, `count_success` viene incrementato; in caso contrario, `count_error` verrà incrementato.

### 4. Errore forzato al processo 3
Al terzo giro il file appena creato viene eliminato e si tenta di leggerlo — il comando fallisce, restituisce un status code diverso da 0, e lo script:
- decrementa `count_success` (il successo precedente era falso)
- incrementa `count_error`

### 5. Funzioni finali
`cleanup()` rimuove i file temporanei
`trap cleanup() exit` garantisce che cleanup venga sempre eseguita(ache quando faccio Ctrl C)

### 6. Report finale
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
./file_gestione_errori_completo.sh

# Come Output avrò:
[INFO] - Processo 1  in esecuzione...
[SUCCES] - Processo 1: Successo!
[INFO] - Processo 2  in esecuzione...
[SUCCES] - Processo 2: Successo!
[INFO] - Processo 3  in esecuzione...
[SUCCES] - Processo 3: Successo!
[Warning--Errore forzato sul processo 3..] - 
ERROR - Status code diverso da 0 su processo 3!
[INFO] - Processo 4  in esecuzione...
[SUCCES] - Processo 4: Successo!
[INFO] - Processo 5  in esecuzione...
[SUCCES] - Processo 5: Successo!
-------------------------------------
Totale  : 5
Successi: 4
Errori  : 1
-------------------------------------
[INFO] - Script terminato con 1 errore/i.
[INFO] - Per risolvere controlla il ciclo for per rimuovere l'errore forzato della simulazione.



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
| v7 | Parte completa con funzioni finali  |

---



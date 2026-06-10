# Esercizio SEMPLICE — Analisi Accessi Server

**Modulo:** Manipolazione del Testo e Automazione in Bash  
**Academy:** #6-#7 — Prova Pratica

---

## Descrizione del Problema

Un server aziendale ha subito un picco anomalo di traffico. Il file `accessi.txt` contiene una riga per ogni connessione ricevuta, con l'indirizzo IP del client. L'obiettivo è **estrarre i 3 indirizzi IP più frequenti**, ordinati dal più al meno frequente.

### File di input — `accessi.txt`

![Contenuto del file accessi.txt aperto in vim](screenshots/01_accessi_vim.png)

---

## Soluzioni

Il problema ammette almeno tre approcci distinti. Tutti producono lo stesso output corretto.

---

### Approccio 1 — Flusso Standard Unix (One-liner)

```bash
sort accessi.txt | uniq -c | sort -rn | head -3
```

#### Spiegazione passo per passo

| Comando | Cosa fa |
|---|---|
| `sort accessi.txt` | Ordina le righe alfabeticamente — gli IP uguali vengono raggruppati consecutivamente |
| `uniq -c` | Conta le occorrenze di righe consecutive identiche, premettendo il numero a sinistra |
| `sort -rn` | Ri-ordina per valore numerico (`-n`) in senso decrescente (`-r`) |
| `head -3` | Mostra solo le prime 3 righe del risultato |

#### Perché è l'approccio preferibile

È il più idiomatico in Bash: componibile, leggibile e composto esclusivamente da tool nativi Unix. Ogni comando fa una cosa sola e il risultato viene passato al successivo tramite pipe `|`.

#### Output a terminale

![Esecuzione del one-liner Unix](screenshots/02_approccio1_unix.png)

---

### Approccio 2 — Array Associativi (Logica da Programmazione)

```bash
#!/bin/bash
declare -A contatore

while IFS= read -r ip; do
    ((contatore[$ip]++))
done < accessi.txt

for ip in "${!contatore[@]}"; do
    echo "${contatore[$ip]} $ip"
done | sort -rn | head -3
```

#### Spiegazione

- `declare -A contatore` — dichiara un **array associativo** (dizionario): le chiavi sono gli IP, i valori i conteggi
- `while IFS= read -r ip` — legge il file riga per riga; `IFS=` evita che gli spazi vengano trattati come separatori
- `((contatore[$ip]++))` — incrementa il contatore per quell'IP (lo inizializza a 0 se non esiste ancora)
- `${!contatore[@]}` — espande tutte le **chiavi** dell'array associativo
- Il risultato finale viene ordinato e troncato con lo stesso `sort -rn | head -3`

---

### Approccio 3 — Array Paralleli (Ciclo Iterativo)

```bash
#!/bin/bash
ip_list=()
count_list=()

while IFS= read -r ip; do
    trovato=0
    for i in "${!ip_list[@]}"; do
        if [[ "${ip_list[$i]}" == "$ip" ]]; then
            ((count_list[$i]++))
            trovato=1
            break
        fi
    done
    if [[ $trovato -eq 0 ]]; then
        ip_list+=("$ip")
        count_list+=(1)
    fi
done < accessi.txt

for i in "${!ip_list[@]}"; do
    echo "${count_list[$i]} ${ip_list[$i]}"
done | sort -rn | head -3
```

#### Spiegazione

- Due array **paralleli**: `ip_list[i]` e `count_list[i]` sono sempre allineati (stesso indice `i`)
- Per ogni IP letto, scorre `ip_list` cercando una corrispondenza:
  - Se trovata → incrementa `count_list[i]` e imposta `trovato=1`
  - Se non trovata → aggiunge il nuovo IP e inizializza il contatore a `1`
- `break` interrompe il ciclo non appena trova la corrispondenza (ottimizzazione)

#### Output a terminale

![Esecuzione dello script con array paralleli](screenshots/03_approccio3_array.png)

---

## Output Atteso

Tutti e tre gli approcci producono lo stesso risultato:

```
3 192.168.1.10
2 10.0.0.5
2 1.2.3.4
```

---

## Confronto tra gli Approcci

| Criterio | Unix One-liner | Array Associativi | Array Paralleli |
|---|---|---|---|
| Leggibilità | ⭐⭐⭐ Alta | ⭐⭐ Media | ⭐ Bassa |
| Righe di codice | 1 | ~10 | ~20 |
| Efficienza | Alta | Alta | Bassa (O(n²)) |
| Portabilità | Alta (POSIX) | Media (bash 4+) | Alta |
| Didattico | Flusso Unix | Strutture dati | Algoritmi |

> **Scelta consigliata:** l'Approccio 1 per uso pratico; l'Approccio 2 per dimostrare padronanza delle strutture dati Bash.

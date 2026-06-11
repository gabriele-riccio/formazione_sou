# Esercizio SEMPLICE 

# Modulo: Manipolazione del Testo e Automazione in Bash.
---

## Descrizione del Problema

Un server aziendale ha subito un picco anomalo di traffico. Il file `accessi.txt` contiene una riga per ogni connessione ricevuta, con l'indirizzo IP del client. L'obiettivo è **estrarre i 3 indirizzi IP più frequenti**, ordinati dal più al meno frequente.

### File di input — `accessi.txt`

![prima parte terminale](immagini_esercizio_facile/Screenshot%202026-06-10%20alle%2014.48.45.png)

---

## Soluzioni

Il problema ammette almeno tre approcci distinti(come detto anche da voi nella traccia), tutti producono lo stesso output corretto.

---

### Approccio 1 — Flusso Standard Unix (in una sola riga del terminale)

```bash
sort accessi.txt | uniq -c | sort -rn | head -3
```

#### Spiegazione passo per passo

| Comando | Cosa fa |
|---|---|
| `sort accessi.txt` | Ordina le righe alfabeticamente, gli IP uguali vengono raggruppati consecutivamente. |
| `uniq -c` | Conta le occorrenze di righe consecutive identiche, mettendo il numero a sinistra. |
| `sort -rn` | Riordina per valore numerico (`-n`) e in senso decrescente (`-r`). |
| `head -3` | Mostra solo le prime 3 righe del risultato(dato che mi servono solo i 3 più frequenti. |

#### Perché è l'approccio preferibile?

È il più idiomatico in Bash: componibile, leggibile e composto esclusivamente da tool nativi Unix. Ogni comando fa una cosa sola e il risultato viene passato al successivo tramite le pipe `|`.

#### Output terminale(dopo aver dato i permessi)

![seconda parte terminale](immagini_esercizio_facile/Screenshot%202026-06-10%20alle%2014.47.58.png)

---

### Approccio 2 — Array Associativi (Logica da Programmazione)

```bash
#!/usr/bin/env bash
declare -A contatore

while IFS= read -r ip; do
    ((contatore[$ip]++))
done < accessi.txt

for ip in "${!contatore[@]}"; do
    echo "${contatore[$ip]} $ip"
done | sort -rn | head -3
```

#### Spiegazione:

- `declare -A contatore`: Dichiaro con esso un **array associativo** (dizionario ad esempio in python) dove le chiavi sono gli IP, i valori i conteggi.
  
- `while IFS= read -r ip`: Con questo while leggo il file accessi.txt(grazie alla riga finale `done < accessi.txt`) riga per riga e salva il testo nella
  variabile $ip.
- `IFS` e `r` servono a fare in modo che Bash legga il testo esattamente com'è, ed evitano che gli spazi vengano trattati come separatori.
- `((contatore[$ip]++))`: Cosa fa? Prende l'IP appena letto, va a cercare quell'IP nel nostro "dizionario" contatore e incrementa il suo valore di 1 con
  (++). Se è la prima volta che vede quell'IP, lo crea partendo da zero e lo porta a 1, se invece esiste già incrementa il contatore per quell'IP.
- Poi c'è un ciclo for:
  - Una volta che il ciclo while è terminato il mio dizionario contatore è pieno, con `${!contatore[@]}` prendo tutti gli ip che ci sono dentro
  - Il ciclo poi passa in rassegna ogni singolo IP e con il comando `echo` stampa a schermo una riga formattata così:
  - NumeroDiAccessi IndirizzoIP (es. 3 192.168.1.10).
  - Il risultato finale viene ordinato e troncato con lo stesso `sort -rn | head -3` di prima.
 
## Output terminale(dopo i permessi)

![terza parte terminale](immagini_esercizio_facile/Screenshot%202026-06-10%20alle%2014.48.13.png)

---

### Approccio 3 — Array Paralleli (Ciclo Iterativo)

```bash
#!/usr/bin/env bash
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

Questo script fa esattamente lo stesso lavoro di quello precedente (trovare i 3 IP più frequenti), ma adotta un approccio algoritmico diverso.
Invece di usare un array associativo (un dizionario), usa due array paralleli e indicizzati: uno per memorizzare gli IP (`ip_list`)
e uno per le occorrenze (`count_list`).
- Per prima cosa mi dichiaro due array **paralleli** vuoti: `ip_list` conterrà le stringhe degli indirizzi IP,
  mentre count_list conterrà numeri interi.
  L'indice $i collegherà l'IP al suo conteggio (es. l'IP in `ip_list[0]` avrà il suo conteggio in `count_list[0]`).

- Poi ho di nuovo un ciclo while con un ciclo for al suo interno:
- Il file accessi.txt viene letto riga per riga.
  Per ogni IP il ciclo for interno cerca se l'IP appena letto è già presente dentro `ip_list`, scorrendo tutto l'array:
    - Se l'IP è già presente (trovato=1): Incrementa di 1 il valore corrispondente in `count_list[$i]` e interrompe la ricerca con `break`.
    - Se l'IP non è presente (trovato=0): Significa che è la prima volta che lo vediamo.
      Lo aggiunge in coda a `ip_list` con l'operatore += e aggiunge il numero 1 in coda a count_list.
      
- Infine ho un ciclo for finale che scorre gli indici dei due array e stampa per ogni riga il conteggio seguito dall'indirizzo IP, con alla fine come
  per gli altri due approcci, il risultato finale viene ordinato e troncato con lo stesso `sort -rn | head -3`.
  


#### Output  terminale

![quarta parte terminale](immagini_esercizio_facile/Screenshot%202026-06-10%20alle%2014.48.20.png)

---


## Confronto tra gli Approcci

| Criterio | Unix One-liner | Array Associativi | Array Paralleli |
|---|---|---|---|
| Leggibilità | Alta | Media | Bassa |
| Righe di codice | 1 | ~10 | ~20 |
| Efficienza | Alta | Alta | Bassa (O(n²)) |
| Portabilità | Alta (POSIX) | Media (bash 4+ array associativi) | Alta |
| Didattico | Flusso Unix | Strutture dati | Algoritmi |

**Scelta consigliata:** L'Approccio 1 perchè in una sola riga ho fatto tutto quello che fanno i due lunghi script;
**NB** L'Approccio 2 va benissimo come esercizio per imparare a scrivere gli script in Bash.

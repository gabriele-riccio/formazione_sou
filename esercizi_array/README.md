# Esercizio Bonus Array
## Ordinamento, Deduplicazione e Conversione Case — Analisi delle Tre Soluzioni

---

## Traccia

Dato un array di stringhe con duplicati e maiuscole/minuscole miste:

1. **Convertire** tutto in uppercase (o lowercase)
2. **Rimuovere** i duplicati
3. **Ordinare** alfabeticamente

```bash
array_seriea=("juvenTUs" "MILAN" "napoli" "Milan" "JUVENTUS" "napoli" ...)
```

---

##  Versione 1 — Pipe Unix

> File: `file_esercizio_pipe.txt`

### Implementazione

```bash
seriea=($(printf "%s\n" "${array_seriea[@]}" \
  | tr '[:lower:]' '[:upper:]' \
  | sort \
  | uniq))
```

### Come funziona

Una catena di pipe dove ogni comando riceve l'output del precedente: `printf → tr → sort → uniq`

| Comando | Ruolo |
|---|---|
| `printf "%s\n"` | Stampa ogni elemento su una riga separata |
| `tr '[:lower:]' '[:upper:]'` | Converte in maiuscolo carattere per carattere |
| `sort` | Ordina alfabeticamente |
| `uniq` | Rimuove righe consecutive duplicate (funziona solo dopo `sort`) |

### Complessità tempo

| Fase | Comando | Complessità |
|---|---|---|
| Stampa | `printf` | O(n) |
| Conversione case | `tr` | O(n·m) |
| Ordinamento | `sort` | O(n log n) |
| Deduplicazione | `uniq` | O(n) |
| **Totale** | | **O(n·m + n log n)** |

**Spazio:** O(n·m) — i dati scorrono attraverso 4 processi separati in pipeline, ognuno con il proprio buffer.

### Pro e Contro

| Pregi | Difetti |
|---|---|
| Soluzione concisa e idiomatica Unix | Overhead di avviare 4 processi separati |
| Leggibile per chi conosce i comandi Unix | `$()` può avere comportamenti inattesi con stringhe che contengono spazi |

---

##  Versione 2 — Script Bash con Cicli e Array Associativi

> File: `file_esercizio_bash.sh`

### Implementazione

Il problema è diviso in tre fasi esplicite:

**Fase 1 — Uppercase con ciclo `for`**

```bash
declare -a upper_list
for item in "${INPUT[@]}"; do
  upper_list+=( "${item^^}" )
done
```

> `${item^^}` è la sintassi Bash ≥ 4 per la conversione in maiuscolo. Ho scaricato la versione 5.3.9 di Bash.

**Fase 2 — Deduplicazione con array associativo**

```bash
declare -A seen
declare -a unique

for item in "${upper_list[@]}"; do
  if [[ -z "${seen[$item]}" ]]; then
    seen["$item"]=1
    unique+=( "$item" )
  fi
done
```

> L'array associativo `seen` funziona come un **set Python**: se la chiave non esiste ancora, l'elemento è nuovo e viene aggiunto a `unique`.

**Fase 3 — Bubble Sort**

```bash
for (( i=0; i<n-1; i++ )); do
  for (( j=0; j<n-1-i; j++ )); do
    if [[ "${unique[$j]}" > "${unique[$((j+1))]}" ]]; then
      tmp="${unique[$j]}"
      unique[$j]="${unique[$((j+1))]}"
      unique[$((j+1))]="$tmp"
    fi
  done
done
```

> Due cicli annidati confrontano elementi adiacenti e li scambiano se fuori ordine.
> Ad ogni passata esterna, l'elemento "più grande" alfabeticamente scivola verso la fine.

### Complessità

| Fase | Metodo | Complessità |
|---|---|---|
| Uppercase | Ciclo `for` + `${item^^}` | O(n·m) |
| Deduplicazione | Array associativo (hash map) | O(n·m) |
| Ordinamento | **Bubble Sort** | O(k²) nel caso peggiore |
| **Totale** | | **O(n·m + k²)** |

> N.B Il Bubble Sort è il punto debole: con `k` elementi unici, nel caso peggiore esegue `k²` confronti. Su grandi dataset è significativamente più lento del `sort` Unix (O(n log n)).

**Spazio:** O(n·m) — `upper_list`, `seen` e `unique` sono tutti in memoria contemporaneamente.

### Pro e Contro

| Pregi |  Difetti |
|---|---|
| Didatticamente chiaro: ogni fase è esplicita | Bubble Sort è O(k²): lento su liste grandi |
| Nessun processo esterno | Più verboso della versione pipe |
| Deduplicazione con array associativo efficiente O(1) per lookup | Richiede Bash ≥ 4 (o ≥ 5 per `${item^^}`) |

---

## Versione 3 — Python

> File: `file_esercizio_python.py`

### Implementazione

```python
# Versione compatta (one-liner)
result_oneliner = sorted(set(s.lower() for s in INPUT))

# Versione esplicita
uppered = [s.upper() for s in INPUT]   # fase 1: case conversion
unique  = set(uppered)                  # fase 2: deduplicazione
result  = sorted(unique)                # fase 3: ordinamento
```

### Come funziona

| Fase | Metodo | Dettaglio |
|---|---|---|
| **Uppercase** | List comprehension + `.upper()` | Applicata elemento per elemento |
| **Deduplicazione** | `set()` — hash table interna | Elementi duplicati ignorati silenziosamente in O(1) |
| **Ordinamento** | `sorted()` — **Timsort** | Algoritmo ibrido MergeSort + InsertionSort, ottimizzato per dati reali |

### Complessità tempo

| Fase | Metodo | Complessità |
|---|---|---|
| Uppercas | List comprehension + `.upper()` | O(n·m) |
| Deduplicazione | `set()` — hash table | O(n·m) |
| Ordinamento | `sorted()` — Timsort | O(k log k) garantito |
| **Totale** | | **O(n·m + k log k)** |

**Spazio:** O(n·m) — `lowered`, `unique` (set) e `result` sono tutti referenziati in memoria.

### Pro e Contro

| Pregi |  Difetti |
|---|---|
| Soluzione più efficiente grazie a Timsort | Richiede Python (non sempre disponibile in ambienti minimali) |
| Sintassi pulita e leggibile | — |
| `set()` gestisce la deduplicazione in modo nativo | — |
| Correttezza verificabile con `assert` | — |

---

##  Confronto Finale

| Aspetto |  Pipe Unix |  Bash + Cicli |  Python |
|---|:---:|:---:|:---:|
| Tempo — case conversion | O(n·m) | O(n·m) | O(n·m) |
| Tempo — deduplicazione | O(n)* | O(n·m) | O(n·m) |
| Tempo — ordinamento | O(n log n) | **O(k²)** | O(k log k) |
| Spazio totale | O(n·m) | O(n·m) | O(n·m) |
| Processi creati | 4 | 1 | 1 |
| Leggibilità | Alta (Unix) | Alta (didattica) | Altissima |
| **Ideale per** | Scripting rapido | Apprendimento | Performance |

> \* `sort | uniq` usa internamente O(n log n) per l'ordinamento; la deduplicazione successiva con `uniq` è O(n).

---

##  Conclusione

Tutte e tre le versioni hanno lo stesso **costo in spazio O(n·m)**, ma differiscono nel tempo:

- **Pipe Unix** e **Python** raggiungono entrambe O(n·m + n log n) — complessità ottimale per questo problema.
- **Bash** è l'unica versione penalizzata dal **Bubble Sort O(k²)**, che la rende significativamente più lenta su dataset grandi.

```
n = numero totale di elementi (inclusi i duplicati)
k = numero di elementi unici  (k ≤ n)
m = lunghezza media delle stringhe
```



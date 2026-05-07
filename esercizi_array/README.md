# Esercizio bonus array --Analisi delle tre soluzioni – Ordinamento, deduplicazione e conversione case

## Descrizione

Il problema da risolvere

Dato un array di stringhe con duplicati e maiuscole/minuscole miste:

Convertire tutto in uppercase (o lowercase)
Rimuovere i duplicati
Ordinare alfabeticamente
---

## Versione 1 – Pipe Unix(file_esercizio_pipe.txt)
```
array_seriea=("juvenTUs" "MILAN" "napoli" ...)
```
seriea=($(printf "%s\n" "${array_seriea[@]}" \
  | tr '[:lower:]' '[:upper:]' \
  | sort \
  | uniq))

```
Ho costruito una catena di pipe dove ogni comando riceve l'output del precedente:
printf → tr → sort → uniq

```
printf "%s\n" → stampa ogni elemento su una riga separata
tr '[:lower:]' '[:upper:]' → converte tutto in maiuscolo carattere per carattere
sort → ordina alfabeticamente
uniq → rimuove le righe consecutive duplicate (funziona correttamente solo dopo sort)

**Costo in tempo**
FaseComandoComplessitàStampaprintfO(n)Conversione casetrO(n·m) – scorre ogni carattere di ogni stringaOrdinamentosortO(n log n) – algoritmo interno efficienteDeduplicazioneuniqO(n) – una sola passata lineareTotaleO(n·m + n log n)

**Costo in spazio**


O(n·m) per i dati che scorrono attraverso la pipe
Ogni processo nella pipe ha un buffer in memoria
In totale vengono creati 4 processi separati che comunicano tramite pipe

**Pregi e difetti**
✅ Soluzione più concisa (una sola riga logica) e idiomatica Unix
✅ Molto leggibile per chi conosce i comandi Unix
⚠️ Overhead di avviare più processi separati
⚠️ L'uso di $(...) per catturare l'output in un array può avere comportamenti inattesi con stringhe contenenti spazi

## Versione 2 – Script Bash con cicli e array associativi (file_esercizio_bash.sh)

Ho diviso il problema in tre fasi esplicite:
**Fase 1 – Uppercase con ciclo for**

declare -a upper_list
for item in "${INPUT[@]}"; do
  upper_list+=( "${item^^}" )
done

${item^^} è la sintassi Bash ≥4 per convertire in maiuscolo. Ho dovuto scaricare la versione 5.3.9 di BASH.

**Fase 2 – Deduplicazione con array associativo**

declare -A seen
declare -a unique

for item in "${upper_list[@]}"; do
  if [[ -z "${seen[$item]}" ]]; then
    seen["$item"]=1
    unique+=( "$item" )
  fi
done

Uso un array associativo (dizionario) come "memoria": se la chiave non esiste ancora in seen, l'elemento è nuovo e va aggiunto a unique. 
Questo è esattamente come funziona un set in Python.

**Fase 3 – Bubble Sort**

for (( i=0; i<n-1; i++ )); do
  for (( j=0; j<n-1-i; j++ )); do
    if [[ "${unique[$j]}" > "${unique[$((j+1))]}" ]]; then
      tmp="${unique[$j]}"
      unique[$j]="${unique[$((j+1))]}"
      unique[$((j+1))]="$tmp"
    fi
  done
done

Implemento manualmente il Bubble Sort: due cicli annidati confrontano elementi adiacenti e li scambiano se sono nell'ordine sbagliato. Ad ogni passata del ciclo esterno, l'elemento "più grande" alfabeticamente va verso la fine dell'array.

**Costo in tempo**
FaseMetodoComplessitàUppercaseCiclo for + ${item^^}O(n·m)DeduplicazioneArray associativo (hash map)O(n·m) – hashing di ogni stringaOrdinamentoBubble SortO(k²) nel caso peggioreTotaleO(n·m + k²)

⚠️ Il punto debole è il Bubble Sort: con k elementi unici, nel caso peggiore fa k² confronti. È l'algoritmo di ordinamento più lento tra quelli comuni. Su liste piccole non si nota, ma su grandi dataset è molto più lento del sort della versione 1 (che usa algoritmi O(n log n)).

**Costo in spazio**

upper_list → O(n·m) – copia dell'array in uppercase
seen → O(k·m) – array associativo con k elementi unici
unique → O(k·m) – array finale deduplicato
Totale: O(n·m) – usi più array in memoria contemporaneamente

**Pregi e difetti**
✅ Didatticamente molto chiaro: ogni fase è esplicita e commentata
✅ Nessun processo esterno: tutto avviene dentro bash
✅ La deduplicazione con array associativo è efficiente (O(1) per ogni lookup)
⚠️ Il Bubble Sort è O(k²): molto più lento di sort per liste grandi
⚠️ Più verboso della versione con pipe



## Versione 3 – Python (file_esercizio_python.sh)
# Versione compatta
result_oneliner = sorted(set(s.lower() for s in INPUT))

# Versione esplicita
lowered = [s.lower() for s in INPUT]   # fase 1
unique = set(lowered)                   # fase 2
result = sorted(unique)                 # fase 3

**Fase 1 - Uppercase:** list comprehension che applica .lower() a ogni stringa.
**Fase 2 – Deduplicazione con set():** il set di Python è internamente una hash table. Quando inserisci un elemento, calcola il suo hash e lo posiziona nella tabella: se l'hash esiste già, l'elemento è duplicato e viene ignorato silenziosamente.
**Fase 3 – Ordinamento con sorted():** usa Timsort, un algoritmo ibrido tra MergeSort e InsertionSort, ottimizzato per dati reali parzialmente ordinati.

**Costo in tempo**
FaseMetodoComplessitàLowercaseList comprehension + .lower()O(n·m)Deduplicazioneset() – hash tableO(n·m) – hashing di ogni stringaOrdinamentosorted() – TimsortO(k log k) garantitoTotaleO(n·m + k log k)
Dove:

n = numero totale di elementi (con duplicati)
k = numero di elementi unici (k ≤ n)
m = lunghezza media delle stringhe

**Costo in spazio**

uppered → O(n·m)
unique (set) → O(k·m)
result → O(k·m)
Totale: O(n·m)

**Pregi e difetti**
✅ Soluzione più efficiente in termini di tempo grazie a Timsort
✅ Sintassi molto pulita e leggibile
✅ set() gestisce la deduplicazione in modo nativo e ottimizzato
✅ Hai verificato correttezza con assert
⚠️ Richiede Python (non sempre disponibile in ambienti server minimali)

## Confronto finale tra le tre versioni
| Aspetto | Pipe Unix | Bash + Cicli | Python |
|---|---|
| Tempo – case conversion | O(n·m) |  O(n·m)   |   O(n·m)     |
|Tempo – deduplicazione | O(n log n)*  | O(n log n)*   |    O(n·m)     |
| Tempo – ordinamento | O(n log n) |   O(k²) ⚠️   |    O(k log k)    |
|Spazio | O(n·m) |  O(n·m)    |    O(n·m)    |
| Processi creati| 4 |   1   |    1    |
| Leggibilità | Alta (per chi conosce Unix) |  Alta(didattica)    |    Altissima    |
| Soluzione migliore per | Scripting rapido |  Apprendimento    |  Performance      |

*sort | uniq nella pipe usa internamente un algoritmo O(n log n) e la deduplicazione avviene in O(n) dopo l'ordinamento.

## Conclusione
Tutte e tre le versioni hanno lo stesso costo in spazio (O(n·m)), ma differiscono nel tempo:

La versione **Pipe** e **Python** hanno entrambe complessità temporale O(n·m + n log n), che è ottimale
La versione **Bash** è l'unica penalizzata dal Bubble Sort O(k²), che la rende significativamente più lenta su dataset grandi


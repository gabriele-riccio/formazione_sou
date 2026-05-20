# Esercizio Bash — ODD/EVEN

**Obiettivo:** scrivere uno script Bash che accetti un argomento numerico e stampi la sequenza di numeri da 1 a quel numero indicando se ciascuno è pari o dispari. Lo script deve gestire correttamente gli errori di input.

---

## Utilizzo

```bash
./file_odd_even.sh <numero>
```

---

## Gestione degli errori

Lo script controlla tre condizioni di errore nell'ordine:

### 1 — Numero di argomenti errato

```bash
if [ $# -ne 1 ]; then
    echo "Errore: numero di argomenti non valido." >&2
    echo "Uso: $0 <numero>" >&2
    exit 1
fi
```

- `$#` contiene il numero di argomenti passati allo script
- `-ne 1` significa "not equal to 1"
- `>&2` reindirizza il messaggio di errore sullo standard error
- `exit 1` termina lo script con codice di uscita 1

### 2 — Argomento non numerico

```bash
if ! [[ $1 =~ ^[0-9]+$ ]]; then
    echo "Errore: l'argomento '$1' non è un numero intero positivo." >&2
    exit 2
fi
```

- `[[ $1 =~ ^[0-9]+$ ]]` usa una regex per verificare che l'argomento sia composto solo da cifre
- `^` ancora all'inizio, `$` ancora alla fine → esclude stringhe miste come `12abc`
- Il `!` nega la condizione: entra nell'if se il match fallisce
- `exit 2` codice di uscita dedicato agli errori di tipo

### 3 — Argomento uguale a zero

```bash
if [ $1 -eq 0 ]; then
    echo "Errore: il numero deve essere maggiore di 0." >&2
    exit 3
fi
```

- Non sapevo come includere lo 0 che è < 1
- `-eq 0` confronta il valore numerico con 0, se sono uguali manda l'errore.
- `exit 3` codice di uscita dedicato al caso zero

---

## Logica principale

```bash
for (( i=1; i<=$1; i++ )); do
    if (( i % 2 == 0 )); then
        echo "$i -> pari"
    else
        echo "$i -> dispari"
    fi
done
```

- `for (( i=1; i<=$1; i++ ))` — ciclo in stile javascript/C++ che va da 1 all'argomento dato
- `(( i % 2 == 0 ))` — usa l'aritmetica bash con `%` che restituisce il resto della divisione per 2
  - se il resto è 0 → il numero è **pari**
  - se il resto è 1 → il numero è **dispari**

---

## Codici di uscita

| Codice | Significato |
|--------|-------------|
| `0` | Esecuzione completata con successo |
| `1` | Numero di argomenti errato |
| `2` | Argomento non numerico |
| `3` | Argomento uguale a zero |

---
## Come eseguire lo script

```bash
# Rendi lo script eseguibile
chmod +x odd_even.sh

# Eseguilo
./odd_even.sh 10
```

---
## Esempi

### Input valido

```bash
./odd_even.sh 7
```

```
1 -> dispari
2 -> pari
3 -> dispari
4 -> pari
5 -> dispari
6 -> pari
7 -> dispari
```

### Nessun argomento

```bash
./odd_even.sh
```

```
Errore: numero di argomenti non valido.
Uso: ./odd_even.sh <numero>
```

### Troppi argomenti

```bash
./odd_even.sh 3 7
```

```
Errore: numero di argomenti non valido.
Uso: ./odd_even.sh <numero>
```

### Argomento non numerico

```bash
./odd_even.sh ciao
```

```
Errore: l'argomento 'ciao' non è un numero intero positivo.
```

### Argomento zero

```bash
./odd_even.sh 0
```

```
Errore: il numero deve essere maggiore di 0.
```

### Argomento misto (numeri e lettere)

```bash
./odd_even.sh 12abc
```

```
Errore: l'argomento '12abc' non è un numero intero positivo.
```

---


## Riepilogo costrutti usati

| Costrutto | Significato |
|-----------|-------------|
| `$#` | Numero di argomenti passati allo script |
| `$1` | Primo argomento |
| `$0` | Nome dello script |
| `-ne` | Operatore numerico "not equal" |
| `-eq` | Operatore numerico "equal" |
| `[[ =~ ]]` | Test con regex estesa |
| `^[0-9]+$` | Regex: solo cifre dall'inizio alla fine |
| `>&2` | Redirige output sullo standard error |
| `exit N` | Termina lo script con codice N |
| `(( ))` | Aritmetica intera in Bash |
| `%` | Operatore modulo (resto della divisione) |

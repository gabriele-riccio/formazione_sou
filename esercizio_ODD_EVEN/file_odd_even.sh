#!/bin/bash

# Controllo numero di argomenti
if [ $# -ne 1 ]; then
    echo "Errore: numero di argomenti non valido." >&2
    echo "Uso: $0 <numero>" >&2
    exit 1
fi

# Controllo che l'argomento sia numerico (intero positivo)
if ! [[ $1 =~ ^[0-9]+$ ]]; then
    echo "Errore: l'argomento '$1' non è un numero intero positivo." >&2
    exit 2
fi

# Controllo che il numero sia maggiore di 0
if [ $1 -eq 0 ]; then
    echo "Errore: il numero deve essere maggiore di 0." >&2
    exit 3
fi

# Sequenza da 1 a N
for (( i=1; i<=$1; i++ )); do
    if (( i % 2 == 0 )); then
        echo "$i -> pari"
    else
        echo "$i -> dispari"
    fi
done

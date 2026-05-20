#!/usr/bin/env bash

#Questo file denominato file_odd_even.sh è uno script per l'esecuzione dell'esercizio dove bisogna scrivere uno script che accetti 
#un argomento numerico e stampi la sequenze di numeri da 1 a quel numero con l'indicazione se è pari o dispari.

#La prima cosa che ho fatto è stata scrivere un iterazione con if che blocchi l'esecuzione se si inviano degli argomenti numerici >1:
#if [ $# -ne 1 ] infatti controlla se il numero di argomenti passati allo script (contenuti in $# ) sia 
#not equal a 1(diversi da 1); se è così stampa l'errore e lo reinderizza allo standard error(stderr >&2) ed interrompe lo script con exit 1.

#Se è stato inserito un solo argomento vado avanti:
#Con un'altro if controllo che l'argomento sia numerico(intero positivo) con if ! [[ $1 =~ ^[0-9]+$ ]] e le espressioni regolari(regex)
#Con ! che indica il not, con =~ che mi mette in confronto la variabile $1 a sx con la regex a dx e con ^[0-9]+$ che è la regex che definisce
#un numero intero senza segni(con ^ che indica inizio riga, [0-9] cifre da 0 a 9, + che indica che può essere presente più di una volta e $ fine riga)
#In poche parole dice se l'argomento non è una cifra intera non va bene l'input, stampo l'errore e lo mando sempre nello stderr.

#Poi non sapevo come includere se il numero fosse compreso tra 0 e 1 dato che la regex [0-9] include anche lo 0.
#Allora ho usato un if ulteriore che controllasse che l'argomento $1 fosse -eq 0 cioè uguale a 0, se è così stampa errore 
#e stampo l'errore e lo mando sempre nello stderr.

#Poi il ciclo for (con argomento la variabile i=1 in modo che comincio da 1 l'iterazione, che man mano che i è minore uguale all'argomento 
#continua il ciclo aumentando i di 1) stampando man mano i numeri dicendo se sono pari fino all'argomento inserito.

# Controllo numero di argomenti
if [ $# -ne 1 ]; then
    echo "Errore: numero di argomenti non valido." >&2
    exit 1
fi

# Controllo che l'argomento sia numerico (intero positivo)
if ! [[ $1 =~ ^[0-9]+$ ]]; then
    echo "Errore: l'argomento '$1' non è un numero intero positivo." >&2
    exit 2   #Metto exit diversi, basta siano diversi da 0 per differenziarli
fi

# Controllo che il numero sia maggiore di 0
if [ $1 -eq 0 ]; then
    echo "Errore: il numero deve essere maggiore di 0." >&2
    exit 3  #Metto exit diversi, basta siano diversi da 0 per differenziarli
fi

# Sequenza da 1 a N
for (( i=1; i<=$1; i++ )); do
    if (( i % 2 == 0 )); then
        echo "$i -> pari"
    else
        echo "$i -> dispari"
    fi
done

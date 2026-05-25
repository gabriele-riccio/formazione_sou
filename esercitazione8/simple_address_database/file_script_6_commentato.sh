#!/bin/bash4
#si può usare anche #!/usr/bin/env bash

#questo script mostra come utilizzare gli array associativi (conosciuti in altri linguaggi di programmazione come dizionari,
#mappe o chiave-valore) che abbiamo già usato in un esercizio precedente.

#A differenza degli array normali, che usano i numeri come indice (0, 1, 2...), 
#gli array associativi permettono di usare del testo (stringhe) come indice per memorizzare e recuperare i dati. 
#Nel caso specifico di questo script, viene creata una rubrica in cui il nome di una persona è la chiave e il suo indirizzo è il valore.

#per prima cosa si dichiara l'array associativo address con -A a differenza della dichiarazione di un array normale con -a.

#Poi vengono inseriti tre elementi (3 valori che indicano la via, la città e il Cap) 
#all'interno dell'array address, usando i nomi propri come chiavi(tra parentesi quadre).

#poi vengono stampati gli indirizzi per ogni persona usando la variabile dollaro e l'array associativo appena creato (con le parentesi 
#graffe, che è il modo per leggere tale array in bash.

#infine si usa "${!address[*]}" recuperare l'elenco di tutte le chiavi (indici) registrate nell'array, anziché i loro valori, dato che ! dice 
# a Bash "voglio le chiavi, non i valori" mentre l'asterisco * significa "tutti gli elementi".


# fetch_address.sh

declare -A address
#       -A option declares associative array.

address[Charles]="414 W. 10th Ave., Baltimore, MD 21236"
address[John]="202 E. 3rd St., New York, NY 10009"
address[Wilma]="1854 Vermont Ave, Los Angeles, CA 90023"


echo "Charles's address is ${address[Charles]}."
# Charles's address is 414 W. 10th Ave., Baltimore, MD 21236.
echo "Wilma's address is ${address[Wilma]}."
# Wilma's address is 1854 Vermont Ave, Los Angeles, CA 90023.
echo "John's address is ${address[John]}."
# John's address is 202 E. 3rd St., New York, NY 10009.

echo

echo "${!address[*]}"   # The array indices ...
# Charles John Wilma

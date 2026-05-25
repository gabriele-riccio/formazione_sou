#!/bin/bash
# Naked variables
#Questo script Bash serve a spiegare una regola fondamentale: il concetto di "naked variables" (variabili "nude"), 
#ovvero quando il nome di una variabile deve essere scritto senza il simbolo $ davanti.

#la regola dice che Il nome della variabile è "nudo" (senza $) quando le si sta assegnando un valore, mentre 
#si usa il $ davanti al nome quando si vuole fare riferimento a quel valore.
#lo script mostra questa regola attraverso 4 scenari diversi:

#'Assegnazione diretta' cioè a=879 la variabile a è "nuda" perché ha inserito il valore 879 al suo interno.
mentre quando lo stampiamo echo "The value of \"a\" is $a." usa $a perché 
si vuole leggere e stampare a schermo il valore memorizzato (restituirà 879).

#stessa cosa per le assegnazioni usando espressioni matematiche con let per fare la somma 16 + 5 a è nuda mentre 
#quando lo stampiamo echo "The value of \"a\" is $a." usa $a perché si vuole leggere e stampare a schermo il valore memorizzato 
#(restituirà 21).

#in un ciclo for uso si effettua un'assegnazione automatica dove ad ogni iterazione del ciclo, 
# prende un numero dall'elenco e lo assegna alla variabile a, che sarà nuda. mentre nella stampa prende il valore che ha in quel momento
#cioè $a.

#se lo scrive l'utente in input: con read ferma lo script e il terminale aspetta che l'utente scriva qualcosa
#Quello che si scrive viene salvato nella  variabile nuda a
#poi viene stampato come valore $a

#in breve Senza $ si scrive/assegna, Con $ si legge/invoca.


echo

# When is a variable "naked", i.e., lacking the '$' in front?
# When it is being assigned, rather than referenced.

# Assignment
a=879
echo "The value of \"a\" is $a."

# Assignment using 'let'
let a=16+5
echo "The value of \"a\" is now $a."

echo

# In a 'for' loop (really, a type of disguised assignment):
echo -n "Values of \"a\" in the loop are: "
for a in 7 8 9 11
do
  echo -n "$a "
done

echo
echo

# In a 'read' statement (also a type of assignment):
echo -n "Enter \"a\" "
read a
echo "The value of \"a\" is now $a."

echo

exit 0 

#!/bin/bash

#Questo script Bash serve a mostrare come gestire e leggere i parametri (o argomenti) passati da riga di comando quando si esegue uno script.
#Per prima cosa dichiara una variabile che indica il numero minimo di argomenti richiesti dallo script 
#per funzionare correttamente (in questo caso, 10).

#Dopo attraverso echo stampa il nome dello script, sapendo che la variabile $0 
#contiene il nome dello script così come è stato digitato nel terminale (ad esempio ./file_script_3.sh).
#Inolre il comando basename serve a prendere solo il nome del file. 
#Se lo si avvia con /desktop/file_script_3.sh, questo comando stamperà solo file_script_3.sh.

#poi c'è un if che controlla uno per uno tutti i parametri che gli vengono dati:
#infatti fa per ogni parametro(1 a 10) if [ -n "$1" ] (ovvero "se il parametro numero 1 NON è vuoto") stampa il parametro $1 è 1 etc

#N.B Il parametro 10 viene messo tra le parentesi graffe, ho visto su internet perchè 
#Bash lo leggerebbe come la variabile $1 seguita dal numero zero, creando un errore.

#Poi c'è la stampa di tutti i parametri passati con la varriabile $*  attraverso un'unica stringa di testo e 
#un if finale che stampa errore se si inviano dal terminale meno di 10 parametri.

# Call this script with at least 10 parameters, for example
# ./scriptname 1 2 3 4 5 6 7 8 9 10
MINPARAMS=10

echo

echo "The name of this script is \"$0\"."
# Adds ./ for current directory
echo "The name of this script is \"`basename $0`\"."
# Strips out path name info (see 'basename')

echo

if [ -n "$1" ]              # Tested variable is quoted.
then
 echo "Parameter #1 is $1"  # Need quotes to escape #
fi 

if [ -n "$2" ]
then
 echo "Parameter #2 is $2"
fi 

if [ -n "$3" ]
then
 echo "Parameter #3 is $3"
fi 

# ...


if [ -n "${10}" ]  # Parameters > $9 must be enclosed in {brackets}.
then
 echo "Parameter #10 is ${10}"
fi 

echo "-----------------------------------"
echo "All the command-line parameters are: "$*""

if [ $# -lt "$MINPARAMS" ]
then
  echo
  echo "This script needs at least $MINPARAMS command-line arguments!"
fi  

echo

exit 0


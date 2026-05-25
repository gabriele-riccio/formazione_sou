#!/bin/bash

#Questo script Bash serve a spiegare il funzionamento degli Exit Status (stati di uscita)  
#focalizzandosi in particolare sull'uso della variabile speciale $?.

#In informatica, ogni volta che un comando viene eseguito nel terminale, restituisce al sistema un numero intero (da 0 a 255) chiamato "exit status". 
#Questo numero serve a capire se il comando ha avuto successo o se si è verificato un errore.

#alcuni esempi
#1  Comando riuscito
# stampa con echo hello la parola "hello" ed essendo un comando valido si conclude con successo(lo 0 è il successo, da 1 in poi errore).
# stampa con echo $? la variabile $? che contiene l'exit status dell'ultimo comando eseguito (in questo caso, echo hello).
# e poiché il comando è andato a buon fine, $? conterrà il valore 0, per cui lo script quindi stamperà 0.
#2 Comando fallito
#se scrivo un comando non conosciuto e poi faccio echo $ mi stampa di nuovo command failed to execute (tipicamente 127 per i comandi non trovati)
#3 Uscita personalizzata dallo script
#exit 113: Il comando exit termina immediatamente lo script. 
#Il numero che inserisce dopo (113) diventa l'exit status dello script stesso(lo facciamo negli script con exit 1 per differnziarlo da exit 0
#oppure con exit 2,3,4 etc per differnziare errori diversi.


echo hello
echo $?    # Exit status 0 returned because command executed successfully.

lskdf      # Unrecognized command.
echo $?    # Non-zero exit status returned -- command failed to execute.

echo

exit 113   # Will return 113 to shell.
           # To verify this, type "echo $?" after script terminates.

#  By convention, an 'exit 0' indicates success,
#+ while a non-zero exit value means an error or anomalous condition.
#  See the "Exit Codes With Special Meanings" appendix.

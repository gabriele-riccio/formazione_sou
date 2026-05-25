#! /bin/bash
# progress-bar2.sh
# Author: Graham Ewart (with reformatting by ABS Guide author).
# Used in ABS Guide with permission (thanks!).

#Questo script Bash mostra un metodo per creare una barra di avanzamento testuale (composta da punti ....) 
#che gira in background mentre il sistema esegue un processo lungo o un calcolo pesante. Esso non funziona in sh per cui si invoca solo 
#bash nome_file.

#Per prima cosa dichiara delle variabili:
#interval=1 che stabilisce che la barra di avanzamento stamperà un punto . ogni secondo e 
#long_interval=10 che simula la durata del "processo lungo" (in questo caso, un'attesa di 10 secondi).

#Tutto il codice viene racchiuso tra le parentesi graffe '{ ... } &'  e  viene eseguito in background (grazie alla & finale)
#
#trap "exit" SIGUSR1  dice al processo in background che se riceve il segnale  SIGUSR1, interrompe immediatamente l' esecuzione.
#mentre poi c'è un ciclo while true con  do echo -n '.'; sleep $interval che è un ciclo infinito che stampa 
#un punto alla volta senza andare a capo (echo -n) e poi aspetta un secondo prima di stampare il successivo.

#Poi c'è la gestione dei pid 
#viene chiamata la variabile pid=$! che dice che  $! cattura l'ID del processo (PID) dell'ultimo comando avviato in background 
#(ovvero il ciclo di punti appena descritto) per poterlo spegnere in seguito.
# poi c'è trap "echo !; kill -USR1 $pid; wait $pid" EXIT che è una misura di sicurezza in caso l'utente interrompa
# bruscamente lo script premendo CTRL+c con il comando trap che intercetta l'uscita (EXIT) uccide il processo in background dei punti e pulisce il terminale.
#Senza questo, i punti continuerebbero a essere stampati all'infinito anche dopo la chiusura dello script.

#poi c'è la simulazione di quello che succede
#con echo -n 'Long-running process ' seguito da sleep $long_interval viene stampato il testo iniziale 
#e il sistema simula un lavoro di 10 secondi. 
#Durante questi 10 secondi, il ciclo in background continua a stampare punti (...) sulla stessa riga.

# poi echo ' Finished!' finisce il processo e con kill -USR1 $pid e wait $pid il processo principale dice a quello in background
#di spegnersi inviando il segnale SIGUSR1 che ha impostato all'inizio.

#Poi trap EXIT rimuove la trappola di sicurezza, poiché lo script sta terminando normalmente e non c'è più bisogno di gestire interruzioni anomale.


# Invoke this script with bash. It doesn't work with sh.

interval=1
long_interval=10

{
     trap "exit" SIGUSR1
     sleep $interval; sleep $interval
     while true
     do
       echo -n '.'     # Use dots.
       sleep $interval
     done; } &         # Start a progress bar as a background process.

pid=$!
trap "echo !; kill -USR1 $pid; wait $pid"  EXIT        # To handle ^C.

echo -n 'Long-running process '
sleep $long_interval
echo ' Finished!'

kill -USR1 $pid
wait $pid              # Stop the progress bar.
trap EXIT

exit $?

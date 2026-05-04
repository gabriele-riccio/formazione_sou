#!/bin/bash

#================================================================================
#Nome file= file_gestione_processi.sh
#Descrizione esercizio= Gestione dei processi,cicli,errori e contatori in Bash
#================================================================================
#in questa parte voglio procedere dopo l'inserimento dei contatori, uno che conta i successi e uno che conta gli errori e un report finale, provo a creare un errore che cat non riesce a leggere anche perchè l'ho eliminato prima con rm dopo aver forzato l'errore.



#1)Prima cosa definisco delle variabili:le metto in maiuscolo proprio perchè devono essere costanti.

NUM_PROCESSI=5

#è ilnumero di volte che il ciclo for deve girare, per il momento ne lascio 5 poi vedrò se aumentare.

#2)Definisco i contatori uno per i successi e uno per gli errori.

count_success=0
count_error=0
#partono da zero e vengono incrementati man mano.

#Ciclo for, dove effettuo una simulazione del processo, per ogni iterazione creo un file, vedendo ulteriormente se c'è l'errore.
#Praticamente uguale a prima ma aggiungo l'incremento del contatore successo e errore se fallisce.
for((i=1; i<=NUM_PROCESSI; i++))do
        echo "Processo $i  in esecuzione..."
        # Simulazione processo: creiamo un file per ogni iterazione
        if echo "dati processo $i" > "processo_$i.txt"; then
                # $? == 0 : comando riuscito
                echo "Processo $i: successo!"
                ((count_success++))
        else
                # $? != 0 : comando fallito
                echo "Processo $i: errore!"
                ((count_error++))
        fi
        # Errore forzato su un processo, esempio 3
        if [ $i -eq 3 ]; then
                echo "Warning--Errore forzato sul processo 3.."
                #elimino con rm il processo appena creato.
                rm "processo_3.txt"

                #proverò a leggerlo con cat ma fallirà perchè non esiste più.
                if ! cat "processo_3.txt" 2>/dev/null; then
                        echo "ERROR - Status code diverso da 0 su processo $i!"
                        ((count_success--))  #correggo dato che il successo è falso!
                        ((count_error++))
                fi
        fi


done

#N.B In questo caso ci saranno solo 4 successisu 5 e un errore.

#Faccio un report finale con numero successi e numero errori come prima.
# --- Report ---
echo "-------------------------------------"
echo "Totale  : $NUM_PROCESSI"
echo "Successi: $count_success"
echo "Errori  : $count_error"

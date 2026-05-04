#!/bin/bash

#================================================================================
#Nome file= file_gestione_processi.sh
#Descrizione esercizio= Gestione dei processi,cicli,errori e contatori in Bash
#================================================================================
#in questa parte voglio procedere all'inserimento dei contatori, uno che conta i successi e uno che conta gli errori e un report finale.



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

done
#N.B Anche in questo caso ci saranno solo successi.

#Faccio un report finale con numero successi e numero errori.
# --- Report ---
echo "-------------------------------------"
echo "Totale  : $NUM_PROCESSI"
echo "Successi: $count_success"
echo "Errori  : $count_error"
echo "-------------------------------------"

# Dai i permessi di esecuzione
#chmod +x file_gestione_processi.sh

# Esegui lo script
#./file_gestione_processi.sh

# Come Output avrò:
Processo 1  in esecuzione...
Processo 1: successo!
Processo 2  in esecuzione...
Processo 2: successo!
Processo 3  in esecuzione...
Processo 3: successo!
Processo 4  in esecuzione...
Processo 4: successo!
Processo 5  in esecuzione...
Processo 5: successo!
-------------------------------------
Totale  : 5
Successi: 5
Errori  : 0
-------------------------------------


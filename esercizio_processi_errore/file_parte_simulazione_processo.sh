#!/bin/bash

#================================================================================
#Nome file= file_gestione_processi.sh
#Descrizione esercizio= Gestione dei processi,cicli,errori e contatori in Bash
#================================================================================
#in questa parte voglio procedere alla simulazione dei processi, ogni iterazione crea un file processo_1.txt etc.

#1)Prima cosa definisco delle variabili:le metto in maiuscolo proprio perchè devono essere costanti.

NUM_PROCESSI=5

#è ilnumero di volte che il ciclo for deve girare, per il momento ne lascio 5 poi vedrò se aumentare

#Ciclo for, dove effettuo una simulazione del processo, per ogni iterazione creo un file.
for((i=1; i<=NUM_PROCESSI; i++))do
        echo "Processo $i  in esecuzione..."
        echo "dati processo $i" > "processo_$i.txt"
        echo "Processo $i: file creato."
done

# Dai i permessi di esecuzione
#chmod +x file_parte_simulazione_processo.sh

# Esegui lo script
#./file_parte_simulazione_processo.sh

# Come Output avrò:
#Processo 1  in esecuzione...
#Processo 1: file creato.
#Processo 2  in esecuzione...
#Processo 2: file creato.
#Processo 3  in esecuzione...
#Processo 3: file creato.
#Processo 4  in esecuzione...
#Processo 4: file creato.
#Processo 5  in esecuzione...
#Processo 5: file creato.


#!/bin/bash

#================================================================================
#Nome file= file_gestione_processi.sh
#Descrizione esercizio= Gestione dei processi,cicli,errori e contatori in Bash
#================================================================================

#Questa è lo script finale: Ho aggiunto in più una funzione cleanup()  che elimina i file(processi) che ho creato durante l'esercizio in maniera automatica e una funzione che garantisce che cleanup avvenga sempre, in più ho aggiunto exit 0 ed exit 1 che comunica al sistema operativo se è andato a buon fine o no.

#1)Prima cosa definisco delle variabili:le metto in maiuscolo proprio perchè devono essere costanti. Diversamente rispetto a prima inserisco anche la variabile LOG_FILE per il file di log.

LOG_FILE="processi.log"
NUM_PROCESSI=5

#è ilnumero di volte che il ciclo for deve girare, per il momento ne lascio 5 poi vedrò se aumentare.

#2)Definisco i contatori uno per i successi e uno per gli errori.

count_success=0
count_error=0
#partono da zero e vengono incrementati man mano.

#--Funzione log_message ---
#Stampa un messaggio sullo schermo e lo scrive nel file di log
# $1 = livello(INFO / SUCCESS / ERROR / WARN)
# $2 = testo del messaggio

log_message() {
        local level="$1"
        local message="$2"
        echo "[$level] - $message" | tee -a "$LOG_FILE"
}

#--funzione cleanup()--
#rimuove i file temporanei durante l'esecuzione,viene chiamata automaticamente da trap alla chiusura dello script.

cleanup() {
        log_message "INFO" "Pulizia file temporanei..."
        rm -f processo_*.txt

}

#trap: la sua funzione è agganciare clenup all'evento EXIT,il quale scatterà sempre alla fine dello script
trap cleanup EXIT


# --- Setup ----
echo "--- Inizio Script ---" > "$LOG_FILE"


#Ciclo for, dove effettuo una simulazione del processo, per ogni iterazione creo un file, vedendo ulteriormente se c'è l'errore.

for((i=1; i<=NUM_PROCESSI; i++))do
	log_message "INFO" "Processo $i  in esecuzione..."

        if echo "dati processo $i" > "processo_$i.txt"; then
                # $? == 0 : comando riuscito
                log_message "SUCCES"  "Processo $i: Successo!"
                ((count_success++))
        else
                # $? != 0 : comando fallito
                log_message "ERROR" "Processo $i: Errore!"
                ((count_error++))
        fi
        # Errore forzato su un processo, esempio 3
        if [ $i -eq 3 ]; then
                log_message "Warning--Errore forzato sul processo 3.."
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

#Faccio un report finale con numero successi e numero errori come prima.
# --- Report ---
echo "-------------------------------------"
echo "Totale  : $NUM_PROCESSI"
echo "Successi: $count_success"
echo "Errori  : $count_error"
echo "-------------------------------------"

#---USCITA---
#exit 0 = successo
#exit 1 = errore

if [ $count_error -eq 0 ]; then
        log_message "INFO" "Script completato con successo."
        exit 0
else
        log_message "INFO" "Script terminato con $count_error errore/i."
        log_message "INFO" "Per risolvere controlla il ciclo for per rimuovere l'errore forzato della simulazione."

fi


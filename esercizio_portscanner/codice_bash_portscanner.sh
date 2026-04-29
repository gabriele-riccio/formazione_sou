#! /bin/bash

# ====================================================================
# Script: portscanner. sh
# Descrizione: Semplice TCP Port Scanner con Netcat
# Uso: /portscanner.sh <IP_TARGET> <PORTA_INIZIALE> <PORTA_FINALE>
# ====================================================================＃

# --- Funzione di Utilizzo ---
usage() {
	echo "Uso: $0 <IP Target> <Porta Inizio> «Porta Fines"
	echo "Esempio: $0 192.168.56.10 1 1024"
	exit 1
}
# ---Sanificazione Input (Controllo Argomenti)---
if [ "$#" -ne 3 ]; then
	usage
fi

TARGET IP=$1
START_PORT=$2
END_PORT=$3

# Regex per validare IP (semplice)
if [[! $TARGET_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	echo "Errore: IP non valido."
	exit 1
fi


# Controllo che le porte siano numeri
if ! [[ "$START_PORT" =~ ^[0-9]+$ ]] ||  ! [[ "$END_PORT" =~ ^ [0-9]+$ ]] ; then
	echo "Errore: Le porte devono essere numeri."
	 exit 1
fi

START_PORT=$2
END_PORT=$3

# Regex per validare IP (semplice)
if [[ ! $TARGET_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	echo "Errore: IP non valido.
	exit 1
fi

# Controllo che le porte siano numeri
if ! [[ "$START _PORT" =~ ^[0-9]+$ ]] || ! [[ "$END_ PORT" =~ ^[0-9]+$ ]]; then
	echo "Errore: Le porte devono essere numeri."
	exit 1
fi
#---Inizio Scansione---

echo "---------------------------------"
echo "Inizio scansione su $TARGET IP"
echo "Range: $START PORT - $END PORT"
echo "---------------------------------"
# Loop sulle porte
for ((port=START_PORT; port<=END_PORT; port++)); do
	# nc -z: modalità zero-I/0 (scansione)
	# nc -wl: timeout di 1 secondo
	# Reindirizziamo output e errori a /dev/null per pulizia
	nc -z -w 1 "$TARGET IP" "$port" > /dev/null 2>&1
	
	# Se l'ultimo comando (nc) ha avuto successo, l'exit status ($?) è 0 
	if [ $? -eq 0 ]; then
		echo "Porta $port: APERTA"
	fi
done
echo "---------------------------------"
echo "Scansione completa"

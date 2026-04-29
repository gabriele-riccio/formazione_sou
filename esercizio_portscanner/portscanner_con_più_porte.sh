#Il comando per mettere in ascolto sulla VM target altre porte è  sudo nc -lk -p porta &
#ritornando nella VM scanner e facendo il comando ./portscanner.sh 192.168.50.11 20 500 ottengo le porte in ascolto tra 20 e 500 e 
#non solo la 22.

vagrant@scanner:~$ ./portscanner.sh 192.168.50.11 20 500
---------------------------------
Inizio scansione su 192.168.50.11
Range: 20 - 500
---------------------------------
Porta 22: APERTA
Porta 80: APERTA
Porta 443: APERTA
---------------------------------

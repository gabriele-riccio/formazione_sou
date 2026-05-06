#!/bin/bash
#--Esercizio 2--Primi 7 file di /etc in un file

#Creare un file contenente i nomi dei primi 7 file della directory /etc.
#prima cosa vedo cosa c'è nella directory /etc
ls /etc
#output: 
         ModemManager     ...         ...
         NetworkManager   ...         ...
         Packagekit
         UPower
         X11
         adduser.conf
         alsa
	     ...
         ...
#Lista di file al suo interno in ordine alfabetico, grande non enorme come prima.

#Per creare il file con i primi 7 file di /etc uso la pipe | utilizzando head -7 per salvare le prime 7 righe e con la funzione freccia > li salvo in un nuovo file che crea in automatico, lo chiamo primi7.txt
#Eseguo:
ls /etc |  head -7 > primi7.txt
#output: nulla, ha salvato primi7.txt
#per vedere se ha funzionato basterà usare cat con primi7.txt
cat primi7.txt
#output: 
     ModemManager
	 NetworkManager
	 Packagekit
	 UPower
	 X11
	 adduser.conf
	 alsa

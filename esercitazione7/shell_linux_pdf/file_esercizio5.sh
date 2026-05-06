#!/bin/bash
#--Esercizio 5--Primi 7 ed ultimi 6  comandi di /etc ordinati in un file

#Creare un file contenente i nomi dei primi 7 e degli ultimi 6 file (in ordine alfabetico) della directory /etc.

#Uso ls  per ordinare in ordine alfabetico i file di /etc  

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

 






	 ...              ...          ...	 wpa_supplicant
						 xattr.conf
	 ...		  ...  	       ...	 xdg
	 ... 		  ...          ...       xemacs21
         ...		  ...          ...       xml
                                                 zsh_command_not_found


	
#Lista di file al suo interno in ordine alfabetico.

#Per creare il file con i primi 7 file e gli ultimi 6 file di /etc  uso la combinazione di head con -7 e tail con -6(con la combinazione usando la parentesi {} e la pipe | utilizzando il ; per dividerle) e con la funzione freccia > li salvo in un nuovo file che crea in automatico, lo chiamo primi7_ultimi6.txt
#Eseguo:

{ls /bin |  head -7; ls/bin | tail -6; } > primi7_ultimi6.txt

#output: nulla, ha salvato primi7_ultimi6.txt.
#per vedere se ha funzionato basterà usare cat con primi7_ultimi6.txt
cat primi7_ultimi6.txt

#output:
         ModemManager 
         NetworkManager   
         Packagekit
         UPower
         X11
         adduser.conf
         alsa
	 wpa_supplicant
	 xattr.conf
	 xdg
 	 xemacs21
	 xml
	 zsh_command_not_found


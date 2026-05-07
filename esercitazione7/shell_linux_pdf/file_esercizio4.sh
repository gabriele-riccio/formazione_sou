
#--Esercizio 4--10 comandi di /bin ordinati per ultimo accesso

#Creare un file con una lista di 10 comandi di /bin ordinati per momento dell'ultimo accesso.
#Uso ls con -t per ordinare nel tempo come ultima modifica ,non più in ordine alfabetico,con -u invece sempre nel tempo ma come ultimo accesso  

ls -tu  /bin

#output:
         zstdcat                 ...         ...
         zstdmt                  ...         ...
         yes       		         ...         ...
	     whoami     		     ...         ...
         x86_64-linux-gnu-cpp    
         x-www-browser
         x-terminal-emulator
         x86_64
	     x-session-manager
	     ypdomainname         
         ...
	     ...
	     ...

#Lista di file al suo interno in ordine temporale,secondo l'ultimo accesso.

#Per creare il file con gli ultimi 10 accesso di /bin uso la pipe | utilizzando head -10 per salvare le prime 10 righe e con la funzione freccia > li salvo in un nuovo file che crea in automatico, lo chiamo ultimi10_accesso.txt

#Eseguo:

ls -tu  /bin |  head -10 > ultimi10_accesso.txt

#output: nulla, ha salvato ultimi10_accesso.txt
#per vedere se ha funzionato basterà usare cat con ultimi10_accesso.txt
cat ultimi10_accesso.txt
#output:
	     zstdcat                 
         zstdmt                  
         yes
         whoami                     
         x86_64-linux-gnu-cpp    
         x-www-browser
         x-terminal-emulator
         x86_64
         x-session-manager
         ypdomainname
         


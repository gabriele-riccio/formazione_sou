
#--Esercizio 3- File nella directory corrente con "snap" nel nome.
# Determinare il numero di file della directory corrente nel cui nome compare la stringa 'snap'.
#prima cosa mi metto nella directory corrente con ls
ls 
#output:
         ''$|004' Documenti  Modelli Pubblici  Scrivania  encoding_vs_ecryption foo.log     script2  snap     
         DEADJOE  Immagini   Musica  Scaricati Video      file_frutta.csv       primi7.txt  scripts  text.txt
         
#Voglio stampare il numero di file in cui compare 'snap', uso ls con la pipe | con grep per filtrare solo quelli che contengono snap e mi stamperà solo snap, se uso un'altra pipe | con wc -l mi conta il numero di righe che contengono snap
#Eseguo prima la prima |:
ls |  grep snap 
#output: snap
#ora lo faccio completo:
ls |  grep snap > wc -l
#output: 1 è solo su una riga.

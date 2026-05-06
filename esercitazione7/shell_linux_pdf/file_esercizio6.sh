
#--Esercizio 5--Creare un file con una lista di 8 file in /usr/sbin ordinati per momento dell'ultima modifica.

#Creare un file con una lista di 8 comandi di  usr/sbin ordinati per momento dell'ultima modifica.
#Uso ls con -t per ordinare nel tempo come ultima modifica.

ls -t /usr/sbin

#output:
         ntfsclone                 ...         ...
         mkntfs                  ...         ...
         mount.ntfs                             ...         ...
         mount.ntfs-3g                          ...         ...
         ntfslabel
         mount.lowntfs-3g
         ntfscp
         mkfs.ntfs
         ...
         ...
         ...

#Lista di file al suo interno in ordine temporale,secondo l'ultima modifica.

#Per creare il file con gli ultimi file di usr/sbin uso la pipe | utilizzando head -8 per salvare le prime 8 righe e con la funzione freccia > li salvo in uni nuovo file che crea in automatico, lo chiamo top8_modifica_usrsbin.txt

#Eseguo:


ls -t /usr/sbin |  head -8 > top8_modifica_usrsbin.txt

#output: nulla, ha salvato i file in top8_modifica_usrsbin.txt
#per vedere se ha funzionato basterà usare cat con top8_modifica_usrsbin.txt:

cat top8_modifica_usrsbin.txt

#output:
	 ntfsclone
	 mkntfs
	 mount.ntfs
	 mount.ntfs-3g
	 ntfslabel
	 mount.lowntfs-3g
	 ntfscp
	 mkfs.ntfs

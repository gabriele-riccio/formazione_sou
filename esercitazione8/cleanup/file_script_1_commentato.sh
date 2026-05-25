# Cleanup
# Run as root, of course.

#Questo è uno script per svuotare i log di sistema.
#Per prima cosa mi sposto nella directory var/log(DIRECTOY STANDARD PER I LOG DI SISTEMA)
# Il comando cat  legge il contenuto di uno o più file e lo stampa direttamente sullo standard output, 
#in questo caso redirige quindi su messages e wtmp il contenuto vuoto di /dev/null.
#Alla fine stampa il messaggio di conferma

cd /var/log
cat /dev/null > messages
cat /dev/null > wtmp
echo "Log files cleaned up." 

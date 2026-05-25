#!/bin/bash

#Questo script Questo script serve a verificare se l'utente che lo sta eseguendo possiede 
#i privilegi di root oppure se è un utente comune.


#per prima cosa si dichiara una variabile root_uid che memorizza il valore 0.
#poi c'è un if che controlla se l'UID è pari a 0(equal) se è vero stampa che l'utente è root, altrimenti che è un utente comune.

#Poi c'è un ulteriore tipologia molto simile che non verrà eseguita dato che è inserita dopo l'exit 0.
#In questo caso si salva nella variabile ROOTUSER_NAME il nome testuale dell'amministratore(root), poi c'è
#username='id -nu' (oppure 'whoami') che esegue un comando di sistema per scoprire il nome dell'utente corrente e lo salva nella variabile username.

#Poi c'è l'if che invece di controllare l'Uid come prima controlla se effettivamente l'username è root, se si stampa quel messaggio ironico
#altrimenti dice che è un utente normale.

#Ho fatto uno script in più per eseguire anche quest'ultimo sul terminale.


ROOT_UID=0   # Root has $UID 0.

if [ "$UID" -eq "$ROOT_UID" ]  # Will the real "root" please stand up?
then
  echo "You are root."
else
  echo "You are just an ordinary user (but mom loves you just the same)."
fi

exit 0

# ============================================================= #
# Code below will not execute, because the script already exited.

# An alternate method of getting to the root of matters:

ROOTUSER_NAME=root

username=`id -nu`              # Or...   username=`whoami`
if [ "$username" = "$ROOTUSER_NAME" ]
then
  echo "Rooty, toot, toot. You are root."
else
  echo "You are just a regular fella."
fi

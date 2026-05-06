#Script terminale esericizio_foo:
#Richiesta:Creare file di nome "foo.log" tramite comando "touch"
#Assegnare permessi di lettura, scrittura ed esecuzione per il proprietario al file foo.log
#Creare un gruppo denominato "foobar"
#Cambiare il gruppo proprietario di foo.log in foobar

#Step 1 creo il file foo.log con touch
touch foo.log
#verifica
ls -l foo.log
#output: -rw-rw-r -- 1 gabriele-riccio gabriele-riccio 0 Data Ora foo.log

#Assegno con chmod permessi di lettura,scrittura e di esecuzione all'utente (conu+rwx(utente read write ed esecuzione)  oppure in notazione ottale 4+2+1=7 700)
chmod u+rwx foo.log

#verifica
ls -l foo.log
#output: -rwxrw-r -- 1 gabriele-riccio gabriele-riccio 0 Data Ora foo.log(in verde perchè ha il permesso)

#Creo e cambio il gruppo in foobar usando groupadd

sudo groupadd foobar
#output: [sudo: authenticate] Password:

#Cambio con chown il gruppo proprietario di foo.log da gabriele-riccio in foobar

sudo chown :foobar foo.log

#verifica
ls -l foo.log
#output: -rwxrw-r -- 1 gabriele-riccio foobar 0 Data Ora foo.log(in verde perchè ha il permesso)
                       

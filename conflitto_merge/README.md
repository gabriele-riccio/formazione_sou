Come consigliato da voi ho scelto di simulare un conflitto tra Branch e Main aggiungendo una spaziatura inattesa nella medesima riga del codice.

Per prima cosa ho proceduto alla configurazione della mia identità (avendo già precedentemente installato sulla mia VM Git) utilizzando il comando:
git config --global user.name "Gabriele" && git config --global user.email "ricciogabriele0@gmail.com"

Poi ho effettuato la clonazione della mia repository GitHub sulla mia VM e ho effettuato il cambio della directory con cd:
git clone https://github.com/gabriele-riccio/formazione_sou.git && cd formazione_sou

Poi ho continuato con la creazione del file di testo codice.txt scrivendoci la riga di codice print("Ciao Mondo"), poi ho effettuato questi comandi per passare al ramo principale di Git (main) dirgli di guardare quel file e salvarlo(add e commit). Dopo di che ho creato un branch(ramo secondario) scrivendoci la riga di codice con la spaziatura inattesa e gli stessi comandi di prima per dire a Git di guardare quel file e salvarlo.

git checkout main
echo "print("Ciao Mondo")">>codice.txt
git add codice.txt
git commit -m "Primo commit"


git checkout -b esperimento1
echo "print  ("Ciao Mondo") > codice.txt  #spaziatura tra print e ("Ciao Mondo")
git add codice.txt
git commit -m "Secondo commit"

Una volta fatto questo torno sul main e provo a fare il merge per vedere il conflitto (con i comandi git checkout main && git merge esperimento1), infatti Git mi restituisce CONFLICT (content): Merge conflict in codice.txt (in allegato),  e guardando codice.txt con il comando cat ottengo i marcatori di conflitto(in allegato).

Utilizzando vim codice.txt posso modificare quello che c'è scritto andando a risolvere il conflitto.

Adesso facendo cat codice.txt ottengo la scritta print('Ciao Mondo') cioè quella che ho scelto per risolvere il conflitto.

Una volta risolto il conflitto ho effettuato il push dei cambiamenti sul repository remoto (una volta configurato il token).
~                                                                                                                             

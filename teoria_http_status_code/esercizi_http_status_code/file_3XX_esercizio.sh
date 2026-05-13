##!/usr/bin/env bash
# ===================================================================================================================
# file_3XX_esercizio.sh

#ESERCIZIO BONUS: Simulare le risposte dei server web con gli HTTP status code dopo delle richieste.

#Faccio prima l'esempio le redirect 301 e 302 usando solo curl su httpbin.org

#Sono due redirect, il primo permanente il secondo temporaneao
#Ho usato come url di base "https://httpbin.org", un'indirizzo chiamato endpoint per testare le richieste HTTP.
# Come quello dei 2XX ho dichiarato dellevariabili colore, in questo caso anche il blu per il reindirizzamento.
#Ho inoltre dichiarato il grassetto e il reset per tornare alla scrittura normale.
#Ho dichiarato come prima 2 funzioni, sep() per stampare delle righe di separazione con $1 che fa in modo che 
# questa condizione si ripete per ogni richiesta che vogliamo fare per cui ogni passo che facciamo diventa $1.
#pausa() invece con read -r  in bash  mette in pausa l'esecuzione dello script e 
# aspetta che l'utente digiti qualcosa
#prima di continuare(in questo caso invio) mentre -r è una sorta di sicurezza per errori dell'utente.
# ====================================================================================================================

BASE="https://httpbin.org"

BLUE="\e[34m"; GREEN="\e[32m"; BOLD="\e[1m"; RESET="\e[0m"

sep() {
  echo ""
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${BOLD}  $1${RESET}"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
}

pausa() {
  echo -e "  ${BOLD}>>> Premi INVIO per continuare...${RESET}"
  read -r
}

# ==============================================================================================================================
# PASSO 1 — 301 Moved Permanently
# Scrivo il titolo con la funzione sep dopo aver pulito tutto quello che avevo a schermo.

# stampo che la risorsa che si sta cercando è stata spostata permanentemente, 
# Poi uso il grassetto per scrivere la parola Locazione per il nuovo indirizzo del sito
# dichiaro le variabili DEST che è la destinazione dopo il reindirizzamento ovvero l'url di base dichiarato prima.
# Poi dichiaro la variabile URL_301, che sfrutta una capacità di httpbin.org, cioè
# mi risponde forzatamente con un codice 301 e mi dice di andare verso $DEST.

# Curl fa esattamente quanto scritto nella riga ${GREEN}curl -s -o /dev/null -w '  → Status: %{http_code}\\n' '$URL_301'${RESET}"
# con green per stamparlo in verde -s per eliminare l avanzamento, -o /dev/null mentre fain modo di scaricare
#solo lo status code e non prende tutto il resto ma lo butta nel cestino, inoltre -w etc che mi rappresenta
#il write out(dice a curl di scrivere esattamemte status 301) con $URL_301 come bersaglio.
#in breve curl prende solo il 301 e lo stampa a video(redirect grezzo).

#Poi scrivo curl -s -v "$URL_301" 2>&1 | grep -E "^< HTTP|^< [Ll]ocation"
# in questo caso il curl con -v stamperebbe tutta la 'conversazione' tra lui e il server
# Dato che a me serve solo lo status (HTTP/2 301) che si trova nell'Header location,
# butto tutto quello che non mi serve.
# Con 2>&1 unisco i messaggi verbosi di curl, e con grep faccio un vero e proprio filtro,
# In poche parole con ^< HTTP e il grep dico di cercare la riga che inizia con HTTP e ^< [Ll]ocation
#la riga che contiene il nuovo indirizzo di location con [Ll] per non avere problemitra maiuscolo e minuscolo
# In questo modo filtriamo tutto per avere solo quello che ci interessa lo status (HTTP/2 301).

# Infine se voglio che curl segua il redirect come i browser mi basta aggiungere -L, con tutto il resto che 
#è uguale a prima.
# ===============================================================================================================================

clear
sep "301 Moved Permanently"

echo -e "  La risorsa è stata spostata DEFINITIVAMENTE a un nuovo indirizzo."
echo -e "  Il browser memorizza il redirect: la prossima volta va diretto."
echo ""
echo -e "  L'header ${BOLD}Locazione${RESET} nella risposta contiene il nuovo URL."
echo ""

DEST="$BASE/get"
URL_301="$BASE/redirect-to?url=$DEST&status_code=301"

echo -e " Redirect  (senza seguire direttamente verso l'url) "
echo ""
echo -e "  ${GREEN}curl -s -o /dev/null -w '  → Status: %{http_code}\\n' '$URL_301'${RESET}"
echo ""
curl -s -o /dev/null -w "  → Status: %{http_code}\n" "$URL_301"
echo ""

echo -e "  Mostro l'header Location con -v "
echo ""
curl -s -v "$URL_301" 2>&1 | grep -E "^< HTTP|^< [Ll]ocation"
echo ""

echo -e "  --- In genere curl non segue il redirect con -L (come fa il browser) ---"
echo -e "  --- Con -L lo segue come fa il browser ---"
echo ""
echo -e "  ${GREEN}curl -s -o /dev/null -w '  → Status finale: %{http_code}\\n' -L '$URL_301'${RESET}"
echo ""
curl -s -o /dev/null -w "  → Status finale: %{http_code}\n" -L "$URL_301"
echo ""

pausa

# ========================================================================================================
# PASSO 2 — 302 Found (redirect temporaneo)

# Scrivo il titolo tramite la funzione sep()
#Stampo inizialmente delle frasi per dire che la risorsa è TEMPORANEAMENTE in un altro indirizzo perchè
#il sito è in manutenzione.

#Dichiaro,come prima la variabile URL_302 che sfrutta una capacità di httpbin.org, cioè
# mi risponde forzatamente con un codice 302 e mi dice di andare verso $DEST.
#Poi è essenzialmente come prima con il redirect senza seguire direttamente verso l'url e la stampa
#dello status 302.
# =========================================================================================================
sep "302 Found (redirect temporaneo)"

echo -e "  La risorsa è TEMPORANEAMENTE a un altro indirizzo."
echo ""
echo -e "  Caso reale: sito in manutenzione che rimanda a una pagina temporanea."
echo ""

URL_302="$BASE/redirect-to?url=$DEST&status_code=302"

echo -e "  ${GREEN}curl -s -o /dev/null -w '  → Status: %{http_code}\\n' '$URL_302'${RESET}"
echo ""
curl -s -o /dev/null -w "  → Status: %{http_code}\n" "$URL_302"
echo ""

echo -e "  Header Location:"
curl -s -v "$URL_302" 2>&1 | grep -E "^< HTTP|^< [Ll]ocation"
echo ""

pausa
# =============================================================================
# RIEPILOGO
# Mi scrivo il riepilogo di quello che ho fatto cioè i 2 reindirizzamenti, 
# permanente e temporaneo con i messaggi di 301 e 302.
#funzione sep() per il titolo, in blu mi stampo i 2 status code e con
# la scrittura normale la spiegazioni di quello che fanno.

#Poi faccio un ciclo for per prendere i 2 codici e per ognuno costruisco gli indirizzi
#per entrambi, sfruttando l'url di endpoint iniziale e con get gli passa la destinazione
#finale.
#Poi c'è curl che come prima stampa a video solo lo status code per ognuno.
#Se prima facevo tutti i comandi man mano con il ciclo for faccio la stessa cosa 
#ma tutto insieme.

# =============================================================================
sep "RIEPILOGO"

echo -e "  ${BLUE}301 Moved Permanently${RESET}  → nuovo URL definitivo, browser lo memorizza"
echo -e "  ${BLUE}302 Found${RESET}              → redirect temporaneo, si riverifica ogni volta"
echo ""
echo -e "  Differenza pratica:"
echo -e "  - 301 → SEO passa al nuovo URL, vecchio link diventa irrilevante"
echo -e "  - 302 → SEO resta sul vecchio URL, utile per manutenzioni temporanee"
echo ""

for code in 301 302 ; do
  url="$BASE/redirect-to?url=$BASE/get&status_code=$code"
  status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  echo -e "    status_code=$code  →  ${BLUE}$status${RESET}"
done

echo ""
echo -e "${BOLD}  Fine simulazione 3xx.${RESET}"
echo ""

#!/usr/bin/env bash
#--file_script_esercizio.sh--
#ESERCIZIO BONUS: Simulare le risposte dei server web con gli HTTP status code dopo delle richieste.
#Faccio prima l'esempio con gli status code 2XX.

#Ho usato come url di base "https://httpbin.org", un'indirizzo chiamato endpoint per testare le richieste HTTP.
#Gli invio una richiesta tramite il comando curl ed il server risponde con un testo in formato JSON per controllare gli HEADER#per leggerne la risposta. 

BASE="https://httpbin.org"

#Dato che gli status code 2XX danno esito positivo ho voluto colorare il testo di verde(ho visto come si faceva su gemini, 
#ho dichiarato quindi una variabile GREEN per colorare il testo del terminale aggiungendo anche il grassetto(bold) e il reset #per tornare al testo normale.


GREEN="\e[32m"; BOLD="\e[1m"; RESET="\e[0m"

#Dichiaro ora una funzione sep(), che crea un separatore visivo e rende l'output più ordinato e leggibile e una funzione
#pausa(),per mettere in pausa lo script man mano.

#Sono due funzioni molto semplici che stampano come output la prima solo un separatore visivo(linea) mentre la seconda mette in pausa lo script e dice che per continuare bisogna premere invio.
#Ecco come funziona:
#echo"" riga vuota
#echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}" invece stampa del testo, con -e che fa in modo di rappresentare i caratteri speciali come colori(verde in questo caso), usa bold per attivare il grassetto stampa una riga e poi torna alla scrittura normale con reset. Questa condizione si ripete per ogni richiesta che vogliamo fare per cui ogni passo che facciamo diventa $1 e poi di nuovo il reset.
# di nuovo la riga con la linea lunga e poi di nuovo una riga vuota.

#come sopra echo -e "  ${BOLD}>>> Premi INVIO per continuare...${RESET}" stampa però la frase premi invio...
#read -r è il cuore della funzione dato che in bash read mette in pausa l'esecuzione dello script e aspetta che l'utente digiti qualcosa prima di continuare(in questo caso invio) mentre -r è una sorta di sicurezza per errori dell'utente.
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

# =============================================================================
# 200 OK — GET semplice
#  Iniziamo: prima cosa pulisco lo schermo con clear
# Poi richiamo la funzione sep mettendogli il titolo della parte di esercizio cioè testare lo status code 200 OK dopo il metodo get(che richiede  soltanto dei dati e li legge ma non li modifica) .
#Poi cè un echo che stampa solo delle spiegazioni cioè che il server ha ricevuto la richiesta e risponde con successo
#Poi uno spazio
#poi il cuore dello script:
#dice prima di colorare in verde con la variabile green
#curl -s -w "\n  → Status: %{http_code}\\n' $BASE/get è il comando che ha lanciato: curl fa la richiesta di rete, -s sta per silent per non mostrare la barra di caricamento, poi
# -w "\n.→ Status: %{http_code}\n" sta per write out cioè una volta scaricato i dati stampami una freccia e al suo fianco stampami esattamente il codice HTTP %{http_code} che ti ha dato il server.
#"$BASE/get" riporta all'indirizzo che chiama "https://httpbin.org".
#poi alla fine riga vuota e richiamo della funzione pausa.

# =============================================================================


clear
sep "200 OK — GET semplice"
echo -e "  Mandiamo dati al server con il metodo GET."
echo -e "  Il server ha ricevuto la richiesta e risponde con successo."
echo ""
echo -e "  ${GREEN}curl -s -w '\\n  → Status: %{http_code}\\n' $BASE/get${RESET}"
echo ""
curl -s -w "\n  → Status: %{http_code}\n" "$BASE/get" 
echo ""

pausa

# =============================================================================
# 201 OK — POST con corpo JSON
# Iniziamo: Ora vediamo il codice 201--> voglio simularlo con il metodo post con corpo json(in questo caso i contenuto visualizzato è in json inoltre Se il primo blocco serviva a mostrare come richiedere semplicemente una pagina (GET), questo serve a mostrare come inviare dei dati a un server(Post).
# Poi richiamo la funzione sep mettendogli il titolo della parte di esercizio cioè testare lo status code 200 OK dopo il metodo post.
#Poi cè un echo che stampa solo delle spiegazioni cioè che il server ha ricevuto la richiesta e risponde con successo con l'eco dei dati.
#Poi uno spazio
#poi il cuore dello script:
#dice prima di colorare in verde con la variabile green
#il comando curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"nome":"Mario","ruolo":"admin"}' \
  -w "\n  → Status: %{http_code}\n" \
  "$BASE/post"
#con le / vado a capo,-s invece fa in modo sempre di non mostrare la barra di caricamento e -X fa proprio quello che vogliamo cioè cambia il metodo di default che è GET a POST.
#-H sta per header dice al server che sto mandando dati in formato json e di leggerli di conseguenza.
#-d sta per data, sto mandando al server dei dati in questo caso nome e ruolo di un utente. 
# -w "\n.→ Status: %{http_code}\n" sta per write out cioè una volta scaricato i dati stampami una freccia e al suo fianco stampami esattamente il codice HTTP %{http_code} che ti ha dato il server 201.
#"$BASE/post" riporta all'indirizzo che chiama "https://httpbin.org".
#poi alla fine riga vuota e richiamo della funzione pausa.

# =============================================================================
sep "201 OK — POST con corpo JSON"

echo -e "  Mandiamo dati al server con il metodo POST."
echo -e "  Il server li riceve, li elabora e risponde 201 con l'eco dei dati."
echo ""
echo -e "  ${GREEN}curl -s -X POST -H 'Content-Type: application/json' \\${RESET}"
echo -e "  ${GREEN}     -d '{\"nome\":\"Mario\",\"ruolo\":\"admin\"}' \\${RESET}"
echo -e "  ${GREEN}     -w '\\n  → Status: %{http_code}\\n' $BASE/post${RESET}"
echo ""
curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"nome":"Mario","ruolo":"admin"}' \
  -w "\n  → Status: %{http_code}\n" \
  "$BASE/post" 
echo ""

pausa

# =============================================================================
# 204 OK — Headers custom visibili nella risposta con una richiesta HEAD
#In questo caso mostra solo gli headers visibili senza body attraverso -I
#Richiamo sempre la funzione sep per stampare il titolo
#Ci sono sempre delle stampe di spiegazione
#in questo caso uso curl -s -I per mostrare solo gli header HTTP senza il body.
#

# =============================================================================
sep "200 OK — Vedere gli header della risposta"

echo -e "  Con -I (o --head) curl mostra SOLO gli header HTTP, senza il body."
echo ""
echo -e "  ${GREEN}curl -s -I $BASE/get${RESET}"
echo ""
curl -s -I "$BASE/get"
echo ""

pausa

# =============================================================================
# RIEPILOGO
#Con la funzione sep per il titolo.
# sempre specificando il verde con delle frasi come prima: in questo caso vorrei
#come risposta anche altre di 2XX come 201 che crea la risorsa(usando il secondo script con il metodo POST dato che inviamo noi i dati) e 
#204 che visualizza soltanto con GET senza restituire il body.
# Metto infine un ciclo for che per ogni codice fa quello sotto
#Cioè controlla l'indirizzo "$BASE/status/$code" per 200,201 e 204, non controlla tutto della pagina ma solo 
# su quello che ci interessa ovvero la risposta del 200,201 etc mandando il resto in dev/null e salvando il tutto nella variabile status 
# e la stampa dando come risposta l'indirizzo che ha testato e il risultato
#poi alla fine c'è solo scritto la fine simulazione.
# =============================================================================
sep "RIEPILOGO — 2xx"

echo -e "  ${GREEN}200 OK${RESET}          → richiesta riuscita, body presente"
echo -e "  ${GREEN}201 Created${RESET}     → risorsa creata (tipico delle POST su API REST)"
echo -e "  ${GREEN}204 No Content${RESET}  → successo ma nessun body da restituire"
echo ""
echo -e "  Verifica rapida dei tre:"
echo ""
for code in 200 201 204; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/status/$code")
  echo -e "    GET /status/$code  →  ${GREEN}$status${RESET}"
done
echo ""
echo -e "${BOLD}  Fine simulazione 2xx.${RESET}"
echo ""

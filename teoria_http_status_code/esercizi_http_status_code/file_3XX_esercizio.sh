#!/usr/bin/env bash
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
#pausa() invece con read -r  in bash  mette in pausa l'esecuzione dello script e aspetta che l'utente digiti qualcosa
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

# ==================================================================================================
# PASSO 1 — 301 Moved Permanently
# Scrivo il titolo con la funzione sep dopo aver pulito tutto quello che avevo 
#a schermo
# stampo che la risorsa che si sta cercando è stata spostata permanentemente, 
# Poi uso il grassetto per scrivere la parola Locazione per il nuovo indirizzo del sito
# dichiaro le variabili DEST che è la destinazione dopo il reindirizzamento ovvero l'url di base dichiarato prima.
# Poi dichiaro la variabile URL_301
# ===================================================================================================
clear
sep "301 Moved Permanently"

echo -e "  La risorsa è stata spostata DEFINITIVAMENTE a un nuovo indirizzo."
echo -e "  Il browser memorizza il redirect: la prossima volta va diretto."
echo ""
echo -e "  L'header ${BOLD}Locazione${RESET} nella risposta contiene il nuovo URL."
echo ""

DEST="$BASE/get"
URL_301="$BASE/redirect-to?url=$DEST&status_code=301"

echo -e "  --- Redirect grezzo (senza seguirlo) ---"
echo ""
echo -e "  ${GREEN}curl -s -o /dev/null -w '  → Status: %{http_code}\\n' '$URL_301'${RESET}"
echo ""
curl -s -o /dev/null -w "  → Status: %{http_code}\n" "$URL_301"
echo ""

echo -e "  --- Mostriamo l'header Location con -v ---"
echo ""
curl -s -v "$URL_301" 2>&1 | grep -E "^< HTTP|^< [Ll]ocation"
echo ""

echo -e "  --- curl segue il redirect con -L (come fa il browser) ---"
echo ""
echo -e "  ${GREEN}curl -s -o /dev/null -w '  → Status finale: %{http_code}\\n' -L '$URL_301'${RESET}"
echo ""
curl -s -o /dev/null -w "  → Status finale: %{http_code}\n" -L "$URL_301"
echo ""

pausa

# =============================================================================
# PASSO 2 — 302 Found (redirect temporaneo)
# =============================================================================
sep "302 Found (redirect temporaneo)"

echo -e "  La risorsa è TEMPORANEAMENTE a un altro indirizzo."
echo -e "  Il browser NON memorizza: controlla ogni volta."
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
# =============================================================================
sep "RIEPILOGO — 3xx"

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

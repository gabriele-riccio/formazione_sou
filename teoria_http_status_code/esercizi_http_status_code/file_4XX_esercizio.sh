#!/usr/bin/env/ bash
# =========================================================================================================================
# file_4XX_esercizio.sh
#ESERCIZIO BONUS: Simulare le risposte dei server web con gli HTTP status code dopo le richieste.
# Vedo in particolare le differenze tra 401 e 403 oltre che il classico 404, tutto con curl utilizzando httpbin.org
# Prima cosa mi scrivo l'url di base "https://httpbin.org", un'indirizzo chiamato endpoint per testare le richieste HTTP.
# dichiaro le variabili errore in questo caso uso anche il giallo oltre che il verde per dichiarare gli errori commessi 
#dall'utente.
#Come gli altri due script mi dichiaro le funzioni sep() per le spaziature e pausa per mettere in pausa l'andamento dello
#script.


#Ora mi genero una funzione che mi mostra quello che succede dietro le quinte quando inserisci un nome utente 
#e una password in un sito web che usa l'autenticazione di base (Basic Authentication).
 
#Dato che quando facciamo una richiesta a una route protetta, HTTP Basic Auth 
#richiede che le credenziali siano in questo formato preciso nell'header:

#Authorization: Basic aGFja2VyOnRlbnRhdGl2bw==

#Non è altro che hacker:tentativo codificato in Base64, non è cifrato serve solo a rendere utente:password 
#trasportabile in un header HTTP senza che il : (che ha significato speciale nel protocollo) crei problemi.

#nella funzione mostra_basic_auth() ho local creds="$1"
#Prende il primo argomento passato alla funzione e lo salva in una variabile locale.
# b64=$(echo -n "$creds" | base64) è la parte centrale della funzione;
#echo -n "hacker:tentativo" — stampa la stringa senza newline finale 
#(il -n è fondamentale: se ci fosse il newline, verrebbe codificato dentro il base64 e l'header sarebbe sbagliato)
# mentre base64 — prende quella stringa e la codifica in Base64.
#Con gli echo ho scritto semplicemente quello che fa man mano in modo che lo possiamo vedere a schermo durante l'output.
# ==========================================================================================================================

BASE="https://httpbin.org"

YELLOW="\e[33m"; GREEN="\e[32m"; BOLD="\e[1m"; RESET="\e[0m"

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

# Costruisco e mostra l'header Authorization Basic:

mostra_basic_auth() {
  local creds="$1"   # formato "utente:password"
  local b64
  b64=$(echo -n "$creds" | base64)
  echo -e "  Costruzione dell'header ${BOLD}Authorization: Basic${RESET}"
  echo -e "    1. credenziali:  ${BOLD}$creds${RESET}"
  echo -e "    2. base64:       ${BOLD}$b64${RESET}"
  echo -e "    3. header:       ${BOLD}Authorization: Basic $b64${RESET}"
  echo ""
  echo "$b64"   # valore di ritorno
}

# =============================================================================
# PASSO 1 — 404 Not Found

# =============================================================================
clear
sep "404 Not Found — la risorsa non esiste"
 
echo -e "  Il server HA CAPITO la richiesta, ma la risorsa cercata"
echo -e "  non esiste su quel percorso."
echo ""
echo -e "  L'errore è sempre del CLIENT — hai richiesto qualcosa che non c'è."
echo ""
echo -e "  Caso reale:"
echo -e "    • URL digitato male "
echo ""
 
# --- Caso reale URL digitato male---
echo -e "  ${BOLD}--- Caso reale URL digitato male ---${RESET}"
echo ""
echo -e "  Chiamiamo /questa-route-non-esiste — httpbin non la conosce."
echo ""
echo -e "  ${GREEN}curl -s -o /dev/null -w '  → Status: %{http_code}\\n' \\${RESET}"
echo -e "  ${GREEN}     $BASE/questa-route-non-esiste${RESET}"
echo ""
curl -s -o /dev/null -w "  → Status: %{http_code}\n" \
  "$BASE/questa-route-non-esiste"
echo ""
 
pausa

# =============================================================================
# PASSO 2 — 401 Unauthorized (nessuna credenziale)
# =============================================================================
sep "401 Unauthorized — nessuna credenziale"

echo -e "  Il server NON SA CHI SEI."
echo -e "  Hai chiamato una route protetta senza mandare nessun header."
echo ""
echo -e "  httpbin espone: ${BOLD}/basic-auth/admin/secret123${RESET}"
echo -e "  → risponde 200 solo se mandi le credenziali giuste"
echo -e "  → risponde 401 se non mandi niente"
echo ""

ROUTE="$BASE/basic-auth/admin/secret123"

echo -e "  ${BOLD}--- Richiesta senza header Authorization ---${RESET}"
echo ""
echo -e "  ${GREEN}curl -s -v '$ROUTE' 2>&1 | grep -E 'HTTP|WWW'${RESET}"
echo ""

# curl -s     → silent: non mostra la barra di avanzamento
# curl -v     → verbose: scrive gli header su stderr (righe che iniziano con < e >)
# 2>&1        → unisce stderr a stdout così grep può filtrare entrambi
# grep filtra → teniamo solo "< HTTP" (status line) e "< WWW" (header WWW-Authenticate)
curl -s -v "$ROUTE" 2>&1 | grep -E "^< HTTP|^< WWW"
echo ""
curl -s -o /dev/null -w "  → Status: %{http_code}\n" "$ROUTE"
echo ""
echo -e "  L'header ${BOLD}WWW-Authenticate${RESET} dice al client il tipo di auth"
echo -e "  che il server si aspetta (Basic, Bearer, Digest, ecc.)."

pausa



# =============================================================================
# PASSO 3 — 403 Forbidden (credenziali presenti ma sbagliate/insufficienti)
# =============================================================================
sep "403 Forbidden — autenticato ma senza permessi"

echo -e "  Il server SA CHI SEI, ma non ti fa passare."
echo -e "  Hai mandato credenziali: sono state lette, ma non bastano."
echo ""
echo -e "  Caso reale: sei loggato ma provi ad aprire /admin senza essere root."
echo ""

echo -e "  ${BOLD}--- Costruzione dell'header con credenziali sbagliate ---${RESET}"
echo ""

# mostra_basic_auth scrive i log didattici su stderr → li vedi a schermo
# e restituisce solo il Base64 su stdout → b64_errate è pulito
b64_errate=$(mostra_basic_auth "hacker:tentativo")

echo -e "  ${GREEN}curl -s -o /dev/null -w '  → Status: %{http_code}\\n' \\${RESET}"
echo -e "  ${GREEN}     -H 'Authorization: Basic $b64_errate' '$ROUTE'${RESET}"
echo ""
curl -s -o /dev/null -w "  → Status: %{http_code}\n" \
  -H "Authorization: Basic $b64_errate" \
  "$ROUTE"
echo ""

echo -e "  Nota: httpbin risponde 401 anche con credenziali sbagliate perché"
echo -e "  non distingue i due casi. Un server reale risponde 403 quando"
echo -e "  capisce che l'utente esiste ma non ha i permessi necessari."

pausa

# =============================================================================
# PASSO 4 — Confronto diretto 404 vs 401 vs 403
# =============================================================================
sep "404 vs 401 vs 403 — confronto diretto"
 
echo -e "  Quattro scenari che mostrano le tre famiglie di errore:"
echo ""
 
# Scenario A — path inesistente → 404
echo -e "  ${BOLD}[A] Path inesistente → 404${RESET}"
echo -e "      La richiesta è ben formata, ma la risorsa non esiste sul server."
curl -s -o /dev/null -w "  → Status: %{http_code}\n" \
  "$BASE/questa-route-non-esiste"
echo ""
 
# Scenario B — nessun header → 401
echo -e "  ${BOLD}[B] Nessun header Authorization → 401${RESET}"
echo -e "      La richiesta è ben formata, ma manca completamente l'identità."
curl -s -o /dev/null -w "  → Status: %{http_code}\n" "$ROUTE"
echo ""
 
# Scenario C — credenziali sbagliate → 403 (simulato con /status/403)
echo -e "  ${BOLD}[C] Credenziali presenti ma rifiutate → 403${RESET}"
echo -e "      L'identità è presente ma non ha i permessi per accedere."
curl -s -o /dev/null -w "  → Status: %{http_code}\n" "$BASE/status/403"
echo ""
 
# Scenario D — credenziali corrette → 200
echo -e "  ${BOLD}[D] Credenziali corrette (admin:secret123) → 200${RESET}"
b64_ok=$(echo -n "admin:secret123" | base64)
curl -s -w "  → Status: %{http_code}\n" \
  -H "Authorization: Basic $b64_ok" \
  "$ROUTE" | python3 -m json.tool 2>/dev/null
echo ""
 
pausa

# =============================================================================
# RIEPILOGO FINALE
# =============================================================================
sep "RIEPILOGO — 404 vs 401 vs 403"
 
echo -e "  ${YELLOW}404 Not Found${RESET}"
echo -e "    → La risorsa richiesta non esiste (path sbagliato, ID inesistente)"
echo -e "    → Il server ha capito la richiesta, ma non trova nulla da restituire"
echo -e "    → Azione: verifica l'URL, l'ID o se la risorsa è stata eliminata"
echo ""
echo -e "  ${YELLOW}401 Unauthorized${RESET}"
echo -e "    → Il server NON SA CHI SEI"
echo -e "    → Credenziali assenti o malformate"
echo -e "    → Il server include ${BOLD}WWW-Authenticate${RESET} → ti dice come autenticarti"
echo -e "    → Azione: fai login / manda le credenziali"
echo ""
echo -e "  ${YELLOW}403 Forbidden${RESET}"
echo -e "    → Il server SA CHI SEI"
echo -e "    → Credenziali presenti ma permessi insufficienti"
echo -e "    → Nessun ${BOLD}WWW-Authenticate${RESET} — autenticarti di nuovo non serve"
echo -e "    → Azione: chiedi all'amministratore i permessi"
echo ""
echo -e "  Schema mentale rapido:"
echo -e "    risorsa non trovata?          → ${YELLOW}404${RESET}"
echo -e "    chi sei? (nessuna auth)       → ${YELLOW}401${RESET}"
echo -e "    so chi sei, non puoi entrare  → ${YELLOW}403${RESET}"
echo ""
echo -e "${BOLD}  Fine simulazione 4xx (404/401/403).${RESET}"
echo ""
 

#!/usr/bin/env bash
# =============================================================================
# simulazione_400.sh
# Dimostra 401 e 403 — nessun server locale, solo curl su httpbin.org
#
# httpbin.org/basic-auth/USER/PASS  → 401 se non autenticato, 200 se OK
# httpbin.org/status/403            → 403 diretto
# =============================================================================

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

# Costruisce e mostra l'header Authorization Basic
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
# PASSO 1 — 401 Unauthorized (nessuna credenziale)
# =============================================================================
clear
sep "401 Unauthorized — nessuna credenziale"

echo -e "  Il server NON SA CHI SEI."
echo -e "  Hai chiamato una route protetta senza mandare nessun header."
echo ""
echo -e "  httpbin espone: ${BOLD}/basic-auth/admin/secret123${RESET}"
echo -e "  → risponde 200 solo se mandi le credenziali giuste"
echo -e "  → risponde 401 se non mandi niente"
echo ""

ROUTE="$BASE/basic-auth/admin/secret123"

echo -e "  --- Richiesta senza header Authorization ---"
echo ""
echo -e "  ${GREEN}curl -s -v '$ROUTE' 2>&1 | grep -E 'HTTP|WWW'${RESET}"
echo ""
curl -s -v "$ROUTE" 2>&1 | grep -E "^< HTTP|^< WWW"
echo ""
curl -s -o /dev/null -w "  → Status: %{http_code}\n" "$ROUTE"
echo ""
echo -e "  L'header ${BOLD}WWW-Authenticate${RESET} dice al client come autenticarsi."

pausa

# =============================================================================
# PASSO 2 — 403 Forbidden (sappiamo chi sei, ma non puoi entrare)
# =============================================================================
sep "403 Forbidden — autenticato ma senza permessi"

echo -e "  Il server SA CHI SEI, ma non ti fa passare."
echo -e "  Hai mandato credenziali: sono state lette, ma non bastano."
echo ""
echo -e "  Caso reale: sei loggato ma provi ad aprire /admin senza essere root."
echo ""

echo -e "  --- Credenziali sbagliate (il server ti riconosce come non-autorizzato) ---"
echo ""
b64_errate=$(mostra_basic_auth "hacker:tentativo")

echo -e "  ${GREEN}curl -s -o /dev/null -w '  → Status: %{http_code}\\n' \\${RESET}"
echo -e "  ${GREEN}     -H 'Authorization: Basic $b64_errate' '$ROUTE'${RESET}"
echo ""
curl -s -o /dev/null -w "  → Status: %{http_code}\n" \
  -H "Authorization: Basic $b64_errate" \
  "$ROUTE"
echo ""

echo -e "  (httpbin restituisce 401 anche qui perché le creds non matchano,"
echo -e "   ma il tuo server reale può scegliere di rispondere 403 se preferisce"
echo -e "   comunicare 'capito chi sei, rifiutato' anziché 'non so chi sei')"
echo ""

pausa

# =============================================================================
# PASSO 3 — Confronto diretto 401 vs 403
# =============================================================================
sep "401 vs 403 — confronto diretto"

echo -e "  Tre scenari sulla stessa route protetta:"
echo ""

# Scenario A — nessun header
echo -e "  ${BOLD}[A] Nessun header → 401 (chi sei?)${RESET}"
curl -s -o /dev/null -w "  → Status: %{http_code}\n" "$ROUTE"
echo ""

# Scenario B — credenziali sbagliate → httpbin risponde 401
# per simulare 403 usiamo /status/403
echo -e "  ${BOLD}[B] Credenziali presenti ma server rifiuta → 403 (non puoi entrare)${RESET}"
curl -s -o /dev/null -w "  → Status: %{http_code}\n" "$BASE/status/403"
echo ""

# Scenario C — credenziali corrette
echo -e "  ${BOLD}[C] Credenziali corrette (admin:secret123) → 200 (benvenuto)${RESET}"
b64_ok=$(echo -n "admin:secret123" | base64)
curl -s -w "  → Status: %{http_code}\n" \
  -H "Authorization: Basic $b64_ok" \
  "$ROUTE" | python3 -m json.tool 2>/dev/null
echo ""

pausa

# =============================================================================
# PASSO 4 — Altri 4xx comuni
# =============================================================================
sep "Altri codici 4xx comuni"

echo -e "  I 4xx indicano sempre un errore dal lato CLIENT (non del server)."
echo ""

declare -A DESCR=(
  [400]="Bad Request        — richiesta malformata (JSON sbagliato, parametri mancanti)"
  [401]="Unauthorized       — non autenticato"
  [403]="Forbidden          — autenticato ma senza permessi"
  [404]="Not Found          — la route/risorsa non esiste"
  [405]="Method Not Allowed — metodo HTTP sbagliato (GET su route che vuole POST)"
  [429]="Too Many Requests  — hai superato il rate limit"
)

for code in 400 401 403 404 405 429; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/status/$code")
  echo -e "  ${YELLOW}$status${RESET}  →  ${DESCR[$code]}"
done

echo ""

pausa

# =============================================================================
# RIEPILOGO
# =============================================================================
sep "RIEPILOGO — differenza chiave 401 vs 403"

echo -e "  ${YELLOW}401 Unauthorized${RESET}"
echo -e "    → Il server NON SA CHI SEI"
echo -e "    → Non hai mandato credenziali (o sono assenti/malformate)"
echo -e "    → Il server include ${BOLD}WWW-Authenticate${RESET} per dirti come autenticarti"
echo -e "    → Azione: fai login / manda le credenziali"
echo ""
echo -e "  ${YELLOW}403 Forbidden${RESET}"
echo -e "    → Il server SA CHI SEI"
echo -e "    → Le credenziali erano presenti, ma non hai i permessi necessari"
echo -e "    → Nessun ${BOLD}WWW-Authenticate${RESET} — autenticarti di nuovo non serve"
echo -e "    → Azione: chiedi all'amministratore i permessi"
echo ""
echo -e "${BOLD}  Fine simulazione 4xx.${RESET}"
echo ""

# Simulazione HTTP Status Code

Laboratorio interattivo a riga di comando per imparare gli status code HTTP dal vivo.
Ogni script fa richieste reali con `curl` e mostra cosa risponde il server, passo per passo.

---

## Struttura del progetto

```
.
├── README.md
├── main.sh                  ← orchestratore: esegue tutti gli script in sequenza
├── file_2XX_esercizio.sh    ← status code 2xx (200, 201, 204)
├── simulazione_300.sh       ← status code 3xx (301, 302, 304)
├── simulazione_400.sh       ← status code 4xx (400, 401, 403)
├── simulazione_500.sh       ← status code 5xx (500) — richiede Flask
└── server_500.py            ← server Python locale usato solo da simulazione_500.sh
```

---

## Requisiti

| Strumento | Versione minima | Necessario per |
|---|---|---|
| `bash` | 4.0+ | tutti gli script |
| `curl` | qualsiasi | tutti gli script |
| `python3` | 3.7+ | solo `simulazione_500.sh` |
| `flask` | qualsiasi | solo `simulazione_500.sh` |

Installare Flask se necessario:

```bash
pip install flask
```

Per gli script `2xx`, `3xx` e `4xx` non serve nessun server locale: le richieste vanno tutte su **httpbin.org**, un servizio pubblico pensato apposta per testare HTTP.

---

## Come eseguire

Rendere gli script eseguibili:

```bash
chmod +x main.sh file_2XX_esercizio.sh simulazione_300.sh simulazione_400.sh simulazione_500.sh
```

Eseguire tutto in sequenza:

```bash
bash main.sh
```

Eseguire un singolo script:

```bash
bash file_2XX_esercizio.sh
bash simulazione_300.sh
bash simulazione_400.sh
bash simulazione_500.sh
```

Eseguire più script scelti tramite `main.sh`:

```bash
bash main.sh 300 400
bash main.sh 400 500
```

---

## Cosa fa ogni file

### `file_2XX_esercizio.sh` — Status code 2xx

Dimostra le tre risposte di successo principali.

**200 OK** — `GET /get`
Richiesta semplice di lettura. Il server risponde con il body della risposta in JSON. Mostra l'uso di `-w "%{http_code}"` per leggere il codice di risposta.

**201 Created** — `POST /status/201`
Simulazione di una creazione risorsa. Usa `-X POST`, `-H "Content-Type: application/json"` e `-d` per mandare un body JSON al server.

**204 No Content** — `HEAD /status/204`
Usa `-I` per mostrare solo gli header HTTP senza body. Tipico delle operazioni di delete o update che non restituiscono nulla.

**Riepilogo finale** — ciclo `for` su `/status/200`, `/status/201`, `/status/204`
Verifica in automatico che i tre codici vengano restituiti correttamente.

---

### `simulazione_300.sh` — Status code 3xx

Dimostra il meccanismo dei redirect.

**301 Moved Permanently**
La risorsa è stata spostata definitivamente. Tre varianti della stessa richiesta:
- senza `-L`: mostra il `301` grezzo senza seguirlo
- con `-v` + `grep`: mostra l'header `Location` che contiene la nuova destinazione
- con `-L`: curl segue il redirect come un browser e mostra lo status finale (`200`)

**302 Found**
Redirect temporaneo. Stessa struttura del 301, evidenzia la differenza semantica: il browser non memorizza il redirect e lo riverifica ogni volta.

**Catena di redirect multipli** — `/redirect/3`
Simula 3 redirect consecutivi. Mostra la differenza tra fermarsi al primo salto (senza `-L`) e seguire tutta la catena (con `-L --max-redirs 10`). La versione verbose mostra ogni singolo `GET` e ogni `Location` nella catena.

**Riepilogo** — 301, 302, 304 con nota SEO
- `301`: il page rank passa al nuovo URL
- `302`: il page rank resta sul vecchio URL
- `304`: risorsa non cambiata, il client usa la cache locale

---

### `simulazione_400.sh` — Status code 4xx

Dimostra i tre errori client più comuni e la loro differenza.

**400 Bad Request**
La richiesta è malformata prima ancora che il server provi ad autenticare. Due esempi:
- JSON con virgola finale non valida (`{"nome":"Mario",}`) mandato con `Content-Type: application/json`
- 400 forzato direttamente con `/status/400`

**401 Unauthorized**
Il server non sa chi sei. Chiamata a `/basic-auth/admin/secret123` senza header. La risposta include `WWW-Authenticate` che dice al client il tipo di autenticazione richiesto (Basic, Bearer, ecc.).

**403 Forbidden**
Il server sa chi sei ma non ti fa entrare. Chiamata con credenziali sbagliate costruite dalla funzione `mostra_basic_auth()`. Simulato con `/status/403` perché httpbin tecnicamente risponde sempre 401 su credenziali errate.

**Confronto diretto A/B/C/D**
Quattro scenari sulla stessa progressione: richiesta rotta → nessuna identità → identità rifiutata → accesso concesso.

**Schema mentale:**
```
richiesta malformata?         → 400
chi sei? (nessuna auth)       → 401
so chi sei, non puoi entrare  → 403
```

#### La funzione `mostra_basic_auth()`

Costruisce l'header `Authorization: Basic` necessario per HTTP Basic Auth.

HTTP richiede che `utente:password` venga codificato in Base64 prima di essere inserito nell'header. Base64 **non è cifratura** — chiunque può decodificarlo. Serve solo a rendere la stringa trasportabile in un header HTTP senza che i caratteri speciali (come `:`) rompano il protocollo. La sicurezza reale è garantita da HTTPS, che cifra l'intera connessione.

```bash
b64=$(mostra_basic_auth "hacker:tentativo")
curl -H "Authorization: Basic $b64" URL
```

Gli echo didattici dentro la funzione usano `>&2` (stderr) per non interferire con il valore di ritorno. Quando una funzione viene chiamata con `var=$(funzione)`, bash cattura tutto lo stdout — redirigere i log su stderr fa sì che `$b64` contenga solo il Base64 pulito.

---

### `simulazione_500.sh` + `server_500.py` — Status code 5xx

Unico script che richiede un server locale. Avvia `server_500.py` in background, aspetta che risponda, poi fa le richieste.

Il server viene fermato automaticamente alla fine tramite `trap cleanup EXIT` — anche in caso di errore o interruzione con `Ctrl+C`.

**500 da ZeroDivisionError** — `/crash`
Il codice Python esegue letteralmente `1 / 0`. L'eccezione non viene gestita, sale fino all'handler globale di Flask che risponde 500.

**500 da ConnectionError** — `/crash-db`
Simula un database irraggiungibile. Il caso reale più comune in produzione: il DB è giù, sovraccarico, o la stringa di connessione è sbagliata.

**500 gestito** — `/crash-gestito`
Il server cattura il `TypeError` lui stesso con `try/except` e costruisce una risposta 500 con un messaggio chiaro. Mostra la buona pratica: non esporre lo stack trace al client, loggarlo internamente e restituire un messaggio generico.

**Differenza gestito vs non gestito:**
- Non gestito: l'eccezione sale fino a Flask, il tipo di errore è visibile nella risposta
- Gestito: `try/except` nel codice, il server controlla esattamente cosa esporre

---

## Concetti chiave riassunti

| Codice | Significato | Chi ha sbagliato |
|---|---|---|
| `200` | OK | — |
| `201` | Risorsa creata | — |
| `204` | Successo, nessun body | — |
| `301` | Redirect permanente | — |
| `302` | Redirect temporaneo | — |
| `304` | Non modificato, usa cache | — |
| `400` | Richiesta malformata | Client |
| `401` | Non autenticato | Client |
| `403` | Autenticato, senza permessi | Client |
| `500` | Crash del server | Server |

---

## httpbin.org

Tutti gli script tranne `simulazione_500.sh` usano [httpbin.org](https://httpbin.org) come server di test. Gli endpoint più usati in questo progetto:

| Endpoint | Comportamento |
|---|---|
| `/get` | Risponde 200 con un JSON che rispecchia la richiesta |
| `/post` | Risponde 200 (o 400 se il JSON è invalido) con eco del body |
| `/status/N` | Risponde sempre con il codice N |
| `/basic-auth/USER/PASS` | Risponde 401 senza auth, 200 con le credenziali giuste |
| `/redirect-to?url=X&status_code=N` | Risponde con redirect N verso X |
| `/redirect/N` | Esegue N redirect consecutivi prima di rispondere 200 |

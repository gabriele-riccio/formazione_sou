# Esercitazione HTTP Status Code
Ho svolto questo esercizio simulando delle richieste del browser e come avvengono le risposte del server con i vari status code.

Ogni script fa richieste reali con `curl` e mostra cosa risponde il server, passo per passo.
Solo per l'ultima parte,dove ho testato come risponderebbe un server a delle richieste se ci fosse un problema 
lato server(5XX), ho inserito un server a parte chiamato server_500.py usando
python e il framework flask.

---

## Requisiti

| Strumento | Versione minima | Necessario per |
|---|---|---|
| `bash` | 4.0+ | tutti gli script |
| `curl` | qualsiasi | tutti gli script |
| `python3` | 3.7+ | solo `file_5XX_esercizio.sh` |
| `flask` | qualsiasi | solo `file_5XX_esercizio.sh`  |

Installare Flask se necessario:

```bash
pip install flask
```

N.B Per gli script `2xx`, `3xx` e `4xx` non serve nessun server locale: le richieste  vanno tutte su **httpbin.org**, un servizio pubblico pensato apposta per testare HTTP.

---

## Come eseguire

Rendere gli script eseguibili:

```bash
chmod +x main.sh file_2XX_esercizio.sh file_3XX_esercizio.sh file_4XX_esercizio.sh
file_5XX_esercizio.sh server_500.py
```
Eseguire ogni singolo script:

```bash
bash file_2XX_esercizio.sh
bash file_3XX_esercizio.sh
bash file_4XX_esercizio.sh
bash file_5XX_esercizio.sh
```
---

## Cosa fa ogni file

### `file_2XX_esercizio.sh` — Status code 2xx

Dimostra le tre risposte di successo principali.

- **200 OK** — `GET /get`
  Richiesta semplice di lettura. Il server risponde con il body della risposta in
  JSON.
  Mostra l'uso di `-w "%{http_code}"` per leggere il codice di risposta.

- **201 Created** — `POST /status/201`
  Simulazione di una creazione risorsa.
  Usa `-X POST`, `-H "Content-Type: application/json"` e `-d` per mandare un body JSON
  al server.

- **204 No Content** — `HEAD /status/204`
  Usa `-I` per mostrare solo gli header HTTP senza body.
  Tipico delle operazioni di delete o update che non restituiscono nulla.

- **Riepilogo finale** — spiego quello che fanno i vari /status 200,201,204.

#### Output

![200 OK — GET semplice](esercizio statuscode HTTP/Screenshot2026-05-14%20alle09.46.58)

**200 OK — GET semplice**
```
Mandiamo dati al server con il metodo GET.
Il server ha ricevuto la richiesta e risponde con successo.

curl -s -w '\n  → Status: %{http_code}\n' https://httpbin.org/get

{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Host": "httpbin.org",
    "User-Agent": "curl/8.7.1",
    "X-Amzn-Trace-Id": "Root=1-6a047d62-7ee4dc1905de88620f497be2"
  },
  "origin": "188.12.196.154",
  "url": "https://httpbin.org/get"
}

  → Status: 200
```

**201 OK — POST con corpo JSON**
```
Mandiamo dati al server con il metodo POST.
Il server li riceve, li elabora e risponde 201 con l'eco dei dati.

curl -s -X POST -H 'Content-Type: application/json'
     -d '{"nome":"Mario","ruolo":"admin"}'
     -w '\n  → Status: %{http_code}\n' https://httpbin.org/status/201

  → Status: 201
```

**204 NO CONTENT — Vedere gli header della risposta**
```
Con -I (o --head) curl mostra SOLO gli header HTTP, senza il body.

curl -s -I https://httpbin.org/status/204

HTTP/2 204
date: Wed, 13 May 2026 13:32:22 GMT
server: gunicorn/19.9.0
access-control-allow-origin: *
access-control-allow-credentials: true
```

**Riepilogo — 2xx**
```
200 OK          → richiesta riuscita, body presente
201 Created     → risorsa creata (tipico delle POST su API REST)
204 No Content  → successo ma nessun body da restituire
```

---

### `file_3XX_esercizio.sh` — Status code 3xx

Dimostra il meccanismo dei redirect.

- **301 Moved Permanently**
  La risorsa è stata spostata definitivamente.
  Tre varianti della stessa richiesta:
  - senza `-L`: mostra il `301` grezzo senza seguirlo
  - con `-v` + `grep`: mostra l'header `Location` che contiene la nuova destinazione
  - con `-L`: curl segue il redirect come un browser e mostra lo status finale (`200`)

- **302 Found**
  Redirect temporaneo.
  Stessa struttura del 301, evidenzia la differenza semantica: il browser non
  memorizza il redirect e lo riverifica ogni volta.


- **Riepilogo** — 301, 302,  con nota SEO
  - `301`: il page rank passa al nuovo URL
  - `302`: il page rank resta sul vecchio URL, per manuetenzioni temporanee.


#### Output

**301 Moved Permanently**
```
La risorsa è stata spostata DEFINITIVAMENTE a un nuovo indirizzo.
Il browser memorizza il redirect: la prossima volta va diretto.

L'header Locazione nella risposta contiene il nuovo URL.

Redirect (senza seguire direttamente verso l'url)

curl -s -o /dev/null -w '  → Status: %{http_code}\n'
     'https://httpbin.org/redirect-to?url=https://httpbin.org/get&status_code=301'

  → Status: 301

Mostro l'header Location con -v

< HTTP/2 301
< location: https://httpbin.org/get

--- In genere curl non segue il redirect con -L (come fa il browser) ---
--- Con -L lo segue come fa il browser ---

curl -s -o /dev/null -w '  → Status finale: %{http_code}\n'
     -L 'https://httpbin.org/redirect-to?url=https://httpbin.org/get&status_code=301'

  → Status finale: 200
```

**302 Found (redirect temporaneo)**
```
La risorsa è TEMPORANEAMENTE a un altro indirizzo.

Caso reale: sito in manutenzione che rimanda a una pagina temporanea.

curl -s -o /dev/null -w '  → Status: %{http_code}\n'
     'https://httpbin.org/redirect-to?url=https://httpbin.org/get&status_code=302'

  → Status: 302

Header Location:
< HTTP/2 302
< location: https://httpbin.org/get
```

**Riepilogo**
```
301 Moved Permanently  → nuovo URL definitivo, browser lo memorizza
302 Found              → redirect temporaneo, si riverifica ogni volta

Differenza pratica:
– 301 → SEO passa al nuovo URL, vecchio link diventa irrilevante
– 302 → SEO resta sul vecchio URL, utile per manutenzioni temporanee

Fine simulazione 3xx.
```

---

### `File_4XX_esercizio.sh` — Status code 4xx

Sono gli errori lato client

- **404 Bad Request**
  La richiesta è malformata prima ancora che il server provi ad autenticare.
  Esempio:
  URL del sito digitato male dall'utente.

- **401 Unauthorized**
  Il server non sa chi sei.
  Chiamata a `/basic-auth/admin/secret123` senza header.
  La risposta include `WWW-Authenticate` che dice al client il tipo di autenticazione
  richiesto (Basic, Bearer, ecc.).

- **403 Forbidden**
  Il server sa chi sei ma non ti fa entrare.
  Chiamata con credenziali sbagliate costruite dalla funzione `mostra_basic_auth()`.
  Simulato con `/status/403` perché httpbin tecnicamente risponde sempre 401 su
  credenziali errate.

- **Confronto diretto A/B/C/D**
  Quattro scenari sulla stessa progressione:
  - richiesta errata
  - nessuna identità
  - identità rifiutata
  - accesso concesso.

- **Schema mentale:**
  ```
  richiesta malformata (URL errato o insesistente)         → 404
  chi sei? (credenziali errate)       → 401
  so chi sei, non puoi entrare (nessuna autorizzazione) → 403
  ```

#### La funzione `mostra_basic_auth()`

Costruisce l'header `Authorization: Basic` necessario per HTTP Basic Auth.

- HTTP richiede che `utente:password` venga codificato in Base64 prima di essere inserito nell'header.
- Base64 **non è cifratura** — chiunque può decodificarlo
- Serve solo a rendere la stringa trasportabile in un header HTTP senza che i
  caratteri speciali (come `:`) rompano il protocollo.
- La sicurezza reale è garantita da HTTPS, che cifra l'intera connessione.

  ```bash
  b64=$(mostra_basic_auth "hacker:tentativo")
  curl -H "Authorization: Basic $b64" URL
  ```

- Gli echo didattici vanno dentro la funzione usano `>&2` (stderr) per non interferire
  con il valore di ritorno.
- Quando una funzione viene chiamata con `var=$(funzione)`, bash cattura tutto lo
  stdout.

#### Output

**404 Not Found — la risorsa non esiste**
```
Il server ti sta dicendo che la risorsa per come l'hai scritta non esiste.

L'errore è sempre del CLIENT — hai richiesto qualcosa che non c'è.

  Caso reale: URL digitato male

Chiamiamo /urlsbagliato e httpbin non la conosce.

curl -s -o /dev/null -w '  → Status: %{http_code}\n'
     https://httpbin.org/urlsbagliato

  → Status: 404
```

**401 Unauthorized — nessuna credenziale**
```
Il server NON SA CHI SEI.
Hai chiamato una route protetta senza mandare nessun header.

il server espone: /basic-auth/admin/secret123
→ risponde 200 solo se mandi le credenziali giuste
→ risponde 401 se non mandi niente

  Richiesta senza header Authorization

curl -s -v 'https://httpbin.org/basic-auth/admin/secret123' 2>&1 | grep -E 'HTTP|WWW'

< HTTP/2 401

  → Status: 401

L'header WWW-Authenticate dice al client il tipo di auth
che il server si aspetta (Basic, Bearer, Digest, ecc.).
```

**403 Forbidden — autenticato ma senza permessi**
```
Il server SA CHI SEI, ma non ti fa passare, non hai l'autorizzazione.

Caso reale: sei loggato ma provi ad aprire /admin senza avere il permesso.

--- Costruzione dell'header con credenziali sbagliate ---

  Costruzione dell'header Authorization: Basic
    1. credenziali:  hacker:tentativo
    2. base64:       aGFja2VyOnRlbnRhdGl2bw==
    3. header:       Authorization: Basic aGFja2VyOnRlbnRhdGl2bw==

curl -s -o /dev/null -w '  → Status: %{http_code}\n'
     -H 'Authorization: Basic aGFja2VyOnRlbnRhdGl2bw=='
     'https://httpbin.org/basic-auth/admin/secret123'

  → Status: 401
```

> **Nota:** httpbin risponde 401 anche con credenziali sbagliate perché non distingue i due casi. Un server reale risponde 403 quando capisce che l'utente esiste ma non ha i permessi necessari.

**404 vs 401 vs 403 — confronto diretto**
```
Quattro scenari che mostrano le tre famiglie di errore:

[1] Url inesistente o sbagliato → 404
    La richiesta è ben formata, ma la risorsa non esiste sul server.
  → Status: 404

[2] Nessun header Authorization → 401
    La richiesta è ben formata, ma manca completamente l'identità.
  → Status: 401

[3] Credenziali presenti ma rifiutate → 403
    L'identità è presente ma non ha i permessi per accedere.
  → Status: 403

[4] Url corretto e credenziali corrette (admin:secret123) → 200
{
  "authenticated": true,
  "user": "admin"
}
  → Status: 200
```

**Riepilogo — 404 vs 401 vs 403**
```
404 Not Found
  → La risorsa richiesta non esiste (path sbagliato, ID inesistente)
  → Il server ha capito la richiesta, ma non trova nulla da restituire
  → Azione: verifica l'URL, l'ID o se la risorsa è stata eliminata

401 Unauthorized
  → Il server NON SA CHI SEI
  → Credenziali assenti o sbagliate
  → Il server include WWW-Authenticate → ti dice come autenticarti
  → Azione: fai login / manda le credenziali

403 Forbidden
  → Il server SA CHI SEI
  → Credenziali presenti ma permessi insufficienti
  → Nessun WWW-Authenticate — autenticarti di nuovo non serve
  → Azione: chiedi all'amministratore i permessi

Fine simulazione 4xx (404/401/403).
```

---

### `file_5XX_esercizio.sh` + `server_500.py` — Status code 5xx

Unico script che richiede un server locale.
Avvia `server_500.py` in background, aspetta che risponda, poi fa le richieste.

Il server viene fermato automaticamente alla fine tramite `trap cleanup EXIT`
anche in caso di errore o interruzione con `Ctrl+C`.

- **500 da ZeroDivisionError** — `/crash`
  Il codice Python esegue letteralmente `1 / 0`.
  L'eccezione non viene gestita, sale fino all'handler globale di Flask che risponde
  500.

- **500 da ConnectionError** — `/crash-db`
  Simula un database irraggiungibile.
  Il caso reale più comune in produzione: il DB è giù, sovraccarico, o la stringa di
  connessione è sbagliata.

- **500 gestito** — `/crash-gestito`
  Il server cattura il `TypeError` lui stesso con `try/except` e costruisce una
  risposta 500 con un messaggio chiaro.
  Mostra la buona pratica: non esporre lo stack trace al client, loggarlo internamente
  e restituire un messaggio generico.

- **Differenza gestito vs non gestito:**
  Non gestito: l'eccezione sale fino a Flask, il tipo di errore è visibile nella
  risposta
  Gestito: `try/except` nel codice, il server controlla esattamente cosa esporre

#### Output

**Avvio server Flask**
```
Server avviato (PID: 24780)
* Serving Flask app 'server_500'
* Debug mode: off
Server pronto!
```

**500 — ZeroDivisionError (crash non gestito)**
```
Il codice Python fa letteralmente: risultato = 1 / 0
Flask intercetta l'eccezione e risponde 500 tramite l'handler globale.

La tua richiesta era corretta. Il bug è nel SERVER.

curl -s -w '\n  → Status: %{http_code}\n' http://127.0.0.1:5000/crash

[2026-05-13 15:13:20,327] ERROR in app: Exception on /crash [GET]
Traceback (most recent call last):
  ...
  File ".../server_500.py", line 21, in crash_zero_division
    risultato = 1 / 0          # ZeroDivisionError — non gestito
ZeroDivisionError: division by zero
{
    "errore": "Internal Server Error",
    "messaggio": "Il server ha incontrato un errore imprevisto.",
    "tipo": "ZeroDivisionError"
}
  → Status: 500
```

**500 — ConnectionError (database non raggiungibile)**
```
Il server prova a connettersi a un DB che non esiste.
Simula il caso reale più comune in produzione:
il DB è giù, sovraccarico, o la stringa di connessione è sbagliata.

curl -s -w '\n  → Status: %{http_code}\n' http://127.0.0.1:5000/crash-db

[2026-05-13 15:13:22,062] ERROR in app: Exception on /crash-db [GET]
Traceback (most recent call last):
  ...
  File ".../server_500.py", line 28, in crash_db
    raise ConnectionError("Impossibile connettersi al database: timeout dopo 30s")
ConnectionError: Impossibile connettersi al database: timeout dopo 30s

  → Status: 500
```

**500 — TypeError gestito dal codice**
```
Il server cattura l'eccezione lui stesso e costruisce
una risposta 500 con un messaggio chiaro per il client.

Buona pratica: non esporre mai lo stack trace al client,
ma loggarlo internamente e dare un messaggio generico.

curl -s -w '\n  → Status: %{http_code}\n' http://127.0.0.1:5000/crash-gestito

{
    "codice": 500,
    "dettaglio": "object of type 'NoneType' has no len()",
    "errore": "Errore interno del server"
}
  → Status: 500
```

**Gestito vs Non gestito — a confronto**
```
Non gestito (/crash):
→ L'eccezione sale fino all'handler globale di Flask
→ Il tipo di errore è visibile nella risposta (ZeroDivisionError)
→ In produzione con debug=False, Flask nasconde i dettagli

Gestito (/crash-gestito):
→ try/except nel codice — il server controlla cosa esporre
→ Messaggio human-readable, nessun leak di info interne
→ Puoi loggare il dettaglio senza inviarlo al client
```

**Riepilogo — 5xx**
```
I 5xx indicano sempre un errore dal lato SERVER.
La richiesta del client era corretta.

500 Internal Server Error  → crash generico, bug nel codice
502 Bad Gateway            → il reverse proxy non raggiunge il backend
503 Service Unavailable    → server sovraccarico o in manutenzione
504 Gateway Timeout        → il backend ha impiegato troppo tempo

Risultati reali delle route testate:
  500  /crash        — ZeroDivisionError (non gestito)
  500  /crash-db     — ConnectionError — DB irraggiungibile
  500  /crash-gestito — TypeError gestito nel codice

Fine simulazione 5xx.

Fermo il server Flask (PID 24780)...
Server fermato.
```

---

## Concetti chiave riassunti

| Codice | Significato | Chi ha sbagliato |
|---|---|---|
| `200` | OK | — |
| `201` | Risorsa creata | — |
| `204` | Successo, nessun body | — |
| `301` | Redirect permanente | — |
| `302` | Redirect temporaneo | — |
| `404` | Richiesta sbagliata | Client |
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

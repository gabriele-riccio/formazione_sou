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

**200 OK — GET semplice**

![200 OK — GET semplice](esercizio%20statuscode%20HTTP/Screenshot%202026-05-14%20alle%2010.05.05.png)


**201 OK — POST con corpo JSON**

![201 OK — POST con corpo JSON](esercizio%20statuscode%20HTTP/Screenshot%202026-05-14%20alle%2010.29.51.png)


**204 NO CONTENT — RIEPILOGO 2XX**

![204 NO CONTENT — RIEPILOGO 2XX](esercizio%20statuscode%20HTTP/Screenshot%202026-05-13%20alle%2015.32.47.png)

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

---

#### Output

**301 Moved Permanently — 302 Found**

![301 Moved Permanently — 302 Found](esercizio%20statuscode%20HTTP/Screenshot%202026-05-14%20alle%2010.31.06.png)

**Riepilogo**

![Riepilogo](esercizio%20statuscode%20HTTP/Screenshot%202026-05-13%20alle%2015.31.06.png)

---

### `File_4XX_esercizio.sh` — Status code 4xx

Sono gli errori lato client

- **404 Not Found — la risorsa non esiste**
  La richiesta è malformata o non esiste prima ancora che il server provi ad autenticare.
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
  
---
#### Output

**404 Not Found — la risorsa non esiste**

![404 Not Found — la risorsa non esiste](esercizio%20statuscode%20HTTP/Screenshot%202026-05-14%20alle%2010.31.53.png)

**401 Unauthorized — nessuna credenziale**

![401 Unauthorized — nessuna credenziale](esercizio%20statuscode%20HTTP/Screenshot%202026-05-14%20alle%2010.32.07.png)

**403 Forbidden — autenticato ma senza permessi**

![403 Forbidden — autenticato ma senza permessi](esercizio%20statuscode%20HTTP/Screenshot%202026-05-14%20alle%2010.32.37.png)

> **Nota:** httpbin risponde 401 anche con credenziali sbagliate perché non distingue i due casi. Un server reale risponde 403 quando capisce che l'utente esiste ma non ha i permessi necessari.

**404 vs 401 vs 403 — confronto diretto**

![404 vs 401 vs 403 — confronto diretto](esercizio%20statuscode%20HTTP/Screenshot%202026-05-14%20alle%2010.32.54.png)

**RIEPILOGO - 404 vs 401 vs 403**

![RIEPILOGO - 404 vs 401 vs 403](esercizio%20statuscode%20HTTP/Screenshot%202026-05-13%20alle%2015.28.29.png)


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

**Avvio server Flask- 500 - ZeroDivisionError (crash non gestito)**
![Avvio server Flask- 500 - ZeroDivisionError (crash non gestito)](esercizio%20statuscode%20HTTP/Screenshot%202026-05-13%20alle%2015.25.47.png)

**500 — ConnectionError (database non raggiungibile)**

![500 — ConnectionError (database non raggiungibile)](esercizio%20statuscode%20HTTP/Screenshot%202026-05-14%20alle%2010.34.24.png)

**500 — TypeError gestito dal codice**

![500 — TypeError gestito dal codice](esercizio%20statuscode%20HTTP/Screenshot%202026-05-14%20alle%2010.34.36.png)

**Gestito vs Non gestito — a confronto**

![Gestito vs Non gestito — a confronto](esercizio%20statuscode%20HTTP/Screenshot%202026-05-13%20alle%2015.26.04.png)

**Riepilogo — 5xx**

![Riepilogo — 5xx](esercizio%20statuscode%20HTTP/Screenshot%202026-05-13%20alle%2015.26.11.png)

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

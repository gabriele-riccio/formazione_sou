# ESERCIZIO HTTP STATUS CODE 

Chi si occupa di siti web, gestione dei portali e degli hosting deve conoscere bene i codici di status HTTP, ovvero gli **HTTP Status Code**, dei codici che i server web restituiscono al browser in risposta a una richiesta.
In pratica, quando visiti una pagina internet ricevi un risultato che corrisponde a un codice di stato HTTP.
Essi sono dei codici che definiscono l'esito positivo o negativo della richiesta.
E' importante conoscere gli HTTP status code per capire se l'operazione è andata a buon fine o se ci sono degli errori.

---

## Cosa sono gli Status Code HTTP?
I codici stato HTTP – noti anche come Status Code HTTP – sono una combinazione di valori numerici che vanno da **100 a 500** per indicare le varie condizioni di una risposta del web server.

Per semplificare, quando un client effettua una richiesta attraverso l’HyperText Transfer Protocol (**HTTP**) si ottiene una risposta che può essere positiva o negativa. Per identificare queste condizioni, l’IETF (RFC 2616) – insieme ad alcune RFC con codici di stato extra – ha individuato una serie di combinazioni numeriche con relativa spiegazione per avere delle informazioni utili su come intervenire e come decifrare la combinazione.

Tutte le interazioni tra il browser e un sito web si basano sul principio di **richiesta-risposta**.
Ogni volta che si digita un indirizzo nel browser, si visita una pagina web, si scarica un file o si esegue qualsiasi azione online, il tuo browser (client) invia una richiesta HTTP al server del sito web.
Il server elabora la richiesta e restituisce una risposta HTTP.



BROWSER(CLIENT) ---> { RICHIESTA HTTP [GET,PUT,POST]} ---> SERVER

BROWSER(CLIENT) <--- { RISPOSTA HTTP [GET,PUT,POST] } <--- SERVER
                <--- { STATUS CODE(200,300,400,500) } <---



## Perché conoscere la lista dei codici?
Bisogna conoscere bene i diversi HTTP Status Code perché in questo modo possono intervenire in modo sistematico e strutturato.
Ad esempio, di fronte a un **errore 404** si possono prendere determinate precauzioni o lasciare la pagina con questo Status Code se non coi sono implicazioni.


---


## La lista dei diversi HTTP Status Code
Per gestire questi codici di status sono state organizzate le diverse alternative con un sistema basato su alcuni numeri che si articolano *in 5 gruppi*, **da 1XX a 5XX**.
Ecco le condizioni più importanti da conoscere:

## 1XX – Informativo (Informational)
Iniziamo da una base solida di Status Code. Questa famiglia codici di stato HTTP indicano che la richiesta effettuata dal client (tipo il browser) è stata ricevuta dal web server e il processo per completare è in corso.

100 Continue: ricevuta la richiesta iniziale, il client può continuare a inviare.
101 Switching Protocols: il server accetta di cambiare il protocollo su richiesta del client.
102 Processing (WebDAV): la macchina sta elaborando ma non ha una risposta.
103 Early Hints: comunica intestazioni anticipate prima della risposta definitiva.
2XX – Successo (Success)
I codici di status che rientrano nella categoria 2XX ci comunicano un messaggio molto importante per chi si occupa della buona gestione del sito web: la richiesta è stata ricevuta, compresa e accettata dal server.

200 OK: la richiesta è stata eseguita.
201 Created: la richiesta completata ha portato a una nuova risorsa.
202 Accepted: accettata l’elaborazione, il processo non è stato completato.
203 Non-Authoritative Information: informazioni da una fonte non autorevole.
204 No Content: tutto funziona ma non c’è contenuto da restituire.
205 Reset Content: Ii client dovrebbe resettare il contenuto.
206 Partial Content: viene restituito solo una parte del contenuto.
207 Multi-Status (WebDAV): abbiamo lo stato di più operazioni.
208 Already Reported (WebDAV): gli elementi esistenti sono stati segnalati.
226 IM Used: la risposta è rappresentazione del risultato di una o più manipolazioni.
3xx – Reindirizzamento (Redirection)
Se i primi gruppi di HTTP Status Code indicano un sostanziale funzionamento del processo, qui iniziano gli aspetti tecnici che meritano maggiore attenzione. Perché in questo caso il client deve affrontare più passaggi.

300 Multiple Choices: il client può scegliere diverse opzioni di risorsa.
301 Moved Permanently: la pagina è stata spostata permanentemente.
302 Found: la risorsa è stata portata in modo temporaneo su un nuovo URL.
303 See Other: la risposta può essere trovata in un altro URL con il metodo GET.
304 Not Modified: risorsa non modificata dal momento dell’ultima richiesta.
305 Use Proxy (Deprecato): pagina accessibile tramite un proxy.
307 Temporary Redirect: la risorsa è temporaneamente accessibile a un altro URL.
308 Permanent Redirect: il client dovrebbe usare sempre l’URL alternativo.
4xx – Errore del client (Client Error)
Questi codici di status comunicano a chiare lettere che c’è un errore nella richiesta inviata dal client. Quindi bisogna quantomeno valutare se intervenire o meno per correggere l’errore. Ecco gli Status Code 4XX più diffusi:

400 Bad Request: c’è un errore, la richiesta non può essere soddisfatta.
401 Unauthorized: serve l’autenticazione per completare la richiesta.
403 Forbidden: il server ha compreso la richiesta ma non la autorizza.
404 Not Found: la pagina non è stata trovata sul server.
405 Method Not Allowed: il metodo usato non è consentito.
406 Not Acceptable: la risorsa non è disponibile nel formato richiesto.
407 Proxy Authentication Required: serve l’autenticazione tramite proxy.
408 Request Timeout: il server ha impiegato troppo tempo per ricevere la richiesta.
409 Conflict: c’è un conflitto con lo stato attuale della risorsa.
410 Gone: la pagina non è più disponibile e non tornerà.
411 Length Required: il server vuole la specificazione della lunghezza corpo della richiesta.
412 Precondition Failed: una precondizione nella richiesta è fallita.
413 Payload Too Large: il corpo della richiesta è troppo grande per il server.
414 URI Too Long: l’URI della richiesta è troppo lungo per il server.
415 Unsupported Media Type: il formato dei dati non è supportato dal server.
416 Range Not Satisfiable: il client ha richiesto una porzione della risorsa non accessibile.
417 Expectation Failed: il server non è in grado di soddisfare l’header Expect della richiesta.
418 I’m a teapot: easter egg, un pesce d’aprile dell’Internet Engineering Task Force.
421 Misdirected Request: la richiesta è stata inviata a un server che non può dare risposta.
422 Unprocessable Entity: il server comprende la richiesta, ma non è in grado di elaborarla.
423 Locked (WebDAV): la risorsa richiesta è bloccata
424 Failed Dependency: la richiesta fallisce a causa di una dipendenza non riuscita.
5xx – Errore del Server
Entriamo nel vivo dell’attività di ottimizzazione da parte del webmaster. In alcuni casi, gli errori di Status Code HTTP possono essere evitati e gestiti dal webmaster. In altri casi, invece, la colpa è del server. Una buona parte di questi problemi possono essere bypassati scegliendo un hosting di qualità con support sempre presente.

500 Internal Server Error: errore generico del server.
501 Not Implemented: la macchina non supporta la funzionalità richiesta.
502 Bad Gateway: il server ha ricevuto una risposta non valida da un altro server.
503 Service Unavailable: il server non è attualmente disponibile.
504 Gateway Timeout: non è stata ricevuta risposta tempestiva da un altro server.
505 HTTP Version Not Supported: non supporta la versione HTTP usata nella richiesta.
506 Variant Also Negotiates: la negoziazione di contenuti ha fallito.
507 Insufficient Storage: il server non ha spazio sufficiente per completare la richiesta.
508 Loop Detected: è stato rilevato un loop infinito.
510 Not Extended: le estensioni richieste non sono supportate.
511 Network Authentication Required: il client deve autenticarsi per ottenere l’accesso alla rete.



---

## Concetti coperti

| Concetto | Implementazione |
|---|---|
| Variabili | `NUM_PROCESSI`, `LOG_FILE`, `count_success`, `count_error` |
| Ciclo iterativo | `for ((i=1; i<=NUM_PROCESSI; i++))` |
| Gestione errori | `if comando; then ... else ... fi` |
| Status code | `$?` — 0 = successo, diverso da 0 = errore |
| Contatori | `((count_success++))`, `((count_error--))` |
| Errore forzato | Eliminazione file + tentativo di lettura al processo 3 |
| Funzioni di supporto | `log_message()`, `cleanup()` |
| Pulizia automatica | `trap cleanup EXIT` |
| Uscita semantica | `exit 0` (successo) / `exit 1` (errore) |

---

## Come funziona

### 1. Variabili
Definite in cima allo script in MAIUSCOLO (convenzione per le costanti):
```bash
LOG_FILE="processi.log"
NUM_PROCESSI=5
```

### 2. Funzioni
`log_message` stampa un messaggio formattato su schermo e lo aggiunge al file di log:
```bash
log_message "SUCCESS" "Processo 1 completato."
# output → [SUCCESS] - Processo 1 completato.
```

`cleanup` rimuove i file temporanei ed è agganciata all'evento `EXIT` tramite `trap`, quindi viene eseguita sempre, anche in caso di interruzione con `Ctrl+C`.

### 3. Ciclo
Per ogni processo viene creato un file temporaneo. Se la creazione va a buon fine, `count_success` viene incrementato; in caso contrario, `count_error` verrà incrementato.

### 4. Errore forzato al processo 3
Al terzo giro il file appena creato viene eliminato e si tenta di leggerlo — il comando fallisce, restituisce un status code diverso da 0, e lo script:
- decrementa `count_success` (il successo precedente era falso)
- incrementa `count_error`

### 5. Funzioni finali
`cleanup()` rimuove i file temporanei
`trap cleanup() exit` garantisce che cleanup venga sempre eseguita(ache quando faccio Ctrl C)

### 6. Report finale
```
-------------------------------------
Totale  : 5
Successi: 4
Errori  : 1
-------------------------------------
[INFO] - Script terminato con 1 errore/i.
[INFO] - Per risolvere controlla il ciclo for per rimuovere l'errore forzato della simulazione.

```

---


## Esecuzione

```bash
# Dai i permessi di esecuzione
chmod +x gestione_processi.sh

# Esegui lo script
./file_gestione_errori_completo.sh

# Come Output avrò:
[INFO] - Processo 1  in esecuzione...
[SUCCES] - Processo 1: Successo!
[INFO] - Processo 2  in esecuzione...
[SUCCES] - Processo 2: Successo!
[INFO] - Processo 3  in esecuzione...
[SUCCES] - Processo 3: Successo!
[Warning--Errore forzato sul processo 3..] - 
ERROR - Status code diverso da 0 su processo 3!
[INFO] - Processo 4  in esecuzione...
[SUCCES] - Processo 4: Successo!
[INFO] - Processo 5  in esecuzione...
[SUCCES] - Processo 5: Successo!
-------------------------------------
Totale  : 5
Successi: 4
Errori  : 1
-------------------------------------
[INFO] - Script terminato con 1 errore/i.
[INFO] - Per risolvere controlla il ciclo for per rimuovere l'errore forzato della simulazione.



```

---

## Versioni sviluppate

| Versione | Contenuto |
|---|---|
| v1 | Variabili + ciclo base |
| v2 | Simulazione processo con creazione file |
| v3 | Gestione errori e status code |
| v4 | Contatori + report finale |
| v5 | Errore forzato al processo 3 |
| v6 | Funzione `log_message`|
| v7 | Parte completa con funzioni finali  |

---

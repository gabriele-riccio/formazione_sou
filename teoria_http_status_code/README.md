# ESERCIZIO HTTP STATUS CODE 

Chi si occupa di siti web, gestione dei portali e degli hosting deve conoscere bene i codici di status HTTP, ovvero gli **HTTP Status Code**, dei codici che i server web restituiscono al browser in risposta a una richiesta.

In pratica, quando visiti una pagina internet ricevi un risultato che corrisponde a un codice di stato HTTP.
Essi sono dei codici che definiscono l'esito positivo o negativo della richiesta.

E' importante conoscere gli HTTP status code per capire se l'operazione è andata a buon fine o se ci sono degli errori.

---
## Protocollo HTTP:
Prima di parlare degli HTTP status code è importante conoscere cosa è il protocollo HTTP e come funziona.

Il protocollo HTTP (**HyperText Transfer Protocol**) è la base del trasferimento dati sul **World Wide Web**, utilizzato dai browser per richiedere e caricare pagine web da un server.
E' basato sul modello client-server, invia richieste HTTP e riceve risposte dai server web operando solitamente sulla porta TCP 80, mentre la versione sicura(e non più sicura come abbiamo detto ai colloqui  :joy: ) **HTTPS** utilizza la crittografia.

## Dettagli chiave del protocollo HTTP:
- **Funzionamento Client-Server** : Il client (es. il browser) invia una richiesta per una risorsa, e il server web risponde inviando
    il contenuto richiesto (HTML, immagini, video).
- **Stateless (Senza Stato)** : Come abbiamo detto questa mattina HTTP non mantiene traccia delle richieste precedenti; ogni
    transazione è indipendente, il che significa che il server non memorizza informazioni sulle chiamate passate.
    Per ottenere un comportamento **statefull** (con stato/memoria) pur mantenendo HTTP intrinsecamente **stateless** (senza stato),
    si utilizzano i **cookie tradizionali** oppure è necessario che sia il client (browser) a inviare esplicitamente un
    identificativo o i dati di sessione ad ogni richiesta(come con l'utilizzo dei **Json Web Tokens(JWT)** nell'Header Authorization).
     
- **Struttura della Comunicazione** :
    - **Richiesta (Request)** : Contiene un metodo (come GET, POST, PUT, DELETE) che specifica l'azione da compiere.
    - **Risposta (Response)** : Include un codice di stato (es. 200 OK, 404 Not Found) e la risorsa richiesta.
- **Differenza con HTTPS** : HTTP trasmette dati in chiaro, mentre HTTPS (HTTP Secure) utilizza il protocollo TLS/SSL per cifrare la
    comunicazione, lavorando solitamente sulla porta 443.
- **Versatilità** : HTTP non trasferisce solo testo ipertestuale (HTML), ma può inviare svariati tipi di file, rendendolo generico e
    standardizzato.


---

## Cosa sono gli Status Code HTTP?
I codici stato HTTP – noti anche come Status Code HTTP – sono una combinazione di valori numerici che vanno da **100 a 500** per indicare le varie condizioni di una risposta del web server.

Per semplificare, quando un client effettua una richiesta attraverso l’HyperText Transfer Protocol (**HTTP**) si ottiene una risposta che può essere positiva o negativa.

Per identificare queste condizioni, l’IETF (RFC 2616) – insieme ad alcune RFC con codici di stato extra – ha individuato una serie di combinazioni numeriche con relativa spiegazione per avere delle informazioni utili su come intervenire e come decifrare la combinazione.

Tutte le interazioni tra il browser e un sito web si basano sul principio di **richiesta-risposta**.

Ogni volta che si digita un indirizzo nel browser, si visita una pagina web, si scarica un file o si esegue qualsiasi azione online, il tuo browser (client) invia una richiesta HTTP al server del sito web.
Il server elabora la richiesta e restituisce una risposta HTTP.

La risposta contiene due parti: **corpo e intestazioni**.

**Il corpo** di solito è costituito da contenuti visualizzati dal browser: testo, immagini, video, etc(alcune risposte non generano contenuti, quindi il corpo potrebbe essere vuoto).

**Le intestazioni** contengono metadati sulle risposte: il codice di stato HTTP, il tipo di server ed altre informazioni importanti.

**I codici di stato HTTP** sono composti da 3 cifre. La prima cifra rappresenta la categoria della risposta, mentre le ultime due cifre definiscono la risposta specifica.


BROWSER(CLIENT) ---> { RICHIESTA HTTP [GET,PUT,POST]} ---> SERVER

BROWSER(CLIENT) <--- { RISPOSTA HTTP [Intestazioni e corpo]; STATUS CODE(200,300,400,500)  } <--- SERVER


---

## Perché conoscere la lista dei codici?
Bisogna conoscere bene i diversi HTTP Status Code perché in questo modo possono intervenire in modo sistematico e strutturato.

Ad esempio, di fronte a un **errore 404** si possono prendere determinate precauzioni o lasciare la pagina con questo Status Code se non ci sono implicazioni.


---


## La lista dei diversi HTTP Status Code
Per gestire questi codici di status sono state organizzate le diverse alternative con un sistema basato su alcuni numeri che si articolano **in 5 gruppi da 1XX a 5XX**.


Ecco gli status-code più importanti da conoscere:


---
## 1XX – Informativo (Informational)
I codici 1XX sono risposte informative dal server del sito web. 

Non generano contenuti e aggiornano solo i clienti sullo stato di avanzamento delle loro richieste.

Questa famiglia di codici di stato HTTP indica che la richiesta effettuata dal client (tipo il browser) è stata ricevuta dal web server e il processo per completare è in corso.

Vediamone alcuni:

- **100 Continue** : Il server, una volta ricevute la richiesta iniziale e le intestazioni dal client, dice al client che può
   continuare e procedere con l’invio del corpo della richiesta.
- **101 Switching Protocols** : Il client richiedente (browser) ha chiesto al server di modificare i protocolli e il server ha             soddisfatto la richiesta.
- **102 Processing (WebDAV)** : Questa è una risposta principalmente associata alle richieste che potrebbero richiedere più tempo per      essere completate. Indica che il server ha ricevuto la richiesta e la sta elaborando.
- **103 Early Hints** :  Il server restituisce alcune intestazioni di risposta prima che venga inviata la risposta HTTP finale.

---

## 2XX – Successo (Success)

I codici di status che rientrano nella categoria 2XX ci comunicano un messaggio molto importante:
La richiesta è stata stata riconosciuta dal server, è stata accettata ed è in fase di elaborazione.

- **200 OK** : E' la  risposta per una richiesta HTTP riuscita, il risultato dipenderà dal tipo di richiesta
- **201 Created** : la richiesta è stata completata ed il server ha creato una nuova risorsa.
- **202 Accepted** : Il server ha accettato la richiesta ma non ha ancora terminato l’elaborazione.
    La richiesta potrebbe essere soddisfatta o rifiutata, ma il risultato è ancora indeterminato.
- **203 Non-Authoritative Information** : Di solito appare quando viene utilizzato un servizio proxy.
    Il server proxy ha ricevuto un codice di stato **200 “OK”** dal server di origine e restituisce una versione modificata
    della risposta dell’origine.
- **204 No Content** : Il server ha soddisfatto la richiesta ma non c’è alcun contenuto da restituire.
- **205 Reset Conten** :  Il server ha soddisfatto la richiesta e non restituirà alcun contenuto ma chiederà al client (browser) di        reimpostare la vista del documento.
- **206 Partial Content** : Il server restituisce solo una parte delle risorse richieste perché il browser utilizza “intestazioni di       intervallo”.
    Queste intestazioni consentono ai browser di riprendere i download o dividere i download in più flussi simultanei.
- **207 Multi-Status** : Abbiamo lo stato di più operazioni: Il server restituisce un messaggio contenente un array di codici di           risposta per tutte le sotto richieste.
- **208 Already Reported** : Questo codice indica che gli elementi esistenti sono stati già enumerati in una parte precedente della        risposta e non verranno enumerati di nuovo.
- **226 IM Used** :  Il server ha soddisfatto la richiesta e la risposta è una rappresentazione di una o più manipolazioni di istanze.


---

## 3xx – Reindirizzamento (Redirection)

I codici 3XX specificano che ci sarà un reindirizzamento.
I reindirizzamenti sono comunemente usati quando una risorsa viene spostata a un nuovo indirizzo e i diversi codici 3XX istruiscono i browser (client) su come deve essere eseguito il reindirizzamento.

Se i primi gruppi di HTTP Status Code indicano un sostanziale funzionamento del processo, qui iniziano gli aspetti tecnici che meritano maggiore attenzione perché in questo caso il client deve affrontare più passaggi per risolvere dei problemi.

- **300 Multiple choices** : Il server presenta al client una scelta di più risorse tra cui scegliere.
    Il codice di stato viene applicato quando si utilizza il browser per scaricare i file e viene data la possibilità di scegliere
    l’estensione del file o quando vengono presentate le opzioni per la disambiguazione del senso delle parole.
- **301 Moved Permanently** : Questo è il codice per un reindirizzamento permanente.
    Significa che l’URL della risorsa richiesta viene sostituito in modo permanente con un nuovo indirizzo e i motori di ricerca
    dovrebbero aggiornare l’URL nei loro database.
- **302 Found** : Il server indica ai browser che la risorsa richiesta viene spostata temporaneamente a un nuovo URL, ma il nuovo
    indirizzo può essere modificato di nuovo in futuro.
    Pertanto, l’URL originale dovrebbe essere ancora utilizzato dal cliente.
- **303 See Other** : Il server indica al client di aver trovato la risorsa, ma deve essere recuperata su un altro URL
    con una richiesta GET.
- **304 Not Modified** : Il server informa il browser che la risorsa non è stata modificata dall’ultima volta che l’ha richiesta.
    Il browser può continuare a utilizzare la versione memorizzata nella cache che già memorizza localmente.
- **305 Use Proxy (Deprecato)**: La risorsa richiesta è disponibile solo tramite un proxy.
    Questo codice è ora deprecato e i browser lo ignorano.
- **306 Switch Proxy** : Questo codice non è più in uso.
    Significa che le seguenti richieste dovrebbero utilizzare il proxy specificato.
- **307 Temporary Redirect** : Questo è il nuovo codice per i reindirizzamenti temporanei che ha sostituito il codice HTTP **302**,        e specifica che la risorsa richiesta è stata spostata su un altro URL.
    A differenza del codice HTTP **302**, il codice HTTP **307** non consente la modifica del metodo di richiesta HTTP.
    Ad esempio, se la prima richiesta era GET, anche la seconda richiesta dovrebbe essere GET.
- **308 Permanent Redirect** : La risorsa richiesta viene spostata in modo permanente a un altro URL e tutte le richieste future
    devono essere reindirizzate al nuovo indirizzo.
    Il codice è simile al codice HTTP **302**, l’unica differenza è che non consente ai browser di modificare il tipo
    di richiesta HTTP.

---

## 4xx – Errore del client (Client Error)

I codici 4XX sono codici di stato di errore HTTP.
Definiscono gli errori come richieste non valide dal browser che il server del sito web non può elaborare.
Il problema potrebbe essere un errore di sintassi nella richiesta, URL inesistente, credenziali errate, etc.

- **400 Bad Request** : Il server non può restituire una risposta valida a causa di un errore da parte del client.
    Le cause più comuni sono URL richiesti non corretti, routing delle richieste ingannevole, file di grandi dimensioni, etc.
- **401 Unauthorized** : Questo errore viene visualizzato quando il client non è riuscito a fornire una risposta valida e la risposta
    dal server include un’intestazione WWW-Authenticate.
    È probabile che si veda questo errore quando si tenta di accedere a una URL protetta da password e non si
    hanno le informazioni di accesso.
- **402 Payment Required** : Questo non è un codice standard, tuttavia è riservato per essere utilizzato in futuro
    dai sistemi di pagamento.
    Lo scopo del codice è quello di indicare che il contenuto non è disponibile a causa di un pagamento non riuscito.
- **403 Forbidden** : L’errore indica che il server nega l’accesso ad un utente che non dispone dell’autorizzazione
    per accedere alle risorse. Le cause tipiche di questo errore sono le regole restrittive del server del sito web, i permessi
    insufficienti dei file  delle cartelle del sito web,etc.

---

## Differenza tra 401 e 403:
La differenza principale tra **401 e 403** risiede nell'autenticazione: 401 Unauthorized significa che **il server non sa chi sei** (richiede login/credenziali valide), mentre 403 Forbidden **significa che il server ti ha riconosciuto, ma non hai i permessi necessari per accedere alla risorsa**. 

In breve: 401 = **non autenticato**, 403 = **autenticato ma non autorizzato**.

---

- **404 Not Found** : Questo è l’errore più frequente che gli utenti vedono online, significa che il server non riesce a trovare la
    risorsa richiesta.
    Di solito, la causa è che l’URL a cui si sta tentando di accedere non esiste.
- **405 Method Not Allowed** : Il server comprende il metodo richiesto, ma la risorsa di destinazione non lo supporta.
- **406 Not Acceptable** : La risorsa richiesta ha generato contenuti che non soddisfano i criteri dello user-agent che lo ha
    richiesto.
- **407 Proxy Authentication Required** : Esiste un server proxy,utilizzato nella comunicazione tra il browser e il server,
    che richiede l’autenticazione.
- **408 Request Timeout** : Il server ha impiegato troppo tempo per ricevere la richiesta.
    In alcuni casi, i server possono inviare questo messaggio su una connessione inattiva anche senza alcuna richiesta
    precedente da client.
- **409 Conflict** : Questo errore si verifica quando una richiesta non può essere elaborata a causa di un conflitto nello stato
    corrente della risorsa sul server. Un esempio di questo errore è quando più modifiche dello stesso file vengono inviate
    al server e le modifiche sono in conflitto tra loro.
- **410 Gone** : La risorsa richiesta non è disponibile e non sarà disponibile in futuro.
    Non viene sostituito con una nuova risorsa su un nuovo indirizzo, quindi i client devono rimuovere eventuali collegamenti e cache
    relativi alla risorsa.
    Ad esempio, i motori di ricerca dovrebbero rimuovere le informazioni della risorsa dai loro database.
- **411 Length Required** : La lunghezza del contenuto della richiesta non è specificata e la risorsa sul server lo richiede.
- **412 Precondition Failed** : Le intestazioni della richiesta specificano alcune precondizioni che il server non riesce a soddisfare.
- **413 Payload Too Large** : La richiesta è più grande dei limiti specificati sul server,
    quindi il server non può elaborarla.
- **414 URI Too Long** : La lunghezza dell’URI è troppo lunga e il server non può elaborarla.
    Di solito, questo è il risultato di una richiesta GET contenente troppi dati e quindi deve essere modificata in una richiesta POST.
- **415 Unsupported Media Type** : La richiesta contiene un tipo di supporto che il server non supporta.
    Ad esempio, provi a caricare un file immagine in formato .jpg, ma il server non lo supporta.
- **416 Range Not Satisfiable** : La richiesta richiedeva una parte della risorsa che il server non può fornire (non accessibile).
    Questo errore può verificarsi quando il tuo browser richiede una parte di un file che è al di fuori della fine del file.
- **417 Expectation Failed** : Il server non soddisfa i requisiti impostati nel campo di intestazione 'expect' della richiesta.
- **418 I’m a teapot** : Questo errore viene restituito dalle teiere richieste per preparare il caffè.
    È un pesce d’aprile che risale al 1998.
- **421 Misdirected Request** : La richiesta è stata inviata a un server che non è in grado di dare una risposta.
- **422 Unprocessable Entity** : Il server comprende la richiesta ben formulata dal client,
    ma non è in grado di elaborarla perchè il client ha commesso errori semantici.
- **423 Locked (WebDAV)** : La risorsa richiesta è bloccata.
- **424 Failed Dependency** : La richiesta fallisce a causa di una dipendenza non riuscita.
- **429 Too many requests** : Il server risponde con questo codice quando l’utente ha inviato troppe richieste nel tempo
    indicato e ha superato il limite di velocità.

---

## 5xx – Errore del Server

Entriamo nel vivo di una delle attività di lavoro dei DevOps.
In alcuni casi, gli errori di Status Code HTTP possono essere evitati e gestiti dal DevOps mentre in altri casi, invece, la colpa è del server.
Una buona parte di questi problemi possono essere bypassati scegliendo un hosting di qualità con supporto sempre presente.

- **500 Internal Server Error** : È un errore generico che indica che il server ha riscontrato una condizione imprevista e non può
    soddisfare la richiesta.
    Il server ti dice che c’è qualcosa che non va, ma non è sicuro di quale sia il problema.
- **501 Not Implemented** : Il server non supporta il metodo di richiesta o non ha la capacità di soddisfare la richiesta.
- **502 Bad Gateway** : Questo errore indica che il server ha agito come gateway o proxy e ha ricevuto una risposta non
    valida dal server upstream.
    Questa è la descrizione ufficiale, ma ci sono vari fattori che possono stressare questo errore.
- **503 Service Unavailable** : Il server non può gestire la richiesta.
    Di solito si tratta di una condizione temporanea causata da un sovraccarico o da una manutenzione continuativa sul server.
- **504 Gateway Timeout** : Il server ha agito come gateway e non ha ricevuto una risposta tempestiva dal server upstream.
    Nella maggior parte dei casi, questo errore è causato dallo script PHP (**Backend**) che non termina in tempo e supera il limite
    di timeout variabile PHP (max_execution_time del server), quindi il server termina la connessione.
- **505 HTTP Version Not Supported** : Il server non supporta la versione HTTP utilizzata nella richiesta.
- **506 Variant Also Negotiates** : Questo errore si verifica quando il client e il server entrano in **Transparent Content
    Negotiation**, che consente al client di recuperare la migliore variante di una risorsa quando il server supporta.
    Tuttavia, c’è un errore di configurazione e la risorsa richiede anche la raccolta del contenuto, che causa un loop chiuso.
- **507 Insufficient Storage** : Il server non è in grado di memorizzare la rappresentazione necessaria per completare la richiesta.
- **508 Loop Detected** : Il server ha rilevato un loop infinito durante l’elaborazione della richiesta.
- **510 Not Extended** :  Sono necessarie ulteriori estensioni alla richiesta affinché il server la soddisfi.
    Questo codice è ora deprecato.
- **511 Network Authentication Required** : Questa risposta viene inviata quando è necessario autenticarsi in modo che la
    rete possa inviare la richiesta a un server.
    Più comunemente, si verifica quando si tenta di utilizzare una rete Wi-Fi e devi accettare i suoi Termini di accordo.
---





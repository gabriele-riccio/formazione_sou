# Esercizio Capra e Cavoli: Teoria e parte architetturale.

**Obiettivo:** Trasformare il famoso indovinello denominato Capra e Cavoli in ambiente informatico, dove gli attori della storia
diventano servizi(container) e le rive sono VM e il fiume una barriera.


---

## Indovinello originale

![prima_parte_foto](capra_cavoli/Screenshot%202026-05-21%10alle%2010.09.49.png)

Questo celebre indovinello di logica richiede il trasporto di tre elementi oltre un fiume.
La barca può ospitare solo il traghettatore più un elemento alla volta.
L'obiettivo è spostare tutto senza che il lupo mangi la pecora o che la pecora mangi il cavolo.

**Soluzione**
- **1 Porta la pecora** : Il traghettatore raghetta la pecora sull'altra sponda e torna indietro da solo.
- **2 Porta il cavolo** : Il traghettatore carica il cavolo e lo porta dall'altra parte. Una volta lì, lascia il cavolo
      ma prende la pecora e la  riporta indietro con se.
- **3 Porta il lupo** : Il traghettatore lascia la pecora, carica il lupo e lo porta sull'altra sponda.
      Ora il lupo e il cavolo sono al sicuro insieme (il lupo non mangia il cavolo).
- **4 Torna indietro da solo** :Ora il traghettatore torna indietro da solo(dato che sulla seconda sponda lupo e cavolo sono al
      sicuro).
- **5 Porta la pecora (di nuovo)** : Infine, porta la pecora sull'altra sponda.
      Tutti e tre sono ora sull'altra sponda, sani e salvi.

![seconda_parte_foto](capra_cavoli/Screenshot%202026-05-21%10alle%2010.13.29.png)

### Come si traduce tutto ciò?

IPv4 (Internet Protocol version 4) è il protocollo di rete che assegna un indirizzo univoco a ogni dispositivo connesso a una rete. È definito nell'RFC 791 (1981) ed è tuttora il protocollo più diffuso, affiancato sempre più da IPv6.

Un indirizzo IPv4 è lungo **32 bit**, suddivisi in 4 gruppi da 8 bit ciascuno chiamati **ottetti**. Viene rappresentato in *decimal dotted notation*: ogni ottetto è convertito in decimale e separato da un punto.

```
Binario:   11000000 . 10101000 . 00000001 . 00000001
Decimale:    192    .   168    .     1    .     1
```

### Struttura

Un indirizzo IPv4 è composto da **4 ottetti** separati da un punto:

```
A . B . C . D
```

Ogni ottetto è un numero intero compreso tra **0 e 255** inclusi (8 bit → 2^8 = 256 valori possibili, da 0 a 255).

Lo spazio di indirizzamento totale è **2^32 = ~4,3 miliardi** di indirizzi.

### Classi di indirizzi

Storicamente gli indirizzi IPv4 erano divisi in classi in base al primo ottetto:

| Classe | Range primo ottetto | Uso tipico |
|--------|--------------------|-----------:|
| A | 1 – 126 | Reti molto grandi |
| B | 128 – 191 | Reti medie |
| C | 192 – 223 | Reti piccole |
| D | 224 – 239 | Multicast |
| E | 240 – 255 | Riservato/sperimentale |

> Oggi il classful addressing è stato sostituito dal **CIDR** (Classless Inter-Domain Routing), che usa la notazione `192.168.1.0/24` dove `/24` indica quanti bit sono riservati alla parte di rete.

### Indirizzi speciali e riservati

| Indirizzo/Range | Significato |
|-----------------|-------------|
| `0.0.0.0` | Indirizzo non specificato (host corrente) |
| `127.0.0.1` | Loopback (localhost) |
| `10.0.0.0/8` | Rete privata (classe A) |
| `172.16.0.0/12` | Rete privata (classe B) |
| `192.168.0.0/16` | Rete privata (classe C) |
| `255.255.255.255` | Broadcast (tutti gli host della rete) |
| `169.254.0.0/16` | Link-local / APIPA (assegnato automaticamente senza DHCP) |

### IPv4 vs IPv6

| | IPv4 | IPv6 |
|--|------|------|
| Lunghezza | 32 bit | 128 bit |
| Notazione | `192.168.1.1` | `2001:db8::1` |
| Indirizzi totali | ~4,3 miliardi | ~340 undecilioni |
| Stato | Esaurito (dal 2011) | In adozione progressiva |

---

## Cos'è un indirizzo IPv4 (in decimal dotted notation)

Un indirizzo IPv4 è composto da **4 ottetti** separati da un punto:

```
A . B . C . D
```

Ogni ottetto è un numero intero compreso tra **0 e 255** inclusi.

Esempi validi:
```
0.0.0.0
10.0.0.1
192.168.1.1
255.255.255.255
```

Esempi **non** validi:
```
256.1.1.1       → 256 > 255
999.999.999.999 → fuori range
192.168.1       → solo 3 ottetti
192.168.1.1.5   → 5 ottetti
192.168.01.1    → zero padding (discutibile, ma spesso escluso)
```

---

## Ragionamento costruttivo della regex

Il problema centrale è che la regex non conosce il concetto di "numero minore di 256". Bisogna quindi **scomporre il range 0–255 in casi distinti** e metterli in OR.

### Step 1 — Analisi del range per un singolo ottetto

| Range | Cifre | Pattern regex |
|-------|-------|---------------|
| 0–9 | 1 cifra | `[0-9]` |
| 10–99 | 2 cifre | `[1-9][0-9]` |
| 100–199 | 3 cifre, inizia con 1 | `1[0-9]{2}` |
| 200–249 | 3 cifre, inizia con 2, seconda 0–4 | `2[0-4][0-9]` |
| 250–255 | 3 cifre, inizia con 25, terza 0–5 | `25[0-5]` |

> I casi vanno messi in ordine dal più restrittivo al meno restrittivo, altrimenti il motore regex potrebbe fermarsi al primo match parziale.

### Step 2 — Regex per un singolo ottetto

Unendo i casi con l'operatore OR (`|`):

```
(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])
```

### Step 3 — Ripetere per 4 ottetti separati da punto

Il punto in regex matcha **qualsiasi carattere**, quindi va escapato come `\.`.

I primi 3 ottetti sono seguiti da un punto, l'ultimo no. Si può compattare con un quantificatore `{3}`:

```
((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\.){3}
```

Seguito dall'ultimo ottetto senza punto:

```
(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])
```

### Step 4 — Ancore di riga

Senza `^` e `$` la regex matcha anche sottostringhe, ad esempio:
- `999.256.1.1` verrebbe matchato parzialmente su `9.256` → `9.2` → falso positivo

Le ancore fissano il match all'intera riga:
- `^` → inizio riga
- `$` → fine riga

---

## Regex finale

```
^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])$
```

---

## Comando `egrep`

```bash
egrep '^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])$' file.txt
```

---

## Svolgimento

**Mi genero la cartella dell'esercizio**:
```bash
mkdir esercizio_ip_regex
cd esercizio_ip_regex
```

**Mi genero un file di testo con vim**:
```bash
vim file_ip.text
```
**Input(file_ip.txt)**
```
192.168.1.1
255.255.255.255
0.0.0.0
256.1.1.1
192.168.1
999.999.999.999
10.0.0.1
192.168.1.1.5
hello
172.16.254.1
```
**Lo rendo eseguibile e svolgo la regex sul file di testo**:

```bash
chmod +x file_ip.text
egrep '^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])$' file_ip.txt

```

## Output

![prima parte terminale](files_ip/Screenshot%202026-05-20%20alle%2015.26.51.png)

---

## Spiegazione dei casi esclusi

| Riga | Motivo dell'esclusione |
|------|------------------------|
| `256.1.1.1` | Il primo ottetto (256) supera 255 |
| `192.168.1` | Solo 3 ottetti, manca il quarto |
| `999.999.999.999` | Tutti gli ottetti fuori range |
| `192.168.1.1.5` | 5 ottetti, l'ancora `$` non trova fine riga dopo il quarto |
| `hello` | Nessun numero, nessun punto |

---

## Test rapido da terminale

```bash
printf "192.168.1.1\n255.255.255.255\n0.0.0.0\n256.1.1.1\n192.168.1\n999.999.999.999\n10.0.0.1\n" \
  | egrep '^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])$'
```
![seconda parte terminale](files_ip/Screenshot%202026-05-20%20alle%2015.27.36.png)

- `256.1.1.1` viene scartato perchè 256>255.
- `192.168.1` viene scartato perchè ha solo 3 ottetti.
- `999.999.999.999` viene scartato perchè è fuori range.

---

## Riepilogo costrutti usati

| Costrutto | Significato |
|-----------|-------------|
| `[0-9]` | Qualsiasi cifra decimale |
| `{2}`, `{3}` | Esattamente n ripetizioni |
| `\|` | OR logico (alternanza) |
| `\.` | Punto letterale (escapato) |
| `( ){3}` | Gruppo ripetuto 3 volte |
| `^` | Ancora inizio riga |
| `$` | Ancora fine riga |

# Esercizi `egrep` — Extended Regular Expressions

> `egrep` è equivalente a `grep -E` e supporta le Extended Regular Expressions (ERE) senza bisogno di escape per i quantificatori (`+`, `?`, `{n,m}`, `|`, ecc.).
---

## Traccia:

- Utilizzare il comando **egrep** per risolvere i seguenti esercizi (dando esempi di possibili input):
  - Matchare sequenze alfabetiche di almeno un carattere, sia maiuscole che minuscole
  - Togliere tutte le righe di commento di uno script Bash matchando le righe che iniziano con '#'
  - Matchare in un file le righe che contengono sequenze di 'a' ripetute da 3 a 6 volte
  - Matchare in un file tutte le righe che contengono una delle seguenti parole: apple, pear, orange

---
## Prima di fare gli esercizi:

**1. Clono il repository**

```bash
git clone https://github.com/gabriele-riccio/formazione_sou.git
cd formazione_sou
```
**2. Creo la cartella esercizio_egrep**

```bash
mkdir esercizio_egrep
cd esercizio_egrep
```
**3. Creo i 4 script(input) per gli esercizi** :

```bash
vim file_egrep_1.sh
vim file_egrep_2.sh
vim file_egrep_3.sh
vim file_egrep_4.sh
```
**4. Rendo eseguibili gli script** :

```bash
chmod +x file_egrep_1.sh file_egrep_2.sh file_egrep_3.sh file_egrep_4.sh
```
---

## Esercizio 1 — Sequenze alfabetiche (maiuscole e minuscole)

**Obiettivo:** matchare righe che contengono almeno un carattere alfabetico.

```bash
egrep '[a-zA-Z]+' file.txt
```

**Input di esempio (`file_egrep_1.sh`):**
```bash
hello World
12345
foo 99 BAR
!!!
ciao123Mondo
```

**Output:**
![prima parte terminale](files_egrep/Screenshot%202026-05-20%20alle%2011.06.52.png)
**Spiegazione:**
- `[a-zA-Z]` — classe di caratteri: lettere minuscole (`a-z`) o maiuscole (`A-Z`)
- `+` — quantificatore: uno o più caratteri consecutivi della classe
- Le righe `12345` e `!!!` non contengono lettere, quindi vengono escluse

---

## Esercizio 2 — Rimuovere le righe di commento Bash

**Obiettivo:** stampare solo le righe che **non** iniziano con `#`.

```bash
egrep -v '^#' script.sh
```

**Input di esempio (`script.sh`):**
```bash
# Questo è un commento
echo "Hello"
# Altro commento
ls -la
  # commento indentato (NON rimosso)
```

**Output:**
```bash
echo "Hello"
ls -la
  # commento indentato (NON rimosso)
```

**Spiegazione:**
- `^` — ancora di inizio riga
- `#` — il carattere cancelletto
- `-v` — inverte il match: stampa le righe che **non** corrispondono al pattern

> **Nota:** i commenti preceduti da spazi (es. `  # nota`) non vengono rimossi perché `^` richiede che `#` sia il primo carattere della riga. Per rimuovere anche quelli, usare `egrep -v '^\s*#'`.

---

## Esercizio 3 — Sequenze di 'a' ripetute da 3 a 6 volte

**Obiettivo:** matchare righe che contengono tra 3 e 6 occorrenze consecutive della lettera `a`.

```bash
egrep 'a{3,6}' file.txt
```

**Input di esempio (`file.txt`):**
```
a
aa
aaa
aaaaa
aaaaaaa
baaat
baaaaab
```

**Output:**
```
aaa
aaaaa
aaaaaaa
baaat
baaaaab
```

**Spiegazione:**
- `a{3,6}` — quantificatore di intervallo: da 3 a 6 occorrenze consecutive di `a`
- La riga `aaaaaaa` (7 'a') viene inclusa perché contiene al suo interno una sottosequenza valida

> **Nota:** per matchare esattamente sequenze isolate di 3–6 'a' (senza che facciano parte di sequenze più lunghe), aggiungere word boundary:
> ```bash
> egrep '\ba{3,6}\b' file.txt
> ```

---

## Esercizio 4 — Righe contenenti apple, pear o orange

**Obiettivo:** trovare le righe che contengono almeno una delle parole specificate.

```bash
egrep 'apple|pear|orange' file.txt
```

**Input di esempio (`file.txt`):**
```
I like apple juice
banana smoothie
one pear and one orange
PEAR in uppercase
grapefruit
```

**Output:**
```
I like apple juice
one pear and one orange
```

**Spiegazione:**
- `|` — operatore di alternanza (OR logico): matcha `apple` oppure `pear` oppure `orange`
- Il match è **case-sensitive**: `PEAR` non viene incluso
- `grapefruit` non contiene nessuna delle parole cercate (nonostante contenga `pear` come sottostringa... attenzione: in realtà `grapefruit` non contiene `pear`, ma `grape` sì contiene `ape`)

> **Varianti utili:**
> ```bash
> # Case-insensitive (include anche APPLE, Pear, ORANGE, ecc.)
> egrep -i 'apple|pear|orange' file.txt
>
> # Solo parole intere (evita match parziali come "pineapple")
> egrep '\b(apple|pear|orange)\b' file.txt
> ```

---

## Riepilogo delle sintassi usate

| Costrutto | Significato | Esempio |
|-----------|-------------|---------|
| `[a-zA-Z]` | Classe di caratteri (range) | qualsiasi lettera |
| `+` | Uno o più (quantificatore) | `[a-z]+` |
| `^` | Inizio riga (ancora) | `^#` |
| `-v` | Inverti il match (flag) | `egrep -v ...` |
| `{n,m}` | Da n a m ripetizioni | `a{3,6}` |
| `\b` | Word boundary | `\bpear\b` |
| `|` | OR logico (alternanza) | `cat|dog` |
| `-i` | Case-insensitive (flag) | `egrep -i ...` |

---

> `egrep` è disponibile su sistemi Unix/Linux/macOS. Su alcune distribuzioni è un alias di `grep -E`.

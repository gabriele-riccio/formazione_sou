# Esercizi `egrep` — Extended Regular Expressions

> `egrep` è equivalente a `grep -E` e supporta le Extended Regular Expressions (ERE) senza bisogno di escape per i quantificatori (`+`, `?`, `{n,m}`, `|`, ecc.).

---
## Prima di fare gli esercizi:

---

## Esercizio 1 — Sequenze alfabetiche (maiuscole e minuscole)

**Obiettivo:** matchare righe che contengono almeno un carattere alfabetico.

```bash
egrep '[a-zA-Z]+' file.txt
```

**Input di esempio (`file.txt`):**
```
hello World
12345
foo 99 BAR
!!!
ciao123Mondo
```

**Output:**
```
hello World
foo 99 BAR
ciao123Mondo
```

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

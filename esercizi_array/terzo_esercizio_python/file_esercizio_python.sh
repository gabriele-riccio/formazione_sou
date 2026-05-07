#!/usr/bin/env python3


#Mi sono aiutato con l'intelligenza artificiale per fare lo stesso esercizio con python per capire in termini di tempo e spazio quale tipo di lavoro convenisse di più.
#la versione compatta scorre la mia lista originale (INPUT) e trasforma ogni singola parola in lettere maiuscole, poi set invece converte i dati mettendoli insieme, con la
# caratteristica che non ammette elementi doppi(non serve uniq),sorted invece prende quello che abbiamo fatto e lo ordina in ordine alfabetico.
#Poi la versione più lunga In pratica, crea una nuova lista vuota, scorre INPUT, trasforma ogni parola in minuscolo e la inserisce nella nuova lista chiamata lowered, poi creo una lista nuova dove con set elimino i doppioni, e con sorted alla fine 


INPUT = [
    "juvenTUS",
    "MILAN",
    "napoli",
    "genoA",
    "milAN",
    "inter",
    "ROMA",
    "LAZIO",
    "bologna",
    "inter",
    "atalanta",
    "Como",
    "Genoa",
]

print("== Input originale ==")
for i in INPUT:
    print(i)

#posso fare 2 versioni

# ── Versione compatta (una riga)
result_oneliner = sorted(set(s.lower() for s in INPUT))
#uso direttamente il ciclo for dichiar
# ── Versione esplicita (più didattica)
# Fase 1: lowercase
lowered = [s.lower() for s in INPUT]
print("\n--- Dopo lowercase ---")
print(lowered)

# Fase 2: deduplicazione con set()
# set() in Python è una tabella hash: inserimento e ricerca in O(1) medio.
# Elementi duplicati vengono silenziosamente ignorati.
unique = set(lowered)
print("\n--- Dopo set() (ordine non garantito) ---")
print(unique)

# Fase 3: ordinamento con sorted()
# sorted() usa Timsort: O(k log k) garantito, ottimizzato per dati reali.
result = sorted(unique)

print("\n=== Output finale (lowercase + dedup + sort) ===")
for s in result:
    print(s)

# Verifica che le due versioni coincidano
assert result == result_oneliner, "Le due versioni non coincidono!"
print("\n✓ Versione compatta e versione esplicita producono lo stesso risultato.")


# Esercizio Capra e Cavoli: Teoria e parte architetturale.

**Obiettivo:** Trasformare il famoso indovinello denominato Capra e Cavoli in ambiente informatico, dove gli attori della storia
diventano servizi(container) e le rive sono VM e il fiume una barriera.


---

## Indovinello originale

![prima_parte_foto](capra_cavoli/Screenshot%202026-05-21%20alle%2010.09.49.png)

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

![seconda_parte_foto](capra_cavoli/Screenshot%202026-05-21%20alle%2010.13.29.png)

### Come si traduce tutto ciò?

Il classico indovinello del lupo, della capra e del cavolo può essere reinterpretato come **un problema di migrazione di processi tra virtual machine attraverso un network bridge**.

## Tabella Rappresentativa

Ogni `attore` dell'indovinello ha un corrispettivo preciso nell'infrastruttura.

| Elemento storia | Ruolo | Tipo | Cosa rappresenta | Cosa fa |
|----------|---------------|------|------------------|---------|
| **Lupo** | `lupo` `PID-001` | Processo | Un processo aggressivo che termina altri processi se non supervisionato | Invia `SIGKILL` a `capra` se lasciato solo con lei |
| **Capra** | `capra` `PID-002` | Processo | Il processo più vincolato: incompatibile con entrambi gli altri | Invia `SIGTERM` a `cavolo`; viene terminata da `lupo` |
| **Cavolo** | `cavolo` `PID-003` | Processo | Un processo passivo senza dipendenze conflittuali | Viene terminato da `capra`; convive con `lupo` senza problemi |
| **Riva di partenza** | `vm1` (nodo di partenza) | Virtual Machine 1 | Il nodo sorgente — contiene tutti i processi prima della migrazione | Ospita i processi in esecuzione e li cede uno alla volta al container (li riceve all'occorrenza) e verifica se ci sono errori |
| **Riva di arrivo** | `vm2` (nodo di arrivo) | Virtual Machine 2 | Il nodo destinazione — riceve i processi migrati | Accoglie i processi scaricati/caricati ogni volta dal container e verifica se ci sono errori |
| **Fiume** | Network bridge `TCP/river` | Infrastruttura | Il canale di rete che separa le due VM (non ha stato proprio) | Trasporta il container(barca) tra i due nodi; non applica regole di conflitto(è un canale di sicurezza, dato che è presente l'admin) |
| **Barca** | Ferry container | Container Docker | Mezzo che trasferire processi tra le VM con capienza massima 1(oltre il traghettatore) | Esegue `load → cross → unload`(poi vediamo bene cosa sono)e porta sempre con sé l'admin (supervisore) |
| **Traghettatore** | Orchestratore / admin | Supervisore | L'unico attore che può prevenire i conflitti, difatti la sua presenza su una VM rende sicura qualsiasi coppia | Decide la sequenza delle mosse ed è sempre presente sulla VM dove si trova il container |

---

## Il problema

L'orchestratore deve migrare tutti e tre i processi tra le 2 VM `vm1` a `vm2` attraverso il network bridge.
Il ferry container può trasportare **al massimo un processo per volta**(considerando sempre l'admin al suo interno).

### Vincoli di runtime

Se il ferry(container) lascia sola una coppia incompatibile su una VM senza supervisione, il sistema emette un segnale di terminazione(ERROR: con kill e SIGTERM) mentre`lupo` e `cavolo` non hanno conflitti diretti e possono coesistere liberamente.

---
## Architettura 

```
┌────────────────────────────────────────────────────────────────────┐
│                      ORCHESTRATORE/ADMIN                           │
│            (supervisore presente dove si trova il ferry)           │
└────────────────────────┬───────────────────────────────────────────┘
                         │ gestisce
           ┌─────────────┼─────────────┐
           ▼             ▼             ▼
     ┌──────────┐  ┌──────────────────┐  ┌──────────┐
     │   vm1    │  │  ferry container │  │   vm2    │
     │ (Nodo di │  │    capienza: 1   │  │ (Nodo di │            
     │ partenza)│  │                  │  │  arrivo) │    
     └──────────┘  └──────────────────┘  └──────────┘
           │                             │
           └──────── network bridge ─────┘
                      (TCP/river)
```
## Principio generale

- `capra` è il processo con **doppio conflitto**: è incompatibile sia con `lupo` che con `cavolo`.

La strategia che vorrei usare è:

1. Spostare la capra per prima, in modo da lasciare i due processi che non sono in conflitto da soli.
2. Usarla come **zavorra** ogni volta che si porta uno degli altri due, per non lasciarla mai sola con un'altro processo.

## Algoritmo
Vorrei creare uno script chiamato ad esempio file_capra_cavoli.sh dove eseguire degli step di migrazione tra `capra`,`cavoli` e `lupo`:

- **Inizio**:
```
    vm1: [`lupo`, `capra`, `cavolo`]
    vm2: [vuota]
```

- **Step 1**: — `capra` → vm2
```
    vm1 : [`lupo`,`cavolo`]   # lupo e cavolo non creano conflitto
    vm2 : [`capra`]
```

- **Step 2** — Container vuoto → vm1   #va sulla riva di inizio
```
    vm1 : [`lupo`,`cavolo`]   #l'admin torna in vm1
    vm2 : [`capra`]

```

- **Step 3** — `cavolo` → vm2  #viene portato sulla riva di arrivo
```
    vm1 : [`lupo`]             # processo isolato, ok
    vm2 : [`cavolo`, `capra`]    #E' presente l'admin, nessun conflitto attivo
```

- **Step 4**  — capra → vm1  #La capra viene riportata sulla vm1 lasciando il cavolo da solo dall'altra parte
```
    vm1 : [ `capra`, `lupo`]  #admin presente
    vm2 : [`cavolo`]              #processo isolato, ok
```
> Se lasciassi capra con cavolo su vm2 e tornassimo indietro, scatterebbe il `SIGTERM`.
> La soluzione è riportarla su vm1.

- **Step 5** —  → `lupo` → vm2
```
    vm1 : [`capra`]             #processo isolato, ok
    vm2 : [`lupo`, `cavolo`]  #nessun conflitto
```

- **Step 6** — container vuoto → vm1
```
    vm1 : [`capra`]             #admin sta tornando nella vm1
    vm2 : [`lupo`, `cavolo`]  #nessun conflitto
```

- **Step 7** —  capra → vm2
```
    vm1: []
    vm2: [`lupo`, `cavolo`,`capra`]  # migrazione completata
```

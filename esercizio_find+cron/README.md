# Find + Cron – Pulizia automatica file vecchi

## Descrizione

Questo progetto contiene uno script Bash che utilizza il comando `find` per individuare e cancellare automaticamente i file più vecchi di **30 giorni** nella directory `/var/log`.  
Lo script viene eseguito in modo automatico tramite **crontab di root** ogni **lunedì mattina alle 06:30**.

---

## File

| File | Descrizione |
|------|-------------|
| `cleanup_old_files.sh` | Script Bash principale |
| `README.md` | Documentazione del progetto |

---

## Come funziona

### Il comando `find`

```bash
find /var/log -type f -mtime +30 -print -delete
```

| Opzione | Significato |
|---------|-------------|
| `/var/log` | Directory in cui cercare |
| `-type f` | Cerca solo file (non cartelle) |
| `-mtime +30` | File modificati più di 30 giorni fa |
| `-print` | Stampa i file trovati (utile per il log) |
| `-delete` | Cancella i file trovati |

---

## Installazione e configurazione

### 1. Clono il repository

```bash
git clone https://github.com/gabriele-riccio/formazione_sou.git
cd formazione_sou
```

### 2. Rendo lo script eseguibile

```bash
chmod +x cleanup_old_files.sh
```

### 4. Configuro il crontab di root

Apro il crontab di root:

```bash
sudo crontab -e
```


**Output**
![prima parte terminale](files/Screenshot%202026-05-19%20alle%2017.33.06.png)

Aggiungo questa riga:

![seconda parte terminale](files/Screenshot%202026-05-19%20alle%2017.32.52.png)

#### Spiegazione della sintassi cron

```
30  6  *  *  1
│   │  │  │  └── Giorno della settimana (1 = Lunedì)
│   │  │  └───── Mese (ogni mese)
│   │  └──────── Giorno del mese (ogni giorno)
│   └─────────── Ora (06)
└─────────────── Minuti (30)
```

> Lo script verrà eseguito **ogni lunedì alle 06:30**.

---
## Verifica
Per verificare che sta funzionando:

```bash
sudo bash cleanup_old_files.sh
```

In modo da poter controllare che lo script funzioni.

N.B Non sarà eseguibile e mi darà permission denied se non uso 'sudo':

![terza parte terminale](files/Screenshot%202026-05-19%20alle%2017.34.57.png)

---

## Log

Lo script registra le proprie operazioni in:

```
/var/log/cleanup_script.log
```

**Output nel log** :

![quarta parte terminale](files/Screenshot%202026-05-19%20alle%2017.35.21.png)

---

## Prerequisiti

- Sistema operativo Linux
- Accesso root (o sudo)
- Bash 4+

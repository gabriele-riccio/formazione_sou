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

### 1. Clona il repository

```bash
git clone https://github.com/gabriele-riccio/formazione_sou.git
cd formazione_sou
```

### 2. Rendi lo script eseguibile

```bash
chmod +x cleanup_old_files.sh
```

### 4. Configura il crontab di root

Apri il crontab di root:

```bash
sudo crontab -e
```

Aggiungi questa riga:

```
30 6 * * 1 /usr/local/bin/cleanup_old_files.sh
```

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

## Log

Lo script registra le proprie operazioni in:

```
/var/log/cleanup_script.log
```

Esempio di output nel log:

```
========================================
Esecuzione: 2025-05-19 06:30:01
Directory target: /var/log
Eliminazione file più vecchi di 30 giorni...
/var/log/syslog.old
/var/log/auth.log.2
Operazione completata.
========================================
```

---

## Prerequisiti

- Sistema operativo Linux
- Accesso root (o sudo)
- Bash 4+

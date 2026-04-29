#Port Scanner in Bash con Vagrant

Questo progetto implementa un **Port Scanner** personalizzato scritto in Bash. L'esercizio simula un ambiente di rete reale composto da due macchine virtuali (VM) che comunicano tra loro, utilizzando **Vagrant** come orchestratore di virtualizzazione.

## 🎯 Obiettivo dell'Esercizio
L'obiettivo è analizzare una macchina target per identificare quali porte TCP siano in stato di ascolto (*listening*). 

### Vincoli Tecnici:
- Utilizzo del comando `nc` (Netcat).
- Divieto di utilizzare le funzioni di scansione integrate di Netcat (es. non è permesso passare un range di porte direttamente al comando).
- Implementazione di un ciclo `for` per la scansione sequenziale.
- Sanificazione degli input (IP e range porte).
- Personalizzazione tramite argomenti da linea di comando.

---

## 🏗️ Architettura di Rete (Vagrant)
L'ambiente è composto da due macchine virtuali Ubuntu 20.04 collegate tramite una rete privata:

| Macchina | Hostname | IP Privato | Ruolo |
| :--- | :--- | :--- | :--- |
| **VM 1** | `scanner` | `192.168.50.10` | Esegue lo script Bash |
| **VM 2** | `target` | `192.168.50.11` | Riceve i tentativi di connessione |

---

## 🚀 Installazione e Utilizzo

### 1. Avvio delle Macchine Virtuali
Assicurati di avere Vagrant e un provider (nel mio caso VirtualBox) installati. Dalla cartella del progetto, esegui:

```bash
vagrant up
#così da far partire vagrant e le due macchine

#--Accesso alla macchina Scanner--
Una volta avviate le VM, entro nella macchina che effettuerà la scansione con il comando:
vagrant ssh scanner

#--Esecuzione dello script--
#Ho creato lo script in bash che è presente nella cartella condivisa.
#Per avviarlo basta eseguire:
./portscanner.sh <IP_TARGET> <PORTA_INIZIO> <PORTA_FINE>
es:./portscanner.sh 192.168.50.11 20 25

#Partirà il tutto e avrò come output:
--------------------------------------
Inizio scansione su 192.168.50.11
Range: 20 - 25
--------------------------------------
Porta 22: APERTA
-------------------------------------- 
#mi dirà che si è aperta la porta 22, quella del SSH.
```

---

## 🔍 Test con Range di Porte Più Ampi

Per verificare il funzionamento dello scanner su più porte, ho installato **nginx** sulla VM target, in modo da mettere in ascolto anche la porta 80 (HTTP). Questo ha permesso di testare la scansione su un range più ampio:

```bash
./portscanner.sh 192.168.50.11 20 100
```

Output ottenuto:
```
--------------------------------------
Inizio scansione su 192.168.50.11
Range: 20 - 100
--------------------------------------
Porta 22: APERTA
Porta 80: APERTA
Porta 443: APERTA
--------------------------------------
Scansione completa
```

Per attivare la porta 80 sulla VM target è stato sufficiente:
```bash
vagrant ssh target
sudo apt update && sudo apt install -y nginx
sudo systemctl start nginx
```
Per attivare la porta 80 sulla VM target è stato sufficiente:
```bash
sudo nc -lk -p 433 &
#Vale per ogni porta
```


---

## ⚙️ Vincolo dell'Esercizio: Ho usato `/dev/null` al posto di `-z`

Netcat supporta il flag `-z` (zero I/O mode) che permette di testare le connessioni senza inviare dati — esattamente quello che serve per un port scanner. Tuttavia, **l'esercizio ne vietava esplicitamente l'utilizzo**, richiedendo di implementare la scansione senza ricorrere alle funzionalità integrate di Netcat.

Come da requisiti, è stata quindi usata la seguente tecnica:

```bash
nc -w 1 "$TARGET_IP" "$port" < /dev/null > /dev/null 2>&1
```

| Parte | Significato |
| :--- | :--- |
| `< /dev/null` | Redirige l'input da `/dev/null`: nc non riceve nulla da inviare e chiude subito la connessione |
| `> /dev/null` | Scarta l'output standard (nessun testo a schermo) |
| `2>&1` | Scarta anche gli errori |
| `-w 1` | Timeout di 1 secondo per non bloccarsi su porte chiuse |

In questo modo si ottiene lo stesso comportamento di `-z` — testare se la porta è aperta senza trasmettere dati reali — rispettando il vincolo imposto dall'esercizio.

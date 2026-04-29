#Port Scanner in Bash con Vagrant

Questo progetto implementa un **Port Scanner ** personalizzato scritto in Bash. L'esercizio simula un ambiente di rete reale composto da due macchine virtuali (VM) che comunicano tra loro, utilizzando **Vagrant** come orchestratore di virtualizzazione.

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

# Ping Pong tra due nodi Vagrant

L'esercizio simula la **migrazione live di un container Docker** tra due macchine virtuali, alternandolo ogni 60 secondi(per questo viene denominato PingPong).

## Requisiti

| Strumento | Versione minima |
|-----------|----------------|
| Vagrant   | 2.x            |
| VirtualBox | 6.x           |
| Bash      | qualsiasi      |

## Struttura

```
.
├── Vagrantfile       # due nodi Ubuntu con Docker.
├── provision.sh      # installa Docker su ogni nodo e scarica l'immagine Docker.
├── migrazione.sh        # script di migrazione (gira sull'host).
├── files/migrazione     #cartella di immagini output per il README.
│   └── Screenshoot 2026-05....png      # Screenshoot per le immagini di output
│   └── Screenshoot 2026-05....png      # Screenshoot per le immagini di output
│   └── Screenshoot 2026-05....png      # Screenshoot per le immagini di output
└── README.md

```

## Come usare

**1. Avvia i due nodi** (la prima volta scarica la box e installa Docker — qualche minuto):

```bash
vagrant up
```

![prima parte terminale](files/migrazione/Screenshot%202026-05-18%20alle%2016.59.55.png)



**2. In un altro terminale, avvia la migrazione:**

```bash
chmod +x migrate.sh
bash migrate.sh
```

**3. Verifica che il container risponda:**

```bash
curl http://192.168.56.10   # node1
curl http://192.168.56.11   # node2
```

Solo uno risponderà alla volta — l'altro darà connection refused.

**4. Per fermare tutto:**

```bash
Ctrl+C          # ferma la migrazione e il container
vagrant halt    # spegne le VM
vagrant destroy # elimina le VM
```

## Come funziona

`migrate.sh` gira sull'host e usa `vagrant ssh` per eseguire comandi Docker
sui nodi. Ogni 60 secondi:

1. Stoppa il container sul nodo attivo
2. Lo avvia sull'altro nodo
3. Attende 60 secondi
4. Ripete

```
t=0s   node1 [ON]  node2 [off]
t=60s  node1 [off] node2 [ON]
t=120s node1 [ON]  node2 [off]
...
```

## Nodi

| Nodo  | IP              | Porta |
|-------|-----------------|-------|
| node1 | 192.168.56.10   | 80    |
| node2 | 192.168.56.11   | 80    |

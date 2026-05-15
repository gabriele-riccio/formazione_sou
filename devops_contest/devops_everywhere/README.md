# Vagrant Webserver — DevOps Academy #6

Portfolio personale servito da **Nginx** su una VM Ubuntu, configurata
automaticamente tramite **Ansible** al primo `vagrant up`.

## Cosa fa

Al primo `vagrant up` la macchina viene provisioned con Ansible che:

1. Installa Nginx, curl e vim
2. Copia il portfolio (`files/index.html`) nella document root di Nginx
3. Avvia Nginx e lo abilita al boot

La pagina è raggiungibile immediatamente su `http://localhost:8080`
senza nessuna configurazione manuale.

## Cosa contiene la pagina

Un portfolio personale in stile **Sourcesense DevOps Academy** con:

- Presentazione personale e stack tecnologico
- Lista di tutti i progetti realizzati durante il percorso di formazione:
  - HTTP Status Code (Bash, curl, Flask)
  - Ping Pong Container (Vagrant, Docker, Bash)
  - Vagrant Webserver (questo progetto)
  - Port Scanner (Bash)
  - Gestione Processi ed Errori (Bash)

## Requisiti

| Strumento  | Versione minima |
|------------|----------------|
| Vagrant    | 2.x            |
| VirtualBox | 6.x            |
| Ansible    | qualsiasi      |

Installa Ansible se necessario:
```bash
pip3 install ansible
```

## Avvio

```bash
git clone https://github.com/gabriele-riccio/formazione_sou.git
cd formazione_sou/devops_contest/devops_everywhere
vagrant up
```

Apri il browser su `http://localhost:8080` e ottengo :

## Pagina web:

![prima parte sito web](index_file/Screenshot%202026-05-15%20alle%2017.04.52.png)

![seconda parte sito web](index_file/Screenshot%202026-05-15%20alle%2017.05.08.png)

![terza parte sito web](index_file/Screenshot%202026-05-15%20alle%2017.05.23.png)

## Struttura

```
.
├── Vagrantfile         # configurazione VM (Ubuntu 20.04, porta 8080)
├── playbook.yml        # provisioner Ansible
├── files/
│   └── index.html      # portfolio personale stile Sourcesense
└── README.md
```

## Comandi utili

```bash
vagrant up        # avvia e configura la VM
vagrant provision # riapplica il playbook (utile dopo modifiche all'HTML)
vagrant ssh       # entra nella VM
vagrant halt      # spegne la VM
vagrant destroy   # elimina la VM
```

## Accesso

| URL                    | Descrizione        |
|------------------------|--------------------|
| http://localhost:8080  | Dal tuo Mac        |
| http://192.168.56.20   | Dalla rete privata |


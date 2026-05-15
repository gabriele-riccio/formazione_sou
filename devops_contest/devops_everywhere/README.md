# Vagrant Webserver — Portfolio Gabriele DevOps Academy #6

**Traccia**
- Creare un progetto Vagrant. 
- Tramite un provisioner a vostra scelta (shell scripting, Puppet, Ansible, Chef, ecc...) configurate una
  macchina Linux ( nessuna preferenza sulla distribuzione ho scelto Ubuntu).
- Sarete liberi di decidere cosa far fare alla macchina l'importante è che sia portabile.
- Colui che analizzerà il vostro progetto dovrà eseguire 'vagrant up' e utilizzarla.
- L’aspetto fantasioso sarà un dato preferenziale.


Ho deciso di creare un Portfolio personale servito da **Nginx** su una **VM Ubuntu**, configurata
automaticamente tramite **Ansible** al primo `vagrant up`.

## Cosa fa

Al primo `vagrant up` la macchina viene provisioned con Ansible che:

1. Installa Nginx, curl e vim
2. Copia il portfolio `files/index.html` nella document root di Nginx(L'ho implementato da un progetto
   precedente che avevo svolto in un progetto che avevo fatto per un corso di programmazione che ho seguito
   prima di inziare l'Academy).
3. Avvia Nginx e lo abilita al boot.

La pagina è raggiungibile immediatamente su `http://localhost:8080` senza nessuna configurazione manuale.

## Cosa contiene la pagina

Un portfolio personale in stile **Sourcesense DevOps Academy** con:

- Presentazione personale e stack tecnologico
- Lista di tutti i progetti/esercizi bonus realizzati fin ora durante l'Academy:
  - HTTP Status Code (Bash, curl, Flask)
  - Ping Pong Container (Vagrant, Docker, Bash) in corso...
  - Vagrant Webserver (questo progetto)
  - Port Scanner (Bash)
  - Gestione Processi ed Errori (Bash)

## Requisiti

| Strumento  | Versione minima |
|------------|----------------|
| Vagrant    | 2.x            |
| VirtualBox | 6.x            |
| Ansible    | qualsiasi      |

## Svolgimento

Ho installato Ansible:
```bash
pip3 install ansible
```
Ho dovuto farlo con pip3 e non con Homebrew dato che si bloccava per la pesantezza delle librerie.

## Avvio

```bash
git clone https://github.com/gabriele-riccio/formazione_sou.git
cd formazione_sou/devops_contest/devops_everywhere
vagrant up
```

Apro il browser su `http://localhost:8080` o  `http://192.168.56.20` e ottengo :


## Pagina web:

![prima parte sito web](index_file/Screenshot%202026-05-15%20alle%2017.04.52.png)

![seconda parte sito web](index_file/Screenshot%202026-05-15%20alle%2017.05.08.png)

![terza parte sito web](index_file/Screenshot%202026-05-15%20alle%2017.05.23.png)


## Struttura

```

├── Vagrantfile         # configurazione VM (Ubuntu 20.04, porta 8080)
├── provisioner_Ansible.yml        # provisioner Ansible(playbook)
├── index_file/
│   └── Screenshoot 2026-05....png      # Screenshoot per le immagini di output
│   └── Screenshoot 2026-05....png      # Screenshoot per le immagini di output
│   └── Screenshoot 2026-05....png      # Screenshoot per le immagini di output
│  
├── files/
│   └── index.html      # portfolio personale stile Sourcesense
│    
└── README.md

```

## Comandi utili

```bash
vagrant up        # avvia e configura la VM
vagrant provision # riapplica il playbook (utile dopo modifiche all'HTML, per riottenere la pagina web giusta)
vagrant ssh       # entra nella VM
vagrant halt      # spegne la VM
vagrant destroy   # elimina la VM
```

## Accesso

| URL                    | Descrizione        |
|------------------------|--------------------|
| http://localhost:8080  | Dal tuo Mac        |
| http://192.168.56.20   | Dalla rete privata |


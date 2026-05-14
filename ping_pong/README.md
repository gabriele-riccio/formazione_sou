# Vagrant Webserver

Macchina Linux Ubuntu con Nginx, configurata automaticamente tramite **Ansible**.

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
vagrant up
```

Questo comando:
1. Scarica la box Ubuntu 20.04
2. Crea la VM in VirtualBox
3. Esegue il playbook Ansible che installa Nginx e copia la pagina web

## Verifica

Apri il browser su:
```
http://localhost:8080
```
oppure
```
http://192.168.56.20
```

## Struttura

```
.
├── Vagrantfile       # configurazione VM
├── playbook.yml      # provisioner Ansible
├── files/
│   └── index.html    # pagina servita da Nginx
└── README.md
```

## Comandi utili

```bash
vagrant up        # avvia e provisionizza la VM
vagrant ssh       # entra nella VM
vagrant halt      # spegne la VM
vagrant destroy   # elimina la VM
vagrant provision # riesegue il playbook senza ricreare la VM
```


# Step 1 — Workstation Mac

Seconda esercitazione TRACK2.  
Automazione completa dell'infrastruttura: una VM Rocky Linux 9 gestita da Vagrant viene configurata interamente tramite Ansible, che installa Docker, configura le reti e deploya Jenkins Master e Agent come container.

---

## Requisiti della traccia

| # | Requisito | Stato |
|---|-----------|-------|
| 1 | VM Rocky Linux 9 via Vagrant (Intel) | ✅ |
| 2 | Installazione Docker via Ansible | ✅ |
| 3 | Configurazione Docker Network con IP statici via Ansible | ✅ |
| 4 | Jenkins Master via Ansible + Docker con IP statico | ✅ |
| 5 | Jenkins Agent via Ansible + Docker collegato al Master | ✅ |

---

## Architettura

```
Mac (control node)
│
├── Vagrant → VM Rocky9 (192.168.56.20)
│             │
│             └── Docker
│                  ├── jenkins_network (172.18.0.0/16)
│                  │    ├── jenkins-controller  → Jenkins Master (porta 8080, 50000)
│                  │    └── jenkins-agent       → Jenkins Agent (label: docker)
│                  │
│                  └── [EXTRA] step1_network (172.26.0.0/24)
│                       ├── app_web   → Nginx  (172.26.0.10, porta 8081)
│                       └── app_cache → Redis  (172.26.0.11, rete interna)
│
└── Ansible
     ├── playbooks/install_docker.yml   → installa Docker sulla VM
     ├── playbooks/deploy_jenkins.yml   → avvia Jenkins Master + Agent
     └── [EXTRA] playbooks/deploy_app.yml → deploya stack Nginx + Redis
```

---

## Struttura del progetto

```
esercitazioni_track2/step1/
├── ansible-lab/
│   ├── ansible.cfg
│   ├── inventory/
│   │   └── hosts.ini
│   ├── vars/
│   │   ├── main.yml       # variabili in chiaro
│   │   └── vault.yml      # variabili cifrate con Ansible Vault
│   ├── .vault_pass        # password Vault (gitignored)
│   └── playbooks/
│       ├── install_docker.yml
│       ├── deploy_jenkins.yml
│       ├── [EXTRA] deploy_app.yml
│       └── roles/
│           ├── jenkins_stack/   # Master + Agent
│           └── [EXTRA] app_stack/  # Nginx + Redis
├── [EXTRA] esercitazione_step1/
│   └── Jenkinsfile
└── README.md
```

---

## Svolgimento:

### 1. Avvia la VM

```bash
cd esercitazioni_track2/step1/ansible-lab
vagrant up
```

Verifica la connettività SSH:

```bash
vagrant ssh
exit
```

Verifica la connettività Ansible:

```bash
ansible rocky9 -m ping
```


### 2. Crea il file della vault password

```bash
echo "la-tua-password-vault" > .vault_pass
chmod 600 .vault_pass
```

> Il file è in `.gitignore` e non viene mai committato nel repository.

### 3. Installa Docker sulla VM
Scrivo il playbook installa_docker.yml:

```bash
---
- name: Installa Docker sulla Rocky9
  hosts: rocky9
  become: true

  tasks:
    - name: Installa pacchetti
      ansible.builtin.dnf:
        name:
          - dnf-utils
          - device-mapper-persistent-data
          - lvm2
        state: present

    - name: Aggiunto Repository Docker
      ansible.builtin.yum_repository:
        name: docker-ce
        description: Docker CE Stable - $basearch
        baseurl: https://download.docker.com/linux/centos/$releasever/$basearch/stable
        gpgcheck: true
        gpgkey: https://download.docker.com/linux/centos/gpg
        enabled: true

    - name: Installa Docker Engine
      ansible.builtin.dnf:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
        state: present

    - name: Avvia e abilita il servizio Docker
      ansible.builtin.systemd:
        name: docker
        state: started
        enabled: true

    - name: Aggiungi l'utente vagrant al gruppo docker
      ansible.builtin.user:
        name: vagrant
        groups: docker
        append: true

    - name: Installa python3-setuptools e python3-pip
      ansible.builtin.dnf:
        name:
          - python3-setuptools
          - python3-pip
        state: present

    - name: Installa la libreria python requests
      ansible.builtin.pip:
        name: requests
        state: present
        executable: pip3

```
---
Installazione vera e propria:
```bash
ansible-playbook playbooks/installa_docker.yml
```

Il playbook installa Docker Engine, abilita il servizio, e aggiunge l'utente `vagrant` al gruppo `docker`. Installa anche le librerie Python necessarie (`requests`, `setuptools`) per i moduli Ansible della collection `community.docker`.



### 4. Deploya Jenkins Master e Agent
Ho scritto il 'deploy_jenkins.yml' :

```bash
---
- name: Deploy Jenkins Controller e Agent
  hosts: rocky9
  become: true

  roles:
    - jenkins_stack
```

Prende il vero playbook dal role jenkins_stack in tasks:

```bash
vim playbooks/roles/jenkins_stack/tasks/main.yml:
```
---

```bash
---
- name: Crea rete Docker per Jenkins
  community.docker.docker_network:
    name: jenkins_network
    driver: bridge
    state: present

- name: Crea volume per i dati Jenkins
  community.docker.docker_volume:
    name: jenkins_home
    state: present

- name: Avvia jenkins Controller(Master)
  community.docker.docker_container:
    name: jenkins-controller
    image: jenkins/jenkins:lts
    state: started
    restart_policy: always
    networks:
      - name: jenkins_network
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home

- name: Avvia Jenkins Agent
  community.docker.docker_container:
    name: jenkins-agent
    image: jenkins/inbound-agent
    state: started
    restart_policy: always
    networks:
      - name: jenkins_network
    env:
      JENKINS_URL: "http://jenkins-controller:8080"
      JENKINS_AGENT_NAME: "agent-docker-1"
      JENKINS_SECRET: "a92dd7b0fc241e7e6482e26980dcd08f2eb476fb45ed682102eb858d760782bd"
      JENKINS_AGENT_WORKDIR: "/home/jenkins/agent"
```

Installazione vera e propria:

```bash
ansible-playbook playbooks/deploy_jenkins.yml
```

Il playbook:
- Crea la rete Docker `jenkins_network`
- Crea il volume `jenkins_home` per la persistenza dei dati
- Avvia il container `jenkins-controller` (Jenkins Master) sulla porta 8080
- Avvia il container `jenkins-agent` collegato al Master.

Jenkins è disponibile su `http://192.168.56.20:8080`.

### 5. Configura Jenkins al primo avvio

Recupera la password iniziale da terminale:

```bash
ansible rocky9 -m command \
  -a "docker exec jenkins-controller cat /var/jenkins_home/secrets/initialAdminPassword" \
  -b
```

Sul browser:
1. Incollo la password → **Continue**
2. **Installo i plugins suggeriti**
3. Creo l'utente admin
4. **Save and Finish** → **Start using Jenkins**

### 6. Collega l'Agent al Master

Creo l'agent(nodo) su Jenkins → **Gestisci Jenkins → Nodi → New Node**:

| Campo | Valore |
|-------|--------|
| Nome | `agent-docker-1` |
| Tipo | Permanent Agent |
| Remote root directory | `/home/jenkins/agent` |
| Labels | `docker` |
| Launch method | Launch agent by connecting it to the controller |


Copio il **secret token** generato dalla pagina del nodo, poi lo aggiorno nel ruolo:

```
playbooks/roles/jenkins_stack/tasks/main.yml → JENKINS_SECRET
```

> Il secret token lo trovo nelle informazioni dell'agent creato, una volta copiato lo aggiorno nel ruolo tra le variabili ambiente usate(ENV).

**JENKINS_SECRET**: "a92dd7b0fc241e7e6482e26980dcd08f2eb476fb45ed682102eb858d760782bd"

Rieseguo poi il playbook per aggiornare il container con il secret corretto:

```bash
ansible-playbook playbooks/deploy_jenkins.yml
```

Verifico nei log che l'Agent sia connesso:

```bash
ansible rocky9 -b -m command -a "docker logs jenkins-agent --tail 5"
```

> Deve comparire `INFO: Connected`.

---

## Credenziali Jenkins (per la pipeline extra)

Se si vuole utilizzare la pipeline Jenkinsfile inclusa nel progetto, configurare queste credenziali su Jenkins prima del primo run:

**Gestisci Jenkins → Credentials → System → Global credentials → Add Credentials**

| ID | Kind | Contenuto |
|----|------|-----------|
| `rocky9-ssh-key` | SSH Username with private key | Chiave da `.vagrant/machines/default/virtualbox/private_key`, username: `vagrant` |
| `ansible-vault-pass` | Secret file | File `.vault_pass` della cartella `ansible-lab` |

---

## Extra — Stack applicativo e pipeline Jenkins

In aggiunta alle richieste ho voluto esercitarmi ad utilizzare il sistema di codifica di Ansible Vault facendo:

- Uno **Stack applicativo** (`deploy_app.yml`): che deploya Nginx (porta 8081) e Redis sulla rete Docker `step1_network` con IP statici, usando Ansible Vault per proteggere la passwor di
  Redis.
  
  ```bash
  ---
  - name: Deploy stack applicativo via Docker
    hosts: rocky9
    become: true
    vars_files:
      - "{{ playbook_dir }}/../vars/vault.yml"

    roles:
      - app_stack
  ```
            
Inoltre anche a fare una pipeline, dato che comunque le avevo già fatte anche per esercizi bonus:
- **Pipeline Jenkins** (`esercitazione_step1/Jenkinsfile`): orchestrata dall'Agent, esegue in sequenza:
1. Checkout del repository
2. Validazione sintattica del playbook (`--syntax-check`)
3. Dry-run contro la VM (`--check --diff`)
4. Deploy reale (opzionale, con il parametro `ESEGUI_DAVVERO` infatti verrà eseguita senza parametri all'inizio e poi verrà eseguit con parametri impostando 'ESEGUI_DAVVERO')
5. Verifica il post-deploy: controlla che Nginx risponda HTTP 200

``` bash
pipeline {
    agent { label 'docker' }

    parameters {
        booleanParam(name: 'ESEGUI_DAVVERO', defaultValue: false,
                     description: 'Se falso esegue solo --check (dry-run)')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/gabriele-riccio/formazione_sou.git'
            }
        }

        stage('Validazione sintattica') {
            steps {
                withCredentials([
                    file(credentialsId: 'ansible-vault-pass', variable: 'VAULT_PASS_FILE')
                ]) {
                    dir('esercitazioni_track2/step1/ansible-lab') {
                        sh """
                            ANSIBLE_VAULT_PASSWORD_FILE=\$VAULT_PASS_FILE \
                            ansible-playbook playbooks/deploy_app.yml \
                              --syntax-check
                        """
                    }
                }
            }
        }

        stage('Dry-run') {
            steps {
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'rocky9-ssh-key', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER'),
                    file(credentialsId: 'ansible-vault-pass', variable: 'VAULT_PASS_FILE')
                ]) {
                    dir('esercitazioni_track2/step1/ansible-lab') {
                        sh """
                            ANSIBLE_VAULT_PASSWORD_FILE=\$VAULT_PASS_FILE \
                            ansible-playbook playbooks/deploy_app.yml \
                              -e ansible_ssh_private_key_file=\$SSH_KEY \
                              -u vagrant \
                              --check --diff
                        """
                    }
                }
            }
        }

        stage('Deploy reale') {
            when {
                expression { params.ESEGUI_DAVVERO == true }
            }
            steps {
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'rocky9-ssh-key', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER'),
                    file(credentialsId: 'ansible-vault-pass', variable: 'VAULT_PASS_FILE')
                ]) {
                    dir('esercitazioni_track2/step1/ansible-lab') {
                        sh """
                            ANSIBLE_VAULT_PASSWORD_FILE=\$VAULT_PASS_FILE \
                            ansible-playbook playbooks/deploy_app.yml \
                              -e ansible_ssh_private_key_file=\$SSH_KEY \
                              -u vagrant
                        """
                    }
                }
            }
        }

        stage('Verifica post-deploy') {
            when {
                expression { params.ESEGUI_DAVVERO == true }
            }
            steps {
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'rocky9-ssh-key', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER'),
                    file(credentialsId: 'ansible-vault-pass', variable: 'VAULT_PASS_FILE')
                ]) {
                    dir('esercitazioni_track2/step1/ansible-lab') {
                        sh """
                            ANSIBLE_VAULT_PASSWORD_FILE=\$VAULT_PASS_FILE \
                            ansible rocky9 -m uri \
                              -e ansible_ssh_private_key_file=\$SSH_KEY \
                              -u vagrant \
                              -a "url=http://192.168.56.20:8081 status_code=200"
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completata. Modalita: ${params.ESEGUI_DAVVERO ? 'deploy reale' : 'dry-run'}"
        }
        failure {
            echo 'Pipeline fallita, controlla i log della console'
        }
    }
}

```






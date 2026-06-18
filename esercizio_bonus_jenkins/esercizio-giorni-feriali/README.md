# Esercizio Bonus Jenkins — Pipeline con controllo del giorno della settimana

## Obiettivo

Scrivere una pipeline Jenkins che esegua la build solo dal lunedì al venerdì, e che stampi un messaggio di warning (senza eseguire la build) il sabato e la domenica. Vincolo dell'esercizio: il giorno della settimana non deve essere ricavato tramite un comando shell, ma utilizzando l'oggetto `Date` (e la classe `Calendar`) fornito nativamente da Groovy.

## Strumenti utilizzati

- Jenkins (immagine Docker ufficiale `jenkins/jenkins:lts`)
- Docker Desktop (macOS)
- Groovy (sintassi Pipeline dichiarativa)
- Git / GitHub

## Setup dell'ambiente

1. Avvio di Jenkins tramite Docker:
```bash
   docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home --name jenkins jenkins/jenkins:lts
```
2. Recupero della password iniziale:
```bash
   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
3. Accesso alla dashboard su `http://localhost:8080`, installazione dei plugin consigliati, creazione del primo utente amministratore.
4. Creazione di un nuovo "Item" di tipo **Pipeline**, con definizione "Pipeline script" (script incollato direttamente, senza repository SCM collegato).

![Dashboard Jenkins](./screenshots/01-dashboard-jenkins.png)
![Creazione job Pipeline](./screenshots/02-creazione-job.png)

## Script principale (`Jenkinsfile`)

```groovy
pipeline {
    agent any

    stages {
        stage('Check del giorno della settimana') {
            steps {
                script {
                    def oggi = new Date()
                    int giornoSettimana = oggi[Calendar.DAY_OF_WEEK]

                    if (giornoSettimana == Calendar.SATURDAY || giornoSettimana == Calendar.SUNDAY) {
                        echo "WARNING: oggi è weekend, la build non verrà eseguita."
                        env.IS_WEEKEND = "true"
                    } else {
                        echo "Oggi è un giorno feriale, procedo con la build."
                        env.IS_WEEKEND = "false"
                    }
                }
            }
        }

        stage('Build') {
            when {
                expression { env.IS_WEEKEND == "false" }
            }
            steps {
                echo "Eseguo la build ..."
            }
        }
    }
}
```

### Come funziona

- Il primo stage usa `new Date()` per ottenere l'istante corrente, e l'operatore `[]` di Groovy (`oggi[Calendar.DAY_OF_WEEK]`) per estrarre il giorno della settimana come numero (1 = domenica ... 7 = sabato), sfruttando le costanti leggibili `Calendar.SATURDAY` e `Calendar.SUNDAY` invece dei numeri grezzi.
- Il risultato del controllo viene salvato in una variabile d'ambiente della pipeline (`env.IS_WEEKEND`), così da essere accessibile anche dal secondo stage.
- Il secondo stage usa la direttiva `when { expression { ... } }` per decidere se eseguirsi oppure essere saltato (skipped), in base al valore di `env.IS_WEEKEND`.

![Script nell'editor Jenkins](./screenshots/03-script-editor.png)

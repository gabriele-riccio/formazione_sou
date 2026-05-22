#!/usr/bin/env bash

set -e #Fa in modo di interrompere lo script immediatamente se un qualsiasi comando fallisce, per evitare problemi.

echo "==> [provision] Aggiornamento pacchetti..."
apt-get update -qq
apt-get install -y -qq procps curl vim bash

# ──────────────────────────────────────────────────────────
# Ciclo for per creare i processi
# ──────────────────────────────────────────────────────────

echo "==> [provision] Creazione utenti lupo / capra / cavolo/ traghettatore"


for user in lupo capra cavolo; do
    if ! id "$user" &>/dev/null; then
        # Per il traghettatore potresti volere una shell valida se devi usarlo per lanciare lo script
        useradd --system --no-create-home --shell /usr/sbin/nologin "$user"
        echo "  utente '$user' creato"
    fi
done

if ! id "traghettatore" &>/dev/null; then
    useradd --system --no-create-home --shell /bin/bash traghettatore
    echo "  utente 'traghettatore' creato "
fi


# ──────────────────────────────────────────────────────────
# Permessi sudoers (Configurazione Sicura)
# ──────────────────────────────────────────────────────────
echo "==> [provision] Configurazione sudoers..."

# File dedicato in /etc/sudoers.d/
cat > /etc/sudoers.d/capra_lupo << 'SUDOERS'

#lupo può mandare SIGTERM (kill -15) SOLO ai processi dell'utente 'capra'
lupo ALL=(root) NOPASSWD: /bin/kill -15 --user capra *, /bin/kill -s 15 --user capra *
lupo ALL=(root) NOPASSWD: /usr/bin/kill -15 --user capra *, /usr/bin/kill -s 15 --user capra *

#capra può mandare SIGTERM (kill -15) SOLO ai processi dell'utente 'cavolo'
capra ALL=(root) NOPASSWD: /bin/kill -15 --user cavolo *, /bin/kill -s 15 --user cavolo *
capra ALL=(root) NOPASSWD: /usr/bin/kill -15 --user cavolo *, /usr/bin/kill -s 15 --user cavolo *

# Traghettatore (admin / orchestratore) può eseguire lo script e usare kill liberamente
traghettatore ALL=(ALL) NOPASSWD: /vagrant/file_script_prova.sh
traghettatore ALL=(ALL) NOPASSWD: /bin/kill *, /usr/bin/kill *
SUDOERS

# Imposto poi i permessi corretti per il file sudoers (obbligatorio, altrimenti sudo lo ignora)
chmod 0440 /etc/sudoers.d/capra_lupo

# ──────────────────────────────────────────────────────────
# Riepilogo finale
# ──────────────────────────────────────────────────────────
echo ""
echo "==> [provision] Riepilogo permessi configurati:"
echo "    lupo    → sudo kill -15 --user capra <PID>   (SIGTERM solo su capra)"
echo "    capra   → sudo kill -15 --user cavolo <PID> (SIGTERM solo su cavolo)"
echo "    traghettatore → sudo /vagrant/file_script_prova.sh (orchestratore)"
echo ""
echo "==> [provision] Completato con successo."

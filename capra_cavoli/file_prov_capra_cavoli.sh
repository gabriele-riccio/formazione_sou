#!/usr/bin/env bash
# ============================================================
# file_prov_capra_cavoli.sh — setup comune a vm1 e vm2.
# ============================================================
# 1. Installa dipendenze minime
# 2. Crea gli utenti lupo, capra, cavolo
# 3. Configura sudoers in modo sicuro:
#      - lupo può inviare kill -9 SOLO ai processi di capra
#      - capra può inviare SIGTERM (kill -15) SOLO ai processi di cavolo
#      - vagrant (admin) gestisce l'orchestratore senza password
# ============================================================

set -e

echo "==> [provision] Aggiornamento pacchetti..."
apt-get update -qq
apt-get install -y -qq procps curl vim bash

# ──────────────────────────────────────────────────────────
# Utenti che rappresentano i "processi"
# ──────────────────────────────────────────────────────────
echo "==> [provision] Creazione utenti lupo / capra / cavolo..."

for user in lupo capra cavolo; do
    if ! id "$user" &>/dev/null; then
        useradd --system --no-create-home --shell /usr/sbin/nologin "$user"
        echo "  utente '$user' creato"
    else
        echo "  utente '$user' già presente, skip"
    fi
done

# ──────────────────────────────────────────────────────────
# Permessi sudoers (Configurazione Sicura)
# ──────────────────────────────────────────────────────────
echo "==> [provision] Configurazione sudoers..."

# File dedicato in /etc/sudoers.d/ (non si tocca /etc/sudoers direttamente)
cat > /etc/sudoers.d/ferry-puzzle << 'SUDOERS'
# ============================================================
# ferry-puzzle — regole di kill tra i processi del puzzle
# ============================================================

#lupo può mandare SIGTERM (kill -15) SOLO ai processi dell'utente 'capra'
lupo ALL=(root) NOPASSWD: /bin/kill -15 --user capra *, /bin/kill -s 15 --user capra *
lupo ALL=(root) NOPASSWD: /usr/bin/kill -15 --user capra *, /usr/bin/kill -s 15 --user capra *

#capra può mandare SIGTERM (kill -15) SOLO ai processi dell'utente 'cavolo'
capra ALL=(root) NOPASSWD: /bin/kill -15 --user cavolo *, /bin/kill -s 15 --user cavolo *
capra ALL=(root) NOPASSWD: /usr/bin/kill -15 --user cavolo *, /usr/bin/kill -s 15 --user cavolo *

# vagrant (admin / orchestratore) può eseguire lo script e usare kill liberamente
vagrant ALL=(ALL) NOPASSWD: /vagrant/file_capra_cavoli.sh
vagrant ALL=(ALL) NOPASSWD: /bin/kill *, /usr/bin/kill *
SUDOERS

# Imposta i permessi corretti per il file sudoers (obbligatorio, altrimenti sudo lo ignora)
chmod 0440 /etc/sudoers.d/ferry-puzzle

# ──────────────────────────────────────────────────────────
# Riepilogo finale
# ──────────────────────────────────────────────────────────
echo ""
echo "==> [provision] Riepilogo permessi configurati:"
echo "    lupo    → sudo kill -15 --user capra <PID>   (SIGTERM solo su capra)"
echo "    capra   → sudo kill -15 --user cavolo <PID> (SIGTERM solo su cavolo)"
echo "    vagrant → sudo /vagrant/file_capra_cavoli.sh (orchestratore)"
echo ""
echo "==> [provision] Completato con successo."


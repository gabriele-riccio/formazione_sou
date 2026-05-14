"""
server_500.py
Server Flask minimale.
Usato per esercizio bonus per il file file_5XX_esercizio.sh
"""

from flask import Flask, jsonify
import os

app = Flask(__name__)

# Silenzia i log di werkzeug per non sporcare l'output della simulazione
import logging
log = logging.getLogger("werkzeug")
log.setLevel(logging.ERROR)


@app.route("/crash")
def crash_zero_division():
    """Crash reale: divisione per zero."""
    risultato = 1 / 0          # ZeroDivisionError — non gestito
    return jsonify({"valore": risultato})


@app.route("/crash-db")
def crash_db():
    """Simula una connessione a DB che fallisce."""
    raise ConnectionError("Impossibile connettersi al database: timeout dopo 30s")


@app.route("/crash-gestito")
def crash_gestito():
    """Il server cattura l'eccezione e risponde 500 con un messaggio chiaro."""
    try:
        dati = None
        lunghezza = len(dati)      # TypeError: dati è None
        return jsonify({"lunghezza": lunghezza})
    except TypeError as e:
        return jsonify({
            "errore": "Errore interno del server",
            "dettaglio": str(e),
            "codice": 500
        }), 500


@app.errorhandler(500)
def gestisci_500(e):
    """Handler globale: intercetta tutti i crash non gestiti."""
    return jsonify({
        "errore": "Internal Server Error",
        "messaggio": "Il server ha incontrato un errore imprevisto.",
        "tipo": type(e.original_exception).__name__
    }), 500


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="127.0.0.1", port=port, debug=False)

 

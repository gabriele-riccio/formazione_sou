from flask import Flask
import datetime, os

app = Flask(__name__)

@app.route('/')
def write():
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    html = f"<h1>Messaggio dal Backend</h1><p>Scritto il {now}</p>"
    os.makedirs('/dati', exist_ok=True)
    with open('/dati/messaggio.html', 'w') as f:
        f.write(html)
    return f"File scritto: {now}"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

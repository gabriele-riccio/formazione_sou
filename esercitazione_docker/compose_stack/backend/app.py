from flask import Flask
import datetime, os, redis

app = Flask(__name__)
r = redis.Redis(host='redis', port=6379)

@app.route('/')
def write():
    visite = r.incr('visite')
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    html = f"<h1>Messaggio dal Backend</h1><p>Scritto il {now}</p><p>Visite: {visite}</p>"
    os.makedirs('/dati', exist_ok=True)
    with open('/dati/messaggio.html', 'w') as f:
        f.write(html)
    return f"File scritto: {now} | Visite: {visite}"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

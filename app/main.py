from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello from your containerized Flask App!"

@app.route('/health')
def health_check():
    return {"status": "ok"}, 200

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))

# hello.py

from flask import Flask, jsonify
from datetime import datetime

app = Flask(__name__)

@app.route('/', methods=["GET"])
def hello_world():
    return jsonify({
        "message": "Hello, World!",
        "timestamp": datetime.now().isoformat(),
        "status": "OK"
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

from flask import Flask
from flask_cors import CORS
from config import Config

app = Flask(__name__)
app.config.from_object(Config)
CORS(app) # Enable CORS for frontend

from routes import *

if __name__ == '__main__':
    app.run(debug=True, port=5000)

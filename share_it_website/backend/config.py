import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key'
    ORACLE_USER = os.environ.get('ORACLE_USER') or 'system'
    ORACLE_PASSWORD = os.environ.get('ORACLE_PASSWORD') or 'oracle'
    ORACLE_DSN = os.environ.get('ORACLE_DSN') or 'localhost:1521/xe'
    USE_MOCK_DB = os.environ.get('USE_MOCK_DB', 'True').lower() == 'true'

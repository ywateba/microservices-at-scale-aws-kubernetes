import logging
import os
import watchtower

from flask import Flask
from flask_sqlalchemy import SQLAlchemy


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
handler = watchtower.CloudWatchLogHandler(
    log_group="uda-app-group",
    stream_name="analytics"
)
logger.addHandler(handler)



db_username = os.environ["DB_USERNAME"]
db_password = os.environ["DB_PASSWORD"]
db_host = os.environ.get("DB_HOST", "127.0.0.1")
db_port = os.environ.get("DB_PORT", "5432")
db_name = os.environ.get("DB_NAME", "postgres")

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = f"postgresql://{db_username}:{db_password}@{db_host}:{db_port}/{db_name}"

db = SQLAlchemy(app)
app.logger = logger
app.logger.setLevel(logging.DEBUG)

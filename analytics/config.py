import logging
import os
import boto3
import watchtower

from flask import Flask
from flask_sqlalchemy import SQLAlchemy

# Create a boto3 session with your specified region
client = boto3.session.Session(
    region_name='us-east-1',

).client("logs") # Replace 'us-west-2' with your desired region


# # Configure logging
logging.basicConfig(level=logging.INFO,
                    format='[%(asctime)s] %(levelname)s in %(module)s: %(message)s',
                    force=True)

logger = logging.getLogger("app")
handler = watchtower.CloudWatchLogHandler(
    log_group="uda-app-group",
    stream_name="analytics",

    boto3_client=client


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

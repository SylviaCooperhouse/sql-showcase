import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, MetaData
from sqlalchemy_schemadisplay import create_schema_graph

# Load environment variables from .env
load_dotenv()

# Get database connection details from .env
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

# Construct the database URL
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# Connect to the database
engine = create_engine(DATABASE_URL)
metadata = MetaData()
metadata.reflect(bind=engine)

# Fix: Pass 'engine' explicitly to 'create_schema_graph'
graph = create_schema_graph(metadata=metadata, engine=engine, show_datatypes=True)

# Save diagram
graph.write_png("db_schema.png")

print("Database schema diagram saved as 'db_schema.png'")

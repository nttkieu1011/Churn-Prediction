
import os
import pandas as pd

from pathlib import Path
from sqlalchemy import create_engine
from dotenv import load_dotenv


# 1. Load database configuration
load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")


# 2. Connect to PostgreSQL
connection_string = (
    f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

engine = create_engine(connection_string)


# 3. Define data directory
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "Data"


# 4. Define CSV files
csv_files = [
    "dim_plan_name.csv",
    "finance_cube_data.csv",
    "gmv_base_month.csv",
    "search_traffic_raw_monthly.csv"
]


# 5. Import CSV files into PostgreSQL
for file_name in csv_files:

    file_path = DATA_DIR / file_name

    print(f"\nProcessing: {file_name}")

    # Read CSV
    data = pd.read_csv(file_path)

    # Add ingestion timestamp
    data["ingestion_at"] = pd.Timestamp.now()

    print("Preview:")
    print(data.head())

    # Load data into PostgreSQL
    table_name = file_path.stem

    data.to_sql(
        name=table_name,
        con=engine,
        schema="bronze",
        if_exists="replace",
        index=False,
        chunksize=1000
    )

    print(f"Imported {len(data):,} rows into bronze.{table_name}")


# 6. Close connection
engine.dispose()

print("\nAll files imported successfully!")

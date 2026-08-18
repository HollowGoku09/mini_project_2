"""
scripts/setup_db.py
===================
Utility script to create job_market_db database in PostgreSQL and initialize tables/indexes.
"""

import os
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from dotenv import load_dotenv

load_dotenv()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", 5432))
DB_NAME = os.getenv("DB_NAME", "job_market_db")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "hollowgoku")

def init_database():
    print(f"Connecting to PostgreSQL server at {DB_HOST}:{DB_PORT} as user '{DB_USER}'...")
    try:
        conn = psycopg2.connect(
            host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASSWORD, dbname='job_market_db'
        )
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        with conn.cursor() as cur:
            cur.execute(f"SELECT 1 FROM pg_database WHERE datname = '{DB_NAME}';")
            exists = cur.fetchone()
            if not exists:
                print(f"Database '{DB_NAME}' does not exist. Creating database...")
                cur.execute(f"CREATE DATABASE {DB_NAME};")
                print(f"[OK] Database '{DB_NAME}' created successfully.")
            else:
                print(f"[OK] Database '{DB_NAME}' already exists.")
        conn.close()
    except Exception as e:
        print(f"Error initializing database: {e}")
        return False

    print(f"Applying schema DDL files to '{DB_NAME}'...")
    try:
        db_conn = psycopg2.connect(
            host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASSWORD, dbname=DB_NAME
        )
        db_conn.autocommit = True
        base_dir = os.path.dirname(os.path.dirname(__file__))
        sql_files = [
            os.path.join(base_dir, 'sql', '00_drop_all.sql'),
            os.path.join(base_dir, 'sql', '01_schema.sql'),
            os.path.join(base_dir, 'sql', '02_indexes.sql')
        ]
        
        for sf in sql_files:
            print(f"Executing {os.path.basename(sf)}...")
            with open(sf, 'r', encoding='utf-8') as f:
                sql_content = f.read()
            with db_conn.cursor() as cur:
                cur.execute(sql_content)
        db_conn.close()
        print("[OK] All database tables and indexes initialized successfully!")
        return True
    except Exception as e:
        print(f"Error applying SQL schema files: {e}")
        return False

if __name__ == "__main__":
    init_database()

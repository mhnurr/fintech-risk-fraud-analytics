import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()
engine = create_engine(os.getenv("DB_URL"))

if __name__ == "__main__":
    with engine.connect() as conn:
        total = conn.execute(text("SELECT COUNT(*) FROM raw.transactions")).scalar()
        print("Koneksi berhasil. Jumlah baris:", total)
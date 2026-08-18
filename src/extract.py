"""
src/extract.py
==============
Chunked and full extraction module for Job Market Analytics raw CSV datasets.
Ensures memory-efficient reading of large files (job_postings_fact and skills_job_dim).
"""

import logging
from pathlib import Path
from typing import Generator
import pandas as pd
from src.config import DATA_RAW_DIR, CHUNK_SIZE

logger = logging.getLogger(__name__)

def get_csv_path(filename: str) -> Path:
    """Find CSV file path in data/raw/."""
    raw_path = DATA_RAW_DIR / filename
    if raw_path.exists():
        return raw_path
    raise FileNotFoundError(f"CSV file '{filename}' not found in '{DATA_RAW_DIR}'")

def extract_companies() -> pd.DataFrame:
    """Extract company_dim.csv into pandas DataFrame."""
    file_path = get_csv_path("company_dim.csv")
    logger.info(f"Extracting company_dim from {file_path}")
    df = pd.read_csv(file_path)
    logger.info(f"Extracted {len(df):,} rows from company_dim.csv")
    return df

def extract_skills() -> pd.DataFrame:
    """Extract skills_dim.csv into pandas DataFrame."""
    file_path = get_csv_path("skills_dim.csv")
    logger.info(f"Extracting skills_dim from {file_path}")
    df = pd.read_csv(file_path)
    logger.info(f"Extracted {len(df):,} rows from skills_dim.csv")
    return df

def extract_job_postings(chunk_size: int = CHUNK_SIZE) -> Generator[pd.DataFrame, None, None]:
    """Yield chunks of job_postings_fact.csv."""
    file_path = get_csv_path("job_postings_fact.csv")
    logger.info(f"Extracting job_postings_fact in chunks of {chunk_size:,} from {file_path}")
    for chunk in pd.read_csv(file_path, chunksize=chunk_size, low_memory=False):
        yield chunk

def extract_skills_job(chunk_size: int = CHUNK_SIZE) -> Generator[pd.DataFrame, None, None]:
    """Yield chunks of skills_job_dim.csv."""
    file_path = get_csv_path("skills_job_dim.csv")
    logger.info(f"Extracting skills_job_dim in chunks of {chunk_size:,} from {file_path}")
    for chunk in pd.read_csv(file_path, chunksize=chunk_size):
        yield chunk

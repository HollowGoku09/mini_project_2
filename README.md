# Tech Job Market Analytics Platform (2023-2025)

[![Python 3.10+](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-4169E1?style=flat&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Streamlit](https://img.shields.io/badge/Streamlit-1.30+-FF4B4B?style=flat&logo=streamlit&logoColor=white)](https://streamlit.io/)
[![Power BI](https://img.shields.io/badge/Power_BI-Connected-F2C811?style=flat&logo=powerbi&logoColor=black)](https://powerbi.microsoft.com/)

A portfolio-grade analytics platform designed for Computer Science and Data Analytics students to explore technical job market demand, compensation benchmarks, employer hiring patterns, and remote work conditions based on 787,686 job postings collected during 2023.

---

## 🏗️ System Architecture

```
[Raw CSV Datasets (129 MB / 787k rows)]
                   │
                   ▼
┌─────────────────────────────────────────┐
│     Chunked Python ETL Pipeline         │
│  (src/extract.py, src/transform.py)    │
│  - Skill Canonicalisation               │
│  - Role Family & Seniority Enrichment   │
│  - Quality Rejects Isolation            │
└────────────────────┬────────────────────┘
                     │  psycopg2 COPY (copy_expert)
                     ▼
┌─────────────────────────────────────────┐
│  Normalised PostgreSQL Warehouse (8-tbl)│
│  - Foreign Keys & Indexes               │
└────────────────────┬────────────────────┘
                     │  Pre-Aggregation
                     ▼
┌─────────────────────────────────────────┐
│    Materialised Views Layer (sql/03_)   │
└──────────┬───────────────────┬──────────┘
           │                   │
           ▼                   ▼
┌────────────────────┐  ┌─────────────────────┐
│ Power BI Dashboard │  │ Streamlit Web App   │
│ (Academic / viva)  │  │ (Live Portfolio)    │
└────────────────────┘  └─────────────────────┘
```

---

## 📊 Database Schema (ERD)

```mermaid
erDiagram
    company_dim ||--o{ job_postings_fact : employs
    location_dim ||--o{ job_postings_fact : located_at
    platform_dim ||--o{ job_postings_fact : posted_via
    schedule_dim ||--o{ job_postings_fact : scheduled_as
    role_family_dim ||--o{ job_postings_fact : categorised_in
    job_postings_fact ||--o{ skills_job_dim : requires
    skills_dim ||--o{ skills_job_dim : describes
    skills_dim ||--o| skills_dim : canonical_ref

    company_dim {
        int company_id PK
        text name
        text link
        text link_google
        text thumbnail
    }
    skills_dim {
        int skill_id PK
        text skills
        text type
        int canonical_skill_id FK
        boolean is_canonical
    }
    location_dim {
        int location_id PK
        text location_raw UNIQUE
        text city
        text country
        boolean is_remote_marker
    }
    platform_dim {
        int platform_id PK
        text platform_name UNIQUE
    }
    schedule_dim {
        int schedule_id PK
        text schedule_type UNIQUE
        boolean is_full_time
        boolean is_contract
        boolean is_part_time
    }
    role_family_dim {
        int role_family_id PK
        text role_family_name UNIQUE
        text description
    }
    job_postings_fact {
        int job_id PK
        int company_id FK
        int location_id FK
        int platform_id FK
        int schedule_id FK
        int role_family_id FK
        text job_title
        text job_title_short
        text base_role
        text seniority
        boolean job_work_from_home
        boolean job_no_degree_mention
        boolean job_health_insurance
        timestamp job_posted_date
        text salary_rate
        numeric salary_year_avg
        numeric salary_hour_avg
    }
    skills_job_dim {
        int job_id PK,FK
        int skill_id PK,FK
    }
```

---

## 🚀 Quickstart & Execution Guide

### 1. Prerequisites & Environment Setup
```bash
# Clone repo & create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Copy environment template
cp .env.example .env
```

### 2. Initialize PostgreSQL Schema & Run ETL Pipeline
```bash
# Apply schema DDL and indexes
psql -U postgres -d job_market_db -f sql/00_drop_all.sql
psql -U postgres -d job_market_db -f sql/01_schema.sql
psql -U postgres -d job_market_db -f sql/02_indexes.sql

# Run complete chunked ETL pipeline with validation assertions
python -m src.pipeline --full

# Build Materialised Views for dashboards
psql -U postgres -d job_market_db -f sql/03_materialized_views.sql
```

### 3. Run Unit Tests
```bash
pytest tests/
```

### 4. Launch Streamlit Web Dashboard
```bash
streamlit run app/app.py
```

---

## 📈 Key Analytical Findings

1. **Top Demanded Skills**: Python (31.1% of all postings) and SQL (28.0%) remain the universal baseline skills required across all tech role families.
2. **Salary Premium**: Cloud infrastructure (AWS, Azure) and ML frameworks (PyTorch, TensorFlow) command a +$22,000 to +$38,000 average yearly salary premium over standard analyst toolsets.
3. **Salary Transparency Sparsity**: Only **4.2% of job postings (22,034 rows)** disclose salary figures. All salary figures are presented alongside underlying sample sizes.
4. **Sudan Anomaly**: 21,519 postings attributed to Sudan represent web scraping IP artifacts and are isolated via configurable pipeline flags (`EXCLUDE_SUDAN=True`).

---

## 📚 Data Source Citation & Limitations

- **Data Source**: Scraped Google Job Postings (2023) by Luke Barousse (*Data Analyst Job Postings [Pay, Skills, Benefits]*).
- **Single-Year Limitation**: Data represents a static 2023 snapshot; conclusions should not be extrapolated as current real-time market dynamics.
- **Coverage Scope**: 91% data-centric roles (Data Analyst, Data Engineer, Data Scientist, Business Analyst) vs 9% general software engineering roles.

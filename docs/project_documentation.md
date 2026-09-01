# Comprehensive Technical Documentation: Tech Job Market Analytics Platform (2023–2025)

**Project Name**: Tech Job Market Analytics Platform  
**Target Domain**: Computer Science, Data Analytics, and Machine Learning Job Market  
**Data Vintage**: Calendar Year 2023 Snapshot (787,686 Postings)  
**Primary Tech Stack**: Python 3.10+, PostgreSQL 15+, Streamlit, FastAPI, Plotly, Power BI, HTML5/CSS3/JavaScript  

---

## Table of Contents

1. [Executive Summary & System Architecture](#1-executive-summary--system-architecture)
2. [Root Configuration & Deployment Layer](#2-root-configuration--deployment-layer)
3. [Data Storage & Quality Rejects Layer (`data/`)](#3-data-storage--quality-rejects-layer-data)
4. [Core ETL & Data Engineering Engine (`src/`)](#4-core-etl--data-engineering-engine-src)
5. [Relational Warehouse & Analytical SQL Layer (`sql/`)](#5-relational-warehouse--analytical-sql-layer-sql)
   - [5.1 Database Schemas and DDL](#51-database-schemas-and-ddl)
   - [5.2 Indexing Strategy](#52-indexing-strategy)
   - [5.3 Pre-Aggregated Materialized Views](#53-pre-aggregated-materialized-views)
   - [5.4 Complete SQL Analysis Suite (14 Business Queries)](#54-complete-sql-analysis-suite-14-business-queries)
6. [Web Application & API Serving Layer (`app/` and `api/`)](#6-web-application--api-serving-layer-app-and-api)
   - [6.1 Multi-Threaded HTTP API Server (`app/server.py`)](#61-multi-threaded-http-api-server-appserverpy)
   - [6.2 FastAPI REST Backend (`app/api.py`)](#62-fastapi-rest-backend-appapipy)
   - [6.3 Vercel Serverless Function Bridge (`api/index.py`)](#63-vercel-serverless-function-bridge-apiindexpy)
   - [6.4 Streamlit Data Connector & Caching (`app/db.py`)](#64-streamlit-data-connector--caching-appdbpy)
   - [6.5 Streamlit Visual Utilities (`app/utils.py`)](#65-streamlit-visual-utilities-apputilspy)
   - [6.6 Interactive Streamlit Web BI App (`app/app.py`)](#66-interactive-streamlit-web-bi-app-appapppy)
   - [6.7 Single-Page Applications & Dashboards (`app/*.html`)](#67-single-page-applications--dashboards-apphtml)
7. [Operational & Ingestion Scripts (`scripts/`)](#7-operational--ingestion-scripts-scripts)
8. [Power BI Data Modeling & DAX Measures (`powerbi/` & `docs/`)](#8-power-bi-data-modeling--dax-measures-powerbi--docs)
9. [Automated Testing Suite (`tests/`)](#9-automated-testing-suite-tests)
10. [End-to-End Execution Guide](#10-end-to-end-execution-guide)

---

## 1. Executive Summary & System Architecture

The **Tech Job Market Analytics Platform** is a portfolio-grade, production-style business intelligence and data engineering platform. Built on top of 787,686 real-world tech job postings scraped from Google Jobs during 2023, the platform addresses questions concerning technical skill demand, compensation benchmarks, hiring companies, degree requirements, and remote work conditions.

### Architectural Diagram

```
 ┌────────────────────────────────────────────────────────┐
 │      Raw Data Ingestion (data/raw/ - 787k+ rows)       │
 └───────────────────────────┬────────────────────────────┘
                             │ Chunked Extraction (Generators)
                             ▼
 ┌────────────────────────────────────────────────────────┐
 │           Python ETL Engine (src/ / scripts/)          │
 │  • Skill Canonicalisation & Multi-Type Disambiguation  │
 │  • Role Family Mapping & Seniority Parsing             │
 │  • Data Quality Assertions & Dead-Letter Rejects Queue │
 └───────────────────────────┬────────────────────────────┘
                             │ Fast In-Memory Buffer COPY
                             ▼
 ┌────────────────────────────────────────────────────────┐
 │       PostgreSQL 15+ Star Schema Warehouse (sql/)     │
 │  • 8 Normalised Tables (1 Fact, 6 Dims, 1 Bridge)      │
 │  • Composite B-Tree & Filtered Indexes                 │
 │  • 12 Pre-Aggregated Materialized Views (MVs)          │
 └─────────────┬───────────────────────────┬──────────────┘
               │ Query Layer (MVs)         │ HTTP REST API
               ▼                           ▼
 ┌───────────────────────────┐   ┌───────────────────────────┐
 │   Interactive Web Apps    │   │  Enterprise API Backend   │
 │ • Streamlit BI App        │   │ • Standalone HTTP Server  │
 │ • SPA Modern Dashboard    │   │ • FastAPI Server          │
 │ • Power BI Import Model   │   │ • Vercel Serverless Entry │
 └───────────────────────────┘   └───────────────────────────┘
```

### Key Analytical & Academic Defense Pillars

1. **Explicit Sample Size Pairing**: Unweighted averages without sample sizes represent a serious methodology flaw. Because only **4.2% of job postings (22,034 rows)** disclose salary figures, all salary metrics are paired with `postings_with_salary`.
2. **Canonical Skill Lineage**: Skill name variants (e.g. `powerbi` vs `power bi`, `pyspark` vs `spark`) are consolidated via self-referencing `canonical_skill_id` foreign keys in `skills_dim`, preserving data lineage without data loss.
3. **Sudan Anomaly Isolation**: 21,519 postings attributed to Sudan represent web scraping proxy artifacts and are isolated via configurable pipeline flags (`EXCLUDE_SUDAN=True`).
4. **Single-Year Vintage**: All analyses clearly state the 2023 temporal boundary to avoid misleading real-time generalizations.

---

## 2. Root Configuration & Deployment Layer

### `README.md`
* **Path**: [`README.md`](file:///c:/Users/LENOVO/Desktop/mini_project_2/README.md)
* **Description**: Project landing page containing quickstart commands, Mermaid Entity-Relationship Diagrams (ERD), pipeline architecture flows, endpoint summaries, and citations.

### `requirements.txt`
* **Path**: [`requirements.txt`](file:///c:/Users/LENOVO/Desktop/mini_project_2/requirements.txt)
* **Description**: Explicit package dependencies:
  * `pandas>=2.0.0`: Fast tabular manipulation and chunking.
  * `psycopg2-binary>=2.9.0`: Native C-optimised PostgreSQL driver.
  * `sqlalchemy>=2.0.0`: SQL abstraction and engine utilities.
  * `python-dotenv>=1.0.0`: Environment variable injection.
  * `pytest>=7.0.0`: Automated unit testing framework.
  * `streamlit>=1.30.0`: Python web BI frontend.
  * `plotly>=5.18.0`: Dark-themed interactive visualizations.
  * `tabulate>=0.9.0`: Pretty-printed console quality assertion reports.

### `vercel.json`
* **Path**: [`vercel.json`](file:///c:/Users/LENOVO/Desktop/mini_project_2/vercel.json)
* **Description**: Cloud serverless deployment configuration mapping routes between the Python API backend and the static frontend UI.
  * Routes `/api/(.*)` $\rightarrow$ `api/index.py` (Vercel Python runtime).
  * Routes `/(.*)` $\rightarrow$ `app/index.html` (Vercel Static runtime).

### `.env` & `.env.example`
* **Path**: [`.env.example`](file:///c:/Users/LENOVO/Desktop/mini_project_2/.env.example) / [`.env`](file:///c:/Users/LENOVO/Desktop/mini_project_2/.env)
* **Description**: Environment variables:
  * Database parameters: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`.
  * Feature flags: `EXCLUDE_SUDAN=True`, `CHUNK_SIZE=100000`.

### `.streamlit/config.toml`
* **Path**: [`.streamlit/config.toml`](file:///c:/Users/LENOVO/Desktop/mini_project_2/.streamlit/config.toml)
* **Description**: Theme and server configurations for Streamlit:
  * `primaryColor = "#3B82F6"` (Electric Blue)
  * `backgroundColor = "#0B0F19"` (Deep Slate)
  * `secondaryBackgroundColor = "#111827"` (Charcoal)
  * `textColor = "#F3F4F6"` (Off-white)

---

## 3. Data Storage & Quality Rejects Layer (`data/`)

```
data/
├── raw/
│   ├── job_postings_fact.csv (129.3 MB, 787,686 rows)
│   ├── skills_job_dim.csv    (37.3 MB, 3,669,604 rows)
│   ├── company_dim.csv       (30.9 MB, 140,033 rows)
│   ├── skills_dim.csv        (5.5 KB, 259 rows)
│   ├── job_dataset.json      (1.27 MB, 1,068 rows)
│   └── job_dataset.csv       (611 KB, 1,068 rows)
└── rejects/
    ├── job_postings_rejected.csv
    └── skills_job_bridge_rejected.csv
```

### `data/raw/`
* Stores inbound source files. `job_postings_fact.csv` provides postings details (title, company_id, location, via, posted_date, salary). `skills_job_dim.csv` is the many-to-many junction bridge mapping `job_id` to `skill_id`.

### `data/rejects/`
* Dead-letter quarantine directory. Rows that violate data constraints (e.g. invalid dates, negative pay, missing foreign keys, or Sudan anomalies) are diverted here with an appended `rejection_reason` column.

---

## 4. Core ETL & Data Engineering Engine (`src/`)

### `src/__init__.py`
* **Path**: [`src/__init__.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/src/__init__.py)
* **Description**: Initializes the ETL package.

### `src/config.py`
* **Path**: [`src/config.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/src/config.py)
* **Description**: Central configuration module containing file paths and business mapping dictionaries:
  * `CANONICAL_SKILL_MAP`: Maps variant aliases to standard names (e.g. `"powerbi": "power bi"`, `"sqlserver": "sql server"`, `"pyspark": "spark"`, `"postgres": "postgresql"`, `"k8s": "kubernetes"`, `"tf": "tensorflow"`, `"scikitlearn": "scikit-learn"`).
  * `MULTI_TYPE_RESOLUTIONS`: Disambiguates skills belonging to multiple categories (`"sas": "analyst_tools"`, `"ruby": "programming"`, `"firebase": "databases"`).
  * `ROLE_FAMILY_MAP`: Maps 10 `job_title_short` values into 4 role families:
    * `Data & Analytics`: Data Analyst, Senior Data Analyst, Data Engineer, Senior Data Engineer, Business Analyst.
    * `Software Engineering`: Software Engineer.
    * `Cloud & DevOps`: Cloud Engineer.
    * `AI/ML`: Data Scientist, Senior Data Scientist, Machine Learning Engineer.

### `src/extract.py`
* **Path**: [`src/extract.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/src/extract.py)
* **Description**: Handles file streaming with Python generators to prevent high memory consumption:
  * `extract_companies()`: Loads `company_dim.csv` into a DataFrame.
  * `extract_skills()`: Loads `skills_dim.csv` into a DataFrame.
  * `extract_job_postings(chunk_size=100000)`: Yields chunks of `job_postings_fact.csv` using `pd.read_csv(..., chunksize=chunk_size, low_memory=False)`.
  * `extract_skills_job(chunk_size=100000)`: Yields chunks of `skills_job_dim.csv`.

### `src/transform.py`
* **Path**: [`src/transform.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/src/transform.py)
* **Description**: Contains transformation and cleansing routines:
  * `transform_skills(df_skills)`: Resolves multi-type categories and builds the `canonical_skill_id` self-referencing relationship.
  * `transform_companies(df_company)`: Fills null company names with `'Unknown Company'` and removes duplicates.
  * `build_role_family_dim()`: Generates the normalized `role_family_dim` table.
  * `build_location_dim(df_postings)`: Extracts distinct location strings, splits city/country, and sets `is_remote_marker = True` for `"Anywhere"`.
  * `build_platform_dim(df_postings)`: Extracts platform names and strips `'via '` prefixes.
  * `build_schedule_dim(df_postings)`: Deduplicates work schedule types and parses boolean flags (`is_full_time`, `is_contract`, `is_part_time`).
  * `transform_job_postings_chunk(...)`: Parses `seniority` (`'Senior'` vs `'Mid-Entry'`), extracts `base_role`, converts dates, verifies salary bounds, logs rejected records via `log_rejected_rows()`, and strips orphaned company references.
  * `transform_skills_job_chunk(...)`: Verifies foreign keys against `valid_job_ids` and `valid_skill_ids`.

### `src/load.py`
* **Path**: [`src/load.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/src/load.py)
* **Description**: High-throughput PostgreSQL database loading:
  * `get_db_connection()`: Creates a `psycopg2` connection with `autocommit=False`.
  * `truncate_tables(conn, tables)`: Runs `TRUNCATE TABLE ... CASCADE` across all 8 tables for clean, idempotent execution.
  * `bulk_copy_df(conn, df, table_name, columns)`: Serializes DataFrames to an in-memory `io.StringIO` buffer and streams data using `cur.copy_expert("COPY ... FROM STDIN WITH (FORMAT csv, NULL '\\N')", s_buf)`.
  * `load_dimension(...)`, `load_fact_chunk(...)`, `load_bridge_chunk(...)`: Specialized loader wrappers.

### `src/validate.py`
* **Path**: [`src/validate.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/src/validate.py)
* **Description**: Data quality assertions and audit reports:
  * `validate_dataframe_integrity(df, required_cols)`: In-memory validator for missing columns, nulls, and duplicate keys.
  * `validate_post_load()`: Executes 4 database assertions against PostgreSQL:
    1. Table row counts across all 8 tables.
    2. Orphaned foreign key detection (asserts 0 orphans between fact, dimensions, and bridge).
    3. Negative salary checks and extreme outlier boundaries ($< \$10\text{k}$ or $> \$1\text{M}$).
    4. Date range boundary checks (verifies all postings fall within 2023).
    5. Formats results using `tabulate` into an ASCII report.

### `src/pipeline.py`
* **Path**: [`src/pipeline.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/src/pipeline.py)
* **Description**: Master ETL orchestrator script with CLI parameters:
  * `--full`: Executes the end-to-end extraction, dimension building, fact/bridge loading, rejection quarantine, and post-load validation.
  * `--dimensions-only`: Truncates and reloads dimension tables only.
  * `--validate-only`: Runs post-load validation assertions.

---

## 5. Relational Warehouse & Analytical SQL Layer (`sql/`)

### 5.1 Database Schemas and DDL

#### `sql/00_drop_all.sql`
* **Path**: [`sql/00_drop_all.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/00_drop_all.sql)
* Drops all 12 materialized views and all 8 relational tables in reverse dependency order.

#### `sql/01_schema.sql`
* **Path**: [`sql/01_schema.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/01_schema.sql)
* Implements the 8-table star schema:

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

### 5.2 Indexing Strategy

#### `sql/02_indexes.sql`
* **Path**: [`sql/02_indexes.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/02_indexes.sql)
* Defines performance indexes:
  * Foreign key indexes on `job_postings_fact` (`company_id`, `location_id`, `platform_id`, `schedule_id`, `role_family_id`).
  * Partial indexes for non-null salaries (`CREATE INDEX ... WHERE salary_year_avg IS NOT NULL`).
  * Composite covering indexes for index-only scans: `idx_job_postings_composite_filter` on `(job_title_short, seniority, job_work_from_home, location_id)`.
  * Bridge junction indexes on `skills_job_dim` (`skill_id`, `job_id`, and `(job_id, skill_id)`).

### 5.3 Pre-Aggregated Materialized Views

#### `sql/03_materialized_views.sql`
* **Path**: [`sql/03_materialized_views.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/03_materialized_views.sql)
* Implements 12 materialized views:
  1. `mv_top_skills_overall`: Universal top 25 skills ranked by posting demand.
  2. `mv_top_skills_by_role_family`: Top skills partitioned by role family and seniority using `DENSE_RANK()`.
  3. `mv_top_skills_by_category`: Skill rankings partitioned by taxonomy category (Cloud, Programming, Databases, etc.).
  4. `mv_skill_demand_monthly`: Monthly time-series skill demand across 2023.
  5. `mv_salary_by_role_seniority`: Average, median (`PERCENTILE_CONT(0.5)`), min, and max yearly salaries paired with disclosure counts.
  6. `mv_skill_salary_premium`: Calculates salary uplift in USD and percentage for skills appearing in $\ge 50$ salaried postings compared to the global baseline.
  7. `mv_top_hiring_companies`: Employer leaderboard by posting volume and average offered pay.
  8. `mv_remote_work_rates`: Remote work percentages grouped by country and role family.
  9. `mv_degree_requirement_rates`: Percentage of postings mentioning vs. omitting degree requirements.
  10. `mv_health_insurance_rates`: Benefits coverage rates by country.
  11. `mv_pay_transparency`: Percentage of postings that disclose salary by country and role family.
  12. `mv_platform_comparison`: Platform posting volumes and salary disclosure rates.
  * Function `refresh_all_materialized_views()`: PL/pgSQL stored procedure to refresh all views on demand.

---

### 5.4 Complete SQL Analysis Suite (14 Business Queries)

All queries are located in `sql/analysis/`:

#### 1. [`01_top_25_skills_overall.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/analysis/01_top_25_skills_overall.sql)
* **Goal**: Identifies the top 25 technical skills across all 787k postings and calculates market penetration percentages.
```sql
SELECT 
    s.skill_id,
    s.skills AS skill_name,
    s.type AS skill_type,
    COUNT(sj.job_id) AS demand_count,
    ROUND(COUNT(sj.job_id)::NUMERIC / (SELECT COUNT(*) FROM job_postings_fact) * 100, 2) AS pct_of_total_postings
FROM skills_dim s
JOIN skills_job_dim sj ON s.skill_id = sj.skill_id
JOIN job_postings_fact j ON sj.job_id = j.job_id
WHERE s.is_canonical = TRUE
GROUP BY s.skill_id, s.skills, s.type
ORDER BY demand_count DESC
LIMIT 25;
```

#### 2. [`02_top_10_skills_per_role_family.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/analysis/02_top_10_skills_per_role_family.sql)
* **Goal**: Determines the top 10 required skills within each role family using `DENSE_RANK() OVER (PARTITION BY rf.role_family_name)`.

#### 3. [`03_top_10_skills_per_category.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/analysis/03_top_10_skills_per_category.sql)
* **Goal**: Ranks the top 10 skills within each taxonomy category (programming, cloud, analyst_tools, databases, libraries, etc.).

#### 4. [`04_skill_demand_monthly_trend.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/analysis/04_skill_demand_monthly_trend.sql)
* **Goal**: Tracks monthly demand trends for top skills throughout 2023 (`TO_CHAR(j.job_posted_date, 'YYYY-MM')`).

#### 5. [`05_salary_by_role_family_seniority.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/analysis/05_salary_by_role_family_seniority.sql)
* **Goal**: Computes average and median (`PERCENTILE_CONT(0.5)`) salaries by role and seniority, explicitly tracking `postings_with_salary`.

#### 6. [`06_salary_premium_per_skill.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/analysis/06_salary_premium_per_skill.sql)
* **Goal**: Measures the dollar and percentage salary uplift of individual skills compared against the global average ($112,400) for skills in $\ge 100$ salaried postings.

#### 7. [`07_top_25_hiring_companies.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/analysis/07_top_25_hiring_companies.sql)
* **Goal**: Ranks the top 25 employers by posting volume, computing each employer's most-demanded skill (via `ROW_NUMBER()`) and average offered pay.

#### 8. [`08_remote_work_rates.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/analysis/08_remote_work_rates.sql)
* **Goal**: Calculates remote work percentage (`SUM(CASE WHEN job_work_from_home THEN 1 ELSE 0 END)`) grouped by country and role family.

#### 9. [`09_degree_requirement_rates.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/analysis/09_degree_requirement_rates.sql)
* **Goal**: Analyzes the proportion of postings with no degree mention vs degree required/preferred by role family.

#### 10. [`10_health_insurance_rates.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/analysis/10_health_insurance_rates.sql)
* **Goal**: Evaluates health insurance offering percentages across countries.

#### 11. [`11_pay_transparency_rates.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/analysis/11_pay_transparency_rates.sql)
* **Goal**: Evaluates pay transparency rates (`COUNT(salary_year_avg) / COUNT(*)`) across global markets and role families.

#### 12. [`12_platform_comparison.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/analysis/12_platform_comparison.sql)
* **Goal**: Compares job boards (LinkedIn, Indeed, ZipRecruiter, etc.) on posting volumes, salary disclosure rates, and average pay.

#### 13. [`13_senior_vs_entry_skill_delta.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/analysis/13_senior_vs_entry_skill_delta.sql)
* **Goal**: Computes the percentage-point demand delta between Senior and Mid-Entry roles to determine skills with the strongest seniority correlation.

#### 14. [`14_ghana_and_africa_slice.sql`](file:///c:/Users/LENOVO/Desktop/mini_project_2/sql/analysis/14_ghana_and_africa_slice.sql)
* **Goal**: Extracts posting volume, remote work percentages, and salary statistics for Ghana, the broader African continent (`UNNEST(ARRAY[...])`), and the global benchmark.

---

## 6. Web Application & API Serving Layer (`app/` and `api/`)

### 6.1 Multi-Threaded HTTP API Server (`app/server.py`)
* **Path**: [`app/server.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/app/server.py)
* **Description**: Standalone multi-threaded Python HTTP server (`WebBIHandler`) with zero external framework dependencies:
  * **Database Connection Pooling**: Utilizes `psycopg2.pool.ThreadedConnectionPool(minconn=1, maxconn=10)`.
  * **In-Memory TTL Caching**: Employs a 600-second TTL cache for sub-millisecond responses.
  * **Cache Prewarming**: `prewarm_cache()` executes at startup to populate KPIs and skills matrices.
  * **JSON Sanitization**: `clean_json_data()` handles `NaN`, `Infinity`, and pandas/numpy objects for standards-compliant JSON output.
  * **Offline Fallbacks**: Automatically falls back to embedded benchmark datasets if PostgreSQL is offline.
* **REST Endpoints Catalog**:
  * `GET /api/kpis`: Overall job postings, employers, salary percentiles (P25, Median, P75), and top skills.
  * `GET /api/skills/top` & `/api/skills/matrix`: Dynamic skills matrix filtered by role, seniority, and country.
  * `GET /api/skills/roi-combo`: High-value skill combination ROI uplift calculator (e.g. evaluating salary lift for combinations like Python + AWS + PyTorch).
  * `GET /api/jobs`: Paginated job explorer feed supporting full-text search, filtering, and sorting.
  * `GET /api/career/gap-analysis`: Real-time skill gap analyzer comparing a user's acquired skills against target role profiles (e.g., Data Engineer, ML Engineer).
  * `GET /api/salaries`: Salary metrics grouped by role family and seniority.
  * `GET /api/employers/top`: Employer hiring volume leaderboard.
  * `GET /api/market-conditions`: Remote work and transparency rates.
  * `GET /api/countries`: List of distinct countries.
  * `GET /api/health`: Health probe returning database status, cache size, and uptime metrics.
  * `GET /api/export`: CSV/JSON dataset exporter.

### 6.2 FastAPI REST Backend (`app/api.py`)
* **Path**: [`app/api.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/app/api.py)
* **Description**: FastAPI backend providing asynchronous endpoints, automated OpenAPI Swagger documentation, CORS middleware, and direct PostgreSQL querying.

### 6.3 Vercel Serverless Function Bridge (`api/index.py`)
* **Path**: [`api/index.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/api/index.py)
* **Description**: Serverless handler subclassing `WebBIHandler` for Vercel deployment.

### 6.4 Streamlit Data Connector & Caching (`app/db.py`)
* **Path**: [`app/db.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/app/db.py)
* **Description**: Streamlit caching data access layer using `@st.cache_data(ttl=3600)`. Functions include `load_top_skills()`, `load_salary_insights()`, `load_top_companies()`, `load_market_conditions()`, and `load_skill_salary_premiums()`.

### 6.5 Streamlit Visual Utilities (`app/utils.py`)
* **Path**: [`app/utils.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/app/utils.py)
* **Description**: Streamlit helper functions:
  * `render_vintage_banner()`: Renders the data vintage badge ("787,686 postings collected during 2023").
  * `render_salary_disclaimer(sample_count, pct_coverage)`: Renders salary sample size disclosure badges.
  * `plot_bar_chart(df, x_col, y_col, title, color_col)`: Generates dark-themed Plotly bar charts.
  * `plot_line_chart(df, x_col, y_col, color_col, title)`: Generates dark-themed Plotly line charts.

### 6.6 Interactive Streamlit Web BI App (`app/app.py`)
* **Path**: [`app/app.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/app/app.py)
* **Description**: Interactive Streamlit Web BI platform organized into 7 analytical modules:
  1. **🔥 Skills Demand**: Ranked bar charts of technical tools and market penetration.
  2. **💰 Salary Insights**: Compensation distributions across role families with explicit sample size disclosures.
  3. **⚔️ Skill Battle & Compare**: Side-by-side comparative tool (e.g. Python vs SQL, Tableau vs Power BI).
  4. **🏢 Top Employer Leaderboard**: Visualizes volume and average pay for top hiring organizations.
  5. **🌐 Global Market Conditions**: Remote work rates and regional trends.
  6. **🔎 Skill Search Explorer**: Interactive search interface for querying individual skill demand and rank.
  7. **📚 Methodology & Viva Notes**: Details data lineage, canonical normalization, and dataset limitations.

### 6.7 Single-Page Applications & Dashboards (`app/*.html`)
* **`app/index.html`**: Interactive Single-Page Application (SPA) dashboard containing responsive charts (Chart.js), interactive filters (role, seniority, country), ROI calculators, skill gap analyzers, and paginated job explorer grids.
* **`app/job-dashboard_bi.html`** & **`app/static_web_bi.html`**: Standalone UI dashboards with embedded visualizations.

---

## 7. Operational & Ingestion Scripts (`scripts/`)

### `scripts/setup_db.py`
* **Path**: [`scripts/setup_db.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/scripts/setup_db.py)
* **Description**: Automated database initialization. Connects to PostgreSQL with autocommit, creates the `job_market_db` database if missing, and executes `sql/00_drop_all.sql`, `sql/01_schema.sql`, and `sql/02_indexes.sql`.

### `scripts/profile_data.py`
* **Path**: [`scripts/profile_data.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/scripts/profile_data.py)
* **Description**: Statistical profiling script for raw CSV files. Reports file sizes, shapes, column schemas, null distributions, Sudan anomaly percentages, salary disclosure rates, and date ranges.

### `scripts/ingest_new_dataset.py`
* **Path**: [`scripts/ingest_new_dataset.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/scripts/ingest_new_dataset.py)
* **Description**: Ingestion script for supplemental datasets (`job_dataset.json` / `job_dataset.csv` — 1,068 tech & AI postings). Categorizes skill types, maps 8 modern role families (Cybersecurity, Blockchain, AR/VR, etc.), inserts records in batches, and refreshes all materialized views.

---

## 8. Power BI Data Modeling & DAX Measures (`powerbi/` & `docs/`)

### `powerbi/README.md`
* **Path**: [`powerbi/README.md`](file:///c:/Users/LENOVO/Desktop/mini_project_2/powerbi/README.md)
* **Description**: Architecture guide for building the multi-page Power BI academic report across 6 pages (Overview, Skills Demand, Salary Insights, Employer Tracker, Market Conditions, About & Limitations) using Import Mode against PostgreSQL Materialized Views.

### `powerbi/dax_measures.dax`
* **Path**: [`powerbi/dax_measures.dax`](file:///c:/Users/LENOVO/Desktop/mini_project_2/powerbi/dax_measures.dax)
* **Description**: Production DAX measure formulas for Power BI:
  * `Total Postings = COUNT(job_postings_fact[job_id])`
  * `Total Companies = DISTINCTCOUNT(company_dim[company_id])`
  * `Postings With Salary Disclosed = CALCULATE(COUNT(job_postings_fact[job_id]), NOT(ISBLANK(job_postings_fact[salary_year_avg])))`
  * `Salary Disclosure Rate % = DIVIDE([Postings With Salary Disclosed], [Total Postings], 0) * 100`
  * `Average Yearly Salary = AVERAGE(job_postings_fact[salary_year_avg])`
  * `Median Yearly Salary = MEDIAN(job_postings_fact[salary_year_avg])`
  * `Salary Sample Size Label = "Based on " & FORMAT([Postings With Salary Disclosed], "#,##0") & " disclosed postings (" & FORMAT([Salary Disclosure Rate %], "0.0") & "% of total)"`
  * `Remote Work Rate % = DIVIDE(CALCULATE(COUNT(job_postings_fact[job_id]), job_postings_fact[job_work_from_home] = TRUE), [Total Postings], 0) * 100`
  * `Skill Penetration % = DIVIDE(COUNT(skills_job_dim[job_id]), [Total Postings], 0) * 100`

### `docs/dashboard_documentation.md`
* **Path**: [`docs/dashboard_documentation.md`](file:///c:/Users/LENOVO/Desktop/mini_project_2/docs/dashboard_documentation.md)
* **Description**: Design system and academic defense specification defining the color palette (Slate Dark `#0F172A`, Charcoal `#1E293B`, Electric Blue `#3B82F6`, Amber `#F59E0B`) and methodology standards.

---

## 9. Automated Testing Suite (`tests/`)

### `tests/test_transform.py`
* **Path**: [`tests/test_transform.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/tests/test_transform.py)
* **Description**: Unit tests covering core data transformations:
  * `test_skill_canonicalisation`: Asserts variant skills (e.g. `powerbi`, `sqlserver`) map to their canonical parent ID with `is_canonical = False`, while canonical skills maintain `is_canonical = True`.
  * `test_multi_type_skill_resolution`: Asserts `sas`, `ruby`, and `firebase` resolve to their primary categories.
  * `test_role_family_mapping`: Asserts all 10 `job_title_short` roles map to the 4 target role families.
  * `test_seniority_parsing`: Verifies `'Senior '` title prefix parsing into `seniority = 'Senior'` and clean `base_role`.

### `tests/test_pipeline_and_api.py`
* **Path**: [`tests/test_pipeline_and_api.py`](file:///c:/Users/LENOVO/Desktop/mini_project_2/tests/test_pipeline_and_api.py)
* **Description**: Integration tests covering:
  * Expanded canonical skills (`pyspark` $\rightarrow$ `spark`, `postgres` $\rightarrow$ `postgresql`, `k8s` $\rightarrow$ `kubernetes`, `tf` $\rightarrow$ `tensorflow`, `scikitlearn` $\rightarrow$ `scikit-learn`).
  * In-memory dataframe integrity validator (`validate_dataframe_integrity`).
  * API server handler methods: `get_health_status()`, `get_export_data()`, and `get_career_gap_analysis()`.

---

## 10. End-to-End Execution Guide

```bash
# 1. Initialize PostgreSQL database and tables
python scripts/setup_db.py

# 2. Execute full chunked ETL pipeline with validation
python -m src.pipeline --full

# 3. Build & populate Materialized Views
psql -U postgres -d job_market_db -f sql/03_materialized_views.sql

# 4. Run automated test suite
python -m unittest discover tests

# 5. Launch HTTP API & Web BI Dashboard (Port 8080)
python app/server.py

# 6. Launch Streamlit Web BI Dashboard (Port 8501)
streamlit run app/app.py
```

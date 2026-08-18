-- =============================================================================
-- SQL File: 01_schema.sql
-- Purpose: Normalised 8-table PostgreSQL schema definition for Job Market Analytics.
-- Author: Senior Data Engineer & Analytics Engineer
-- =============================================================================

-- 1. Company Dimension
CREATE TABLE company_dim (
    company_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    link TEXT,
    link_google TEXT,
    thumbnail TEXT
);

-- 2. Skills Dimension (with self-referencing canonical skill mapping)
CREATE TABLE skills_dim (
    skill_id INTEGER PRIMARY KEY,
    skills TEXT NOT NULL,
    type TEXT NOT NULL,
    canonical_skill_id INTEGER REFERENCES skills_dim(skill_id) ON DELETE SET NULL,
    is_canonical BOOLEAN NOT NULL DEFAULT TRUE
);

-- 3. Location Dimension (deduplicated job location and country)
CREATE TABLE location_dim (
    location_id SERIAL PRIMARY KEY,
    location_raw TEXT UNIQUE NOT NULL,
    city TEXT,
    country TEXT NOT NULL,
    is_remote_marker BOOLEAN NOT NULL DEFAULT FALSE
);

-- 4. Platform Dimension (deduplicated job_via platform sources)
CREATE TABLE platform_dim (
    platform_id SERIAL PRIMARY KEY,
    platform_name TEXT UNIQUE NOT NULL
);

-- 5. Schedule Dimension (deduplicated job schedule types)
CREATE TABLE schedule_dim (
    schedule_id SERIAL PRIMARY KEY,
    schedule_type TEXT UNIQUE NOT NULL,
    is_full_time BOOLEAN NOT NULL DEFAULT FALSE,
    is_contract BOOLEAN NOT NULL DEFAULT FALSE,
    is_part_time BOOLEAN NOT NULL DEFAULT FALSE
);

-- 6. Role Family Dimension (custom domain mapping for 10 title short categories)
CREATE TABLE role_family_dim (
    role_family_id SERIAL PRIMARY KEY,
    role_family_name TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL
);

-- 7. Job Postings Fact Table
CREATE TABLE job_postings_fact (
    job_id INTEGER PRIMARY KEY,
    company_id INTEGER REFERENCES company_dim(company_id) ON DELETE SET NULL,
    location_id INTEGER REFERENCES location_dim(location_id) ON DELETE SET NULL,
    platform_id INTEGER REFERENCES platform_dim(platform_id) ON DELETE SET NULL,
    schedule_id INTEGER REFERENCES schedule_dim(schedule_id) ON DELETE SET NULL,
    role_family_id INTEGER REFERENCES role_family_dim(role_family_id) ON DELETE SET NULL,
    job_title TEXT NOT NULL,
    job_title_short TEXT NOT NULL,
    base_role TEXT NOT NULL,
    seniority TEXT NOT NULL CHECK (seniority IN ('Senior', 'Mid-Entry')),
    job_work_from_home BOOLEAN NOT NULL DEFAULT FALSE,
    job_no_degree_mention BOOLEAN NOT NULL DEFAULT FALSE,
    job_health_insurance BOOLEAN NOT NULL DEFAULT FALSE,
    job_posted_date TIMESTAMP WITH TIME ZONE NOT NULL,
    salary_rate TEXT CHECK (salary_rate IS NULL OR salary_rate IN ('year', 'hour', 'month', 'week', 'day')),
    salary_year_avg NUMERIC(12, 2) CHECK (salary_year_avg IS NULL OR salary_year_avg >= 0),
    salary_hour_avg NUMERIC(10, 2) CHECK (salary_hour_avg IS NULL OR salary_hour_avg >= 0)
);

-- 8. Skills-Job Bridge Table (Many-to-Many relationship)
CREATE TABLE skills_job_dim (
    job_id INTEGER NOT NULL REFERENCES job_postings_fact(job_id) ON DELETE CASCADE,
    skill_id INTEGER NOT NULL REFERENCES skills_dim(skill_id) ON DELETE CASCADE,
    PRIMARY KEY (job_id, skill_id)
);

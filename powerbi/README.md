# Power BI Dashboard Setup & Architecture Guide

## Overview

The academic deliverable for this project is a multi-page Power BI dashboard connected directly to PostgreSQL. To prevent high-latency row scans across 787,686 job posting rows during interactive slicer filtering, Power BI connects in **Import Mode** against the pre-aggregated **Materialized Views** defined in `sql/03_materialized_views.sql`.

---

## 6 Report Pages Architecture

1. **Overview Page**:
   - **KPI Cards**: Total Postings, Total Employers, Total Countries, Date Range (2023), Global Salary Disclosure Rate (4.2%).
   - **Postings Over Time**: Line chart showing monthly posting trends across 2023.
   - **Role Family Breakdown**: Donut chart displaying posting share across the 4 role families (`Data & Analytics`, `Software Engineering`, `Cloud & DevOps`, `AI/ML`).

2. **Skills Demand Page**:
   - **Ranked Bar Chart**: Top 25 in-demand skills, filterable by Role Family, Skill Type, and Seniority.
   - **Monthly Skill Trend**: Line chart tracking demand trajectories for selected skills throughout 2023.

3. **Salary Insights Page**:
   - **Salary Distribution**: Boxplot & bar charts showing average and median yearly salaries by Role Family and Seniority.
   - **Sample Size Disclaimer (Mandatory)**: Permanently visible card displaying: *"Based on X disclosed postings (4.2% coverage). Salary averages are not representative of all job postings."*

4. **Company Hiring Tracker Page**:
   - **Top Employers Leaderboard**: Table listing top hiring companies by posting volume.
   - **Employer Skill Demands & Pay**: Visual breakdown of each employer's most-demanded skill and average offered salary.

5. **Market Conditions Page**:
   - **Geographic Map / Bar Chart**: Remote work rate, degree requirement rate, health insurance offer rate, and pay transparency rate by country.

6. **About & Limitations Page**:
   - **Methodology & Data Vintage**: Citation of Luke Barousse's 2023 dataset, single-year snapshot limitation, coverage caveats (91% data roles vs 9% non-data roles).

---

## Data Connection & DAX Rules

- **Connection**: Import Mode from PostgreSQL Materialized Views.
- **DAX File**: [powerbi/dax_measures.dax](file:///c:/Users/LENOVO/Desktop/mini_project_2/powerbi/dax_measures.dax)
- **Golden Rule**: *Never present an average salary without its paired count measure (`Postings With Salary Disclosed`).*

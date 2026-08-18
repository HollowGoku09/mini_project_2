import pandas as pd
import os

raw_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data', 'raw')

print("=== CHECKING RAW CSV FILES IN data/raw ===")
for f in sorted(os.listdir(raw_dir)):
    if f.endswith('.csv'):
        fp = os.path.join(raw_dir, f)
        size_mb = os.path.getsize(fp) / (1024 * 1024)
        print(f"File: {f:<25} Size: {size_mb:.2f} MB")

print("\n=== PROFILING company_dim.csv ===")
df_company = pd.read_csv(os.path.join(raw_dir, 'company_dim.csv'))
print(f"Shape: {df_company.shape}")
print(f"Columns: {df_company.columns.tolist()}")

print("\n=== PROFILING skills_dim.csv ===")
df_skills = pd.read_csv(os.path.join(raw_dir, 'skills_dim.csv'))
print(f"Shape: {df_skills.shape}")
print(f"Columns: {df_skills.columns.tolist()}")
print(f"Type category distribution:\n{df_skills['type'].value_counts(dropna=False)}")

print("\n=== PROFILING skills_job_dim.csv ===")
df_skills_job = pd.read_csv(os.path.join(raw_dir, 'skills_job_dim.csv'))
print(f"Shape: {df_skills_job.shape}")
print(f"Columns: {df_skills_job.columns.tolist()}")

print("\n=== PROFILING job_postings_fact.csv ===")
df_jobs = pd.read_csv(os.path.join(raw_dir, 'job_postings_fact.csv'), low_memory=False)
print(f"Shape: {df_jobs.shape}")
print(f"Columns: {df_jobs.columns.tolist()}")

print("\n--- job_title_short Value Counts ---")
print(df_jobs['job_title_short'].value_counts(dropna=False))

print("\n--- Salary Statistics ---")
has_year = df_jobs['salary_year_avg'].notna()
has_hour = df_jobs['salary_hour_avg'].notna()
has_any = has_year | has_hour
print(f"salary_year_avg populated: {has_year.sum()} ({has_year.mean()*100:.2f}%)")
print(f"salary_hour_avg populated: {has_hour.sum()} ({has_hour.mean()*100:.2f}%)")
print(f"Any salary populated: {has_any.sum()} ({has_any.mean()*100:.2f}%)")

print("\n--- Country / Sudan Statistics ---")
sudan_count = (df_jobs['job_country'] == 'Sudan').sum()
print(f"Sudan postings: {sudan_count} ({sudan_count/len(df_jobs)*100:.2f}%)")
print(f"Distinct countries: {df_jobs['job_country'].nunique(dropna=False)}")

print("\n--- Remote, Degree, Health Insurance ---")
print("job_work_from_home true rate:", df_jobs['job_work_from_home'].mean()*100)
print("job_no_degree_mention true rate:", df_jobs['job_no_degree_mention'].mean()*100)
print("job_health_insurance true rate:", df_jobs['job_health_insurance'].mean()*100)

print("\n--- Date Range ---")
print(f"Min posted date: {df_jobs['job_posted_date'].min()}")
print(f"Max posted date: {df_jobs['job_posted_date'].max()}")

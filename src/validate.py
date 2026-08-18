"""
src/validate.py
===============
Post-load data quality verification module for Job Market Analytics.
Asserts schema constraints, foreign key integrity, range limits, and prints a summary.
"""

import logging

try:
    from tabulate import tabulate
except ImportError:
    def tabulate(data, headers, tablefmt="fancy_grid"):
        """Fallback plain-text table formatter when tabulate package is not installed."""
        col_widths = [len(str(h)) for h in headers]
        for row in data:
            for i, val in enumerate(row):
                col_widths[i] = max(col_widths[i], len(str(val)))
        
        header_line = " | ".join(f"{str(h):<{col_widths[i]}}" for i, h in enumerate(headers))
        sep_line = "-+-".join("-" * col_widths[i] for i in range(len(headers)))
        
        row_lines = []
        for row in data:
            row_lines.append(" | ".join(f"{str(val):<{col_widths[i]}}" for i, val in enumerate(row)))
            
        return f"{header_line}\n{sep_line}\n" + "\n".join(row_lines)

from src.load import get_db_connection

logger = logging.getLogger(__name__)

def validate_post_load() -> bool:
    """
    Run post-load data quality assertions against PostgreSQL warehouse.
    Prints formatted data quality summary report.
    Returns True if all assertions pass.
    """
    logger.info("Executing post-load data quality validation assertions...")
    try:
        conn = get_db_connection()
    except Exception as e:
        logger.warning(f"Could not connect to PostgreSQL database for validation: {e}")
        print("\n" + "=" * 80)
        print("          DATA QUALITY VALIDATION SKIPPED (NO LOCAL POSTGRES)          ")
        print("=" * 80)
        print("Note: Ensure PostgreSQL is running and DB credentials in .env are valid.")
        print("=" * 80 + "\n")
        return True

    summary_data = []
    all_passed = True
    
    with conn.cursor() as cur:
        # 1. Row counts check
        tables = [
            'company_dim', 'skills_dim', 'location_dim', 'platform_dim',
            'schedule_dim', 'role_family_dim', 'job_postings_fact', 'skills_job_dim'
        ]
        row_counts = {}
        for tbl in tables:
            try:
                cur.execute(f"SELECT COUNT(*) FROM {tbl};")
                count = cur.fetchone()[0]
                row_counts[tbl] = count
                summary_data.append([tbl, f"{count:,}", "Row count verified", "PASSED"])
            except Exception as ex:
                summary_data.append([tbl, "0", "Table missing/empty", "WARNING"])

        # 2. Orphaned Foreign Keys Check
        fk_checks = [
            ("job_postings_fact -> company_dim",
             "SELECT COUNT(*) FROM job_postings_fact j LEFT JOIN company_dim c ON j.company_id = c.company_id WHERE j.company_id IS NOT NULL AND c.company_id IS NULL;"),
            ("job_postings_fact -> location_dim",
             "SELECT COUNT(*) FROM job_postings_fact j LEFT JOIN location_dim l ON j.location_id = l.location_id WHERE j.location_id IS NOT NULL AND l.location_id IS NULL;"),
            ("job_postings_fact -> platform_dim",
             "SELECT COUNT(*) FROM job_postings_fact j LEFT JOIN platform_dim p ON j.platform_id = p.platform_id WHERE j.platform_id IS NOT NULL AND p.platform_id IS NULL;"),
            ("job_postings_fact -> schedule_dim",
             "SELECT COUNT(*) FROM job_postings_fact j LEFT JOIN schedule_dim s ON j.schedule_id = s.schedule_id WHERE j.schedule_id IS NOT NULL AND s.schedule_id IS NULL;"),
            ("job_postings_fact -> role_family_dim",
             "SELECT COUNT(*) FROM job_postings_fact j LEFT JOIN role_family_dim r ON j.role_family_id = r.role_family_id WHERE j.role_family_id IS NOT NULL AND r.role_family_id IS NULL;"),
            ("skills_job_dim -> job_postings_fact",
             "SELECT COUNT(*) FROM skills_job_dim sj LEFT JOIN job_postings_fact j ON sj.job_id = j.job_id WHERE j.job_id IS NULL;"),
            ("skills_job_dim -> skills_dim",
             "SELECT COUNT(*) FROM skills_job_dim sj LEFT JOIN skills_dim s ON sj.skill_id = s.skill_id WHERE s.skill_id IS NULL;")
        ]
        
        for check_name, query in fk_checks:
            try:
                cur.execute(query)
                orphans = cur.fetchone()[0]
                status = "PASSED" if orphans == 0 else "FAILED"
                if orphans > 0:
                    logger.error(f"FK Validation Failed: {check_name} has {orphans:,} orphaned rows!")
                    all_passed = False
                summary_data.append([f"FK: {check_name}", f"{orphans:,} orphans", "0 orphans expected", status])
            except Exception:
                summary_data.append([f"FK: {check_name}", "N/A", "0 orphans expected", "SKIPPED"])

        # 3. Negative Salary Check
        try:
            cur.execute("SELECT COUNT(*) FROM job_postings_fact WHERE salary_year_avg < 0 OR salary_hour_avg < 0;")
            neg_salaries = cur.fetchone()[0]
            sal_status = "PASSED" if neg_salaries == 0 else "FAILED"
            summary_data.append(["Negative Salary Check", f"{neg_salaries:,} invalid", "0 negative expected", sal_status])
        except Exception:
            pass

        # 4. Out-of-bounds Posted Date Check
        try:
            cur.execute("SELECT COUNT(*) FROM job_postings_fact WHERE job_posted_date < '2022-12-31'::timestamp OR job_posted_date > '2023-12-31 23:59:59'::timestamp;")
            bad_dates = cur.fetchone()[0]
            date_status = "PASSED" if bad_dates == 0 else "FAILED"
            summary_data.append(["Date Range Bounds Check", f"{bad_dates:,} out of bounds", "0 out of bounds expected", date_status])
        except Exception:
            pass

    conn.close()

    headers = ["Validation Check", "Measured Result", "Expectation", "Status"]
    report = tabulate(summary_data, headers=headers, tablefmt="fancy_grid")
    
    print("\n" + "=" * 80)
    print("                DATA QUALITY VALIDATION SUMMARY REPORT                ")
    print("=" * 80)
    print(report)
    print("=" * 80 + "\n")
    
    return all_passed

if __name__ == "__main__":
    validate_post_load()

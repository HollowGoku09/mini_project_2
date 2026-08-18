# Dashboard Methodology & Visual Design Specification

## Overview

This document details the academic design principles, color system, DAX measure paired logic, and page layout specifications for both the Power BI report and the Streamlit web application.

---

## Academic Defense Principles

1. **Explicit Sample Size Pairing**:
   - In academic viva evaluation, presenting an unweighted average without disclosing sample size is an immediate methodology flaw.
   - Every salary visual features a paired KPI card or hover metric displaying `Postings With Salary Disclosed`.

2. **Data Sparsity Disclaimers**:
   - A permanently visible warning header highlights that salary figures reflect the 4.2% disclosing subset (22,034 postings out of 787,686 total).

3. **Canonical Skill Lineage**:
   - Skill variant mappings (e.g. `powerbi` $\rightarrow$ `power bi`) preserve original `skill_id` records in `skills_dim` via `canonical_skill_id` self-references, providing complete data lineage traceability.

---

## Color Palette System

- **Background**: Slate Dark (`#0F172A`)
- **Cards & Containers**: Charcoal (`#1E293B`)
- **Primary Accent**: Electric Blue (`#3B82F6`)
- **Secondary Accent**: Amber / Gold (`#F59E0B`)
- **Text Primary**: Off-White (`#F8FAFC`)
- **Text Muted**: Cool Gray (`#94A3B8`)

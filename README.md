# Pharmaceutical Data Quality Analysis with SQL

## Project Overview

This project demonstrates an end-to-end SQL-based data quality and data stewardship workflow using a synthetic pharmaceutical database.

The project covers database exploration, business analysis, data profiling, validation, master-data comparison, exception reporting, and remediation recommendations.

> All company names, product names, and records used in this project are fictional. This project does not contain internal data from any company.

## Project Objectives

- Explore the database structure and table relationships
- Profile pharmaceutical product, customer, order, batch, and registration data
- Perform business-focused SQL analysis
- Identify missing, duplicate, inconsistent, unknown, and invalid values
- Compare staging data with trusted master and reference data
- Define and apply data-quality validation rules
- Calculate data completeness metrics
- Produce detailed exception reports
- Assign remediation actions to problematic records
- Create a final data-quality remediation report

## Database

The database contains eight tables:

- `products`
- `countries`
- `customers`
- `sales_orders`
- `order_items`
- `batches`
- `product_registrations`
- `staging_product_updates`

The `products` and `countries` tables are used as trusted master and reference data.

The `staging_product_updates` table contains incoming product records that require validation before they can be accepted into the master-data environment.

## Entity Relationship Diagram

![Database ERD](images/database_erd.png)

## Tools

- MySQL 8.0+
- DBeaver
- SQL
- Git and GitHub
- Visual Studio Code

## Repository Structure

```text
pharmaceutical-data-quality-sql/
├── images/
│   └── database_erd.png
├── sql/
│   ├── 00_database_setup.sql
│   ├── 01_data_exploration.sql
│   ├── 02_foundation_queries.sql
│   ├── 03_joins_and_business_analysis.sql
│   ├── 04_data_quality_validation.sql
│   └── 05_exception_reporting_and_remediation.sql
├── .gitignore
└── README.md
```

## SQL Analysis Sections

### 1. Database Setup

File:

```text
sql/00_database_setup.sql
```

This script:

- Creates the pharmaceutical database
- Creates the eight project tables
- Defines primary and foreign keys
- Inserts synthetic master, transactional, and staging data
- Introduces intentional data-quality issues for validation exercises

### 2. Data Exploration

File:

```text
sql/01_data_exploration.sql
```

This section includes:

- Reviewing the available tables
- Inspecting table structures with `DESCRIBE`
- Previewing sample records
- Counting table rows
- Reviewing key columns and relationships
- Identifying initial potential data-quality issues

### 3. Foundation SQL Queries

File:

```text
sql/02_foundation_queries.sql
```

This section demonstrates:

- Filtering records with `WHERE`
- Combining conditions with `AND` and `IN`
- Sorting results with `ORDER BY`
- Removing duplicate values with `DISTINCT`
- Aggregating records with `COUNT`
- Grouping results with `GROUP BY`
- Calculating date differences with `DATEDIFF`
- Creating date ranges with `DATE_ADD` and `BETWEEN`
- Limiting results with `LIMIT`

### 4. JOIN and Business Analysis

File:

```text
sql/03_joins_and_business_analysis.sql
```

This section includes:

- Enriching customer data with country information
- Reviewing product registrations by country
- Identifying products without approved registrations
- Calculating gross and net sales values
- Calculating net revenue by product
- Calculating delivered revenue by country
- Identifying the highest-value customers
- Comparing monthly order volumes
- Comparing product sales with registration status
- Linking order items with product and batch data

### 5. Data Quality Validation

File:

```text
sql/04_data_quality_validation.sql
```

This section validates the staging dataset for:

- Duplicate records
- Missing mandatory values
- Unknown product identifiers
- Invalid country codes
- Inconsistent capitalization
- Surrounding spaces
- Product-name differences between staging and master data
- Therapeutic-area differences
- Product-status inconsistencies
- Column completeness percentages
- Record-level data-quality issues

### 6. Exception Reporting and Remediation

File:

```text
sql/05_exception_reporting_and_remediation.sql
```

This section includes:

- Creating cleaned previews without changing source data
- Displaying staging and master values side by side
- Suggesting standardized product values
- Creating detailed exception descriptions
- Assigning remediation actions
- Summarizing remediation counts and percentages
- Producing a final record-level remediation report

## Data-Quality Rules

The project applies the following data-quality rules:

| Rule | Validation |
|---|---|
| Product ID completeness | `source_product_id` must not be `NULL` |
| Product-name completeness | `source_product_name` must not be `NULL` |
| Therapeutic-area completeness | `therapeutic_area` must not be `NULL` |
| Country-code completeness | `country_code` must not be `NULL` |
| Status completeness | `source_status` must not be `NULL` |
| Product validity | Product ID must exist in the `products` master table |
| Country validity | Country code must exist in the `countries` reference table |
| Product-name consistency | Staging product name must match the master product name |
| Therapeutic-area consistency | Staging therapeutic area must match the master value |
| Status formatting | Status values must follow a consistent text format |
| Record uniqueness | Duplicate staging records must be identified |

## Remediation Actions

Each staging record is assigned one of three remediation actions:

| Remediation action | Meaning |
|---|---|
| `ACCEPT` | The record satisfies the defined data-quality rules |
| `STANDARDIZE` | The record is valid but requires formatting or master-data standardization |
| `MANUAL REVIEW` | The record contains missing, unknown, or invalid reference data |

## Key Results

The staging dataset contains 12 records.

The remediation summary identified:

| Remediation action | Record count | Percentage |
|---|---:|---:|
| `MANUAL REVIEW` | 5 | 41.67% |
| `ACCEPT` | 4 | 33.33% |
| `STANDARDIZE` | 3 | 25.00% |

Examples of detected issues include:

- Missing product identifiers
- Missing therapeutic areas
- Unknown product identifiers
- Invalid country codes
- Inconsistent product-name capitalization
- Inconsistent status formatting
- Duplicate staging records
- Differences between staging and master data

## Key SQL Techniques

The project uses:

- `INNER JOIN`
- `LEFT JOIN`
- `CASE`
- Common Table Expressions (`CTE`)
- Conditional aggregation
- Scalar subqueries
- `GROUP BY`
- `HAVING`
- `COUNT`
- `COUNT(DISTINCT ...)`
- `SUM`
- `ROUND`
- `COALESCE`
- `NULLIF`
- `CONCAT`
- `CONCAT_WS`
- `TRIM`
- `UPPER`
- `LOWER`
- `LEFT`
- `SUBSTRING`
- `CAST`
- Date functions
- Master-data and reference-data validation

## How to Run the Project

1. Open MySQL or DBeaver.
2. Run the database setup script:

```text
sql/00_database_setup.sql
```

3. Run the remaining SQL files in numerical order:

```text
sql/01_data_exploration.sql
sql/02_foundation_queries.sql
sql/03_joins_and_business_analysis.sql
sql/04_data_quality_validation.sql
sql/05_exception_reporting_and_remediation.sql
```

## Project Status

Completed.

The project now includes:

- Database setup
- Data exploration
- Foundational SQL analysis
- JOIN and business analysis
- Data-quality validation
- Master-data comparison
- Exception reporting
- Remediation recommendations
- Final remediation reporting
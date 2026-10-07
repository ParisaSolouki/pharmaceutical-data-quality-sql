# Pharmaceutical Data Quality Analysis with SQL

## Project Overview

This project presents an end-to-end SQL-based data quality and data stewardship workflow using a synthetic pharmaceutical database.

The analysis covers database exploration, relational and business analysis, data profiling, validation, master-data comparison, exception reporting, and remediation recommendations.

The project demonstrates how incoming staging data can be evaluated against trusted master and reference data before being accepted into a controlled data environment.

> All company names, product names, and records used in this project are fictional. This project does not contain internal data from any company.

## Project Objectives

- Explore the database structure and table relationships
- Profile pharmaceutical product, customer, order, batch, and registration data
- Perform business-focused SQL analysis
- Identify missing, duplicate, inconsistent, unknown, and invalid values
- Compare staging data with trusted master and reference data
- Define and apply data-quality validation rules
- Calculate field-level completeness metrics
- Assign record-level quality statuses
- Produce consolidated exception reports
- Recommend remediation actions for problematic records
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

The `products` table represents trusted product master data.

The `countries` table provides trusted country reference data.

The `staging_product_updates` table contains incoming product records that must be validated before they can be accepted into the master-data environment.

The remaining tables provide customer, order, sales, registration, and batch information for business analysis and operational data-quality controls.

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

## Project Workflow

The project follows this data-quality workflow:

1. Create the database and load synthetic data
2. Explore the tables, columns, and relationships
3. Analyze operational and transactional data
4. Profile the incoming staging dataset
5. Validate staging values against business rules
6. Compare staging records with master and reference data
7. Identify data-quality exceptions
8. Assign remediation actions
9. Produce a final record-level remediation report

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
- Inserts synthetic master, reference, transactional, and staging data
- Introduces intentional data-quality issues for validation and remediation scenarios

### 2. Data Exploration

File:

```text
sql/01_data_exploration.sql
```

This analysis includes:

- Reviewing the available database tables
- Inspecting table structures with `DESCRIBE`
- Previewing sample records
- Creating a row-count inventory
- Reviewing important columns
- Understanding table relationships
- Identifying initial potential data-quality concerns

### 3. Core SQL Analysis

File:

```text
sql/02_foundation_queries.sql
```

This analysis includes:

- Filtering and sorting operational records
- Reviewing distinct pharmaceutical attributes
- Aggregating products by prescription type
- Aggregating orders by status
- Filtering customers by country
- Analyzing order-delivery durations
- Identifying batches within defined expiry windows
- Reviewing recently launched products

### 4. Relational and Business Analysis

File:

```text
sql/03_joins_and_business_analysis.sql
```

This analysis includes:

- Enriching customer data with country information
- Reviewing product registrations by country
- Identifying products without approved registrations
- Calculating gross sales values
- Calculating net revenue after discounts
- Calculating net revenue by product
- Calculating delivered revenue by country
- Identifying the highest-value customers
- Comparing monthly order volumes
- Comparing product sales with registration status
- Detecting sales in countries without approved registration
- Linking order items with batch records
- Detecting product and batch inconsistencies

### 5. Data Quality Assessment and Validation

File:

```text
sql/04_data_quality_validation.sql
```

This section evaluates the staging dataset for:

- Exact duplicate records
- Missing mandatory values
- Unknown product identifiers
- Invalid country codes
- Inconsistent capitalization
- Surrounding spaces
- Product-name differences between staging and master data
- Therapeutic-area differences
- Product-status inconsistencies
- Field-level completeness percentages
- Record-level quality statuses

### 6. Exception Reporting and Data Remediation

File:

```text
sql/05_exception_reporting_and_remediation.sql
```

This section includes:

- Ranking products by revenue within each country
- Identifying the highest-revenue active Rx products
- Producing a consolidated operational exception report
- Identifying unapproved product sales
- Identifying recalled or quarantined batches used in orders
- Identifying orders placed by inactive customers
- Identifying delivered orders with missing delivery dates
- Creating cleaned staging-data previews without changing source data
- Displaying staging and master values side by side
- Suggesting standardized values from trusted master data
- Creating detailed data-quality issue descriptions
- Assigning remediation actions
- Summarizing remediation counts and percentages
- Producing a final record-level remediation report

## Data-Quality Dimensions

The project evaluates several data-quality dimensions:

| Dimension | Description |
|---|---|
| Completeness | Required values must not be missing |
| Validity | Values must exist in trusted master or reference data |
| Consistency | Staging values must agree with corresponding master values |
| Uniqueness | Duplicate incoming records must be identified |
| Conformity | Text values must follow consistent formatting standards |
| Integrity | Relationships between products, orders, registrations, and batches must remain valid |

## Data-Quality Rules

The project applies the following validation rules:

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
| Product-status consistency | Staging status must be consistent with the master status |
| Text conformity | Text values must follow consistent capitalization and spacing |
| Record uniqueness | Duplicate staging records must be identified |
| Registration compliance | Products sold in a country must have an approved registration |
| Batch integrity | The batch product must match the ordered product |
| Delivery completeness | Delivered orders must contain a delivery date |

## Remediation Actions

Each staging record is assigned one of three remediation actions:

| Remediation action | Meaning |
|---|---|
| `ACCEPT` | The record satisfies the defined data-quality rules |
| `STANDARDIZE` | The record is valid but requires formatting or alignment with master data |
| `MANUAL REVIEW` | The record contains missing, unknown, or invalid reference data and requires investigation |

The remediation rules are applied in priority order.

Records with missing or invalid reference information are assigned to `MANUAL REVIEW` before formatting differences are considered.

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

The final remediation report displays:

- Original staging values
- Corresponding master and reference values
- Identified data-quality issues
- Recommended remediation actions

## Operational Exception Reporting

The project also produces a consolidated exception report for operational risks.

The report combines the following issue types:

- Product sold without an approved registration
- Recalled or quarantined batch used in an order
- Inactive customer associated with an order
- Delivered order with a missing delivery date

Each exception includes:

- `issue_type`
- `record_id`
- A short descriptive detail field

## Key SQL Techniques

The project uses:

- `INNER JOIN`
- `LEFT JOIN`
- `UNION ALL`
- `CASE`
- Common Table Expressions
- Window functions
- `RANK`
- `OVER`
- `PARTITION BY`
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
- `YEAR`
- `MONTH`
- `DATEDIFF`
- `DATE_ADD`
- `BETWEEN`
- Master-data validation
- Reference-data validation

## How to Run the Project

### Step 1: Create the database

Open MySQL or DBeaver and run:

```text
sql/00_database_setup.sql
```

This creates the database, tables, relationships, and synthetic records.

### Step 2: Run the analysis files

Run the remaining SQL files in numerical order:

```text
sql/01_data_exploration.sql
sql/02_foundation_queries.sql
sql/03_joins_and_business_analysis.sql
sql/04_data_quality_validation.sql
sql/05_exception_reporting_and_remediation.sql
```

### Step 3: Review the results

Review the result sets produced by each section, particularly:

- Business-analysis results
- Staging-data validation results
- Completeness metrics
- Operational exception reports
- Remediation summaries
- The final record-level remediation report

## Project Status

Completed.

The project includes:

- Database design and setup
- Data exploration
- Core SQL analysis
- Relational and business analysis
- Advanced revenue analysis
- Data-quality assessment
- Master-data comparison
- Reference-data validation
- Operational exception reporting
- Remediation recommendations
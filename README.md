# Pharmaceutical Data Quality Analysis with SQL

## Project Overview

This project demonstrates an SQL-based data quality and data stewardship
workflow using a synthetic pharmaceutical database.

The analysis covers database exploration, data profiling, validation,
master-data comparison, duplicate and missing-value detection, and
exception reporting.

> All company names, product names, and records used in this project are
> fictional. This project does not contain internal data from any company.

## Project Objectives

- Explore the database structure and table relationships
- Profile pharmaceutical product, customer, order, and batch data
- Identify missing, duplicate, inconsistent, and invalid values
- Compare staging data with master data
- Define and test data-quality rules
- Produce exception reports for data-quality issues
- Practise business-focused SQL queries

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
│   └── 01_data_exploration.sql
└── README.md
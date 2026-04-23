# Snowflake SCD Type 2 Pipeline with dbt

This project demonstrates how to implement Slowly Changing Dimension Type 2 using dbt and Snowflake. The pipeline captures changes in source product data, versions those changes using a dbt snapshot, and exposes the current view of the data in the Gold layer.

The main goal of this project is to preserve historical changes instead of overwriting older values. When a record changes, the previous version remains stored with a valid time range, and a new version is created for the updated record.

## Overview

This project follows a simple ELT pattern.

Source data is uploaded to Amazon S3 using Python. Snowflake reads the files through an external stage and loads the raw data into a copy table. dbt is then used to transform the source data, capture historical changes through snapshots, and create a final view for downstream querying.

The pipeline is organized into layers:

* Bronze layer for raw copied data
* Silver layer for transformed data and snapshot versioning
* Gold layer for the final reporting view

## What is SCD Type 2

Slowly Changing Dimension Type 2 is used when you need to preserve history.

If a product attribute changes, such as product name, category, price, or description, the existing row is not overwritten. Instead:

* the old version is closed with an end timestamp
* a new version is inserted with a new start timestamp

This makes it possible to answer questions such as:

* what was the product price last month
* when did a product description change
* which version of a record was active at a given time

## How This Project Works

### Step 1: Upload Source File

A Python script uploads a source file to Amazon S3. This file contains product data and can include updated values for existing product records.

### Step 2: Ingest Raw Data into Snowflake

Snowflake reads the file from S3 through an external stage and loads it into a raw copy table in the Bronze layer.

### Step 3: Transform Source Data with dbt

A dbt model loads and standardizes the raw source data into a transformed table. This step prepares the data for snapshot tracking.

### Step 4: Capture Historical Changes with dbt Snapshot

A dbt snapshot compares the current transformed data with previously captured records. When a change is detected, dbt closes the old version and inserts a new one.

This is the main SCD Type 2 step in the project.

### Step 5: Build Gold View

A dbt view is created in the Gold schema to present the versioned data in a clean and queryable format. This view can be used to inspect current and historical record states.

## Architecture Summary

The pipeline flow is:

1. Python uploads changed source data to Amazon S3
2. Snowflake reads the file through an external stage
3. Raw data is loaded into the Bronze layer
4. dbt transforms the data into the Silver layer
5. dbt snapshot versions the records
6. dbt creates a Gold view for reporting and analysis

## Tech Stack

* Python
* Amazon S3
* Snowflake
* dbt Cloud or dbt Core
* SQL
* dbt Snapshots

## Project Structure

```text
snowflake-scd2-dbt-pipeline/
├── README.md
├── requirements.txt
├── .gitignore
├── python/
│   └── upload_product_file.py
├── models/
│   ├── transform_product_load.sql
│   └── product_view.sql
├── snapshots/
│   └── product_snapshot.sql
├── macros/
├── seeds/
└── sample_data/
    ├── product_initial.csv
    └── product_changed.csv
```

## Layers Explained

### Bronze Layer

This layer stores the copied raw data loaded from the S3 file. It acts as the ingestion layer and preserves the source feed before business logic is applied.

### Silver Layer

This layer contains cleaned and transformed data. It also contains the snapshot table that stores historical versions of the records.

### Gold Layer

This layer exposes the final business-facing view used for analysis. It makes the SCD Type 2 output easier to query.

## Snapshot Logic

The snapshot is responsible for tracking row-level changes over time.

When dbt detects that a tracked column has changed, it:

* marks the current version as no longer active
* assigns an end timestamp to the previous version
* inserts a new current row with a new start timestamp

Typical columns in an SCD Type 2 snapshot include:

* business key such as `product_id`
* `dbt_valid_from`
* `dbt_valid_to`
* current product attributes

## Why Use SCD Type 2

This approach is useful when historical tracking matters.

Common examples include:

* product price changes
* customer profile changes
* employee title changes
* vendor contract updates

If you need the latest value only, SCD Type 1 is enough. If you need to preserve history, SCD Type 2 is the better choice.

## How to Run

### 1. Upload changed data

Run the Python script to upload the source file to Amazon S3.

### 2. Load transformed source data

Run the dbt model that prepares the source table:

```bash
dbt run --select transform_product_load
```

### 3. Capture changes using snapshot

Run the snapshot to version the records:

```bash
dbt snapshot --select product_snapshot
```

### 4. Refresh the Gold view

Run the view model:

```bash
dbt run --select product_view
```

### 5. Validate in Snowflake

Example validation query:

```sql
select *
from PC_DBT_DB.GOLD.PRODUCT_VIEW
where PRODUCT_ID = '<product_id>';
```

## What This Project Demonstrates

This project shows practical knowledge of:

* file-based ingestion into Snowflake
* layered data modeling
* dbt transformations
* dbt snapshots for historical tracking
* SCD Type 2 design in a warehouse
* building a final reporting view from versioned records

## Design Notes

This repository is intentionally simple. The focus is on clearly demonstrating SCD Type 2 logic rather than building a large production framework.

The key idea is to make the project easy to understand:

* source file comes in
* transformed table is refreshed
* snapshot captures change history
* final view exposes the result

## Summary

This project implements SCD Type 2 using dbt and Snowflake by capturing changes in source product data, versioning those changes through snapshots, and exposing them through a Gold-layer view. It is a clean example of historical dimension tracking in a modern cloud data stack.

-- Product Snapshot
-- Purpose: implement SCD Type 2 logic using dbt snapshot

{% snapshot product_snapshot %}

{{
    config(
        target_schema='SILVER',
        unique_key='product_id',
        strategy='check',
        check_cols=[
            'product_name',
            'category',
            'selling_price',
            'model_number',
            'about_product',
            'product_specification',
            'technical_details',
            'shipping_weight'
        ]
    )
}}

select
    product_id,
    product_name,
    category,
    selling_price,
    model_number,
    about_product,
    product_specification,
    technical_details,
    shipping_weight
from {{ ref('transform_product_load') }}

{% endsnapshot %}

-- Notes:
-- strategy='check' compares columns listed in check_cols to detect changes
-- When a change is detected, dbt closes the old record and inserts a new version
-- dbt automatically manages:
--   dbt_valid_from
--   dbt_valid_to
--   dbt_scd_id

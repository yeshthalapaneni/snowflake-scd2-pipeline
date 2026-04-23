-- Product View (Gold Layer)
-- Purpose: expose versioned SCD Type 2 data in a clean, queryable format

{{ config(
    materialized='view',
    schema='GOLD'
) }}

with src as (

    select
        product_id,
        product_name,
        category,
        selling_price,
        model_number,
        about_product,
        product_specification,
        technical_details,
        shipping_weight,
        dbt_valid_from,
        dbt_valid_to
    from {{ ref('product_snapshot') }}

),

final as (

    select
        product_id,
        product_name,
        category,
        selling_price,
        model_number,
        about_product,
        product_specification,
        technical_details,
        shipping_weight,

        dbt_valid_from as valid_from,
        coalesce(dbt_valid_to, to_timestamp_ntz('9999-12-31 00:00:00')) as valid_to,

        case
            when dbt_valid_to is null then true
            else false
        end as is_current

    from src

)

select * from final

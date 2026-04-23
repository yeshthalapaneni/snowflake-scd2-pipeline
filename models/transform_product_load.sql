-- Transform Product Load
-- Purpose: standardize and prepare raw product data for snapshot processing

{{ config(
    materialized='table'
) }}

with source as (

    select
        PRODUCT_ID,
        PRODUCT_NAME,
        CATEGORY,
        SELLING_PRICE,
        MODEL_NUMBER,
        ABOUT_PRODUCT,
        PRODUCT_SPECIFICATION,
        TECHNICAL_DETAILS,
        SHIPPING_WEIGHT
    from {{ source('raw', 'product_source') }}

),

cleaned as (

    select
        cast(PRODUCT_ID as string)                as product_id,
        trim(PRODUCT_NAME)                        as product_name,
        trim(CATEGORY)                            as category,
        cast(SELLING_PRICE as number)             as selling_price,
        trim(MODEL_NUMBER)                        as model_number,
        trim(ABOUT_PRODUCT)                       as about_product,
        trim(PRODUCT_SPECIFICATION)               as product_specification,
        trim(TECHNICAL_DETAILS)                   as technical_details,
        trim(SHIPPING_WEIGHT)                     as shipping_weight
    from source

)

select * from cleaned

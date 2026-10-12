select
    id as product_id,
    product_code,
    product_name,
    product_type,
    commercial_phase

from {{ ref('stg_product') }}
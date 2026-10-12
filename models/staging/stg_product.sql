select
    id,
    product_code,
    product_name,
    product_type,
    commercial_phase

from {{ source('olome_raw', 'product') }}
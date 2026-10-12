select
    id,
    deal_id,
    product_id

from {{ source('olome_raw', 'deal_product') }}
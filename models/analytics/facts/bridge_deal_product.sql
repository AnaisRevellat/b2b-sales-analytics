select
    id as deal_product_id,
    deal_id,
    product_id

from {{ ref('stg_deal_product') }}
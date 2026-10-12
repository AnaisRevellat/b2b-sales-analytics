select
    deal_id,
    product_id,
    count(*) as duplicate_count

from {{ ref('bridge_deal_product') }}

group by
    deal_id,
    product_id

having count(*) > 1
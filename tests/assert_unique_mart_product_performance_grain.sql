select
    activity_month,
    commercial_phase,
    product_id,
    company_id,
    salesperson_id,
    count(*) as row_count
from {{ ref('mart_product_performance') }}
group by
    activity_month,
    commercial_phase,
    product_id,
    company_id,
    salesperson_id
having count(*) > 1
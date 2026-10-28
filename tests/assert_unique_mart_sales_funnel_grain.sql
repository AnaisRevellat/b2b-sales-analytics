select
    activity_month,
    commercial_phase,
    salesperson_id,
    count(*) as row_count
from {{ ref('mart_sales_funnel') }}
group by
    activity_month,
    commercial_phase,
    salesperson_id
having count(*) > 1
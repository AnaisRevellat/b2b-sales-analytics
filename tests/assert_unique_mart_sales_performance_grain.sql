select
    activity_month,
    commercial_phase,
    company_id,
    salesperson_id,
    count(*) as row_count
from {{ ref('mart_sales_performance') }}
group by
    activity_month,
    commercial_phase,
    company_id,
    salesperson_id
having count(*) > 1
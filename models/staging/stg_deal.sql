select
    id,
    company_id,
    salesperson_id,
    demo_id,
    signed_at,
    status,
    installation_amount,
    monthly_recurring_amount

from {{ source('olome_raw', 'deal') }}
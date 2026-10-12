select
    id,
    company_id,
    call_id,
    salesperson_id,
    scheduled_at,
    demo_at,
    demo_result,
    dff_dqf_interest_at_demo,
    demo_source

from {{ source('olome_raw', 'demo') }}
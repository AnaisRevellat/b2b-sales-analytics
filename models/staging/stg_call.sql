select
    id,
    company_id,
    salesperson_id,
    called_at,
    call_type,
    call_duration_seconds,
    call_outcome,
    demo_scheduled,
    dff_dqf_interest_at_call

from {{ source('olome_raw', 'call') }}
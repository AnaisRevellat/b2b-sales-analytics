with base as (

    select
        activity_month,
        commercial_phase,
        salesperson_id,
        salesperson_initials,

        total_calls,
        answered_calls,
        demos_planned,
        demos_held,
        signed_deals

    from {{ ref('mart_sales_funnel') }}
),

funnel_steps as (

    select
        activity_month,
        commercial_phase,
        salesperson_id,
        salesperson_initials,
        'Total Calls' as stage,
        1 as stage_order,
        total_calls as stage_value
    from base

    union all

    select
        activity_month,
        commercial_phase,
        salesperson_id,
        salesperson_initials,
        'Answered Calls' as stage,
        2 as stage_order,
        answered_calls as stage_value
    from base

    union all

    select
        activity_month,
        commercial_phase,
        salesperson_id,
        salesperson_initials,
        'Demos Planned' as stage,
        3 as stage_order,
        demos_planned as stage_value
    from base

    union all

    select
        activity_month,
        commercial_phase,
        salesperson_id,
        salesperson_initials,
        'Demos Held' as stage,
        4 as stage_order,
        demos_held as stage_value
    from base

    union all

    select
        activity_month,
        commercial_phase,
        salesperson_id,
        salesperson_initials,
        'Signed Deals' as stage,
        5 as stage_order,
        signed_deals as stage_value
    from base
)

select *
from funnel_steps
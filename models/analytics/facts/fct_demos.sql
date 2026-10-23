with demos as (

    select *
    from {{ ref('stg_demo') }}

),

final as (

    select
        id as demo_id,
        company_id,
        call_id,
        salesperson_id,

        scheduled_at,
        demo_at,

        cast(scheduled_at as date) as scheduled_date,
        cast(demo_at as date) as demo_date,

        date_trunc(cast(scheduled_at as date), month) as scheduled_month,

        case
            when cast(scheduled_at as date) < date '2025-07-01' then 'PRE_PIVOT'
            when cast(scheduled_at as date) < date '2025-09-01' then 'TRANSITION'
            else 'POST_PIVOT'
        end as commercial_phase,

        case
            when demo_at is null then true
            else false
        end as is_no_show,

        case
            when demo_at is not null then true
            else false
        end as is_demo_held,

        demo_result,
        dff_dqf_interest_at_demo,
        demo_source

    from demos

)

select *
from final
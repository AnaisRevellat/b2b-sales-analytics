with calls as (

    select *
    from {{ ref('stg_call') }}

),

final as (

    select
        id as call_id,
        company_id,
        salesperson_id,

        called_at,
        cast(called_at as date) as call_date,
        date_trunc(cast(called_at as date), month) as call_month,
        extract(hour from called_at) as call_hour,

        case
            when extract(hour from called_at) < 12 then 'MORNING'
            else 'AFTERNOON'
        end as day_part,

        case
            when cast(called_at as date) < date '2025-07-01' then 'PRE_PIVOT'
            when cast(called_at as date) < date '2025-09-01' then 'TRANSITION'
            else 'POST_PIVOT'
        end as commercial_phase,

        call_type,
        call_duration_seconds,
        call_outcome,

        case
            when call_outcome <> 'NO_ANSWER' then true
            else false
        end as is_answered,

        case
            when call_outcome = 'DISCOVERY' then true
            else false
        end as is_discovery,

        case
            when call_outcome = 'KO' then true
            else false
        end as is_ko,

        case
            when call_outcome = 'BAD_TIMING' then true
            else false
        end as is_bad_timing,

        case
            when call_outcome = 'GATEKEEPER' then true
            else false
        end as is_gatekeeper,

        case
            when call_outcome = 'HANG_UP' then true
            else false
        end as is_hang_up,

        demo_scheduled,
        dff_dqf_interest_at_call

    from calls

)

select *
from final
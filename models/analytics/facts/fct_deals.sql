with deals as (

    select *
    from {{ ref('stg_deal') }}

),

demos as (

    select
        id as demo_id,
        demo_at

    from {{ ref('stg_demo') }}

),

final as (

    select
        deals.id as deal_id,
        deals.company_id,
        deals.salesperson_id,
        deals.demo_id,

        deals.signed_at,
        cast(deals.signed_at as date) as signed_date,
        date_trunc(cast(deals.signed_at as date), month) as signed_month,

        case
            when cast(deals.signed_at as date) < date '2025-07-01' then 'PRE_PIVOT'
            when cast(deals.signed_at as date) < date '2025-09-01' then 'TRANSITION'
            else 'POST_PIVOT'
        end as commercial_phase,

        deals.status,

        deals.installation_amount,
        deals.monthly_recurring_amount,

        deals.monthly_recurring_amount * 12
            as annual_recurring_amount,

        deals.installation_amount
            + (deals.monthly_recurring_amount * 12)
            as first_year_revenue,

        date_diff(
            cast(deals.signed_at as date),
            cast(demos.demo_at as date),
            day
        ) as days_demo_to_signature

    from deals

    left join demos
        on deals.demo_id = demos.demo_id

)

select *
from final
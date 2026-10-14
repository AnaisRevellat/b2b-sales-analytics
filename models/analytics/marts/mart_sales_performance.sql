with call_metrics as (

    select
        cast(call_month as date) as activity_month,
        commercial_phase,
        company_id,
        salesperson_id,

        count(*) as total_calls,
        count_if(is_answered) as answered_calls,
        count_if(is_discovery) as discovery_calls,

        0 as demos_planned,
        0 as demos_held,
        0 as no_shows,

        0 as signed_deals,

        0 as installation_revenue,
        0 as monthly_recurring_revenue,
        0 as annual_recurring_revenue,
        0 as first_year_revenue,

        0 as closing_days_sum,
        0 as closing_days_count

    from {{ ref('fct_calls') }}

    group by
        activity_month,
        commercial_phase,
        company_id,
        salesperson_id
),

demo_metrics as (

    select
        cast(scheduled_month as date) as activity_month,
        commercial_phase,
        company_id,
        salesperson_id,

        0 as total_calls,
        0 as answered_calls,
        0 as discovery_calls,

        count(*) as demos_planned,
        count_if(is_demo_held) as demos_held,
        count_if(is_no_show) as no_shows,

        0 as signed_deals,

        0 as installation_revenue,
        0 as monthly_recurring_revenue,
        0 as annual_recurring_revenue,
        0 as first_year_revenue,

        0 as closing_days_sum,
        0 as closing_days_count

    from {{ ref('fct_demos') }}

    group by
        activity_month,
        commercial_phase,
        company_id,
        salesperson_id
),

deal_metrics as (

    select
        cast(signed_month as date) as activity_month,
        commercial_phase,
        company_id,
        salesperson_id,

        0 as total_calls,
        0 as answered_calls,
        0 as discovery_calls,

        0 as demos_planned,
        0 as demos_held,
        0 as no_shows,

        count_if(status = 'WON') as signed_deals,

        sum(
            case
                when status = 'WON' then installation_amount
                else 0
            end
        ) as installation_revenue,

        sum(
            case
                when status = 'WON' then monthly_recurring_amount
                else 0
            end
        ) as monthly_recurring_revenue,

        sum(
            case
                when status = 'WON' then annual_recurring_amount
                else 0
            end
        ) as annual_recurring_revenue,

        sum(
            case
                when status = 'WON' then first_year_revenue
                else 0
            end
        ) as first_year_revenue,

        coalesce(
            sum(
                case
                    when status = 'WON'
                    then days_demo_to_signature
                end
            ),
            0
        ) as closing_days_sum,

        count(
            case
                when status = 'WON'
                then days_demo_to_signature
            end
        ) as closing_days_count

    from {{ ref('fct_deals') }}

    group by
        activity_month,
        commercial_phase,
        company_id,
        salesperson_id
),

all_metrics as (

    select * from call_metrics

    union all

    select * from demo_metrics

    union all

    select * from deal_metrics
),

aggregated as (

    select
        activity_month,
        commercial_phase,
        company_id,
        salesperson_id,

        sum(total_calls) as total_calls,
        sum(answered_calls) as answered_calls,
        sum(discovery_calls) as discovery_calls,

        sum(demos_planned) as demos_planned,
        sum(demos_held) as demos_held,
        sum(no_shows) as no_shows,

        sum(signed_deals) as signed_deals,

        sum(installation_revenue) as installation_revenue,
        sum(monthly_recurring_revenue) as monthly_recurring_revenue,
        sum(annual_recurring_revenue) as annual_recurring_revenue,
        sum(first_year_revenue) as first_year_revenue,

        sum(closing_days_sum) as closing_days_sum,
        sum(closing_days_count) as closing_days_count

    from all_metrics

    group by
        activity_month,
        commercial_phase,
        company_id,
        salesperson_id
)

select
    aggregated.activity_month,
    aggregated.commercial_phase,

    aggregated.company_id,
    company.company_name,
    company.source_type,
    company.source_name,
    company.company_size,
    company.naf_code,
    company.city,
    company.country,

    aggregated.salesperson_id,
    salesperson.initials as salesperson_initials,

    aggregated.total_calls,
    aggregated.answered_calls,
    aggregated.discovery_calls,

    aggregated.demos_planned,
    aggregated.demos_held,
    aggregated.no_shows,

    aggregated.signed_deals,

    aggregated.installation_revenue,
    aggregated.monthly_recurring_revenue,
    aggregated.annual_recurring_revenue,
    aggregated.first_year_revenue,

    aggregated.closing_days_sum,
    aggregated.closing_days_count,

    case
        when aggregated.closing_days_count > 0
        then cast(aggregated.closing_days_sum as float)
             / aggregated.closing_days_count
    end as avg_days_demo_to_signature

from aggregated

left join {{ ref('dim_company') }} as company
    on aggregated.company_id = company.company_id

left join {{ ref('dim_salesperson') }} as salesperson
    on aggregated.salesperson_id = salesperson.salesperson_id
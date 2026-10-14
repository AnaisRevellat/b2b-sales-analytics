with call_metrics as (

    select
        cast(call_month as date) as activity_month,
        commercial_phase,
        salesperson_id,

        count(*) as total_calls,
        count_if(is_answered) as answered_calls,
        count_if(is_discovery) as discovery_calls,
        count_if(is_ko) as ko_calls,
        count_if(is_bad_timing) as bad_timing_calls,
        count_if(is_gatekeeper) as gatekeeper_calls,
        count_if(is_hang_up) as hang_up_calls,
        count_if(demo_scheduled) as demos_scheduled_from_calls,

        0 as demos_planned,
        0 as demos_held,
        0 as no_shows,
        0 as demo_cohort_signatures,

        0 as signed_deals

    from {{ ref('fct_calls') }}

    group by
        activity_month,
        commercial_phase,
        salesperson_id
),

demo_metrics as (

    select
        cast(d.scheduled_month as date) as activity_month,
        d.commercial_phase,
        d.salesperson_id,

        0 as total_calls,
        0 as answered_calls,
        0 as discovery_calls,
        0 as ko_calls,
        0 as bad_timing_calls,
        0 as gatekeeper_calls,
        0 as hang_up_calls,
        0 as demos_scheduled_from_calls,

        count(distinct d.demo_id) as demos_planned,

        count(
            distinct case
                when d.is_demo_held then d.demo_id
            end
        ) as demos_held,

        count(
            distinct case
                when d.is_no_show then d.demo_id
            end
        ) as no_shows,

        count(
            distinct case
                when deals.status = 'WON' then deals.deal_id
            end
        ) as demo_cohort_signatures,

        0 as signed_deals

    from {{ ref('fct_demos') }} as d

    left join {{ ref('fct_deals') }} as deals
        on d.demo_id = deals.demo_id

    group by
        activity_month,
        d.commercial_phase,
        d.salesperson_id
),

deal_metrics as (

    select
        cast(signed_month as date) as activity_month,
        commercial_phase,
        salesperson_id,

        0 as total_calls,
        0 as answered_calls,
        0 as discovery_calls,
        0 as ko_calls,
        0 as bad_timing_calls,
        0 as gatekeeper_calls,
        0 as hang_up_calls,
        0 as demos_scheduled_from_calls,

        0 as demos_planned,
        0 as demos_held,
        0 as no_shows,
        0 as demo_cohort_signatures,

        count_if(status = 'WON') as signed_deals

    from {{ ref('fct_deals') }}

    group by
        activity_month,
        commercial_phase,
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
        salesperson_id,

        sum(total_calls) as total_calls,
        sum(answered_calls) as answered_calls,
        sum(discovery_calls) as discovery_calls,
        sum(ko_calls) as ko_calls,
        sum(bad_timing_calls) as bad_timing_calls,
        sum(gatekeeper_calls) as gatekeeper_calls,
        sum(hang_up_calls) as hang_up_calls,
        sum(demos_scheduled_from_calls) as demos_scheduled_from_calls,

        sum(demos_planned) as demos_planned,
        sum(demos_held) as demos_held,
        sum(no_shows) as no_shows,
        sum(demo_cohort_signatures) as demo_cohort_signatures,

        sum(signed_deals) as signed_deals

    from all_metrics

    group by
        activity_month,
        commercial_phase,
        salesperson_id
)

select
    aggregated.activity_month,
    aggregated.commercial_phase,
    aggregated.salesperson_id,
    salesperson.initials as salesperson_initials,

    aggregated.total_calls,
    aggregated.answered_calls,
    aggregated.discovery_calls,
    aggregated.ko_calls,
    aggregated.bad_timing_calls,
    aggregated.gatekeeper_calls,
    aggregated.hang_up_calls,

    aggregated.demos_scheduled_from_calls,
    aggregated.demos_planned,
    aggregated.demos_held,
    aggregated.no_shows,

    aggregated.demo_cohort_signatures,
    aggregated.signed_deals,

    case
        when aggregated.total_calls > 0
        then cast(aggregated.answered_calls as float)
             / aggregated.total_calls
    end as answer_rate,

    case
        when aggregated.answered_calls > 0
        then cast(aggregated.discovery_calls as float)
             / aggregated.answered_calls
    end as discovery_rate,

    case
        when aggregated.answered_calls > 0
        then cast(aggregated.demos_scheduled_from_calls as float)
             / aggregated.answered_calls
    end as answered_to_demo_rate,

    case
        when aggregated.demos_planned > 0
        then cast(aggregated.no_shows as float)
             / aggregated.demos_planned
    end as no_show_rate,

    case
        when aggregated.demos_held > 0
        then cast(aggregated.demo_cohort_signatures as float)
             / aggregated.demos_held
    end as demo_to_signature_rate

from aggregated

left join {{ ref('dim_salesperson') }} as salesperson
    on aggregated.salesperson_id = salesperson.salesperson_id
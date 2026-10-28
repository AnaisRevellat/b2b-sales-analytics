with deal_product_counts as (

    select
        deal_id,
        count(*) as product_count

    from {{ ref('bridge_deal_product') }}

    group by deal_id
),

deal_product_allocated as (

    select
        deals.deal_id,
        deals.company_id,
        deals.salesperson_id,

        cast(deals.signed_month as date) as activity_month,
        deals.commercial_phase,

        bridge.product_id,

        product_counts.product_count,

        safe_divide(
            cast(1 as float64),
            product_counts.product_count
        ) as allocated_deal_count,

        safe_divide(
            deals.installation_amount,
            product_counts.product_count
        ) as allocated_installation_revenue,

        safe_divide(
            deals.monthly_recurring_amount,
            product_counts.product_count
        ) as allocated_monthly_recurring_revenue,

        safe_divide(
            deals.annual_recurring_amount,
            product_counts.product_count
        ) as allocated_annual_recurring_revenue,

        safe_divide(
            deals.first_year_revenue,
            product_counts.product_count
        ) as allocated_first_year_revenue

    from {{ ref('fct_deals') }} as deals

    inner join {{ ref('bridge_deal_product') }} as bridge
        on deals.deal_id = bridge.deal_id

    inner join deal_product_counts as product_counts
        on deals.deal_id = product_counts.deal_id

    where deals.status = 'WON'
),

aggregated as (

    select
        activity_month,
        commercial_phase,
        company_id,
        salesperson_id,
        product_id,

        count(distinct deal_id) as deals_with_product,
        sum(allocated_deal_count) as allocated_deal_count,

        sum(allocated_installation_revenue)
            as allocated_installation_revenue,

        sum(allocated_monthly_recurring_revenue)
            as allocated_monthly_recurring_revenue,

        sum(allocated_annual_recurring_revenue)
            as allocated_annual_recurring_revenue,

        sum(allocated_first_year_revenue)
            as allocated_first_year_revenue

    from deal_product_allocated

    group by
        activity_month,
        commercial_phase,
        company_id,
        salesperson_id,
        product_id
)

select
    aggregated.activity_month,
    aggregated.commercial_phase,

    aggregated.product_id,
    product.product_code,
    product.product_name,
    product.product_type,
    product.commercial_phase as product_commercial_phase,

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

    aggregated.deals_with_product,
    aggregated.allocated_deal_count,

    aggregated.allocated_installation_revenue,
    aggregated.allocated_monthly_recurring_revenue,
    aggregated.allocated_annual_recurring_revenue,
    aggregated.allocated_first_year_revenue

from aggregated

left join {{ ref('dim_product') }} as product
    on aggregated.product_id = product.product_id

left join {{ ref('dim_company') }} as company
    on aggregated.company_id = company.company_id

left join {{ ref('dim_salesperson') }} as salesperson
    on aggregated.salesperson_id = salesperson.salesperson_id
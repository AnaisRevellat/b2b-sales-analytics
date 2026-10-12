select
    id as company_id,
    siren,
    siret,
    name as company_name,
    postal_code,
    city,
    country,
    company_size,
    naf_code,
    web_domain,
    website_url,
    source_type,
    source_name,
    created_at

from {{ ref('stg_company') }}
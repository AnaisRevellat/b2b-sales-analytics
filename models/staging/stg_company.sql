select
    id,
    siret,
    siren,
    name,
    postal_code,
    city,
    phone,
    web_domain,
    website_url,
    source_type,
    source_name,
    created_at,
    country,
    company_size,
    naf_code

from {{ source('olome_raw', 'company') }}
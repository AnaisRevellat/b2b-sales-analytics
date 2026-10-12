select
    id,
    company_id,
    job_title,
    first_name,
    last_name,
    phone,
    email

from {{ source('olome_raw', 'contact') }}
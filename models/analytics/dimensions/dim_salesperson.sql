select
    id as salesperson_id,
    initials

from {{ ref('stg_salesperson') }}
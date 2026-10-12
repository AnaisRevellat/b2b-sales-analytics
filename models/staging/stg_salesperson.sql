select
    id,
    initials

from {{ source('olome_raw', 'salesperson') }}
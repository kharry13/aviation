SELECT
    *
FROM {{ source('raw', 'FLIGHTS_2025') }}
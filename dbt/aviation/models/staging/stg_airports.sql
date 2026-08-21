{{ config(materialized='table') }}

SELECT
    airport_id,
    name AS airport_name,
    city,
    country,
    UPPER(iata_code) AS iata_code,
    icao_code,
    latitude,
    longitude,
    altitude,
    tz AS timezone
FROM {{ source('raw', 'AIRPORTS_RAW') }}
WHERE iata_code IS NOT NULL
  AND tz IS NOT NULL
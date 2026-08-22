{{ config(materialized='table') }}

WITH airport_reference AS (

    SELECT DISTINCT

        AIRPORT_ID AS airport_key,

        IATA_CODE AS iata_code,
        ICAO_CODE AS icao_code,

        AIRPORT_NAME AS airport_name,
        CITY AS city,
        COUNTRY AS country,

        LATITUDE AS latitude,
        LONGITUDE AS longitude,
        ALTITUDE AS elevation,

        TIMEZONE AS timezone

    FROM {{ ref('stg_airports') }}

    WHERE AIRPORT_ID IS NOT NULL

),

missing_airports AS (

    SELECT
        NULL AS airport_key,
        'XWA' AS iata_code,
        'KXWA' AS icao_code,
        'Williston Basin International Airport' AS airport_name,
        'Williston' AS city,
        'USA' AS country,
        48.2597836 AS latitude,
        -103.7505567 AS longitude,
        2356 AS elevation,
        'America/Chicago' AS timezone

    UNION ALL

    SELECT
        NULL AS airport_key,
        'EAR' AS iata_code,
        'KEAR' AS icao_code,
        'Kearney Regional Airport' AS airport_name,
        'Kearney' AS city,
        'USA' AS country,
        40.7270406 AS latitude,
        -99.0067700 AS longitude,
        2132 AS elevation,
        'America/Chicago' AS timezone

    UNION ALL

    SELECT
        NULL AS airport_key,
        'BIH' AS iata_code,
        'KBIH' AS icao_code,
        'Bishop Airport' AS airport_name,
        'Bishop' AS city,
        'USA' AS country,
        37.3731111 AS latitude,
        -118.3636111 AS longitude,
        4124 AS elevation,
        'America/Los_Angeles' AS timezone
)

SELECT * FROM airport_reference

UNION ALL

SELECT * FROM missing_airports
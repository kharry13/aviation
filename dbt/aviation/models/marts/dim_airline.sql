{{ config(materialized='table') }}

SELECT DISTINCT

    OPERATING_AIRLINE_CODE AS airline_key,

    OPERATING_AIRLINE_CODE AS airline_code,

    OPERATING_AIRLINE AS airline_name

FROM {{ ref('stg_flights') }}

WHERE OPERATING_AIRLINE_CODE IS NOT NULL
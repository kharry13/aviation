{{ config(materialized='table') }}

WITH dates AS (

    SELECT DISTINCT
        CAST(flight_date AS DATE) AS date
    FROM {{ ref('stg_flights') }}

)

SELECT

    date AS date_key,
    date,

    YEAR(date) AS year,
    QUARTER(date) AS quarter,
    MONTH(date) AS month,
    MONTHNAME(date) AS month_name,

    WEEK(date) AS week,
    DAY(date) AS day,

    DAYOFWEEK(date) AS day_of_week,
    DAYNAME(date) AS day_name,

    CASE
        WHEN DAYOFWEEK(date) IN (1, 7)
        THEN TRUE
        ELSE FALSE
    END AS is_weekend,

    TO_CHAR(date, 'YYYY-MM') AS year_month,
    CONCAT(
        YEAR(date),
        '-Q',
        QUARTER(date)
    ) AS year_quarter

FROM dates
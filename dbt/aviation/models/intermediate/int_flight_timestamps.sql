{{ config(materialized='table') }}

WITH flights AS (

    SELECT *
    FROM {{ ref('stg_flights') }}

),

airports AS (

    SELECT
        iata_code,
        timezone
    FROM {{ ref('stg_airports') }}

),

joined AS (

    SELECT
        f.*,

        origin_airport.timezone AS origin_timezone,
        destination_airport.timezone AS destination_timezone

    FROM flights f

    LEFT JOIN airports origin_airport
        ON f.origin = origin_airport.iata_code

    LEFT JOIN airports destination_airport
        ON f.destination = destination_airport.iata_code

),

times AS (

    SELECT
        *,

        -- Convert HHMM → minutes after midnight
        CASE
            WHEN actual_departure_raw IS NULL THEN NULL
            WHEN actual_departure_raw = 2400 THEN 1440
            ELSE
                FLOOR(actual_departure_raw / 100) * 60
                + MOD(actual_departure_raw, 100)
        END AS actual_departure_minutes,

        CASE
            WHEN actual_arrival_raw IS NULL THEN NULL
            WHEN actual_arrival_raw = 2400 THEN 1440
            ELSE
                FLOOR(actual_arrival_raw / 100) * 60
                + MOD(actual_arrival_raw, 100)
        END AS actual_arrival_minutes,

        CASE
            WHEN scheduled_departure_raw IS NULL THEN NULL
            WHEN scheduled_departure_raw = 2400 THEN 1440
            ELSE
                FLOOR(scheduled_departure_raw / 100) * 60
                + MOD(scheduled_departure_raw, 100)
        END AS scheduled_departure_minutes,

        CASE
            WHEN scheduled_arrival_raw IS NULL THEN NULL
            WHEN scheduled_arrival_raw = 2400 THEN 1440
            ELSE
                FLOOR(scheduled_arrival_raw / 100) * 60
                + MOD(scheduled_arrival_raw, 100)
        END AS scheduled_arrival_minutes

    FROM joined

),

local_timestamps AS (

    SELECT

        *,

        -- Departure is on FlightDate
        CASE
            WHEN actual_departure_minutes IS NOT NULL
            THEN DATEADD(
                minute,
                actual_departure_minutes,
                flight_date
            )
        END AS actual_departure_local,

        -- Arrival moves to next day when clock time crosses midnight
        CASE
            WHEN actual_arrival_minutes IS NOT NULL
            THEN DATEADD(
                minute,
                actual_arrival_minutes,
                flight_date
                + CASE
                    WHEN actual_arrival_minutes < actual_departure_minutes
                    THEN 1
                    ELSE 0
                  END
            )
        END AS actual_arrival_local,

        CASE
            WHEN scheduled_departure_minutes IS NOT NULL
            THEN DATEADD(
                minute,
                scheduled_departure_minutes,
                flight_date
            )
        END AS scheduled_departure_local,

        CASE
            WHEN scheduled_arrival_minutes IS NOT NULL
            THEN DATEADD(
                minute,
                scheduled_arrival_minutes,
                flight_date
                + CASE
                    WHEN scheduled_arrival_minutes < scheduled_departure_minutes
                    THEN 1
                    ELSE 0
                  END
            )
        END AS scheduled_arrival_local

    FROM times

)

SELECT 
    *,
    CONVERT_TIMEZONE(
    origin_timezone,
    'UTC',
    actual_departure_local
    ) AS actual_departure_utc,

    CONVERT_TIMEZONE(
        destination_timezone,
        'UTC',
        actual_arrival_local
    ) AS actual_arrival_utc,

    CONVERT_TIMEZONE(
        origin_timezone,
        'UTC',
        scheduled_departure_local
    ) AS scheduled_departure_utc,

    CONVERT_TIMEZONE(
        destination_timezone,
        'UTC',
        scheduled_arrival_local
    ) AS scheduled_arrival_utc
FROM local_timestamps
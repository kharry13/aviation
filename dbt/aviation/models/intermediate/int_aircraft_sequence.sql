{{ config(materialized='table') }}

WITH flights AS (

    SELECT *
    FROM {{ ref('int_flight_timestamps') }}

    WHERE
        tail_number IS NOT NULL
        AND cancelled = 0
        AND actual_departure_utc IS NOT NULL
        AND actual_arrival_utc IS NOT NULL

),

sequenced AS (

    SELECT

        *,

        LAG(tail_number) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_tail_number,

        LAG(destination) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_destination,

        LAG(actual_arrival_utc) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_arrival_utc,

        LAG(scheduled_arrival_utc) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_scheduled_arrival_utc,

        LAG(scheduled_departure_utc) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_scheduled_departure_utc,

        LAG(arrival_delay_minutes) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_arrival_delay_minutes,

        LAG(flight_number) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_flight_number,

        LAG(origin) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_origin

    FROM flights

)

SELECT

    *,

    DATEDIFF(
        minute,
        previous_arrival_utc,
        actual_departure_utc
    ) AS actual_turnaround_minutes,

    CASE
        WHEN previous_destination = origin
         AND DATEDIFF(
                minute,
                previous_arrival_utc,
                actual_departure_utc
             ) BETWEEN 0 AND 240
        THEN TRUE
        ELSE FALSE
    END AS valid_aircraft_connection,

FROM sequenced
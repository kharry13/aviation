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

        LAG(
            MD5(
                CONCAT_WS(
                    '|',
                    TO_VARCHAR(flight_date),
                    COALESCE(operating_airline_code, ''),
                    COALESCE(flight_number, ''),
                    COALESCE(origin, ''),
                    COALESCE(destination, '')
                )
            )
        ) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_flight_key,

        MD5(
            CONCAT_WS(
                '|',
                TO_VARCHAR(flight_date),
                COALESCE(operating_airline_code, ''),
                COALESCE(flight_number, ''),
                COALESCE(origin, ''),
                COALESCE(destination, '')
            )
        ) AS current_flight_key,

        LAG(destination) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_destination,

        LAG(origin) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_origin,

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

        LAG(carrier_delay_minutes) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_carrier_delay_minutes,

        LAG(weather_delay_minutes) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_weather_delay_minutes,

        LAG(nas_delay_minutes) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_nas_delay_minutes,

        LAG(security_delay_minutes) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_security_delay_minutes,

        LAG(late_aircraft_delay_minutes) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_late_aircraft_delay_minutes,

        LAG(flight_number) OVER (
            PARTITION BY tail_number
            ORDER BY actual_departure_utc
        ) AS previous_flight_number

    FROM flights

)

SELECT

    *,

    DATEDIFF(
        minute,
        previous_arrival_utc,
        actual_departure_utc
    ) AS actual_turnaround_minutes,

    DATEDIFF(
        minute,
        previous_scheduled_arrival_utc,
        scheduled_departure_utc
    ) AS scheduled_turnaround_minutes,

    DATEDIFF(
        minute,
        previous_scheduled_arrival_utc,
        scheduled_departure_utc
    )
    - GREATEST(
        COALESCE(previous_arrival_delay_minutes, 0),
        0
    ) AS remaining_buffer_minutes,

    CASE
        WHEN previous_destination = origin
         AND DATEDIFF(
                minute,
                previous_arrival_utc,
                actual_departure_utc
             ) BETWEEN 0 AND 240
        THEN TRUE
        ELSE FALSE
    END AS valid_aircraft_connection

FROM sequenced
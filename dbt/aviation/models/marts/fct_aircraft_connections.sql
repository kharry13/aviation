{{ config(materialized='table') }}

SELECT

    /* Connection identity */

    MD5(
        CONCAT_WS(
            '|',
            previous_flight_key,
            current_flight_key
        )
    ) AS connection_key,

    current_flight_key,
    previous_flight_key,

    /* Aircraft */

    tail_number,
    OPERATING_AIRLINE_CODE AS airline_key,

    /* Connection location */

    previous_origin,
    previous_destination AS connection_airport,
    origin AS current_origin,
    destination AS current_destination,

    /* Dates */

    flight_date AS date_key,

    /* Flight timing */

    previous_scheduled_arrival_utc,
    previous_arrival_utc,

    scheduled_departure_utc AS current_scheduled_departure_utc,
    actual_departure_utc AS current_actual_departure_utc,

    /* Turnaround */

    scheduled_turnaround_minutes,
    actual_turnaround_minutes,
    remaining_buffer_minutes,
    CASE
        WHEN remaining_buffer_minutes < 0 THEN '<0'
        WHEN remaining_buffer_minutes < 5 THEN '0-5'
        WHEN remaining_buffer_minutes < 15 THEN '5-15'
        WHEN remaining_buffer_minutes < 30 THEN '15-30'
        WHEN remaining_buffer_minutes < 60 THEN '30-60'
        ELSE '60+'
    END AS buffer_bucket,

    /* Delay */

    previous_arrival_delay_minutes,
    departure_delay_minutes AS current_departure_delay_minutes,

    GREATEST(
        COALESCE(departure_delay_minutes, 0)
        - GREATEST(
            COALESCE(previous_arrival_delay_minutes, 0),
            0
        ),
        0
    ) AS propagated_delay_minutes,

    GREATEST(
        GREATEST(
            COALESCE(previous_arrival_delay_minutes, 0),
            0
        )
        - GREATEST(
            COALESCE(departure_delay_minutes, 0),
            0
        ),
        0
    ) AS recovered_delay_minutes,

    /* Propagation classification */

    CASE
        WHEN previous_arrival_delay_minutes > 0
         AND departure_delay_minutes > 0
        THEN TRUE
        ELSE FALSE
    END AS next_flight_delayed,

    CASE
        WHEN previous_arrival_delay_minutes > 0
         AND departure_delay_minutes > 15
        THEN TRUE
        ELSE FALSE
    END AS significant_propagation,

    /* Previous flight delay causes */

    previous_carrier_delay_minutes,
    previous_weather_delay_minutes,
    previous_nas_delay_minutes,
    previous_security_delay_minutes,
    previous_late_aircraft_delay_minutes,

    /* Current flight delay causes */

    carrier_delay_minutes AS current_carrier_delay_minutes,
    weather_delay_minutes AS current_weather_delay_minutes,
    nas_delay_minutes AS current_nas_delay_minutes,
    security_delay_minutes AS current_security_delay_minutes,
    late_aircraft_delay_minutes AS current_late_aircraft_delay_minutes

FROM {{ ref('int_aircraft_sequence') }}

WHERE valid_aircraft_connection = TRUE
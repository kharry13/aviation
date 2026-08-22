{{ config(materialized='table') }}

SELECT

    MD5(
        CONCAT_WS(
            '|',
            TO_VARCHAR(FLIGHT_DATE),
            COALESCE(OPERATING_AIRLINE_CODE, ''),
            COALESCE(FLIGHT_NUMBER, ''),
            COALESCE(ORIGIN, ''),
            COALESCE(DESTINATION, '')
        )
    ) AS flight_key,

    FLIGHT_DATE AS date_key,

    OPERATING_AIRLINE_CODE AS airline_key,

    TAIL_NUMBER AS tail_number,

    FLIGHT_NUMBER AS flight_number,

    ORIGIN AS origin_airport_code,
    DESTINATION AS destination_airport_code,

    ORIGIN_CITY AS origin_city,
    DESTINATION_CITY AS destination_city,

    ORIGIN_STATE AS origin_state,
    DESTINATION_STATE AS destination_state,

    SCHEDULED_DEPARTURE_UTC AS scheduled_departure_utc,
    ACTUAL_DEPARTURE_UTC AS actual_departure_utc,

    SCHEDULED_ARRIVAL_UTC AS scheduled_arrival_utc,
    ACTUAL_ARRIVAL_UTC AS actual_arrival_utc,

    DEPARTURE_DELAY_MINUTES AS departure_delay_minutes,
    ARRIVAL_DELAY_MINUTES AS arrival_delay_minutes,

    DEPARTURE_DELAY_MINUTES_BTS AS departure_delay_minutes_bts,
    ARRIVAL_DELAY_MINUTES_BTS AS arrival_delay_minutes_bts,

    TAXI_OUT_MINUTES AS taxi_out_minutes,
    TAXI_IN_MINUTES AS taxi_in_minutes,
    AIR_TIME_MINUTES AS air_time_minutes,
    DISTANCE_MILES AS distance_miles,

    CANCELLED AS cancelled,
    CANCELLATION_CODE AS cancellation_code,
    DIVERTED AS diverted,

    CARRIER_DELAY_MINUTES AS carrier_delay_minutes,
    WEATHER_DELAY_MINUTES AS weather_delay_minutes,
    NAS_DELAY_MINUTES AS nas_delay_minutes,
    SECURITY_DELAY_MINUTES AS security_delay_minutes,
    LATE_AIRCRAFT_DELAY_MINUTES AS late_aircraft_delay_minutes

FROM {{ ref('int_flight_timestamps') }}
{{ config(materialized='table') }}

WITH source AS (

    SELECT *
    FROM {{ source('raw', 'FLIGHTS_RAW') }}

),

cleaned AS (

    SELECT

        -- Identity
        TRY_TO_DATE("FlightDate") AS flight_date,
        "Operating_Airline" AS operating_airline,
        "IATA_Code_Operating_Airline" AS operating_airline_code,
        "Tail_Number" AS tail_number,
        "Flight_Number_Operating_Airline" AS flight_number,

        -- Route
        "Origin" AS origin,
        "OriginCityName" AS origin_city,
        "OriginState" AS origin_state,
        "Dest" AS destination,
        "DestCityName" AS destination_city,
        "DestState" AS destination_state,

        -- Scheduled / actual times
        "CRSDepTime" AS scheduled_departure_raw,
        "DepTime" AS actual_departure_raw,
        "CRSArrTime" AS scheduled_arrival_raw,
        "ArrTime" AS actual_arrival_raw,

        -- Delays
        TRY_TO_NUMBER("DepDelay") AS departure_delay_minutes,
        TRY_TO_NUMBER("ArrDelay") AS arrival_delay_minutes,
        TRY_TO_NUMBER("DepDelayMinutes") AS departure_delay_minutes_bts,
        TRY_TO_NUMBER("ArrDelayMinutes") AS arrival_delay_minutes_bts,

        -- Airport operations
        TRY_TO_NUMBER("TaxiOut") AS taxi_out_minutes,
        TRY_TO_NUMBER("TaxiIn") AS taxi_in_minutes,
        TRY_TO_NUMBER("AirTime") AS air_time_minutes,
        TRY_TO_NUMBER("Distance") AS distance_miles,

        -- Status
        TRY_TO_NUMBER("Cancelled") AS cancelled,
        "CancellationCode" AS cancellation_code,
        TRY_TO_NUMBER("Diverted") AS diverted,

        -- Delay causes
        TRY_TO_NUMBER("CarrierDelay") AS carrier_delay_minutes,
        TRY_TO_NUMBER("WeatherDelay") AS weather_delay_minutes,
        TRY_TO_NUMBER("NASDelay") AS nas_delay_minutes,
        TRY_TO_NUMBER("SecurityDelay") AS security_delay_minutes,
        TRY_TO_NUMBER("LateAircraftDelay") AS late_aircraft_delay_minutes

    FROM source

)

SELECT *
FROM cleaned
SELECT
    tail_number,
    previous_flight_key,
    current_flight_key,
    previous_flight_number,
    flight_number,
    previous_destination,
    origin,
    previous_arrival_delay_minutes,
    scheduled_turnaround_minutes,
    remaining_buffer_minutes,
    previous_carrier_delay_minutes,
    previous_weather_delay_minutes,
    previous_nas_delay_minutes,
    previous_security_delay_minutes,
    previous_late_aircraft_delay_minutes
FROM AVIATION_DB.INTERMEDIATE.INT_AIRCRAFT_SEQUENCE
WHERE valid_aircraft_connection = TRUE
LIMIT 10;



SELECT
    COUNT(*) AS total_flights,
    COUNT(DISTINCT current_flight_key) AS unique_flight_keys
FROM AVIATION_DB.INTERMEDIATE.INT_AIRCRAFT_SEQUENCE;



SELECT
    COUNT(*) AS connections,
    COUNT(DISTINCT connection_key) AS unique_connections,
    COUNT_IF(previous_arrival_delay_minutes > 0) AS late_inbound,
    COUNT_IF(significant_propagation) AS significant_propagation
FROM AVIATION_DB.MARTS.FCT_AIRCRAFT_CONNECTIONS;


SELECT
    COUNT(*) AS connections,
    COUNT_IF(previous_arrival_delay_minutes > 0) AS late_inbound,
    COUNT_IF(
        previous_arrival_delay_minutes > 0
        AND current_departure_delay_minutes > 15
    ) AS significant_propagation
FROM AVIATION_DB.INTERMEDIATE.INT_AIRCRAFT_CONNECTIONS;


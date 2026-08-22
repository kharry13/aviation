-- FCT_FLIGHTS
SELECT
    COUNT(*) AS rowss,
    COUNT(DISTINCT flight_key) AS unique_keys,
    COUNT_IF(flight_key IS NULL) AS null_keys
FROM AVIATION_DB.MARTS.FCT_FLIGHTS;

-- FCT_AIRCRAFT_CONNECTIONS
SELECT
    COUNT(*) AS rowss,
    COUNT(DISTINCT connection_key) AS unique_keys,
    COUNT_IF(connection_key IS NULL) AS null_keys
FROM AVIATION_DB.MARTS.FCT_AIRCRAFT_CONNECTIONS;

-- AIRLINE RELATIONSHIPS
SELECT COUNT(*) AS orphan_airlines
FROM AVIATION_DB.MARTS.FCT_FLIGHTS f
LEFT JOIN AVIATION_DB.MARTS.DIM_AIRLINE a
    ON f.airline_key = a.airline_key
WHERE f.airline_key IS NOT NULL
  AND a.airline_key IS NULL;

-- DATE RELATIONSHIPS
SELECT COUNT(*) AS orphan_dates
FROM AVIATION_DB.MARTS.FCT_FLIGHTS f
LEFT JOIN AVIATION_DB.MARTS.DIM_DATE d
    ON f.date_key = d.date_key
WHERE f.date_key IS NOT NULL
  AND d.date_key IS NULL;

  -- AIRPORT RELATIONSHIPS
SELECT COUNT(*) AS orphan_origin_airports
FROM AVIATION_DB.MARTS.FCT_FLIGHTS f
LEFT JOIN AVIATION_DB.MARTS.DIM_AIRPORT a
    ON f.origin_airport_code = a.iata_code
WHERE f.origin_airport_code IS NOT NULL
  AND a.iata_code IS NULL;

-- DESTINATIONS

SELECT COUNT(*) AS orphan_destination_airports
FROM AVIATION_DB.MARTS.FCT_FLIGHTS f
LEFT JOIN AVIATION_DB.MARTS.DIM_AIRPORT a
    ON f.destination_airport_code = a.iata_code
WHERE f.destination_airport_code IS NOT NULL
  AND a.iata_code IS NULL;

-- CONNECTION --> FLIGHT RELATIONSHIPS

SELECT COUNT(*) AS orphan_previous_flights
FROM AVIATION_DB.MARTS.FCT_AIRCRAFT_CONNECTIONS c
LEFT JOIN AVIATION_DB.MARTS.FCT_FLIGHTS f
    ON c.previous_flight_key = f.flight_key
WHERE c.previous_flight_key IS NOT NULL
  AND f.flight_key IS NULL;

SELECT COUNT(*) AS orphan_current_flights
FROM AVIATION_DB.MARTS.FCT_AIRCRAFT_CONNECTIONS c
LEFT JOIN AVIATION_DB.MARTS.FCT_FLIGHTS f
    ON c.current_flight_key = f.flight_key
WHERE c.current_flight_key IS NOT NULL
  AND f.flight_key IS NULL;


-- REPORT:
-- ALL PASS EXCEPT:
-- ORPHAN_DESTINATION_AIRPORTS = 3301
-- ORPHAN_ORIGIN_AIRPORTS = 3301

SELECT
    f.origin_airport_code AS airport_code,
    COUNT(*) AS flight_count
FROM AVIATION_DB.MARTS.FCT_FLIGHTS f
LEFT JOIN AVIATION_DB.MARTS.DIM_AIRPORT a
    ON f.origin_airport_code = a.iata_code
WHERE f.origin_airport_code IS NOT NULL
  AND a.iata_code IS NULL
GROUP BY 1
ORDER BY flight_count DESC;

SELECT
    f.destination_airport_code AS airport_code,
    COUNT(*) AS flight_count
FROM AVIATION_DB.MARTS.FCT_FLIGHTS f
LEFT JOIN AVIATION_DB.MARTS.DIM_AIRPORT a
    ON f.destination_airport_code = a.iata_code
WHERE f.destination_airport_code IS NOT NULL
  AND a.iata_code IS NULL
GROUP BY 1
ORDER BY flight_count DESC;

SELECT *
FROM AVIATION_DB.STAGING.STG_AIRPORTS
WHERE IATA_CODE IN ('XWA', 'EAR', 'BIH');

{# Now i will manualy put metadeta for these 3 airports in the dim_airports #}
{# After correction ORPHAN_ORIGIN_AIRPORTS = 0 ORPHAN_DESTINATION_AIRPORTS = 0 #}


SELECT
    COUNT(*) AS total_airports,
    COUNT(DISTINCT iata_code) AS unique_iata_codes,
    COUNT_IF(iata_code IS NULL) AS null_iata_codes,
    COUNT_IF(airport_key IS NULL) AS null_airport_keys
FROM AVIATION_DB.MARTS.DIM_AIRPORT;

-- null airport keys = 3 expexted for ('XWA', 'EAR', 'BIH')
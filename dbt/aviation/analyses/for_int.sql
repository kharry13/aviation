SELECT
    COUNT(*) AS connections,
    COUNT_IF(previous_arrival_delay_minutes > 0) AS late_inbound_connections,
    COUNT_IF(previous_arrival_delay_minutes > 15) AS inbound_over_15,
    COUNT_IF(previous_arrival_delay_minutes > 30) AS inbound_over_30,
    COUNT_IF(previous_arrival_delay_minutes > 60) AS inbound_over_60
FROM AVIATION_DB.STAGING.INT_AIRCRAFT_CONNECTIONS;
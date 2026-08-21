SELECT
    COUNT(*) AS connections,

    COUNT_IF(previous_arrival_delay_minutes > 0)
        AS late_inbound_connections,

    COUNT_IF(
        previous_arrival_delay_minutes > 0
        AND current_departure_delay_minutes > 0
    ) AS next_flight_also_delayed,

    ROUND(
        100.0 *
        COUNT_IF(
            previous_arrival_delay_minutes > 0
            AND current_departure_delay_minutes > 0
        )
        /
        NULLIF(
            COUNT_IF(previous_arrival_delay_minutes > 0),
            0
        ),
        2
    ) AS propagation_rate_pct

FROM AVIATION_DB.INTERMEDIATE.INT_AIRCRAFT_CONNECTIONS;
SELECT
    buffer_bucket,
    COUNT(*) AS connections
FROM AVIATION_DB.MARTS.FCT_AIRCRAFT_CONNECTIONS
GROUP BY buffer_bucket
ORDER BY
    CASE buffer_bucket
        WHEN '<0' THEN 1
        WHEN '0-5' THEN 2
        WHEN '5-15' THEN 3
        WHEN '15-30' THEN 4
        WHEN '30-60' THEN 5
        WHEN '60+' THEN 6
    END;
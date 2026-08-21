{{ config(materialized='table') }}

WITH sequence AS (

    SELECT *
    FROM {{ ref('int_aircraft_sequence') }}

    WHERE valid_aircraft_connection = TRUE

),

metrics AS (

    SELECT

        flight_date,
        tail_number,

        previous_flight_number,
        flight_number AS current_flight_number,

        previous_destination AS connection_airport,
        origin AS current_origin,
        destination AS current_destination,

        previous_scheduled_arrival_utc,
        scheduled_departure_utc AS current_scheduled_departure_utc,

        previous_arrival_utc,
        actual_departure_utc,

        previous_arrival_delay_minutes,
        departure_delay_minutes AS current_departure_delay_minutes,

        actual_turnaround_minutes,

        /*
        Scheduled turnaround:
        next flight's scheduled departure
        minus previous flight's scheduled arrival
        */

        DATEDIFF(
            minute,
            previous_scheduled_arrival_utc,
            scheduled_departure_utc
        ) AS scheduled_turnaround_minutes,

        /*
        Positive inbound delay consumes the scheduled buffer.
        */

        GREATEST(
            COALESCE(previous_arrival_delay_minutes, 0),
            0
        ) AS inbound_delay_consumed_minutes

    FROM sequence

),

final AS (

    SELECT

        *,

        /*
        Remaining buffer after absorbing the inbound delay.
        */

        scheduled_turnaround_minutes
            - inbound_delay_consumed_minutes
            AS remaining_buffer_minutes,

        /*
        Did the next flight depart late?
        */

        CASE
            WHEN current_departure_delay_minutes > 0
            THEN TRUE
            ELSE FALSE
        END AS next_flight_delayed,

        /*
        Delay that remains relative to the inbound delay.
        We cap this at zero.
        */

        GREATEST(
            COALESCE(current_departure_delay_minutes, 0)
            - GREATEST(
                COALESCE(previous_arrival_delay_minutes, 0),
                0
              ),
            0
        ) AS propagated_delay_minutes,

        /*
        Amount of inbound delay recovered.
        */

        GREATEST(
            GREATEST(
                COALESCE(previous_arrival_delay_minutes, 0),
                0
            )
            - GREATEST(
                COALESCE(current_departure_delay_minutes, 0),
                0
            ),
            0
        ) AS recovered_delay_minutes

    FROM metrics

)

SELECT *
FROM final
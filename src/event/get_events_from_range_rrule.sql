DROP FUNCTION get_events_from_range_rrule(integer, integer, timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION get_events_from_range_rrule(
    user_id integer,
    e_calendar_id integer,
    e_frame_dt_start timestamp,
    e_frame_dt_end timestamp
)
    RETURNS TABLE
            (
                id          integer,
                calendar_id integer,
                title       text,
                dt_start    timestamp,
                dt_end      timestamp
            )
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    user_id alias for $1;
    e_calendar_id alias for $2;
    e_frame_dt_start alias for $3;
    e_frame_dt_end alias for $4;

BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(user_id, e_calendar_id);

    RETURN QUERY SELECT events.*
                 FROM (SELECT sq.id                     as id,
                              e_calendar_id             as calendar_id,
                              sq.title                  as title,
                              sq.dt_start               as dt_start,
                              sq.dt_start + sq.duration as dt_end
                       FROM (
                                SELECT event.id as id,
                                       event.title as title,
                                       unnest(get_occurrences(
                                               get_rrule_from_jsonb(event.rrule_json),
                                               event.dt_start, e_frame_dt_end)) as dt_start,
                                       event.duration                           as duration
                                FROM event
                                WHERE event.dt_frame_end >= e_frame_dt_start
                                  AND event.dt_frame_start <= e_frame_dt_end
                                  AND event.dt_start <= e_frame_dt_end
                                GROUP BY event.id, event.calendar_id) as sq
                     ) as events
                          FULL JOIN exception_event ex_e
                                    ON events.id = ex_e.event_id
                                        AND events.dt_end >= e_frame_dt_start
                                        AND events.dt_start <= e_frame_dt_end
                                        AND events.calendar_id = ex_e.calendar_id
                                        AND events.dt_start = ex_e.dt_start
                                        AND events.dt_end = ex_e.dt_end
                 WHERE ex_e.event_id IS NULL
                 ORDER BY events.dt_start;
END;
$Body$;
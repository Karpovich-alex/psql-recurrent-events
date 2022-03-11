
DROP FUNCTION get_events_from_range(integer, integer, timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION get_events_from_range(
    user_id integer,
    calendar_id integer,
    frame_dt_start timestamp,
    frame_dt_end timestamp
)
    RETURNS TABLE
            (
                e_id          integer,
                e_calendar_id integer,
                e_title       text,
                e_dt_start    timestamp,
                e_dt_end      timestamp
            )
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    user_id alias for $1;
    calendar_id alias for $2;
    frame_dt_start alias for $3;
    frame_dt_end alias for $4;

BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(user_id, calendar_id);

    RETURN QUERY SELECT events.*
                 FROM (SELECT sq.id                     as e_id,
                              calendar_id               as e_calendar_id,
                              sq.title                  as e_title,
                              sq.dt_start               as e_dt_start,
                              sq.dt_start + sq.duration as e_dt_end
                       FROM (
                                SELECT event.id,
                                       event.title,
                                       unnest(get_occurrences(
                                               STRING_AGG(UPPER(name) || '=' || UPPER(parameter_value), ';')::text,
                                               event.dt_start, event.dt_end)) as
                                                                                 dt_start,
                                       event.duration                         as duration
                                FROM event
                                         LEFT JOIN (pattern pat LEFT JOIN parameters par on pat.parameter_id = par.id) as params
                                                   on event.id = params.event_id and event.calendar_id = params.calendar_id
                                WHERE name IS NOT NULL
                                GROUP BY event.id, event.calendar_id) as sq) as events
                 WHERE events.e_dt_start NOT IN (SELECT dt_start
                                                 FROM exception_event as ex_e
                                                 WHERE ex_e.event_id = events.e_id
                                                   AND ex_e.calendar_id = events.e_calendar_id);
END ;
$Body$;

SELECT *
FROM get_events_from_range(1, 1, '2019-01-01 11:00'::timestamp, '2022-12-06 23:30'::timestamp);
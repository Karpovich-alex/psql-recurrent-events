-- Get events with parameters in json
SELECT event.id, event.title, event.dt_start, event.dt_end, json_object_agg(name, parameter_value) as parameters
FROM event
         LEFT JOIN (pattern pat LEFT JOIN parameters par on pat.parameter_id = par.id) as params
                   on event.id = params.eventid and event.calendar_id = params.calendar_id
WHERE name IS NOT NULL
GROUP BY event.id, event.calendar_id;

SELECT event.id, event.title, json_agg(name)
FROM event
         LEFT JOIN (pattern pat LEFT JOIN parameters par on pat.parameter_id = par.id) as params
                   on event.id = params.eventid and event.calendar_id = params.calendar_id
WHERE name IS NOT NULL
GROUP BY event.id, event.calendar_id;


-- Get users and calendars
SELECT username, c.id calendar_id, c.title, c.description
FROM users
         LEFT JOIN users_calendar uc on users.id = uc.user_id
         LEFT JOIN calendar c on uc.calendar_id = c.id;

DROP FUNCTION get_event(integer, integer, timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION get_event(
    user_id integer,
    calendar_id integer,
    dt_start timestamp,
    dt_end timestamp
)
    RETURNS TABLE (event_id integer,e_calendar_id integer,dt timestamp)
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    event record;
BEGIN
    -- Check if a calendar is available to a user

    PERFORM check_user_calendar(user_id, calendar_id);
    FOR event in SELECT e.id,
                         e.title,
                         e.description,
                         e.dt_start,
                         e.dt_end,
                         json_object_agg(name, parameter_value) as parameters
                  FROM event as e
                           LEFT JOIN (pattern pat LEFT JOIN parameters par on pat.parameter_id = par.id) as params
                                     on e.id = params.event_id
                  WHERE name IS NOT NULL
                    and e.dt_frame_end > $3
                    and e.dt_frame_start < $4
                  GROUP BY e.id
        LOOP
            IF event.description IS NOT NULL THEN
                RETURN NEXT (event.id, calendar_id, dt_start);
            end if;

            RAISE NOTICE '#%, %', event.id, event.title;
        end loop;
END ;
$Body$;
end;

SELECT *
FROM get_event(1, 1, '2020-01-01 11:00'::timestamp, '2022-02-06 23:30'::timestamp);

SELECT e.id,
       e.calendar_id,
       e.title,
       e.dt_start,
       e.dt_end,
       json_object_agg(name, parameter_value) as parameters
FROM event as e
         LEFT JOIN (pattern pat LEFT JOIN parameters par on pat.parameter_id = par.id) as params
                   on e.id = params.eventid and e.calendar_id = params.calendar_id
WHERE name IS NOT NULL
  and e.dt_frame_end > '2020-01-01'::timestamp
  and e.dt_frame_start < '2022-12-06'::timestamp
GROUP BY e.id, e.calendar_id;

CREATE EXTENSION pg_rrul;
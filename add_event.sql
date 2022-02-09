-- Add event and returns new event id

CREATE OR REPLACE FUNCTION add_event(
    user_id integer,
    calendar_id integer,
    e_title text,
    e_description text,
    dt_start timestamp,
    dt_end timestamp,
    params json
)
    RETURNS integer
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    calendar_ids users_calendar.calendar_id%type;
    event_id     event.id%type := -1;
BEGIN
    -- Check if a calendar is available to a user
    SELECT uc.calendar_id
    INTO calendar_ids
    from users
             LEFT JOIN users_calendar uc on users.id = uc.user_id
    WHERE users.id = $1
      and uc.calendar_id = $2;
    IF not FOUND
    THEN
        RAISE EXCEPTION 'User #% doesnt have Calendar #%', user_id, calendar_id;
    ELSE
        -- Add event to the calendar
        INSERT INTO event (calendar_id, title, description, dt_start, dt_end)
        VALUES (calendar_id,
                e_title,
                e_description,
                dt_start,
                dt_end)
        RETURNING id INTO event_id;
        -- Add parameters for the event
        INSERT INTO pattern
        SELECT event_id, calendar_id, id, value #>> '{}'
        FROM parameters as p
                 JOIN json_each(params) params ON params.key = p.name;

        RETURN event_id;
    END IF;
END;
$Body$;
end;

-- Error, the user does not have this calendar!
SELECT *
from add_event(1, 2, 'New event', 'Event has added from function',
               '2022-03-01 13:00'::timestamp,
               '2022-03-06 13:30'::timestamp,
               '{
                 "frequency": "2",
                 "count": "2",
                 "interval": "3"
               }'::json);

SELECT *
from add_event(1, 1, 'New event', 'Event has added from function',
               '2022-03-01 13:00'::timestamp,
               '2022-03-06 13:30'::timestamp,
               '{
                 "frequency": "2",
                 "count": "2",
                 "interval": "3",
                 "new rule": "1000"
               }'::json);
SELECT *
from add_event(1, 1, 'Second event', 'Event has added from function x2',
               '2021-03-01 09:00'::timestamp,
               '2021-03-06 12:30'::timestamp,
               '{
                 "until": "2021-03-06",
                 "count": "3",
                 "interval": "1"
               }'::json);
-- Add event and returns new event id
DROP FUNCTION add_exception_event(integer, integer, integer, timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION add_exception_event(
    user_id integer,
    calendar_id integer,
    event_id int,
    dt_start timestamp,
    dt_end timestamp
)
    RETURNS integer
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    exception_event_id exception_event.id%type := -1;
BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(user_id, calendar_id);
    -- Add exception event to the calendar
    INSERT INTO exception_event (event_id, calendar_id, dt_start, dt_end)
    VALUES (event_id,
            calendar_id,
            dt_start,
            dt_end)
    RETURNING id INTO exception_event_id;

    RETURN exception_event_id;
END;
$Body$;
end;

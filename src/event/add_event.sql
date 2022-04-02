-- Add event and returns new event id

CREATE OR REPLACE FUNCTION add_event(
    user_id integer,
    calendar_id integer,
    title text,
    description text,
    dt_start timestamp,
    dt_end timestamp,
    params jsonb
)
    RETURNS integer
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    user_id alias for $1;
    calendar_id alias for $2;
    title alias for $3;
    description alias for $4;
    dt_start alias for $5;
    dt_end alias for $6;
    params alias for $7;

    event_id       event.id%type := -1;
    dt_frame_start timestamp;
    dt_frame_end   timestamp;
BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(user_id, calendar_id);
    -- Validate rrule
    SELECT validate_rrule(params) INTO params;
    -- Add event to the calendar
    INSERT INTO event (calendar_id, title, description, dt_start, dt_end, rrule_json)
    VALUES (calendar_id,
            title,
            description,
            dt_start,
            dt_end,
            params)
    RETURNING id INTO event_id;

    RETURN event_id;
END;
$Body$;
end;

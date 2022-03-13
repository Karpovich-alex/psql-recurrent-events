-- Add event and returns new event id

CREATE OR REPLACE FUNCTION add_event(
    user_id integer,
    calendar_id integer,
    e_title text,
    e_description text,
    dt_start timestamp,
    dt_end timestamp,
    params jsonb
)
    RETURNS integer
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    event_id event.id%type := -1;
    dt_frame timestamp[2];
BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(user_id, calendar_id);
    -- Get dt_frame start and end
    SELECT * FROM get_dt_frame(dt_start, dt_end, params) INTO dt_frame;
    RAISE NOTICE 'end: %', dt_frame[2];
    -- Add event to the calendar
    INSERT INTO event (calendar_id, title, description, dt_start, dt_end, dt_frame_start, dt_frame_end)
    VALUES (calendar_id,
            e_title,
            e_description,
            dt_start,
            dt_end,
            dt_frame[1],
            dt_frame[2])
    RETURNING id INTO event_id;
    -- Add parameters for the event
    INSERT INTO pattern
    SELECT event_id, calendar_id, id, value #>> '{}'
    FROM parameters as p
             JOIN jsonb_each(params) params ON params.key = p.name;

    RETURN event_id;
END;
$Body$;
end;

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
    event_id       event.id%type := -1;
    dt_frame_start timestamp;
    dt_frame_end   timestamp;
BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(user_id, calendar_id);
    -- Get dt_frame start and end
    SELECT * INTO dt_frame_start, dt_frame_end FROM unnest(get_dt_frame(dt_start, dt_end, params));
    RAISE NOTICE 'end: %', dt_frame_end;
    -- Add event to the calendar
    INSERT INTO event (calendar_id, title, description, dt_start, dt_end, dt_frame_start, dt_frame_end)
    VALUES (calendar_id,
            e_title,
            e_description,
            dt_start,
            dt_end,
            dt_frame_start,
            dt_frame_end)
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

DROP FUNCTION get_dt_frame(timestamp, timestamp, jsonb);
CREATE OR REPLACE FUNCTION get_dt_frame(
    dt_start timestamp,
    dt_end timestamp,
    params jsonb)
    RETURNS timestamp[2]
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    last_day timestamp;
BEGIN
    -- Check if a calendar is available to a user
    IF params ? 'until' AND params ? 'count' THEN
        RAISE 'You cannot pass both until and count parameters';
    end if;
    IF params ? 'until' OR params ? 'count' THEN
        SELECT days
        INTO last_day
        FROM unnest(get_occurrences(get_rrule_from_json(params), dt_start)) as days
        ORDER BY days DESC
        LIMIT 1;
        --[dt_start, dt_end+duration of the event]
        RETURN array [dt_start, (last_day + (dt_end - dt_start))::timestamp];
    end if;
    RETURN array [dt_start, 'infinity'::timestamp];
END;
$Body$;
end;
-- "until": "20210306T120300Z",

CREATE OR REPLACE FUNCTION test_get_dt_frame(
    dt_start timestamp,
    dt_end timestamp,
    params jsonb
)
    RETURNS int
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    dt_frame_start timestamp;
    dt_frame_end   timestamp;
BEGIN
    SELECT dt_frame INTO dt_frame_start, dt_frame_end FROM unnest(get_dt_frame(dt_start, dt_end, params)) dt_frame;
    RAISE NOTICE 'start: %', dt_frame_start;
    RAISE NOTICE 'end: %', dt_frame_end;
    RETURN 1;
END;
$Body$;
end;

SELECT days
FROM unnest(get_occurrences(get_rrule_from_json(
                                    '{
                                      "count": "3",
                                      "interval": "1",
                                      "freq": "weekly"
                                    }'::jsonb), '2021-03-01 09:00'::timestamp)) as days
ORDER BY days DESC
LIMIT 1;

SELECT *
FROM unnest(get_dt_frame(
        '2021-03-01 09:00'::timestamp,
        '2021-03-10 12:30'::timestamp,
        '{
          "until": "20210306T120300Z",
          "interval": "1",
          "freq": "weekly"
        }'::jsonb));

-- 19980118T073000Z
SELECT to_char('2021-03-06 12:30'::timestamp, 'YYYYMMDDThhmmssZ');
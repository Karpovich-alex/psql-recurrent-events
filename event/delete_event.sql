CREATE OR REPLACE FUNCTION delete_event(user_id int, calendar_id int, event_id int)
    RETURNS integer
    LANGUAGE plpgsql
AS
$Body$
DECLARE
BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(user_id, calendar_id);
    -- Delete pattern
    DELETE FROM pattern pat WHERE pat.event_id = $3;
    -- Delete exception events
    DELETE FROM exception_event ex_e WHERE ex_e.calendar_id = $2 AND ex_e.event_id = $3;
    -- Delete event
    DELETE FROM event ev WHERE ev.id = $3;
    RETURN event_id;
END;
$Body$;
end;

CREATE OR REPLACE FUNCTION delete_exception_event(user_id int, calendar_id int, exception_event_id int)
    RETURNS integer
    LANGUAGE plpgsql
AS
$Body$
DECLARE
BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(user_id, calendar_id);
    -- Delete exception events
    DELETE FROM exception_event ex_e WHERE ex_e.calendar_id = $2 AND ex_e.id = $3;

    RETURN exception_event_id;
END;
$Body$;
end;
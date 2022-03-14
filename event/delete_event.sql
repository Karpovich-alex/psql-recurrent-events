CREATE OR REPLACE FUNCTION delete_event(user_id int, calendar_id int, event_id int)
    RETURNS integer
    LANGUAGE plpgsql
AS
$Body$
DECLARE
BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(user_id, calendar_id);
    -- Delete event
    DELETE FROM pattern pat WHERE pat.event_id = $3;
    DELETE FROM event ev WHERE ev.id = $3;

    RETURN event_id;
END;
$Body$;
end;
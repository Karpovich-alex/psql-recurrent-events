CREATE OR REPLACE FUNCTION update_event_params(user_id int, calendar_id int, event_id int, params jsonb)
    RETURNS integer
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    e_user_id alias for $1;
    e_calendar_id alias for $2;
    e_event_id alias for $3;
    params alias for $4;
    new_rrule_json jsonb;
BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(e_user_id, e_calendar_id);
    -- Validate new params
    SELECT validate_rrule(params) INTO params;
    -- Select old rrule
    SELECT rrule_json
    FROM event e
    WHERE e.calendar_id = e_calendar_id
      AND e.id = e_event_id
    INTO new_rrule_json;
    -- Union params
    new_rrule_json := new_rrule_json || params;
    -- Update rrule in the event table
    -- dt frame will be updated by trigger
    UPDATE event e
    SET rrule_json = new_rrule_json
    WHERE e.calendar_id = e_calendar_id
      AND e.id = e_event_id;

    RETURN event_id;
END;
$Body$;
end;

CREATE OR REPLACE FUNCTION set_event_params(user_id int, calendar_id int, event_id int, params jsonb)
    RETURNS integer
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    e_user_id alias for $1;
    e_calendar_id alias for $2;
    e_event_id alias for $3;
    params alias for $4;
BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(e_user_id, e_calendar_id);
    -- Validate new params
    SELECT validate_rrule(params) INTO params;
    -- Update rrule in the event table
    -- dt frame will be update by trigger
    UPDATE event e
    SET rrule_json = params
    WHERE e.calendar_id = e_calendar_id
      AND e.id = e_event_id;
    RETURN event_id;
END;
$Body$;
end;
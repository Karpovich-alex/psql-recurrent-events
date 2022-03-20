CREATE OR REPLACE FUNCTION delete_event_params(user_id int, calendar_id int, event_id int, params jsonb)
    RETURNS integer
    LANGUAGE plpgsql
AS
$Body$
DECLARE
BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(user_id, calendar_id);
    -- Delete event params
    DELETE FROM pattern pat WHERE pat.event_id = $3;

    UPDATE event SET rrule = get_rrule_from_jsonb(params) WHERE calendar_id = $2 AND id = $3;

    INSERT INTO pattern (event_id, calendar_id, parameter_id, parameter_value)
    SELECT event_id, calendar_id, id, parameter_value
    FROM get_parameters(params);

    RETURN event_id;
END;
$Body$;
end;

CREATE OR REPLACE FUNCTION add_event_params(user_id int, calendar_id int, event_id int, params jsonb)
    RETURNS integer
    LANGUAGE plpgsql
AS
$Body$
DECLARE
BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(user_id, calendar_id);

    -- Insert new pattern to the event
    INSERT INTO pattern (event_id, calendar_id, parameter_id, parameter_value)
    SELECT event_id, calendar_id, id, parameter_value
    FROM get_parameters(params);

    -- Update rrule in event table
    UPDATE event SET rrule = get_rrule_from_jsonb(params) WHERE calendar_id = $2 AND id = $3;

    RETURN event_id;
END;
$Body$;
end;

-- Use to set/change rrule params
CREATE TEMP TABLE params_resolved (id int, parameter_value text)
    ON COMMIT DELETE ROWS;
CREATE OR REPLACE FUNCTION set_event_params(user_id int, calendar_id int, event_id int, params jsonb)
    RETURNS integer
    LANGUAGE plpgsql
AS
$Body$
DECLARE
BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(user_id, calendar_id);
    -- Select id for params
    INSERT INTO params_resolved SELECT id, parameter_value FROM get_parameters(params);
    -- Delete old params
    DELETE FROM pattern pat WHERE pat.event_id = $3 AND pat.parameter_id IN (SELECT id FROM params_resolved);
    -- Insert new params
    INSERT INTO pattern (event_id, calendar_id, parameter_id, parameter_value)
    SELECT $3, $2, p_r.id, p_r.parameter_value
    FROM params_resolved p_r;
    -- Update rrule in event table
    UPDATE event e SET rrule = get_rrule_from_jsonb(params) WHERE e.calendar_id = $2 AND e.id = $3;

    RETURN event_id;
END;
$Body$;
end;
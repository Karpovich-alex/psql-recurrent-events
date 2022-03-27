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
    -- Select old rrule
    SELECT rrule_json
    FROM event e
    WHERE e.calendar_id = e_calendar_id
      AND e.id = e_event_id
    INTO new_rrule_json;
    -- Union params
    new_rrule_json := new_rrule_json || params;
    -- Update rrule in the event table
    -- dt frame will be update by trigger
    UPDATE event e
    SET rrule_json=validate_rrule(new_rrule_json)
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
    dt_frame timestamp[2];
BEGIN
    -- Check if a calendar is available to a user
    PERFORM check_user_calendar(e_user_id, e_calendar_id);
    -- Update rrule in the event table
    -- dt frame will be update by trigger
    UPDATE event e
    SET rrule_json=validate_rrule(params)
    WHERE e.calendar_id = e_calendar_id
      AND e.id = e_event_id;
    RETURN event_id;
END;
$Body$;
end;

-- Trigger for updating dt frame corresponding to the rule
CREATE FUNCTION dt_frame_update() RETURNS trigger AS
$dt_frame_update$
BEGIN
    IF NEW.rrule_json IS NOT NULL AND (OLD.rrule_json != NEW.rrule_json OR OLD.rrule_json IS NULL) THEN
        SELECT dt_start, dt_end
        FROM get_dt_frame(NEW.dt_start, NEW.dt_end, NEW.rrule_json)
        INTO NEW.dt_frame_start, NEW.dt_frame_end;
    END IF;
    RETURN NEW;
END;
$dt_frame_update$ LANGUAGE plpgsql;

CREATE TRIGGER event_dt_frame_update
    BEFORE INSERT OR UPDATE
    ON event
    FOR EACH ROW
EXECUTE FUNCTION dt_frame_update();
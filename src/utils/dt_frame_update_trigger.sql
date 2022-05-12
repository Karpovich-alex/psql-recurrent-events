-- Trigger for updating dt frame corresponding to the rule
CREATE FUNCTION dt_frame_update() RETURNS trigger AS
$dt_frame_update$
BEGIN
    IF NEW.rrule_json IS NOT NULL AND
       (OLD.rrule_json != NEW.rrule_json OR OLD.rrule_json IS NULL OR
        NEW.dt_start != OLD.dt_start OR NEW.dt_end != OLD.dt_end) THEN
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
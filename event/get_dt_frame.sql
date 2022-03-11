
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
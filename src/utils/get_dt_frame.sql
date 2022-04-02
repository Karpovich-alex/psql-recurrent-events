CREATE TYPE timestamp_array_2 as
(
    dt_start timestamp,
    dt_end   timestamp
);

CREATE OR REPLACE FUNCTION get_dt_frame(
    dt_start timestamp,
    dt_end timestamp,
    params jsonb)
    RETURNS SETOF timestamp_array_2
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    last_day      timestamp;
    return_record timestamp_array_2%ROWTYPE;
BEGIN
    -- Check if params have until or count.
    IF params ? 'UNTIL' OR params ? 'COUNT' THEN
        SELECT days
        INTO last_day
        FROM unnest(get_occurrences(get_rrule_from_jsonb(params), dt_start)) as days
        ORDER BY days DESC
        LIMIT 1;
        --[dt_start, dt_end+duration of the event]
        return_record.dt_start = dt_start;
        return_record.dt_end = (last_day + (dt_end - dt_start))::timestamp;
        RETURN NEXT return_record;
    ELSE
        -- Otherwise params don't have both until and count => this event have no end.
        return_record.dt_start = dt_start;
        return_record.dt_end = 'infinity'::timestamp;
        RETURN NEXT return_record;
    END IF;
END;
$Body$;
end;
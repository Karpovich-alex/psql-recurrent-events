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
    dt_frame     timestamp[2];
    dt_frame_end timestamp;
BEGIN
    SELECT * FROM get_dt_frame(dt_start, dt_end, params) INTO dt_frame;
    RAISE NOTICE 'start: %', dt_frame[1];
    RAISE NOTICE 'end: %', dt_frame[2];
    RETURN 1;
END;
$Body$;
end;

SELECT test_get_dt_frame(
               '2021-03-01 09:00'::timestamp,
               '2021-03-01 12:30'::timestamp,
               '{
                 "until": "20210306T120300Z",
                 "interval": "1",
                 "freq": "WEEKLY"
               }'::jsonb);

DROP FUNCTION test_get_dt_frame(dt_start timestamp, dt_end timestamp, params jsonb);
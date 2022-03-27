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
    dt_frame     timestamp;
    dt_frame_end timestamp;
BEGIN
    SELECT * FROM get_dt_frame(dt_start, dt_end, params) INTO dt_frame, dt_frame_end;
    RAISE NOTICE 'start: %', dt_frame;
    RAISE NOTICE 'end: %', dt_frame_end;
    RETURN 1;
END;
$Body$;
end;

SELECT test_get_dt_frame(
               '2021-03-01 09:00'::timestamp,
               '2021-03-01 12:30'::timestamp,
               '{"FREQ": "WEEKLY", "UNTIL": "20210310T120000Z", "INTERVAL": "1"}'::jsonb);

DROP FUNCTION test_get_dt_frame(dt_start timestamp, dt_end timestamp, params jsonb);

SELECT * FROM get_dt_frame('2021-03-01 09:00'::timestamp,
               '2021-03-01 12:30'::timestamp, '{"FREQ": "WEEKLY", "UNTIL": "20210306T120000Z", "INTERVAL": "1"}'::jsonb) as dt;
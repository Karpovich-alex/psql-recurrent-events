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
    dt_frame_start timestamp;
    dt_frame_end   timestamp;
BEGIN
    SELECT dt_frame INTO dt_frame_start, dt_frame_end FROM unnest(get_dt_frame(dt_start, dt_end, params)) dt_frame;
    RAISE NOTICE 'start: %', dt_frame_start;
    RAISE NOTICE 'end: %', dt_frame_end;
    RETURN 1;
END;
$Body$;
end;


SELECT *
FROM unnest(get_dt_frame(
        '2021-03-01 09:00'::timestamp,
        '2021-03-10 12:30'::timestamp,
        '{
          "until": "20210306T120300Z",
          "interval": "1",
          "freq": "weekly"
        }'::jsonb));

SELECT test_get_dt_frame(
               '2021-03-01 09:00'::timestamp,
               '2021-03-01 12:30'::timestamp,
               '{
                 "until": "20210306T120300Z",
                 "interval": "1",
                 "freq": "WEEKLY"
               }'::jsonb);

SELECT unnest(get_dt_frame('2021-03-01 09:00'::timestamp,
                           '2021-03-01 12:30'::timestamp,
                           '{
                             "until": "20210306T120300Z",
                             "interval": "1",
                             "freq": "WEEKLY"
                           }'::jsonb));
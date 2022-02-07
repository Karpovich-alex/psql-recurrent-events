DROP FUNCTION recurring_events_for();
CREATE OR REPLACE FUNCTION recurring_events_for(
  range_start timestamptz,
  range_end  timestamptz
)
    RETURNS SETOF event
    LANGUAGE plpgsql
AS
$BODY$
DECLARE
    _event event;
BEGIN
    --     DECLARE
--         quantity integer := 80;
--     BEGIN
--         RAISE NOTICE 'Quantity here is %', quantity; -- Prints 80
--     END;
    FOR _event IN
        SELECT * FROM event WHERE range_start<_event.end_date::timestamptz and _event.start_date::timestamptz<range_end
        LOOP
        RETURN NEXT _event;
        end loop;
    RETURN;
END
$BODY$;

SELECT *
FROM recurring_events_for(to_timestamp(1643734763), to_timestamp(1644512363));
SELECT * FROM to_timestamp(1643734763) WHERE to_timestamp(1643734763)>to_timestamp(1644512363);
SELECT *
FROM event;
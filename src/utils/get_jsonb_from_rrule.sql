-- DOES NOT WORK!
-- RRULE:FREQ=YEARLY;UNTIL=20000131T090000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA
CREATE OR REPLACE FUNCTION get_jsonb_from_rrule(rrule text)
    RETURNS jsonb
    LANGUAGE plpgsql
AS
$Body$
BEGIN
    RETURN (SELECT STRING_AGG(UPPER(jsn.key) || '=' || UPPER(jsn.value), ';')::text
            FROM (SELECT 1 as grouper, * FROM jsonb_each_text(rrule)) as jsn
            GROUP BY grouper);
END;
$Body$;
end;

SELECT * FROM regexp_replace('RRULE:FREQ=YEARLY;UNTIL=20000131T090000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA', 'RRULE:\s?', '');
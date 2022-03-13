CREATE OR REPLACE FUNCTION get_rrule_from_jsonb(rrule jsonb)
    RETURNS text
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
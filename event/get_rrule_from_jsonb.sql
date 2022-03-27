CREATE OR REPLACE FUNCTION get_rrule_from_jsonb(rrule jsonb)
    RETURNS text
    LANGUAGE plpgsql
AS
$Body$
DECLARE
BEGIN
    RETURN (SELECT STRING_AGG(UPPER(jsn.parameter_name) || '=' || UPPER(jsn.value), ';')::text
            FROM (SELECT 1 as grouper, parameter_name, STRING_AGG(parameter_value, ',') as value
                  FROM unnest_parameters(rrule)
                  GROUP BY parameter_name) as jsn
            GROUP BY grouper);
END;
$Body$;
end;

CREATE OR REPLACE FUNCTION get_rrule_for_event(event_id int, calendar_id int)
    RETURNS text
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    e_event_id alias for $1;
    e_calendar_id alias for $2;
BEGIN
    RETURN (SELECT get_rrule_from_jsonb(e.rrule_json)
            FROM event e
            WHERE e.id = e_event_id AND e.calendar_id = e_calendar_id);
END;
$Body$;
end;

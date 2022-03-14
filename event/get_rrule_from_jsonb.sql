CREATE OR REPLACE FUNCTION get_rrule_from_jsonb(rrule jsonb)
    RETURNS text
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    until text;
BEGIN
    SELECT to_char((rrule #>> '{until}')::timestamp without time zone, 'YYYYMMDDThhMIssZ')
    LIMIT 1
    INTO until;
    rrule = jsonb_set(rrule, '{until}', to_jsonb(until));
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
    RETURN (SELECT STRING_AGG(UPPER(sq.name) || '=' || sq.parameter_value, ';')
            FROM (SELECT pat.event_id                            as event_id,
                         pat.calendar_id                         as calendar_id,
                         par.name                                as name,
                         STRING_AGG(UPPER(parameter_value), ',') as parameter_value
                  FROM pattern pat
                           LEFT JOIN parameters par on pat.parameter_id = par.id
                  WHERE pat.event_id = e_event_id
                    AND pat.calendar_id = e_calendar_id
                  GROUP BY pat.event_id, pat.calendar_id, par.name) as sq
            GROUP BY sq.event_id, sq.calendar_id
            LIMIT 1);
END;
$Body$;
end;

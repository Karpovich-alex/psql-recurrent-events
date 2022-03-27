CREATE OR REPLACE FUNCTION validate_rrule(rrule jsonb)
    RETURNS jsonb
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    rrule alias for $1;
    until text;
BEGIN
    -- Uppercase all parameters and filter them using built in parameters
    SELECT jsonb_object_agg(jsn.parameter_name, jsn.value)
    FROM (SELECT 1                                       as grouper,
                 upper(parameter_name)                   as parameter_name,
                 string_agg(upper(parameter_value), ',') as value
          FROM unnest_parameters(rrule)
                   INNER JOIN parameters par on upper(parameter_name) = par.name
          GROUP BY parameter_name) as jsn
    GROUP BY grouper
    INTO rrule;
    -- Check if params have both until and count.
    IF rrule ? 'UNTIL' AND rrule ? 'COUNT' THEN
        RAISE 'You cannot pass both until and count parameters';
    end if;
    -- Change date until format to rrule format.
    IF rrule ? 'UNTIL' THEN
        SELECT to_char((rrule #>> '{UNTIL}')::timestamp without time zone, 'YYYYMMDDThhMIssZ')
        LIMIT 1
        INTO until;
        rrule = jsonb_set(rrule, '{UNTIL}', to_jsonb(until));
    END IF;
    RETURN rrule;
END;
$Body$;
end;

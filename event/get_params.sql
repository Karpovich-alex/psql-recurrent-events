DROP FUNCTION get_parameters(jsonb);

CREATE OR REPLACE FUNCTION get_parameters(params jsonb)
    RETURNS TABLE
            (
                id              int,
                parameter_value text
            )
    LANGUAGE plpgsql
AS
$Body$
BEGIN
    RETURN QUERY SELECT p.id, jsonb_array_elements_text(sq.value_)
                 FROM parameters as p
                          JOIN (
                     SELECT key,
                            CAST(CASE
                                     WHEN (value -> 1) IS NOT NULL
                                         THEN (value)
                                     ELSE to_jsonb(array [value])
                                END AS jsonb) as value_
                     FROM jsonb_each(params)) as sq ON sq.key = p.name;
END;
$Body$;
end;
DROP FUNCTION unnest_parameters(jsonb);

CREATE OR REPLACE FUNCTION unnest_parameters(params jsonb)
    RETURNS TABLE
            (
                parameter_name  text,
                parameter_value text
            )
    LANGUAGE plpgsql
AS
$Body$
BEGIN
    RETURN QUERY SELECT sq.key, jsonb_array_elements_text(sq.value_)
                 FROM (
                          SELECT key,
                                 CAST(CASE
                                          WHEN (value -> 1) IS NOT NULL
                                              THEN (value)
                                          ELSE to_jsonb(array [value])
                                     END AS jsonb) as value_
                          FROM jsonb_each(params)) as sq;
END;
$Body$;
end;
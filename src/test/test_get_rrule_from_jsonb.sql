SELECT days
FROM unnest(get_occurrences(get_rrule_from_jsonb(
                                    '{
                                      "count": "3",
                                      "interval": "1",
                                      "freq": "weekly"
                                    }'::jsonb), '2021-03-01 09:00'::timestamp)) as days
ORDER BY days;
-- 2021-03-01 09:00:00.000000, 2021-03-08 09:00:00.000000, 2021-03-15 09:00:00.000000

--get_rrule_from_json
SELECT get_rrule_from_jsonb('{
  "freq": "WEEKLY",
  "count": "2",
  "interval": "3"
}'::jsonb);

SELECT get_rrule_from_jsonb('{
  "count": "3",
  "interval": "1",
  "byday": [
    "SU",
    "MO",
    "TU",
    "WE",
    "TH",
    "FR",
    "SA"
  ]
}'::jsonb);

SELECT get_rrule_from_jsonb('{"BYDAY": "SU,MO,TU,WE,TH,FR,SA", "UNTIL": "20210306T120000Z", "INTERVAL": "1"}'::jsonb);
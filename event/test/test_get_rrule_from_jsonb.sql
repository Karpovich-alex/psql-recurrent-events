SELECT days
FROM unnest(get_occurrences(get_rrule_from_jsonb(
                                    '{
                                      "count": "3",
                                      "interval": "1",
                                      "freq": "weekly"
                                    }'::jsonb), '2021-03-01 09:00'::timestamp)) as days
ORDER BY days;
-- DESC LIMIT 1
-- 2021-03-01 09:00:00.000000, 2021-03-08 09:00:00.000000, 2021-03-15 09:00:00.000000

--get_rrule_from_json
SELECT get_rrule_from_jsonb('{
  "freq": "WEEKLY",
  "count": "2",
  "interval": "3"
}'::jsonb);

SELECT get_rrule_from_jsonb('{
  "until": "2021-03-06",
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

SELECT * FROM get_rrule_for_event(14,1)
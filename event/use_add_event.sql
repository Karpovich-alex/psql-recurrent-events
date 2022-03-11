-- Error, the user does not have this calendar!
SELECT *
from add_event(1, 2, 'New event', 'Event has added from function',
               '2022-03-01 13:00'::timestamp,
               '2022-03-06 13:30'::timestamp,
               '{
                 "frequency": "2",
                 "count": "2",
                 "interval": "3"
               }'::jsonb);

SELECT *
from add_event(1, 1, 'New event', 'Event has added from function',
               '2022-03-01 13:00'::timestamp,
               '2022-03-06 13:30'::timestamp,
               '{
                 "frequency": "2",
                 "count": "2",
                 "interval": "3",
                 "new rule": "1000"
               }'::jsonb);

SELECT add_event(1, 1, 'Second event', 'Event has added from function x2',
                 '2021-03-01 09:00'::timestamp,
                 '2021-03-06 12:30'::timestamp,
                 '{
                   "until": "2021-03-06",
                   "count": "3",
                   "interval": "1"
                 }'::jsonb);

SELECT add_event(1, 1, 'Third event', 'Event has added from function x2',
                 '2021-03-01 09:00'::timestamp,
                 '2021-03-06 12:30'::timestamp,
                 '{
                   "until": "2021-03-06",
                   "freq": "weekly",
                   "interval": "1"
                 }'::jsonb);

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

--get_rrule_from_json
SELECT get_rrule_from_json('{
  "freq": "WEEKLY",
  "count": "2",
  "interval": "3"
}'::jsonb)
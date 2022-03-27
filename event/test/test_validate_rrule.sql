SELECT validate_rrule(
               '{
                 "freq": "weekly",
                 "BYDAY": "MO",
                 "UNTIL": "20220331T000000Z",
                 "lol": "kek"
               }'::jsonb);

SELECT validate_rrule('{
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

SELECT validate_rrule('{
  "until": "2021-03-06",
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
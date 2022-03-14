SELECT *
FROM unnest_parameters('{
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
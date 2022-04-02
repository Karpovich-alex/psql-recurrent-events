-- Add some users and calendars
INSERT INTO calendar (title)
VALUES ('First calendar'),
       ('Second calendar');
INSERT INTO users (username)
VALUES ('first user'),
       ('second user'),
       ('third user');
INSERT INTO users_calendar (user_id, calendar_id)
VALUES (1, 1),
       (1, 2);

-- Check if any events exist
SELECT *
FROM event;

SELECT add_event(
               1,
               1,
               'Event #1',
               'This is an event description.',
               '20220301T090000'::timestamp,
               '20220301T103000'::timestamp,
               '{
                 "freq": "weekly",
                 "until": "20220331T000000Z"
               }'::jsonb);

SELECT add_event(1, 1,
                 'Event #2',
                 'This is an event description.',
                 '20220301T104500'::timestamp,
                 '20220301T121500'::timestamp,
                 '{
                   "FREQ": "weekly",
                   "BYDAY": "MO",
                   "UNTIL": "20220331T000000Z"
                 }'::jsonb);

SELECT *
FROM get_events_from_range_rrule(
        1,
        1,
        '20220301T090000'::timestamp,
        '20220401T103000'::timestamp
    );

SELECT add_exception_event(
    1,
    1,
    1,
    '20220315T090000'::timestamp,
    '20220315T103000'::timestamp);

SELECT *
FROM get_events_from_range(1, 1,
                           '20220301T090000'::timestamp,
                           '20220401T103000'::timestamp);

SELECT add_event(1, 1,
                 'Event #3',
                 'This is an event description.',
                 '20220301T104500'::timestamp,
                 '20220301T121500'::timestamp,
                 '{
                   "freq": "weekly",
                   "interval": "1",
                   "byday": [
                     "MO",
                     "WE",
                     "FR"
                   ],
                   "until": "20220331T000000Z"
                 }'::jsonb); -- Monday, Wednesday, Friday Every other week

SELECT *
FROM get_events_from_range(1, 1,
                           '20220321T090000'::timestamp,
                           '20220328T103000'::timestamp);

SELECT delete_event(1, 1, 1);

SELECT update_event_params(
               1,
               1,
               7,
               '{
                 "BYDAY": [
                   "WE",
                   "FR",
                   "MO"
                 ]
               }'::jsonb);

SELECT update_event_params(1, 1, 10, '{
  "FREQ": "WEEKLY"
}'::jsonb);

SELECT *
FROM get_rrule_for_event(3, 1);

SELECT *
FROM get_events_from_range(1, 1,
                           '20220321T090000'::timestamp,
                           '20220328T103000'::timestamp);
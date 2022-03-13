INSERT INTO calendar (title)
VALUES ('First calendar');
INSERT INTO users (username)
VALUES ('first user'),
       ('second user'),
       ('third user');
INSERT INTO users_calendar (user_id, calendar_id)
VALUES (1, 1);

SELECT add_event(1, 1, 'First event', '', '19980101T090000'::timestamp, '19980101T103000'::timestamp, '{
  "freq": "YEARLY",
  "until": "20000131T090000Z",
  "bymonth": 1,
  "byday": "SU"
}'::jsonb);

SELECT add_event(1, 1, 'Second event', '', '20220203T090000'::timestamp, '20220203T113000'::timestamp, '{
  "freq": "weekly",
  "count": "10"
}'::jsonb);
SELECT add_event(1, 1, 'Second event', '', '20210103T090000'::timestamp, '20210203T113000'::timestamp, '{
  "freq": "daily",
  "bymonth": 1,
  "until": "20230131T090000Z"
}'::jsonb);
--  RRULE:FREQ=YEARLY;UNTIL=20000131T090000Z;
--    BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA
-- {"freq"=""yearly","until" = "20000131T090000Z", "bymonth": 1, "BYDAY" = "SU} RRULE:\s?([A-Z]+=(.+)\;)
SELECT *
FROM unnest(string_to_array(
        regexp_replace('RRULE:FREQ=YEARLY;UNTIL=20000131T090000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA', 'RRULE:\s?',
                       ''), ';'));
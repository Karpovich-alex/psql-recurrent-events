INSERT INTO calendar (title)
VALUES ('First calendar');
INSERT INTO event (calendar_id, title, dt_start, dt_end)
VALUES (1, 'event_1', '2022-02-01 11:00'::timestamp, '2022-03-06 12:30'::timestamp),
       (1, 'event_2', '2022-01-01 09:00'::timestamp, '2022-01-06 11:20'::timestamp);
INSERT INTO pattern (event_id, calendar_id, parameter_id, parameter_value)
VALUES (1, 1, 1, 'weekly'),
       (1, 1, 2, '3'),
       (1, 1, 4, 2);
INSERT INTO users (username)
VALUES ('first user'),
       ('second user'),
       ('third user');
INSERT INTO users_calendar (user_id, calendar_id)
VALUES (1, 1);
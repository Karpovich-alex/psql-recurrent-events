CREATE TABLE users
(
    id       SERIAL PRIMARY KEY,
    username text NOT NULL
);
CREATE TABLE calendar
(
    id          SERIAL PRIMARY KEY,
    title       text NOT NULL,
    description text
);
CREATE TABLE users_calendar
(
    user_id     integer REFERENCES users (id),
    calendar_id integer REFERENCES calendar (id),
    CONSTRAINT users_calendar_pkey PRIMARY KEY (user_id, calendar_id)
);
CREATE TABLE event
(
    id          SERIAL,
    calendar_id integer REFERENCES calendar (id),
    title       text NOT NULL,
    description text,
    start_date  date,
    end_date    date,
    start_time  time,
    end_time    time,
    PRIMARY KEY (id, calendar_id)
);
CREATE TABLE parameters
(
    id   SERIAL PRIMARY KEY,
    name text NOT NULL
);
CREATE TABLE pattern
(
    event_id        integer                            NOT NULL,
    calendar_id     integer                            NOT NULL,
    parameter_id    integer REFERENCES parameters (id) NOT NULL,
    parameter_value text                               NOT NULL,
    CONSTRAINT pattern_pkey PRIMARY KEY (event_id, calendar_id, parameter_id),
    FOREIGN KEY (event_id, calendar_id) REFERENCES event (id, calendar_id)
);
CREATE TABLE exception_event
(
    id          integer PRIMARY KEY,
    event_id    integer NOT NULL,
    calendar_id integer NOT NULL,
    start_date  date,
    end_date    date,
    start_time  time,
    end_time    time,
    FOREIGN KEY (event_id, calendar_id) REFERENCES event (id, calendar_id)
);
INSERT INTO parameters (name)
VALUES ('frequency'),
       ('count'),
       ('until'),
       ('interval'),
       ('by_day'),
       ('by_month'),
       ('by_month_day');
INSERT INTO calendar (title)
VALUES ('First calendar');
INSERT INTO event (calendar_id, title, start_date, end_date, start_time, end_time)
VALUES (1, 'event_1', '2022-02-01'::date, '2022-02-06'::date, '11:00'::time, '12:30'::time),
       (1, 'event_2', '2022-01-01'::date, '2022-01-06'::date, '09:00'::time, '11:20'::time);
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
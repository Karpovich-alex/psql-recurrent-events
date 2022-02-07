CREATE TABLE users
(
    id       integer PRIMARY KEY,
    username text NOT NULL
);
CREATE TABLE calendar
(
    id          integer PRIMARY KEY,
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
    id          integer,
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
    id   integer PRIMARY KEY,
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
INSERT INTO parameters (id, name)
VALUES (1, 'frequency'),
       (2, 'count'),
       (3, 'until'),
       (4, 'interval'),
       (5, 'by_day'),
       (6, 'by_month'),
       (7, 'by_month_day');
INSERT INTO calendar (id, title)
VALUES (1, 'First calendar');
INSERT INTO event (id, calendar_id, title, start_date, end_date, start_time, end_time)
VALUES (1, 1, 'event_1', 01 - 02 - 2022, 06 - 02 - 2022, 1100, 1230),
       (2, 1, 'event_2');
INSERT INTO pattern (event_id, calendar_id, parameter_id, parameter_value)
VALUES (1, 1, 1, 'weekly'),
       (1, 1, 2, '3'),
       (1, 1, 4, 2);
INSERT INTO users (id, username)
VALUES (1, 'first user'),
       (2, 'second user'),
       (3, 'third user');
INSERT INTO users_calendar (user_id, calendar_id)
VALUES (1, 1);

UPDATE event
SET start_date='2022-02-01'::date,
    end_date='2022-02-06'::date,
    start_time='11:00'::time,
    end_time='12:30'::time
WHERE id = 1;
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
INSERT INTO event (id, calendar_id, title)
VALUES (1, 1, 'event_1'),
       (2, 1, 'event_2');
INSERT INTO pattern (event_id, calendar_id, parameter_id, parameter_value)
VALUES (1, 1, 1, 'weekly'),
       (1, 1, 2, '3'),
       (1, 1, 4, 2);

SELECT event.id, event.title, json_object_agg(name, parameter_value)
FROM event
         LEFT JOIN (pattern pat LEFT JOIN parameters par on pat.parameter_id = par.id) as params
                   on event.id = params.event_id and event.calendar_id = params.calendar_id
WHERE name IS NOT NULL
GROUP BY event.id, event.calendar_id;

SELECT event.id, event.title, json_agg(name)
FROM event
         LEFT JOIN (pattern pat LEFT JOIN parameters par on pat.parameter_id = par.id) as params
                   on event.id = params.event_id and event.calendar_id = params.calendar_id
WHERE name IS NOT NULL
GROUP BY event.id, event.calendar_id;
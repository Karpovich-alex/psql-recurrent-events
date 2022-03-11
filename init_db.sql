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
    id             SERIAL,
    calendar_id    integer REFERENCES calendar (id),
    title          text NOT NULL,
    description    text,
    dt_start       timestamp,
    dt_end         timestamp,
    dt_frame_start timestamp,
    dt_frame_end   timestamp,
    duration       interval GENERATED ALWAYS AS (dt_end - dt_start) STORED,
    PRIMARY KEY (id, calendar_id)
);
CREATE TABLE parameters
(
    id   SERIAL PRIMARY KEY,
    name text NOT NULL,
    type text NOT NULL
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
    event_id    integer NOT NULL,
    calendar_id integer NOT NULL,
    dt_start    timestamp,
    CONSTRAINT exception_event_pkey PRIMARY KEY (event_id, calendar_id),
    FOREIGN KEY (event_id, calendar_id) REFERENCES event (id, calendar_id)
);
INSERT INTO parameters (name, type)
VALUES ('freq', 'integer'),
       ('count', 'integer'),
       ('until', 'date'),
       ('interval', 'integer'),
       ('bysecond', 'integer[]'),
       ('byminute', 'integer[]'),
       ('byhour', 'integer[]'),
       ('byday', 'text[]'),
       ('bmonth', 'integer[]'),
       ('by_month_day', 'integer[]'),
       ('wkst', 'text[]');

CREATE EXTENSION pg_rrule;
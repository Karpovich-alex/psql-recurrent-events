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
    rrule_json     jsonb,
    PRIMARY KEY (id, calendar_id)
);
CREATE TABLE parameters
(
    id   SERIAL PRIMARY KEY,
    name text NOT NULL,
    type text NOT NULL
);
-- CREATE TABLE pattern
-- (
--     event_id        integer                            NOT NULL,
--     calendar_id     integer                            NOT NULL,
--     parameter_id    integer REFERENCES parameters (id) NOT NULL,
--     parameter_value text                               NOT NULL,
--     CONSTRAINT pattern_pkey PRIMARY KEY (event_id, calendar_id, parameter_id, parameter_value),
--     FOREIGN KEY (event_id, calendar_id) REFERENCES event (id, calendar_id)
-- );
CREATE TABLE exception_event
(
    id          SERIAL PRIMARY KEY,
    event_id    integer NOT NULL,
    calendar_id integer NOT NULL,
    dt_start    timestamp,
    dt_end      timestamp,
    FOREIGN KEY (event_id, calendar_id) REFERENCES event (id, calendar_id)
);
INSERT INTO parameters (name, type)
VALUES ('FREQ', 'integer'),
       ('COUNT', 'integer'),
       ('UNTIL', 'date'),
       ('INTERVAL', 'integer'),
       ('BYSECOND', 'integer[]'),
       ('BYMINUTE', 'integer[]'),
       ('BYHOUR', 'integer[]'),
       ('BYDAY', 'text[]'),
       ('BYWEEKNO', 'integer[]'),
       ('BYMONTH', 'integer[]'),
       ('BYMONTHDAY', 'integer[]'),
       ('BYYEARDAY', 'integer[]'),
       ('BYSETPOS', 'integer[]'),
       ('WKST', 'text[]');

-- CREATE EXTENSION pg_rrule;
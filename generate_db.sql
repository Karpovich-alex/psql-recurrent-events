CREATE TABLE event (
    id integer PRIMARY KEY,
    description text
);
CREATE TABLE parameters (
    id integer PRIMARY KEY,
    name text
);
CREATE TABLE pattern (
    event_id integer REFERENCES event (id),
    parameter_id integer REFERENCES parameters(id)
);
INSERT INTO parameters (id, name) VALUES
                                         (1, 'frequency'),
                                         (2, 'count');

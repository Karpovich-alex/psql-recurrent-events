SELECT to_char('2021-03-06 12:30'::timestamp, 'YYYYMMDDThhmmssZ');

-- Get events with parameters in json
SELECT event.id,
       event.title,
       event.dt_start,
       event.dt_end,
       json_object_agg(UPPER(params.name), UPPER(params.parameter_value)) ->> 0 as parameters
FROM event
         LEFT JOIN (pattern pat LEFT JOIN parameters par on pat.parameter_id = par.id) as params
                   on event.id = params.event_id and event.calendar_id = params.calendar_id
WHERE params.name IS NOT NULL
GROUP BY event.id, event.calendar_id;

SELECT event.id,
       event.title,
       event.dt_start,
       event.dt_end,
       event.dt_frame_start,
       event.dt_frame_end,
       jsonb_object_agg(UPPER(name), UPPER(parameter_value)) as parameters
FROM event
         LEFT JOIN (pattern pat LEFT JOIN parameters par on pat.parameter_id = par.id) as params
                   on event.id = params.event_id and event.calendar_id = params.calendar_id
WHERE name IS NOT NULL
GROUP BY event.id, event.calendar_id;

SELECT sq.id                     as e_id,
       sq.title                  as e_title,
       sq.dt_start               as e_dt_start,
       sq.dt_start + sq.duration as e_dt_end
FROM (
         SELECT event.id,
                event.title,
                unnest(get_occurrences(STRING_AGG(UPPER(name) || '=' || UPPER(parameter_value), ';')::text,
                                       event.dt_start, event.dt_end)) as
                                                                         dt_start,
                event.duration                                        as duration
         FROM event
                  LEFT JOIN (pattern pat LEFT JOIN parameters par on pat.parameter_id = par.id) as params
                            on event.id = params.event_id and event.calendar_id = params.calendar_id
         WHERE name IS NOT NULL
         GROUP BY event.id, event.calendar_id) as sq;

-- Get users and calendars
SELECT username, c.id calendar_id, c.title, c.description
FROM users
         LEFT JOIN users_calendar uc on users.id = uc.user_id
         LEFT JOIN calendar c on uc.calendar_id = c.id;

SELECT event.id,
       event.title,
       unnest(get_occurrences(
               STRING_AGG(UPPER(name) || '=' || UPPER(parameter_value), ';')::text,
               '1996-01-01 11:00'::timestamp, '1998-12-06 23:30'::timestamp)) as
                                                                                 dt_start,
       event.duration                                                         as duration
FROM event
         LEFT JOIN (pattern pat LEFT JOIN parameters par on pat.parameter_id = par.id) as params
                   on event.id = params.event_id and event.calendar_id = params.calendar_id
WHERE name IS NOT NULL
GROUP BY event.id, event.calendar_id;

SELECT event.id,
       event.title,
       STRING_AGG(UPPER(name) || '=' || UPPER(parameter_value), ';') as dt_start
FROM event
         LEFT JOIN (pattern pat LEFT JOIN parameters par on pat.parameter_id = par.id) as params
                   on event.id = params.event_id and event.calendar_id = params.calendar_id
WHERE name IS NOT NULL
  AND event.id = 4
GROUP BY event.id, event.title, event.calendar_id;

SELECT sq.id                     as e_id,
       sq.title                  as e_title,
       sq.dt_start               as e_dt_start,
       sq.dt_start + sq.duration as e_dt_end
FROM (
         SELECT event.id,
                event.title,
                unnest(get_occurrences(
                        STRING_AGG(UPPER(name) || '=' || UPPER(parameter_value), ';')::text,
                        event.dt_start, '2022-12-06 23:30'::timestamp)) as
                                                                           dt_start,
                event.duration                                          as duration
         FROM event
                  LEFT JOIN (pattern pat LEFT JOIN parameters par on pat.parameter_id = par.id) as params
                            on event.id = params.event_id and event.calendar_id = params.calendar_id
         AND name IS NOT NULL
           AND event.dt_frame_end >= '2000-01-01 11:00'::timestamp
           AND event.dt_frame_start <= '2022-12-06 23:30'::timestamp
         GROUP BY event.id, event.calendar_id) as sq
         LEFT JOIN exception_event ex_e
                   ON sq.id = ex_e.event_id;

SELECT * FROM (SELECT events.*, ex_e.*
                 FROM (SELECT sq.id                     as id,
                              1               as calendar_id,
                              sq.title                  as title,
                              sq.dt_start               as dt_start,
                              sq.dt_start + sq.duration as dt_end
                       FROM (
                                SELECT event.id,
                                       event.title,
                                       unnest(get_occurrences(
                                               STRING_AGG(UPPER(params.name) || '=' || UPPER(params.parameter_value),
                                                          ';')::text,
                                               event.dt_start, '2022-12-06 23:30'::timestamp)) as
                                                                                   dt_start,
                                       event.duration                           as duration
                                FROM event
                                         LEFT JOIN (pattern pat LEFT JOIN parameters par on pat.parameter_id = par.id) as params
                                                   ON event.id = params.event_id AND
                                                      event.calendar_id = params.calendar_id
                                                       AND params.name IS NOT NULL
                                                       AND event.dt_frame_end >= '2020-01-01 11:00'::timestamp
                                                       AND event.dt_frame_start <= '2022-12-06 23:30'::timestamp
                                WHERE event.dt_start <= '2022-12-06 23:30'::timestamp
                                GROUP BY event.id, event.calendar_id) as sq) as events
                          FULL JOIN exception_event ex_e
                                    ON events.id = ex_e.event_id
                                        AND events.dt_end >= '2020-01-01 11:00'::timestamp
                                        AND events.calendar_id = ex_e.calendar_id
                                        AND events.dt_start = ex_e.dt_start
                                        AND events.dt_end = ex_e.dt_end
    WHERE ex_e.event_id IS NULL) as tempr
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
       STRING_AGG(UPPER(name) || '=' || UPPER(parameter_value), ';') as parameters
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

-- STRING_AGG(UPPER(json_obj->1) || '=' || UPPER(json_obj->2), ';')::text
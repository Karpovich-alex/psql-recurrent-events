-- Получить события вместе с правилом
SELECT event.id, event.title, json_object_agg(name, parameter_value) as parameters
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

SELECT username, c.id, c.title, c.description FROM users LEFT JOIN users_calendar uc on users.id = uc.user_id LEFT JOIN calendar c on uc.calendar_id = c.id
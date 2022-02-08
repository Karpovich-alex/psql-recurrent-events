DROP FUNCTION IF EXISTS add_event(integer, integer, text, text, date, date, time without time zone,
                                  time without time zone,
                                  text[]);
-- Add event and returns new event id
CREATE OR REPLACE FUNCTION add_event(
    user_id integer,
    calendar_id integer,
    e_title text,
    e_description text,
    start_date date,
    end_date date,
    start_time time,
    end_time time,
    params json
)
    RETURNS integer
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    calendar_ids users_calendar.calendar_id%type;
    event_id     event.id%type := -1;
BEGIN
    -- Проверяем доступность календаря пользователю
    SELECT uc.calendar_id
    INTO calendar_ids
    from users
             LEFT JOIN users_calendar uc on users.id = uc.user_id
    WHERE users.id = $1
      and uc.calendar_id = $2;
    IF not FOUND
    THEN
        RAISE EXCEPTION 'User with id: % doesnt have Calendar with id %', user_id, calendar_id;
    ELSE
        RAISE NOTICE 'Calendar %  exists', calendar_ids;
        -- Добавляем событие в календарь
        INSERT INTO event (calendar_id, title, description, start_date, end_date, start_time, end_time)
        VALUES (calendar_id,
                e_title,
                e_description,
                start_date,
                end_date,
                start_time,
                end_time)
        RETURNING id INTO event_id;
        RAISE NOTICE 'Event % inserted', event_id;
        RAISE NOTICE 'Params: %', params;
        -- Добавляем параметры к событию
        INSERT INTO pattern
        SELECT event_id, calendar_id, id, value #>> '{}'
        FROM parameters as p
                 JOIN json_each(params) params ON params.key = p.name;

        RETURN event_id;
    END IF;
END;
$Body$;
end;

-- Ошибка, так как у пользователя нет такого календаря!
SELECT *
from add_event(1, 2, 'New event', 'Event has added from function',
               '2022-03-01'::date,
               '2022-03-06'::date,
               '13:00'::time,
               '13:30'::time,
               '{
                 "frequency": "2",
                 "count": "2",
                 "interval": "3"
               }'::json);

SELECT *
from add_event(1, 1, 'New event', 'Event has added from function',
               '2022-03-01'::date,
               '2022-03-06'::date,
               '13:00'::time,
               '13:30'::time,
               '{
                 "frequency": "2",
                 "count": "2",
                 "interval": "3",
                 "new rule": "1000"
               }'::json);
SELECT *
from add_event(1, 1, 'Second event', 'Event has added from function x2',
               '2021-03-01'::date,
               '2021-03-06'::date,
               '09:00'::time,
               '12:30'::time,
               '{
                 "until": "2021-03-06",
                 "count": "3",
                 "interval": "1"
               }'::json);
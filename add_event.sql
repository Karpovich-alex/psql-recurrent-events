DROP FUNCTION add_event(integer, integer, text, text, date, date, time without time zone, time without time zone,
                        text[]);
CREATE OR REPLACE FUNCTION add_event(
    user_id integer,
    calendar_id integer,
    e_title text,
    e_description text,
    start_date date,
    end_date date,
    start_time time,
    end_time time,
    params text[][]
)
    RETURNS VOID
    LANGUAGE plpgsql
AS
$Body$
DECLARE
    calendar_ids  users_calendar.calendar_id%type;
    event_id      event.id%type := -1;
    param         parameters%rowtype;
    param_counter integer       := 1;
BEGIN
    SELECT uc.calendar_id
    INTO calendar_ids
    from users
             LEFT JOIN users_calendar uc on users.id = uc.user_id
    WHERE users.id = $1
      and uc.calendar_id = $2;
    IF not FOUND
    THEN
        RAISE NOTICE 'Calendar id doesnt exist';
    ELSE
        RAISE NOTICE 'Calendar %  exists', calendar_ids;
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
        RAISE NOTICE '_______________';
        FOR param in SELECT * FROM parameters as p WHERE p.name = ANY (params)
            LOOP
                RAISE NOTICE 'Params info: %', param.id;
                RAISE NOTICE 'Params info input: %', params[param_counter][2];
                RAISE NOTICE '_______________';
                INSERT INTO pattern (event_id, calendar_id, parameter_id, parameter_value)
                VALUES (event_id,
                        calendar_id,
                        param.id,
                        params[param_counter][2]);
                param_counter = param_counter + 1;
            end loop;
    END IF;
END;
$Body$;
end;

SELECT *
from add_event(1, 1, 'New event', 'Event has added from function',
               '2022-03-01'::date,
               '2022-03-06'::date,
               '13:00'::time,
               '13:30'::time,
               ARRAY [['frequency', '2'],['count', '3'],['interval', '3']]);
SELECT *
from add_event(1, 1, 'Second event', 'Event has added from function x2',
               '2021-03-01'::date,
               '2021-03-06'::date,
               '09:00'::time,
               '12:30'::time,
               ARRAY [['until', '2021-03-06'],['count', '3'],['interval', '1']]);
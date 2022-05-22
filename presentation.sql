INSERT INTO calendar (title)
VALUES ('Личный Календарь'),
        ('Недоступный календарь');

INSERT INTO users (username)
VALUES ('Пользователь №1');

INSERT INTO users_calendar (user_id, calendar_id)
VALUES (1, 1);

-- Сложные правила.
-- Валидация правил.
-- Добавить больше жизни в события.

-- Проверяем отсутствие событий.
SELECT *
FROM event;

-- Добавляем занятие. Невалидные правила отсекаются.
SELECT add_event(
               1,
               1,
               'Лекция по математическому анализу',
               'Улица Радищева.',
               '20220301T090000'::timestamp,
               '20220301T103000'::timestamp,
               '{
                 "freq": "weekly",
                 "until": "20220331T000000Z",
                 "NotARule": "FAKE"
               }'::jsonb);

-- Добавляем занятие в недоступный календарь
SELECT add_event(1, 2,
                 'Практическое занятие по философии',
                 'Улица Радищева.',
                 '20220301T104500'::timestamp,
                 '20220301T121500'::timestamp,
                 '{
                   "FREQ": "weekly",
                   "BYDAY": "MO",
                   "UNTIL": "20220331T000000Z"
                 }'::jsonb);

-- Добавляем еще одно занятие с более сложным правилом повторения.
SELECT add_event(1, 1,
                 'Практическое занятие по философии',
                 'Улица Радищева.',
                 '20220301T104500'::timestamp,
                 '20220301T121500'::timestamp,
                 '{
                   "FREQ": "weekly",
                   "BYDAY": "MO",
                   "UNTIL": "20220331T000000Z"
                 }'::jsonb);

-- Получаем список занятий на нужную неделю
SELECT *
FROM get_events_from_range_rrule(
        1,
        1,
        '20220321T090000'::timestamp,
        '20220328T103000'::timestamp
    );

-- Занятие отменилось. Убираем его появление из календаря
SELECT add_exception_event(
               1,
               1,
               1,
               '20220315T090000'::timestamp,
               '20220315T103000'::timestamp);

-- Получаем обновленный список занятий на нужную неделю
SELECT *
FROM get_events_from_range(1, 1,
                           '20220301T090000'::timestamp,
                           '20220401T103000'::timestamp);

-- Добавляем тренировки, которые проходят по понедельникам, средам и пятницам каждую вторую неделю.
SELECT add_event(1, 1,
                 'Тренировка',
                 'Зал около дома.',
                 '20220301T194500'::timestamp,
                 '20220301T211500'::timestamp,
                 '{
                   "freq": "weekly",
                   "interval": "1",
                   "byday": [
                     "MO",
                     "WE",
                     "FR"
                   ],
                   "until": "20220331T000000Z"
                 }'::jsonb);

-- Получаем обновленный список занятий на нужную неделю
SELECT *
FROM get_events_from_range(1, 1,
                           '20220321T090000'::timestamp,
                           '20220328T103000'::timestamp);

-- Курс мат анализа закончился. Удаляем его пары.
SELECT delete_event(1, 1, 1);


-- Расписание тренировок изменилось. Изменяем правило повторения
-- Теперь тренировки по вторникам, четвергам и субботам. КАЖДУЮ НЕДЕЛЮ.
SELECT update_event_params(
               1,
               1,
               3,
               '{
                 "BYDAY": [
                   "TU",
                   "TH",
                   "SA"
                 ],
                 "FREQ": "WEEKLY"
               }'::jsonb);

SELECT *
FROM get_rrule_for_event(1, 1);

-- Повторяется каждую пятницу 13 с января по май.
-- TODO: Проверить!
SELECT add_event(1, 1,
                 'Встреча с друзьями',
                 'Придумать страшные истории.',
                 '20220301T194500'::timestamp,
                 '20220301T211500'::timestamp,
                 '{
                   "freq": "MONTHLY",
                   "BYDAY": ["FR"],
                   "BYMONTHDAY": 13,
                   "BYMONTH": [1,2,3,4,5]
                 }'::jsonb);

-- Получаем обновленный список занятий на нужную неделю
SELECT *
FROM get_events_from_range(1, 1,
                           '20220321T090000'::timestamp,
                           '20220328T103000'::timestamp);

-- Проверяем список событий на май
SELECT *
FROM get_events_from_range(1, 1,
                           '20220501T090000'::timestamp,
                           '20220501T103000'::timestamp);
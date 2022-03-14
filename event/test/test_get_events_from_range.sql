SELECT *
FROM get_events_from_range(1, 1, '2020-01-01 11:00'::timestamp, '2022-12-06 23:30'::timestamp);

SELECT *
FROM get_events_from_range_rrule(1, 1, '2020-01-01 11:00'::timestamp, '2022-12-06 23:30'::timestamp);
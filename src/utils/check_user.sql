CREATE OR REPLACE FUNCTION check_user_calendar(
    user_id integer,
    calendar_id integer
)
    RETURNS void
    LANGUAGE plpgsql
AS
$Body$
DECLARE
BEGIN
    -- Check if a calendar is available to a user
    PERFORM uc.calendar_id
    from users
             LEFT JOIN users_calendar uc on users.id = uc.user_id
    WHERE users.id = $1
      and uc.calendar_id = $2;
    IF not FOUND
    THEN
        RAISE EXCEPTION 'User #% doesnt have Calendar #%', user_id, calendar_id;
    END IF;
END;
$Body$;
end;
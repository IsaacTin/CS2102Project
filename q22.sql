/*
  Q22: Change room for a course *session*
*/
CREATE OR REPLACE PROCEDURE update_room(input_courseId INT, input_launchDate DATE, input_sessionId INT, input_roomId INT)
AS $$
DECLARE
    numRegistrations INT;
BEGIN
    numRegistrations := (SELECT count(*) 
                         FROM Registers
                         WHERE sid = input_sessionId
                         AND course_id = input_courseId
                         AND launch_date = input_launchDate);

    /*Determine if input room id is valid, and sufficient space available*/
    IF NOT EXISTS(SELECT 1
                  FROM Rooms
                  WHERE rid = input_roomId
                  AND seating_capacity >= numRegistrations) THEN
        RETURN;
    END IF;

    /*Update if course session hasn't started*/
    UPDATE CourseOfferingSessions
    SET rid = input_roomId
    WHERE course_id = input_courseId
    AND sid = input_sessionId
    AND launch_date = input_launchDate
    AND (session_date + end_time) < INTERVAL '0'; -- Course session hasn't started
END;
$$ LANGUAGE plpgsql;

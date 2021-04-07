/*
  Q23: Remove a course *session*
*/
CREATE OR REPLACE PROCEDURE remove_session(input_courseId INT, input_launchDate DATE, input_sessionId INT)
AS $$
BEGIN
    /*Don't perform request if at least one registration for session*/
    IF (SELECT count(*)
        FROM Registers
        WHERE sid = input_sessionId
        AND course_id = input_courseId
        AND launch_date = input_launchDate) >= 1 THEN
        RETURN;
    END IF;

    DELETE FROM CourseOfferingSessions
    WHERE course_id = input_courseId
    AND sid = input_sessionId
    AND launch_date = input_launchDate
    AND (session_date + end_time) < INTERVAL '0'; -- Course session hasn't started
END;
$$ LANGUAGE plpgsql;

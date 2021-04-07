/* 
  Q21: Change instructor for a course *session*
  Reference for date/time functions and operators: https://www.postgresql.org/docs/8.2/functions-datetime.html
*/
CREATE OR REPLACE PROCEDURE update_instructor(input_courseId INT, input_launchDate DATE, input_sessionId INT, input_instructorId INT)
AS $$
BEGIN 
    /*Determine if input instructor id is valid*/
    IF NOT EXISTS(SELECT 1
                  FROM Instructors
                  WHERE eid = input_instructorId) THEN
        RETURN;
    END IF;


    /*Update if course session hasn't started*/
    UPDATE CourseOfferingSessions
    SET eid = input_instructorId
    WHERE course_id = input_courseId
    AND sid = input_sessionId
    AND launch_date = input_launchDate
    AND (session_date + end_time) < INTERVAL '0'; -- Course session hasn't started
END;
$$ LANGUAGE plpgsql;

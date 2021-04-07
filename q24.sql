/*
  Q24: Add a new session to a course offering
*/
CREATE OR REPLACE PROCEDURE add_session(input_courseId INT, input_launchDate DATE, input_sessionId INT, input_sessionDate DATE,
                                        input_sessionStart TIME, input_instructorId INT, input_roomId INT)
AS $$
DECLARE
    registrationDeadline DATE;
    endHour TIME;
BEGIN
    registrationDeadline := (SELECT registration_deadline
                             FROM CourseOfferings
                             WHERE course_id = input_courseId
                             AND launch_date = input_launchDate);
    
    endHour := input_sessionStart + ((SELECT duration 
                                     FROM Courses
                                     WHERE course_id = input_courseId) * INTERVAL '1 hour');

    /*Course offering registration deadline has not passed*/
    IF registrationDeadline > CURRENT_DATE THEN
		/*Check session constraints*/
		INSERT INTO CourseOfferingSessions
		VALUES (number, input_sessionStart, endHour, input_roomId, input_instructorId, input_courseId, input_sessionDate, input_launchDate);
	END IF;
END;
$$ LANGUAGE plpgsql;

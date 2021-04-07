/*
  Q28
*/
CREATE OR REPLACE FUNCTION popular_courses() 
RETURNS TABLE(course_id INT, title VARCHAR, course_area VARCHAR, num_offerings INT, num_registrations INT) AS $$
DECLARE
    firstCourseOffering RECORD;
    secondCourseOffering RECORD;
    firstNumRegistrations INT;
    secondNumRegistrations INT;
BEGIN
    FOR firstCourseOffering IN 
 		(SELECT CO1.course_id
        FROM CourseOfferings CO1, CourseOfferings CO2
        WHERE CO1.course_id = CO2.course_id 
        AND CO1.launch_date <> CO2.launch_date -- Same course but different offering
        AND date_part('year', CO1.start_date) = date_part('year', CURRENT_DATE) -- Within current year
        AND date_part('year', CO2.start_date) = date_part('year', CURRENT_DATE))
    LOOP
        FOR secondCourseOffering IN
			(SELECT CO1.course_id
			FROM CourseOfferings CO1, CourseOfferings CO2
			WHERE CO1.course_id = CO2.course_id 
			AND CO1.launch_date <> CO2.launch_date -- Same course but different offering
			AND date_part('year', CO1.start_date) = date_part('year', CURRENT_DATE) -- Within current year
			AND date_part('year', CO2.start_date) = date_part('year', CURRENT_DATE))
        LOOP
            /*Different course, or same course and same course offering*/
            IF firstCourseOffering.course_id <> secondCourseOffering.course_id 
            OR (firstCourseOffering.course_id = secondCourseOffering.course_id 
                AND firstCourseOffering.launch_date = secondCourseOffering.launch_date)
            THEN
                CONTINUE;
            END IF;

            firstNumRegistrations := (SELECT COUNT(*) 
                                     FROM Registers R 
                                     WHERE R.course_id = firstCourseOffering.course_id 
                                     AND R.launch_date = firstCourseOffering.launch_date);

            secondNumRegistrations := (SELECT COUNT(*) 
                                     FROM Registers R 
                                     WHERE R.course_id = secondCourseOffering.course_id 
                                     AND R.launch_date = secondCourseOffering.launch_date);

            /*Same course but different offering*/
            IF firstCourseOffering.start_date > secondCourseOffering.start_date THEN -- First has later start date than second
                IF firstNumRegistrations > secondNumRegistrations THEN
                    course_id := firstCourseOffering.course_id;
                    title :=  (SELECT title
                              FROM Courses
                              WHERE course_id = firstCourseOffering.course_id);
                    course_area :=  (SELECT course_area_name 
                                    FROM Courses
                                    WHERE course_id = firstCourseOffering.course_id);
                    num_offerings := (SELECT COUNT(*)
                                     FROM CourseOfferings CO
                                     WHERE firstCourseOffering.course_id = CO.id
                                     AND date_part('year', CO.start_date) = date_part('year', CURRENT_DATE)); -- Within current year
                    num_registrations := firstNumRegistrations;
                    RETURN NEXT;
                END IF;
            ELSIF secondCourseOffering.start_date > firstCourseOffering.start_date THEN
                IF secondNumRegistrations > firstNumRegistrations THEN
                    course_id := secondCourseOffering.course_id;
                    title :=  (SELECT title
                              FROM Courses
                              WHERE course_id = secondCourseOffering.course_id);
                    course_area :=  (SELECT course_area_name 
                                    FROM Courses
                                    WHERE course_id = secondCourseOffering.course_id);
                    num_offerings := (SELECT COUNT(*)
                                     FROM CourseOfferings CO
                                     WHERE secondCourseOffering.course_id = CO.id
                                     AND date_part('year', CO.start_date) = date_part('year', CURRENT_DATE)); -- Within current year
                    num_registrations := secondNumRegistrations;
                    RETURN NEXT;
                END IF;
            ELSE
                CONTINUE; -- Same start date, do nothing
            END IF;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

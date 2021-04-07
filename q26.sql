/*
  Q26: Idenfiy potential course offerings that could be of interest to inactive customers.
*/
CREATE OR REPLACE FUNCTION promote_courses() 
RETURNS TABLE(cust_id INT, cust_name VARCHAR, course_area VARCHAR, 
              course_id INT, course_title VARCHAR, launch_date DATE, 
              registration_deadline DATE, fees NUMERIC(36, 2)) AS $$
DECLARE
    customerRecord RECORD;
    courseRecord RECORD;
BEGIN
    FOR customerRecord IN (SELECT R1.cust_id, R1.name
        FROM Registers R1
        EXCEPT
        SELECT R2.cust_id
        FROM Registers R2
        WHERE registers_date > (CURRENT_DATE - INTERVAL '6 months') -- Active customers
		ORDER BY cust_id ASC -- Ensure output table is in ASC order of cust_id
    )
    LOOP
        /*Every course area is of interest as there are no registrations yet*/
        IF NOT EXISTS (SELECT 1 
                    FROM Registers
                    WHERE cust_id = input_custId) THEN
            /*Get all courseRecords available, since all are of interest*/
            FOR courseRecord IN (SELECT * 
                                FROM (CourseOfferings CO JOIN Course C ON (CO.course_id = C.course_id)) AS CourseData
                                ORDER BY CourseData.registration_deadline ASC)
			LOOP
                cust_id := customerRecord.cust_id;
                cust_name = customerRecord.name;
                course_area := courseRecord.course_area_name;
                course_id := courseRecord.course_id;
                course_title := courseRecord.title;
                launch_date := courseRecord.launch_date;
                IF courseRecord.registration_deadline > CURRENT_DATE THEN
                    registration_deadline := courseRecord.registration_deadline;
                END IF;
                fees := courseRecord.fees;
                RETURN NEXT;
            END LOOP;
        ELSE 
            /*Get all course record that are in the customer's interest area*/
            FOR courseRecord IN (SELECT *
                                FROM (CourseOfferings CO JOIN Course C ON (CO.course_id = C.course_id)) AS CourseData
                                WHERE EXISTS(SELECT 1
                                             FROM (SELECT course_area
													FROM (Registers R JOIN Courses C ON (R.course_id = C.course_id)) AS TopThree
													WHERE customerRecord.cust_id = TopThree.cust_id
													ORDER BY R.registers_date DESC -- Earliest to latest
													LIMIT 3) as TopThreeAreas
                                             WHERE TopThreeAreas.course_area = CourseData.course_area_name)
                                ORDER BY CourseData.registration_deadline ASC)
			LOOP
                cust_id := customerRecord.cust_id;
                cust_name = customerRecord.name;
                course_area := courseRecord.course_area_name;
                course_id := courseRecord.course_id;
                course_title := courseRecord.title;
                launch_date := courseRecord.launch_date;
                IF courseRecord.registration_deadline > CURRENT_DATE THEN
                    registration_deadline := courseRecord.registration_deadline;
                END IF;
                fees := courseRecord.fees;
                RETURN NEXT;
            END LOOP;
        END IF;
    END LOOP;    
END;
$$ LANGUAGE plpgsql;

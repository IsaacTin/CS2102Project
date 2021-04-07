/*
  Q30
*/
CREATE OR REPLACE FUNCTION view_manager_report() 
RETURNS TABLE(manager_name VARCHAR, num_course_areas_managed INT, total_course_offerings_managed INT, 
              total_net_registration_fee NUMERIC(36,2), course_title VARCHAR[]) AS $$
DECLARE
    managerCursor CURSOR FOR (
        SELECT eid, name
        FROM Employees NATURAL JOIN Managers
        ORDER BY name
    );
    courseDetailCursor CURSOR FOR (
        SELECT C.course_id, C.title, CO.launch_date, CO.end_date, CO.fees, CAM.eid
        FROM (Courses C JOIN CourseOfferings CO ON (C.course_id = CO.course_id))
        JOIN CourseAreaManaged CAM ON (C.course_area_name = CAM.course_area_name)
        WHERE date_part('year', CO.end_date) = date_part('year', CURRENT_DATE)
    );
    managerRecord RECORD;
    courseDetailRecord RECORD;
    highestRegistrationCourse VARCHAR[];
    highestRegistrationFee NUMERIC(36,2);
    registrationFee NUMERIC(36,2);
    temporarySum NUMERIC(36,2);
    cancelledRegistrations INT;
    registrations INT;
BEGIN
    OPEN managerCursor;
    LOOP
        FETCH managerCursor INTO managerRecord;
        EXIT WHEN NOT FOUND;

        /*Assign attributes*/
        manager_name  := managerCursor.name;
        num_course_areas_managed := (SELECT COUNT(*)
                                     FROM CourseAreaManaged
                                     WHERE eid = managerRecord.eid);
        total_course_offerings_managed := (SELECT COUNT(*)
                                           FROM (Courses C JOIN CourseOfferings CO ON (C.course_id = CO.course_id))
                                           JOIN CourseAreaManaged CAM ON (C.course_area_name = CAM.course_area_name)
                                           WHERE date_part('year', CO.end_date) = date_part('year', CURRENT_DATE)
                                           AND CAM.eid = managerCursor.eid
                                           );

        /*Assign first in case detail not found in inner loop*/
        total_net_registration_fee := 0;
        highestRegistrationCourse := ARRAY[]::VARCHAR[];
        highestRegistrationFee := -999; -- Arbitrarily large to act as starting minimum

        /*Inner loop to get net registration fee and course with highest total net registration fee*/
        OPEN courseDetailCursor;
        LOOP
            FETCH courseDetailCursor INTO courseDetailRecord;
            EXIT WHEN NOT FOUND;

            /*We don't care when employee is different*/
            IF managerCursor.eid <> courseDetailCursor.eid THEN
                CONTINUE;
            END IF;

            registrations := (SELECT COUNT(*) 
                              FROM Registers
                              WHERE course_id = courseDetailCursor.course_id
                              AND launch_date = courseDetailCursor.launch_date);

            /*Account for total registration fees paid via credit card payment*/
            registrationFee := registrations * courseDetailCursor.fees;

            cancelledRegistrations := (SELECT COUNT(*)
                                       FROM Cancels
                                       WHERE course_id = courseDetailCursor.launch_date
                                       AND launch_date = courseDetailCursor.launch_date
                                       AND refund_amt IS NOT NULL
                                       );
            temporarySum := (SELECT SUM(refund_amt)
                             FROM Cancels
                             WHERE course_id = courseDetailCursor.launch_date
                             AND launch_date = courseDetailCursor.launch_date
                             AND refund_amt IS NOT NULL
                             );
            IF temporarySum IS NULL THEN
                temporarySum := 0;
            END IF;

            /*Account for refunds*/
            registrationFee := registrationFee - temporarySum + (cancelledRegistrations * courseDetailCursor.fees);

            temporarySum := (SELECT SUM(CP.price / CP.num_free_registrations)
                             FROM (Redeems R JOIN Buys B ON (R.buys_date = B.buys_date
                                                            AND R.cust_id = B.cust_id
                                                            AND R.number = B.number
                                                            AND R.package_id = B.package_id))
                             JOIN Course_packages CP ON (B.package_id = CP.package_id)
                             );
            IF temporarySum IS NULL THEN
                temporarySum := 0;
            END IF;

            /*Account for individual registrations*/
            registrationFee := registrationFee + temporarySum;

            total_net_registration_fee := total_net_registration_fee + registration_fee;
            IF registrationFee > highestRegistrationFee THEN
                highestRegistrationFee := registrationFee;
                highestRegistrationCourse := ARRAY[courseDetailCursor.title];

            ELSIF registrationFee = highestRegistrationFee THEN
                highestRegistrationCourse := array_append(highestRegistrationCourse, courseDetailCursor.title);

            END IF;

        END LOOP;
        CLOSE courseDetailCursor;
        course_title := highestRegistrationCourse;
    END LOOP;
    CLOSE managerCursor;
END;
$$ LANGUAGE plpgsql;
    
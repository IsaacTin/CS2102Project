/* ALL TRIGGERS*/
/*
explanation for multiple triggers checking the same thing 
https://stackoverflow.com/questions/39689523/postgresql-multiple-triggers-and-functions
*/
/*
1) No two course offering session of the same course offering can be done on 
the same day and time (but idk if two sessions can be done on the same day at different times)
*/

DROP TRIGGER IF EXISTS check_course_offering_session ON CourseOfferingSessions;
DROP TRIGGER IF EXISTS check_register ON Registers;
DROP TRIGGER IF EXISTS update_course_offering_seating_capacity ON CourseOfferingSessions;
DROP TRIGGER IF EXISTS check_rooms ON CourseOfferingSessions;
DROP TRIGGER IF EXISTS check_instructor_specialization ON Instructors;
DROP TRIGGER IF EXISTS check_if_specialized ON CourseOfferingSessions;
DROP TRIGGER IF EXISTS check_if_same_hour ON CourseOfferingSessions;
DROP TRIGGER IF EXISTS check_part_time_instructor_hours ON CourseOfferingSessions;

CREATE OR REPLACE FUNCTION check_course_offering_session() 
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM CourseOfferingSessions 
        WHERE NEW.course_id = course_id 
        AND NEW.launch_date = launch_date 
        AND NEW.session_date = session_date
        AND NEW.start_time BETWEEN start_time AND end_time - INTERVAL '1 second') THEN
        RAISE EXCEPTION 'No course offering session of the same course offering to be conducted on same day and time.';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_course_offering_session
BEFORE UPDATE OR INSERT ON CourseOfferingSessions
FOR EACH ROW 
EXECUTE FUNCTION check_course_offering_session();

/*
2)2. For each course offered by company, 
customer can register for at most one of its session before its registration deadline
*/

CREATE OR REPLACE FUNCTION check_register()
RETURNS TRIGGER AS $$
DECLARE
    registrationDeadline INT;
BEGIN
    SELECT registration_deadline FROM CourseOfferings WHERE launch_date = NEW.launch_date AND course_id = NEW.course_id INTO registrationDeadline;
    IF EXISTS (SELECT 1 FROM Registers WHERE sid IN (SELECT sid FROM CourseOfferingSessions WHERE launch_date = NEW.launch_date AND course_id = NEW.course_id AND sid <> NEW.sid) AND cust_id = NEW.cust_id)
    OR
    NEW.registers_date >= registration_deadline THEN
        RAISE EXCEPTION 'Cannot register for more than one session of the same course offering and must register before registration deadline';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_register
BEFORE INSERT ON Registers
FOR EACH ROW
EXECUTE FUNCTION check_register();


/*
3) Seating capacity of course session is equal 
to seating capacity of room where session conducted, 
and the seating capacity of a course offering is equal to 
sum of seating capacities of its sessions (I think can use triggers to update everytime a course session is added)
*/


CREATE OR REPLACE FUNCTION update_course_offering_seating_capacity()
RETURNS TRIGGER AS $$
DECLARE
        newSum INT;
BEGIN
        SELECT SUM(R.seating_capacity) 
        FROM Rooms R, CourseOfferingSessions C 
        WHERE R.rid = C.rid GROUP BY (launch_date, course_id) 
        HAVING NEW.launch_date = launch_date AND NEW.course_id = course_id
        INTO newSum;
        UPDATE CourseOfferings
        SET seating_capacity = newSum
        WHERE launch_date = NEW.launch_date AND course_id = NEW.course_id;
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_course_offering_seating_capacity
AFTER INSERT OR UPDATE ON CourseOfferingSessions
FOR EACH ROW
EXECUTE FUNCTION update_course_offering_seating_capacity();

/*
7.	Each room can be used to conduct at most one course session at any time.
*/

CREATE OR REPLACE FUNCTION check_rooms()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM CourseOfferingSessions 
        WHERE NEW.rid = rid 
        AND NEW.session_date = session_date 
        AND NEW.start_time BETWEEN start_time AND (end_time - INTERVAL '1 second')
        AND NOT (sid = NEW.sid AND launch_date = NEW.launch_date AND course_id = NEW.course_id)
        )
    THEN
        RAISE EXCEPTION 'Room can only be used to conduct at most one course at any time';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_rooms
BEFORE INSERT OR UPDATE ON CourseOfferingSessions
FOR EACH ROW
EXECUTE FUNCTION check_rooms();


/*
8.	Each instructor specializes in a set of one or more course areas 
*/

/* actl i think this one dont need since foreign key kinda ensures it but i just leave it here first*/

CREATE OR REPLACE FUNCTION check_instructor_specialization()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM Specializes WHERE NEW.eid = eid) = 0 THEN
        RAISE EXCEPTION 'Instructors need to specialize in a set of one or more course areas';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER check_instructor_specialization
AFTER INSERT OR UPDATE ON Instructors
DEFERRABLE INITIALLY IMMEDIATE
FOR EACH ROW
EXECUTE FUNCTION check_instructor_specialization();



/*
9.	instructor who is assigned to teach a course session must be specialized in that course area
*/



CREATE OR REPLACE FUNCTION check_if_specialized()
RETURNS TRIGGER AS $$
DECLARE
    CourseAreaName VARCHAR;
BEGIN
    SELECT course_area_name FROM Courses WHERE course_id = NEW.course_id INTO CourseAreaName;
    IF (CourseAreaName NOT IN (SELECT course_area_name FROM Specializes WHERE NEW.eid = eid)) THEN
        RAISE EXCEPTION 'Instructor who is assigned to this course session must specialize in the course area the course needs.';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_if_specialized 
BEFORE INSERT OR UPDATE ON CourseOfferingSessions
FOR EACH ROW
EXECUTE FUNCTION check_if_specialized();

/*
10.	Each instructor can teach at most one course session at any hour AND Each instructor must not be assigned to teach two consecutive course sessions
*/



CREATE OR REPLACE FUNCTION check_if_same_hour()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM CourseOfferingSessions 
        WHERE eid = NEW.eid 
        AND NOT (NEW.sid = sid AND NEW.launch_date = launch_date AND NEW.course_id = course_id) /* Whenever this comes out, its for the case of update*/
        AND NEW.session_date = session_date 
        AND NEW.start_time BETWEEN start_time AND end_time) 
    THEN   
        RAISE EXCEPTION 'Instructor can only teach at most one course session at any hour and cannot be assigned to teach two consecutive sessions.';
        RETURN NULL;
    ELSE 
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_if_same_hour 
BEFORE INSERT OR UPDATE ON CourseOfferingSessions
FOR EACH ROW
EXECUTE FUNCTION check_if_same_hour();


/*
12.	Each part-time instructor must not teach more than 30 hours for each month.
*/



CREATE OR REPLACE FUNCTION check_part_time_instructor_hours()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.eid IN (SELECT eid FROM Part_time_instructors) THEN
        IF (SELECT EXTRACT (EPOCH FROM 
            (SELECT SUM(end_time - start_time) FROM CourseOfferingSessions 
                WHERE eid = NEW.eid
                AND (SELECT EXTRACT (MONTH FROM session_date) = (SELECT EXTRACT (MONTH FROM NEW.session_date)))))/3600) > 30
        THEN
            RAISE EXCEPTION 'Part-time instructors must not teach more than 30 hours for each month.';
            RETURN NULL;
        ELSE
            RETURN NEW;
        END IF;
    ELSE 
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_part_time_instructor_hours
BEFORE INSERT OR UPDATE ON CourseOfferingSessions
FOR EACH ROW
EXECUTE FUNCTION check_part_time_instructor_hours();



/*ENDS HERE*/ 
CREATE OR REPLACE PROCEDURE add_employee(input_Name VARCHAR, input_Phone INT, input_Address VARCHAR,  input_Email VARCHAR, input_Salary NUMERIC(36,2), input_Join_date DATE, input_Category VARCHAR, input_Areas VARCHAR[])
AS $$
DECLARE
        employeeId INT;
        area VARCHAR;
BEGIN
        SET CONSTRAINTS check_instructor_specialization DEFERRED;
        INSERT INTO Employees(name, phone, address, email, depart_date, join_date) 
        VALUES(input_Name, input_Phone, input_Address, input_Email, NULL, input_Join_date);

        SELECT eid INTO employeeId FROM Employees WHERE input_Name = name;

        IF (input_Category = 'manager') THEN
		    INSERT INTO Full_time_Emp VALUES (employeeId, input_Salary);
            INSERT INTO Managers VALUES(employeeId);
            FOREACH area IN ARRAY input_Areas
            LOOP 
                IF NOT EXISTS (SELECT 1 FROM CourseAreaManaged WHERE area = course_area_name) THEN
                    INSERT INTO CourseAreaManaged VALUES(area, employeeId);
                END IF;
            END LOOP;
        ELSIF (input_Category = 'instructor') THEN
            INSERT INTO Instructors VALUES(employeeId);
            FOREACH area IN ARRAY input_Areas
            LOOP
                INSERT INTO Specializes VALUES(employeeId, area);
            END LOOP;
            IF (input_Salary < 1000) THEN /*i not sure if can compare int to numeric, and also i assume minimum monthly salary is above 1000*/ 
                INSERT INTO Part_time_Emp VALUES (employeeId, input_Salary);
                INSERT INTO Part_time_instructors VALUES(employeeId);
            ELSE
                INSERT INTO Full_time_Emp VALUES(employeeId, input_Salary);
                INSERT INTO Full_time_instructors VALUES(employeeId);
            END IF;
        ELSIF (input_Category = 'administrator') THEN /*WHEN ADMINISTRATOR idk if we should check if it is administrator and then raise exception if its not probably should*/
            IF (array_length(input_Areas, 1) > 0) THEN
                RAISE EXCEPTION 'Administrators should not have course areas';
            ELSE
                INSERT INTO Full_time_emp VALUES(employeeId, input_Salary);
                INSERT INTO Administrators VALUES(employeeId);
            END IF;
        ELSE 
            RAISE EXCEPTION 'Invalid Category';
        END IF;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE PROCEDURE remove_employee(input_Eid INT, input_DepartureDate DATE) /*Not sure if i should implement the constraints as a trigger*/
AS $$
BEGIN 
    IF (
        EXISTS (SELECT 1 FROM CourseOfferings WHERE eid = input_Eid AND registration_deadline > input_DepartureDate)
        OR 
        EXISTS (SELECT 1 FROM CourseOfferingSessions WHERE eid = input_Eid AND session_date > input_DepartureDate)
        OR
        EXISTS (SELECT 1 FROM CourseAreaManaged WHERE eid = input_Eid)
        )
    THEN
        RAISE NOTICE 'Unable to remove employee.';
    ELSE 
        UPDATE Employees
        SET depart_date = input_DepartureDate
        WHERE eid = input_Eid;
        DELETE FROM Full_time_Emp
        WHERE eid = input_Eid;
        DELETE FROM Part_time_Emp
        WHERE eid = input_Eid;
        DELETE FROM Instructors
        WHERE eid = input_Eid;
        DELETE FROM Administrators
        WHERE eid = input_Eid;
        DELETE FROM Managers
        WHERE eid = input_Eid;
        DELETE FROM Specializes
        WHERE eid = input_Eid;
    END IF;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE PROCEDURE add_customer(input_Name VARCHAR, input_Phone INT, input_address VARCHAR, input_Email VARCHAR, input_Number VARCHAR(16), input_Date DATE, input_CVV INT)
AS $$
DECLARE 
    customerID INT;
BEGIN 
    INSERT INTO Customers(phone, address, email, name, number) VALUES(input_Phone, input_Address, input_Email, input_Name, input_Number);
    SELECT cust_id INTO customerID FROM Customers WHERE number = input_Number GROUP BY cust_id; /*added groupby to ensure that it is only one value(though it shouldnt have more anyway)*/
    INSERT INTO Credit_Cards VALUES(input_Number, input_CVV, input_Date, CURRENT_DATE, customerID);
END;
$$ LANGUAGE plpgsql;



/*REMB TO MAKE A TRIGGER FOR THIS'*/
CREATE OR REPLACE PROCEDURE update_credit_card(input_ID INT, input_Number VARCHAR(16), input_Date DATE, input_CVV INT)
AS $$
DECLARE
    currentActive VARCHAR(16);
BEGIN 
    SELECT number INTO currentActive FROM Credit_cards WHERE cust_id = input_ID ORDER BY from_date DESC LIMIT 1;
    UPDATE Credit_cards
    SET number = input_Number, expiry_date = input_Date, CVV = input_CVV, from_date = CURRENT_DATE WHERE number = currentActive;
	UPDATE Customers
	SET number = input_Number WHERE number = currentActive;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE PROCEDURE add_course(input_Title VARCHAR, input_Desc VARCHAR, input_Area VARCHAR, input_Duration INT)
AS $$
BEGIN
    INSERT INTO Courses(course_area_name, title, description, duration) VALUES(input_Area, input_Title, input_Desc, input_Duration);
END;
$$ LANGUAGE plpgsql;





CREATE OR REPLACE FUNCTION find_instructors(input_Cid INT, input_Date DATE, input_StartTime TIME)
RETURNS TABLE (eid INT, name VARCHAR) AS $$
DECLARE
    curs CURSOR FOR (SELECT E.eid, E.name FROM Instructors I, Employees E WHERE I.eid = E.eid); /*Finding the names of the instructors*/
    r RECORD;
    SessionDuration INT;
    endTime TIME;
BEGIN
    SELECT duration FROM Courses WHERE course_id = input_Cid INTO SessionDuration;
    endTime := input_StartTime + SessionDuration * INTERVAL '1 hour';
    OPEN curs;
    LOOP
        FETCH curs into r;
        EXIT WHEN NOT FOUND;
        EXIT WHEN 
            input_StartTime < '09:00:00' /*cannot start before 9*/
            OR endTime > '18:00:00' /*cannot end after 6*/
            OR input_StartTime BETWEEN '12:00:00' AND '13:59:00' /*cannot start class between 12 to 2*/
            OR (input_StartTime < '12:00:00' AND endTime > '12:00:00'); /*cannot start class before 12 and end class after 12*/
        IF NOT EXISTS (
            SELECT 1 FROM CourseOfferingSessions C
            WHERE C.eid = r.eid 
            AND session_date = input_Date 
            AND input_StartTime <= end_time AND endTime >= start_time /* cannot teach if session time is between start and end time of another session*/
        ) 
        AND
        EXISTS (SELECT 1 FROM Courses C, Specializes S WHERE S.eid = r.eid AND S.course_area_name = C.course_area_name AND C.course_id = input_Cid)
        THEN
            eid := r.eid;
            name := r.name;
            RETURN NEXT;
        ELSE
            CONTINUE;
		END IF;
    END LOOP;
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION get_available_instructors(input_Cid INT, input_StartDate DATE, input_EndDate DATE)
RETURNS TABLE(eid INT, name VARCHAR, hours int, day DATE, availableHours TIME[]) AS $$
DECLARE 
    curs1 CURSOR FOR (SELECT * FROM Specializes ORDER BY eid ASC);
    r RECORD;
    currDay INT;
    endDay INT;
    currDate DATE;
    courseArea VARCHAR;
    currTime TIME;
BEGIN
    hours := 0;
    SELECT course_area_name INTO courseArea FROM Courses WHERE course_id = input_Cid;
    OPEN curs1;
    LOOP
        FETCH curs1 INTO r;
        EXIT WHEN NOT FOUND;
        CONTINUE WHEN r.course_area_name <> courseArea;
        currDate := input_StartDate;
        IF EXISTS (SELECT 1 FROM CourseOfferingSessions C WHERE r.eid = C.eid) THEN
            SELECT SUM((SELECT EXTRACT (HOUR FROM session_date + end_time)) - (SELECT EXTRACT (HOUR FROM session_date + start_time))) FROM CourseOfferingSessions INTO hours;
        END IF;
        LOOP 
            EXIT WHEN currDate > input_EndDate;
            currTime := TIME '08:00:00';
            availableHours := '{}';
            LOOP
                currTime := currTime + INTERVAL '1 hour';
                EXIT WHEN currTime = TIME '18:00:00';
                IF EXISTS (SELECT 1 FROM find_instructors(input_Cid, currDate, currTime) F WHERE r.eid = F.eid) THEN
                    SELECT E.name INTO name FROM Employees E WHERE r.eid = E.eid;
                    eid := r.eid;
                    day := currDate;
                    SELECT array_append(availableHours, currTime) INTO availableHours;
                ELSE
                    CONTINUE;
				END IF;
            END LOOP;
            IF (array_length(availableHours, 1) > 0) THEN
                RETURN NEXT;
                SELECT currDate + INTERVAL '1 day' INTO currDate;
            ELSE
                SELECT currDate + INTERVAL '1 day' INTO currDate;
			END IF;
        END LOOP;
    END LOOP;
    CLOSE curs1;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION find_rooms(input_Date DATE, input_StartTime TIME, input_Duration INT)
RETURNS TABLE(rid INT) AS $$
DECLARE 
    curs CURSOR FOR (SELECT * FROM Rooms);
    r RECORD;
    endTime TIME;
BEGIN
    SELECT input_StartTime + input_Duration * INTERVAL '1 hour' INTO endTime;
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        EXIT WHEN (
            input_StartTime < '09:00:00'
            OR endTime > '18:00:00'
            OR input_StartTime BETWEEN '12:00:00' AND '13:59:00'
            OR input_StartTime < '12:00:00' AND endTime > '12:00:00' 
        );
        IF NOT EXISTS (SELECT 1 FROM CourseOfferingSessions C
            WHERE C.rid = r.rid 
            AND input_Date = session_date 
            AND (input_StartTime < end_time AND endTime > start_time)
            )
        THEN 
            rid := r.rid;
            RETURN NEXT;
        ELSE
            CONTINUE;
		END IF;
    END LOOP;
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION get_available_rooms(input_StartDate DATE, input_EndDate DATE) 
RETURNS TABLE(rid INT, capacity INT, day DATE, availableHours TIME[]) AS $$
DECLARE
    curs1 CURSOR FOR (SELECT * FROM Rooms ORDER BY rid ASC);
    r RECORD;
    currTime TIME;
    currDate DATE;
BEGIN
    OPEN curs1;
    LOOP
        FETCH curs1 INTO r;
        EXIT WHEN NOT FOUND;
            currDate := input_StartDate;
        LOOP   
            EXIT WHEN currDate > input_EndDate;
            currTime := TIME '08:00:00';
            availableHours := '{}';
            LOOP
                currTime := currTime + INTERVAL '1 hour';
                EXIT WHEN currTime = TIME '18:00:00';
                IF EXISTS (SELECT 1 FROM find_rooms(currDate, currTime, 1) F WHERE F.rid = r.rid) THEN
                    rid := r.rid;
                    capacity := r.seating_capacity;
                    day := currDate;
                    SELECT array_append(availableHours, currTime) INTO availableHours;
                ELSE
                    CONTINUE;
                END IF;
            END LOOP;
            IF (rid = r.rid) THEN
                RETURN NEXT;
                SELECT currDate + INTERVAL '1 day' INTO currDate;
            ELSE 
                SELECT currDate + INTERVAL '1 day' INTO currDate;
            END IF;
        END LOOP;
    END LOOP;
    CLOSE curs1;
END;
$$ LANGUAGE plpgsql;
    



CREATE OR REPLACE PROCEDURE add_course_offering(input_Course_id INT, input_Fees NUMERIC(36,2), input_Launch_date DATE, input_Registration_deadline DATE, input_Eid INT, input_Target_registration INT, input_SessionDateAndTime TIMESTAMP[], input_Rid INT[]) /*I'm having trouble with this as I do not know how to input all the sessions at one go*/
AS $$
DECLARE 
    SessionDate DATE;
    SessionStartHour TIME;
    SessionEndHour TIME;
    SessionRoomId INT;
    noOfSessions INT;
    SessionCounter INT;
    SessionDuration INT;
    instructorId INT;
BEGIN
    SELECT array_length(input_SessionDateAndTime, 1) INTO noOfSessions;
    sessionCounter := 1;
    IF NOT EXISTS (SELECT 1 FROM Courses WHERE course_id = input_Course_id) THEN
        RAISE EXCEPTION 'Course does not exist';
    ELSE /* add course offering first without total seating capacity, start and end date*/
        SELECT duration FROM Courses WHERE course_id = input_Course_id INTO SessionDuration;
        INSERT INTO CourseOfferings VALUES(input_Launch_date, NULL, NULL, input_Registration_deadline, input_Target_registration, 0, input_Fees, input_Course_id, input_Eid);
        LOOP
            EXIT WHEN sessionCounter > noOfSessions;
            SELECT input_SessionDateAndTime[SessionCounter]::TIMESTAMP::DATE INTO SessionDate;
            SessionRoomId := input_Rid[SessionCounter];
            SELECT input_SessionDateAndTime[SessionCounter]::TIMESTAMP::TIME INTO SessionStartHour;
            SessionEndHour := SessionStartHour + SessionDuration * INTERVAL '1 hour';
            IF EXISTS (SELECT 1 FROM find_instructors(input_Course_id, SessionDate, SessionStartHour)) THEN
                SELECT eid FROM find_instructors(input_Course_id, SessionDate, SessionStartHour) ORDER BY eid LIMIT 1 INTO instructorId;
                INSERT INTO CourseOfferingSessions VALUES(SessionCounter, SessionStartHour, SessionEndHour, SessionRoomId, instructorId, input_Course_id, SessionDate, input_Launch_date);
                SessionCounter := SessionCounter + 1;
            ELSE
                RAISE EXCEPTION 'No Instructor available to do this shit';
            END IF;
        END LOOP;
    END IF;
    IF /* update course offerings if meets expectations else stop */
        (   
            SELECT SUM(seating_capacity) 
            FROM CourseOfferingSessions NATURAL JOIN Rooms 
            WHERE course_id = input_Course_id 
            AND launch_date = input_Launch_date
        ) < input_Target_registration 
    THEN 
        RAISE EXCEPTION 'Insufficient seating capacity';
    ELSE 
        UPDATE CourseOfferings
        SET 
            start_date = (
                SELECT MAX(session_date) 
                FROM CourseOfferingSessions 
                WHERE input_Launch_date = launch_date AND input_Course_id = course_id
                ),
            end_date = (
                SELECT MIN(session_date)
                FROM CourseOfferingSessions
                WHERE input_Launch_date = launch_date AND input_Course_id = course_id
            ),
            seating_capacity = (
                SELECT SUM(seating_capacity) 
                FROM CourseOfferingSessions NATURAL JOIN Rooms 
                WHERE input_Course_id = course_id
                AND input_Launch_date = launch_date
            )
        WHERE input_Launch_date = launch_date AND input_Course_id = course_id;
    END IF;
END
$$ LANGUAGE plpgsql;



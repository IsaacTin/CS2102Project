CREATE OR REPLACE PROCEDURE add_employee(input_Name VARCHAR, input_Address VARCHAR, input_Phone INT, input_Email VARCHAR, input_Salary NUMERIC(36,2), input_Join_date DATE, input_Category VARCHAR, input_Areas SET)
AS $$
DECLARE
        curs CURSOR FOR areas;
        employeeId INT;
        r RECORD;
BEGIN
        INSERT INTO Employees(name, phone, address, email, depart_date, join_date) 
        VALUES(input_Name, input_Phone, input_Address, input_Email, NULL, input_Join_date);

        SELECT eid INTO employeeId FROM Employees WHERE input_Name = name;

        IF (input_Category = 'manager') THEN
            INSERT INTO Managers VALUES(employeeId);
            INSERT INTO Full_time_Emp VALUES (employeeId, input_Salary);
            OPEN curs;
            LOOP
                FETCH curs INTO r;
                EXIT WHEN NOT FOUND;
                INSERT INTO Manages VALUES(r.name, employeeId);
                CONTINUE;
            END LOOP;
            CLOSE curs;
        ELSE IF (input_Category = 'instructor') THEN
            OPEN curs;
            LOOP
                FETCH curs INTO r;
                EXIT WHEN NOT FOUND;
                INSERT INTO Instructors VALUES (employeeId, r.name);
                CONTINUE;
            END LOOP
            CLOSE curs;
            IF (input_Salary < 1000) THEN /*i not sure if can compare int to numeric, and also i assume minimum monthly salary is above 1000*/ 
                INSERT INTO Part_time_Emp VALUES (employeeId, input_Salary);
                INSERT INTO Part_time_instructors VALUES(employeeId);
            ELSE
                INSERT INTO Full_time_Emp VALUES(employeeId, input_Salary);
                INSERT INTO Full_time_instructors VALUES(employeeId);
            END IF;

        ELSE /*WHEN ADMINISTRATOR idk if we should check if it is administrator and then raise exception if its not probably should*/
            INSERT INTO Full_time_emp VALUES(employeeId, input_Salary);
            INSERT INTO Administrators VALUES(employeeId);\
        END IF;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION delete_employee() RETURNS TRIGGER 
AS $$
BEGIN 
    IF (
        EXISTS (SELECT 1 FROM Offerings WHERE eid = NEW.eid AND end_date > NEW.depart_date
        OR 
        EXISTS (SELECT 1 FROM Sessions WHERE eid = NEW.eid AND launch_date > NEW.depart_date)
        OR
        EXISTS (SELECT 1 FROM Manages WHERE eid = NEW.eid)
        )
    THEN
        RETURN NULL;
    ELSE 
        OLD.depart_date := NEW.depart_date;
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_employee
BEFORE UPDATE ON Employees
FOR EACH ROW EXECUTE FUNCTION delete_employee();




CREATE OR REPLACE PROCEDURE add_customer(input_Name VARCHAR, input_address VARCHAR, input_Phone INT, input_Email VARCHAR, input_Number VARCHAR(16), input_Date DATE, input_CVV INT)
AS $$
DECLARE 
    customerID INT;
BEGIN 
    INSERT INTO customer(phone, address, email, name, number) VALUES(input_Phone, input_Address, input_Email, input_Name, input_Number);
    SELECT cust_id INTO customerID FROM Customers WHERE number = input_Number GROUP BY cust_id; /*added groupby to ensure that it is only one value(though it shouldnt have more anyway)*/
    INSERT INTO Credit_Cards VALUES(input_Number, input_CVV, input_Date, CURRENT_DATE, customerID);
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE PROCEDURE update_credit_card(input_ID INT, input_Number VARCHAR(16), input_Date DATE, input_CVV INT)
AS $$
DECLARE
    currentActive INT;
BEGIN 
    SELECT number INTO currentActive FROM Credit_cards WHERE cust_id = input_ID AND CURRENT_DATE < expiry_date ORDER BY from_date DESC LIMIT 1;
    UPDATE Credit_cards
    SET number = input_Number, expiry_date = input_Date, CVV = input_CVV WHERE number = input_Number;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE PROCEDURE add_course(input_Title VARCHAR, input_Desc VARCHAR, input_Area VARCHAR, input_Duration INT)
AS $$
BEGIN
    INSERT INTO Courses(area, title, description, duration) VALUES(input_Area, input_Title, input_Desc, input_Duration);
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION find_instructors(input_Cid INT, input_Date DATE, input_Hour TIME)
RETURNS TABLE (eid INT, name VARCHAR) AS $$
DECLARE
    curs CURSOR FOR (SELECT E.eid, E.name FROM Instructors I, Employees E WHERE I.eid = E.eid); /*Finding the names of the instructors*/
    r RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs into r;
        EXIT WHEN NOT FOUND;
        IF NOT EXISTS (
            SELECT 1 FROM Sessions 
            WHERE eid = r.eid 
            AND date = input_Date 
            AND input_StartHour BETWEEN start_time AND end_time)
        AND
        EXISTS (SELECT 1 FROM Courses C, Instructors I WHERE I.eid = r.eid AND I.area = C.area)
        THEN
            eid := r.eid;
            name := r.name;
            RETURN NEXT;
        ELSE
            RETURN; /*I'm assuming this means dont add the tuple into the new table */
    END LOOP;
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION get_available_instructors(input_Cid INT, input_StartDate DATE, input_EndDate DATE)
RETURNS TABLE(eid INT, name VARCHAR, hours INT, day INT, availableHours TIME[]) AS $$
DECLARE 
    curs CURSOR FOR (SELECT * FROM Instructors ORDER BY eid ASC);
    r RECORD;
    currDay INT;
    endDay INT;
    currDate DATE;
    courseArea INT;
    currTime TIME;
BEGIN
    SELECT area INTO courseArea FROM Courses WHERE course_id = input_Cid;
    currDate := input_StartDate;
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        EXIT WHEN r.area <> courseArea;
        SELECT EXTRACT(DAY FROM input_StartDate) INTO currDay;
        SELECT EXTRACT(DAY FROM input_EndDate) INTO endDay;
        LOOP 
            EXIT WHEN currDay > endDay;
            hours := 0;
            currTime := '09:00:00';
            LOOP
                EXIT WHEN currTime = '18:00:00';
                CONTINUE WHEN currTime BETWEEN '12:00:00' AND '14:00:00'
                IF EXISTS (SELECT 1 FROM find_instructors(input_Cid, currDate, currTime) WHERE r.eid = eid) THEN
                    SELECT name INTO name FROM Employees WHERE r.eid = eid;
                    eid := r.eid;
                    hours := hours + 1;
                    day := currDay;
                    SELECT array_append(availableHours, currTime);
                    SELECT currTime + INTERVAL '1 hour' INTO currTime;
                ELSE
                    SELECT currTime + INTERVAL '1 hour' INTO currTime;
                    CONTINUE
            END LOOP
            IF (eid = r.eid) THEN
                RETURN NEXT;
                currDay := currDay + 1;
                SELECT currDate + INTERVAL '1 day' INTO currDate;
            ELSE:
                currDay := currDay + 1;
                SELECT currDate + INTERVAL '1 day' INTO currDate;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION find_rooms(input_Date DATE, input_StartHour TIME, input_Duration INT)
RETURNS TABLE(rid INT) AS $$
DECLARE 
    curs CURSOR FOR (SELECT * FROM Rooms);
    r RECORD;
    endTime INT;
BEGIN
    SELECT input_StartHour + input_Duration * INTERVAL '1 hour' INTO endTime;;
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        IF NOT EXISTS (SELECT 1 FROM Sessions 
            WHERE rid = r.rid 
            AND input_Date = date 
            AND (input_StartHour BETWEEN start_time AND end_time OR endTime BETWEEN start_time AND end_time)
        THEN 
            rid := r.rid;
            RETURN NEXT;
        ELSE
            CONTINUE;
    END LOOP;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION get_available_rooms(input_StartDate DATE, input_EndDate DATE) 
RETURNS TABLE(rid INT, capacity INT, day INT, availableHours TIME[]) AS $$
DECLARE
    curs CURSOR FOR (SELECT * FROM Rooms ORDER BY ASC);
    r RECORD;
    currDay INT;
    endDay INT;
    currTime TIME;
BEGIN
    currDate := input_StartDate;
    OPEN curs
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        SELECT EXTRACT(DAY FROM input_StartDate) INTO currDay;
        SELECT EXTRACT(DAY FROM input_EndDate) INTO endDay;
        LOOP   
            EXIT WHEN currDay > endDay;
            currTime := '09:00:00';
            LOOP
                EXIT WHEN currTime = '18:00:00';
                CONTINUE WHEN currTime BETWEEN '12:00:00' AND '14:00:00';
                IF EXISTS (SELECT 1 FROM find_rooms(currDate, currTime, 1) WHERE rid = r.rid) THEN
                    rid := r.rid;
                    capacity := r.capacity;
                    day := currDay;
                    SELECT array_append(availableHours, currTime) INTO availableHours;
                    SELECT currTime + INTERVAL '1 hour' INTO currTime;
                ELSE
                    SELECT currTime + INTERVAL '1 hour' INTO currTime;
                    CONTINUE;
            END LOOP;
            IF (rid = r.rid) THEN
                RETURN NEXT;
                currDay := currDay + 1;
                SELECT currDate + INTERVAL '1 day' INTO currDate;
            ELSE 
                currDay := currDay + 1;
                SELECT currDate + INTERVAL '1 day' INTO currDate;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
    



CREATE OR REPLACE PROCEDURE add_course_offering(input_Cid INT, )

/* 
  Q21: Change instructor for a course *session*
  Reference for date/time functions and operators: https://www.postgresql.org/docs/8.2/functions-datetime.html

  NOTE: CourseOfferingSession is a weak entity, but update_instructor procedure does not use the launch_date
  which is part of CourseOfferingSession's primary key. I have ommitted using launch_date in my check for
  the matching course session. Not sure if this is okay, I think it should be fine if we can garuantee that
  sid is unique (which is what we are doing now).
*/
CREATE OR REPLACE PROCEDURE update_instructor(input_courseId INT, input_sessionId INT, input_instructorId INT)
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
    AND (date session_date + time end_time) < INTERVAL '0'; -- Course session hasn't started
END;
$$ LANGUAGE plpgsql;


/*
  Q22: Change room for a course *session*

  NOTE: Similar to Q21, the checking for course session with input_sessionId assumes that the sid
  of course sessions are unique. This however contradicts the sample ER model which shows sessions
  as a weak entity, requiring launch date to uniquely identify a particular course session.
*/
CREATE OR REPLACE PROCEDURE update_room(input_courseId INT, input_sessionId INT, input_roomId INT)
AS $$
DECLARE
    numRegistrations INT;
BEGIN
    numRegistrations := SELECT count(*) 
                        FROM Registers
                        WHERE sid = input_sessionId

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
    AND (date session_date + time end_time) < INTERVAL '0'; -- Course session hasn't started
END;
$$ LANGUAGE plpgsql;
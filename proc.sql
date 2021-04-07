/* ALL TRIGGERS*/
/*
explanation for multiple triggers checking the same thing 
https://stackoverflow.com/questions/39689523/postgresql-multiple-triggers-and-functions
*/
/*
1) No two course offering session of the same course offering can be done on 
the same day and time (but idk if two sessions can be done on the same day at different times)
*/

CREATE TRIGGER check_course_offering_session
BEFORE UPDATE OR INSERT ON CourseOfferingSessions
FOR EACH ROW 
EXECUTE FUNCTION check_course_offering_session();

CREATE OR REPLACE FUNCTION check_course_offering_session() 
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM CourseOfferingSessions 
        WHERE NEW.course_id = course_id 
        AND NEW.launch_date = launch_date 
        AND NEW.session_date = session_date
        AND NEW.start_time BETWEEN start_time AND end_time - INTERVAL '1 second') THEN
        RAISE EXCEPTION 'No course offering session of the same course offering to be conducted on same day and time.'
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql

/*
2)2. For each course offered by company, 
customer can register for at most one of its session before its registration deadline
*/
CREATE TRIGGER check_register
BEFORE INSERT ON Registers
FOR EACH ROW
EXECUTE FUNCTION check_register();

CREATE OR REPLACE FUNCTION check_register()
RETURNS TRIGGER AS $$
DECLARE
    registrationDeadline INT;
BEGIN
    WITH CurrSessions AS (SELECT sid FROM CourseOfferingSessions WHERE launch_date = NEW.launch_date AND course_id = NEW.course_id AND sid <> NEW.sid);
    SELECT registration_deadline FROM CourseOfferings WHERE launch_date = NEW.launch_date AND course_id = NEW.course_id INTO registrationDeadline;
    IF EXISTS (SELECT 1 FROM Registers WHERE sid IN CurrSessions AND cust_id = NEW.cust_id)
    OR
    NEW.registers_date >= registration_deadline THEN
        RAISE EXCEPTION 'Cannot register for more than one session of the same course offering and must register before registration deadline'
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;


/*
3) Seating capacity of course session is equal 
to seating capacity of room where session conducted, 
and the seating capacity of a course offering is equal to 
sum of seating capacities of its sessions (I think can use triggers to update everytime a course session is added)
*/


CREATE TRIGGER update_course_offering_seating_capacity
AFTER INSERT OR UPDATE ON CourseOfferingSessions
FOR EACH ROW
EXECUTE FUNCTION update_course_offering_seating_capacity();


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
END;
$$ LANGUAGE plpgsql;

/*
7.	Each room can be used to conduct at most one course session at any time.
*/

CREATE TRIGGER check_rooms
BEFORE INSERT OR UPDATE ON CourseOfferingSessions
FOR EACH ROW
EXECUTE FUNCTION check_rooms();

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
        RAISE EXCEPTION 'Room can only be used to conduct at most one course at any time'
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

/*
8.	Each instructor specializes in a set of one 
or more course areas (need to check if the course_area exists) 
(also I guess check if course_area is null or not)
*/

/* actl i think this one dont need since foreign key kinda ensures it but i just leave it here first*/
CREATE TRIGGER check_instructor_specialization
BEFORE INSERT OR UPDATE ON Instructors
FOR EACH ROW
EXECUTE FUNCTION check_instructor_specialization();

CREATE OR REPLACE FUNCTION check_instructor_specialization()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.course_area_name NOT IN (SELECT course_area_name FROM CourseAreaManaged) THEN
        RAISE EXCEPTION 'Course area instructor specializes in does not exist';
    ELSE 
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;



/*
9.	instructor who is assigned to teach a course session must be specialized in that course area
*/

CREATE TRIGGER check_if_specialized 
BEFORE INSERT OR UPDATE ON CourseOfferingSessions
FOR EACH ROW
EXECUTE FUNCTION check_if_specialized();


CREATE OR REPLACE FUNCTION check_if_specialized()
RETURNS TRIGGER AS $$
DECLARE
    CourseAreaName VARCHAR;
BEGIN
    SELECT course_area_name FROM Courses WHERE course_id = NEW.course_id INTO CourseAreaName;
    IF (NEW.course_area_name NOT IN (SELECT course_area_name FROM Instructors WHERE NEW.eid = eid)) THEN
        RAISE EXCEPTION 'Instructor who is assigned to this course session must specialize in the course area the course needs.';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

/*
10.	Each instructor can teach at most one course session at any hour AND Each instructor must not be assigned to teach two consecutive course sessions
*/

CREATE TRIGGER check_if_same_hour 
BEFORE INSERT OR UPDATE ON CourseOfferingSessions
FOR EACH ROW
EXECUTE FUNCTION check_if_same_hour();

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


/*
12.	Each part-time instructor must not teach more than 30 hours for each month.
*/

CREATE TRIGGER check_part_time_instructor_hours
BEFORE INSERT OR UPDATE ON CourseOfferingSessions
FOR EACH ROW
EXECUTE FUNCTION check_part_time_instructor_hours();


CREATE OR REPLACE FUNCTION check_part_time_instructor_hours()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.eid IN (SELECT eid FROM Part_time_instructors) THEN
        IF (SELECT EXTRACT (EPOCH FROM 
            (SELECT SUM(end_time - start_time) FROM CourseOfferingSessions 
                WHERE eid = NEW.eid
                AND (SELECT EXTRACT (MONTH FROM session_date) = (SELECT EXTRACT (MONTH FROM NEW.session_date)))))/3600) > 30
        THEN
            RAISE EXCEPTION 'Part-time instructors must not teach more than 30 hours for each month.'
            RETURN NULL;
        ELSE
            RETURN NEW;
        END IF;
    ELSE 
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;



/*ENDS HERE*/ 
CREATE OR REPLACE PROCEDURE add_employee(input_Name VARCHAR, input_Address VARCHAR, input_Phone INT, input_Email VARCHAR, input_Salary NUMERIC(36,2), input_Join_date DATE, input_Category VARCHAR, input_Areas VARCHAR[])
AS $$
DECLARE
        employeeId INT;
        area VARCHAR;
BEGIN
        INSERT INTO Employees(name, phone, address, email, depart_date, join_date) 
        VALUES(input_Name, input_Phone, input_Address, input_Email, NULL, input_Join_date);

        SELECT eid INTO employeeId FROM Employees WHERE input_Name = name;

        IF (input_Category = 'manager') THEN
            INSERT INTO Managers VALUES(employeeId);
            INSERT INTO Full_time_Emp VALUES (employeeId, input_Salary);
            FOREACH area IN ARRAY input_Areas
            LOOP
                INSERT INTO CourseAreaManaged VALUES(area, employeeId);
            END LOOP;
        ELSIF (input_Category = 'instructor') THEN
            FOREACH area IN ARRAY input_Areas
            LOOP
                INSERT INTO Instructors VALUES(area, employeeId);
            END LOOP;
            IF (input_Salary < 1000) THEN /*i not sure if can compare int to numeric, and also i assume minimum monthly salary is above 1000*/ 
                INSERT INTO Part_time_Emp VALUES (employeeId, input_Salary);
                INSERT INTO Part_time_instructors VALUES(employeeId);
            ELSE
                INSERT INTO Full_time_Emp VALUES(employeeId, input_Salary);
                INSERT INTO Full_time_instructors VALUES(employeeId);
            END IF;

        ELSE /*WHEN ADMINISTRATOR idk if we should check if it is administrator and then raise exception if its not probably should*/
            INSERT INTO Full_time_emp VALUES(employeeId, input_Salary);
            INSERT INTO Administrators VALUES(employeeId);
        END IF;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE PROCEDURE remove_employee(input_Eid INT, input_DepartureDate DATE) /*Not sure if i should implement the constraints as a trigger*/
AS $$
BEGIN 
    IF (
        EXISTS (SELECT 1 FROM CourseOfferings WHERE eid = input_Eid AND registration_deadline > input_DepartureDate
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
    END IF;
END;
$$ LANGUAGE plpgsql;



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
            AND input_StartHour BETWEEN start_time AND end_time) /*end_time inclusive as instructor not supposed to teach two sessions in a row anyway*/
        AND
        EXISTS (SELECT 1 FROM Courses C, Instructors I WHERE I.eid = r.eid AND I.area = C.area AND C.course_id = input_Cid)
        THEN
            eid := r.eid;
            name := r.name;
            RETURN NEXT;
        ELSE
            CONTINUE;
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
        (SELECT EXTRACT (EPOCH FROM 
            (SELECT SUM(end_time - start_time) FROM CourseOfferingSessions 
                WHERE eid = r.eid
                AND (SELECT EXTRACT (MONTH FROM session_date) = (SELECT EXTRACT (MONTH FROM currDate)))))/3600) INTO hours;
        LOOP 
            EXIT WHEN currDay > endDay;
            currTime := TIME '09:00:00';
            LOOP
                EXIT WHEN currTime = TIME '18:00:00';
                CONTINUE WHEN currTime BETWEEN TIME '12:00:00' AND TIME '13:59:00'
                IF EXISTS (SELECT 1 FROM find_instructors(input_Cid, currDate, currTime) WHERE r.eid = eid) THEN
                    SELECT name INTO name FROM Employees WHERE r.eid = eid;
                    eid := r.eid;
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
        IF NOT EXISTS (SELECT 1 FROM CourseOfferingSessions 
            WHERE rid = r.rid 
            AND input_Date = date 
            AND (input_StartHour BETWEEN start_time AND (end_time - INTERVAL '1 second') OR endTime BETWEEN start_time AND end_time)
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
            currTime := TIME '09:00:00';
            LOOP
                EXIT WHEN currTime = TIME '18:00:00';
                CONTINUE WHEN currTime BETWEEN TIME '12:00:00' AND TIME '13:59:00';
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
    



CREATE OR REPLACE PROCEDURE add_course_offering(input_Coid INT, input_Cid INT, input_Fees NUMERIC(36,2), input_Launch_date DATE, input_Registration_deadline DATE, input_Eid INT, input_Target_registration INT, ) /*I'm having trouble with this as I do not know how to input all the sessions at one go*/



-- 18 
-- Does not include redeems
CREATE OR REPLACE FUNCTION get_my_registrations(input_cust_id INT)
RETURNS TABLE(course_name VARCHAR, course_fees NUMERIC(36,2), session_date DATE,
session_start_hour TIME, session_duration INT, instructor_name VARCHAR) AS $$
BEGIN
    RETURN QUERY
        (SELECT title, S2.fees, S2.session_date, S2.start_time, duration, S2.instructor_name
        FROM 
            (SELECT S1.course_id, fees, S1.session_date, S1.start_time, S1.instructor_name
            FROM 
                (SELECT S0.launch_date, S0.course_id, S0.session_date, S0.start_time,
                    S0.name AS instructor_name
                FROM (Registers NATURAL JOIN CourseOfferingSessions NATURAL JOIN Employees) AS S0
                WHERE S0.cust_id = input_cust_id
                    AND (
                        CASE
                        WHEN S0.session_date = CURRENT_DATE THEN S0.start_time >= CURRENT_TIME
                        WHEN S0.session_date > CURRENT_DATE THEN TRUE
                        ELSE FALSE
                        END
                        )
                    AND S0.depart_date IS NULL) AS S1 -- just to make sure
                NATURAL JOIN CourseOfferings) AS S2
            NATURAL JOIN Courses)
        UNION
        (SELECT title, S4.fees, S4.session_date, S4.start_time, duration, S4.instructor_name
        FROM 
            (SELECT S3.course_id, fees, S3.session_date, S3.start_time, S3.instructor_name
            FROM 
                (SELECT S0.launch_date, S0.course_id, S0.session_date, S0.start_time,
                    S0.name AS instructor_name
                FROM (Redeems NATURAL JOIN CourseOfferingSessions NATURAL JOIN Employees) AS S0
                WHERE S0.cust_id = input_cust_id
                    AND (
                        CASE
                        WHEN S0.session_date = CURRENT_DATE THEN S0.start_time >= CURRENT_TIME
                        WHEN S0.session_date > CURRENT_DATE THEN TRUE
                        ELSE FALSE
                        END
                        )
                    AND S0.depart_date IS NULL) AS S3 -- just to make sure
                NATURAL JOIN CourseOfferings) AS S4
            NATURAL JOIN Courses)
        ORDER BY (session_date, start_time) ASC;
END;
$$ LANGUAGE plpgsql;
        
-- TODO: trigger to prevent customer from registering and redeeming same session.
-- 19
CREATE OR REPLACE PROCEDURE update_course_session(input_cust_id INT, input_course_id INT, new_sid INT)
AS $$
DECLARE
    count INT;
    num_registrations INT;
    has_space BOOLEAN;
BEGIN
    SELECT COUNT(*) INTO num_registrations
        FROM Registers
        WHERE sid = new_sid
        AND course_id = input_course_id;

    IF ((SELECT COUNT(*)
        FROM Registers
        WHERE cust_id = input_cust_id 
            AND course_id = input_course_id 
            AND sid <> new_sid) > 0) 
        THEN 
        -- find out if there is space in new session
        IF NOT EXISTS (SELECT 1
                        FROM Rooms R
                        WHERE R.rid = 
                            (SELECT S1.rid
                                FROM (Registers NATURAL JOIN CourseOfferingSessions) S1
                                WHERE S1.cust_id = input_cust_id
                                    AND S1.course_id = course_id
                                    AND S1.sid = new_sid)
                            AND R.seating_capacity >= (num_registrations + 1)
        ) THEN RAISE NOTICE 'Seating capacity full for Session with sid: %', new_sid;
        ELSE
            UPDATE Registers
            SET sid = new_sid
            WHERE course_id = input_course_id
                AND cust_id = input_cust_id;
        END IF;
    ELSIF ((SELECT COUNT(*)
        FROM Redeems
        WHERE cust_id = input_cust_id 
            AND course_id = input_course_id 
            AND sid <> new_sid) > 0)
        THEN
        -- find out if there is space in new session
        IF NOT EXISTS (SELECT 1
                        FROM Rooms R
                        WHERE R.rid = 
                            (SELECT S1.rid
                                FROM (Redeems NATURAL JOIN CourseOfferingSessions) S1
                                WHERE S1.cust_id = input_cust_id
                                    AND S1.course_id = course_id
                                    AND S1.sid = new_sid)
                            AND R.seating_capacity >= (num_registrations + 1)
        ) THEN RAISE NOTICE 'Seating capacity full for Session with sid: %', new_sid;
        ELSE
            UPDATE Redeems
            SET sid = new_sid
            WHERE course_id = input_course_id
                AND cust_id = input_cust_id;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 20
CREATE OR REPLACE PROCEDURE cancel_registration(input_cust_id INT, input_course_id INT)
AS $$
DECLARE
    curr_session_date DATE;
    session_price NUMERIC(36,2);
    session_id INT;
    session_launch_date DATE;
BEGIN 
    IF NOT EXISTS (
        SELECT 1 
        FROM Registers
        WHERE cust_id = input_cust_id AND course_id = input_course_id
        ) THEN RETURN;
    END IF;

    SELECT P1.session_date, P1.fees, P1.sid, P1.launch_date INTO curr_session_date, session_price, session_id, session_launch_date
    FROM ((SELECT R1.sid
            FROM Registers R1
            WHERE R1.cust_id = input_cust_id AND R1.course_id = input_course_id) AS S1
            NATURAL JOIN
            CourseOfferingSessions) AS P1;
    
    -- We treat fees in CourseOfferings as fees per session not fees per offering.
    -- Only insert into cancels if refunded.
    IF (curr_session_date - CURRENT_DATE > 7) THEN
        INSERT INTO Cancels (date, refund_amt, package_credit, cust_id, sid, course_id, launch_date)
        VALUES (CURRENT_DATE, 0.9 * session_price, NULL, input_cust_id, session_id, input_course_id, session_launch_date);
    END IF;
    DELETE FROM Registers
    WHERE course_id = input_course_id
        AND cust_id = input_cust_id;
END;
$$ LANGUAGE plpgsql;

--25
CREATE OR REPLACE FUNCTION pay_salary()
RETURNS TABLE(eid INT, name VARCHAR, status VARCHAR(10), num_work_days INT,
num_work_hours INT, hourly_rate numeric(36,2), monthly_salary numeric(36,2), salary_amount numeric(36,2)) AS $$
DECLARE
  num_days_in_month INT;
  curs CURSOR FOR (SELECT * FROM Employees ORDER BY eid ASC);
  r RECORD;
  first_work_day_of_month INT;
  last_work_day_of_month INT;
BEGIN
    num_days_in_month := (SELECT DATE_PART('days', 
                            DATE_TRUNC('month', CURRENT_DATE) 
                            + INTERVAL '1 month' 
                            - INTERVAL '1 day')
                        );
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        eid := r.eid;
        name := r.name;
        IF (
            (SELECT COUNT(*)
            FROM Part_time_Emp P1 
            WHERE P1.eid = r.eid) > 0
        ) THEN
            status := 'part-time';
            num_work_days := NULL;
            monthly_salary := NULL;
            num_work_hours := (SELECT COALESCE(SUM(COS1.end_time - COS1.start_time), 0) 
                                FROM CourseOfferingSessions COS1 
                                WHERE COS1.eid = r.eid);
            hourly_rate := (SELECT P2.hourly_rate FROM Part_time_Emp P2 WHERE P2.eid = r.eid);
            salary_amount := num_work_hours * hourly_rate;
            INSERT INTO Pay_slips
            VALUES (CURRENT_DATE, salary_amount, num_work_hours, NULL, r.eid);
        ELSE
            status := 'full-time';
            num_work_hours := NULL;
            hourly_rate := NULL;
            -- getting first and last day of work to find number of days in the month worked. Pay is prorated based on this number.
            IF ((CURRENT_DATE - r.join_date) < num_days_in_month) THEN
                SELECT EXTRACT(DAY FROM r.join_date) INTO first_work_day_of_month;
            ELSE
                first_work_day_of_month := 1;
            END IF;
            IF (r.depart_date IS NOT NULL AND (CURRENT_DATE - r.depart_date) < num_days_in_month) THEN
                SELECT EXTRACT(DAY FROM r.join_date) INTO last_work_day_of_month;
            ELSE
                last_work_day_of_month := num_days_in_month;
            END IF;
            num_work_days := last_work_day_of_month - first_work_day_of_month + 1;
            monthly_salary := (SELECT F1.monthly_salary FROM Full_time_Emp F1 WHERE F1.eid = r.eid);
            salary_amount := (num_work_days / num_days_in_month) * monthly_salary;
            INSERT INTO Pay_slips
            VALUES (CURRENT_DATE, salary_amount, NULL, num_work_days, r.eid);
        END IF;
        RETURN NEXT;
    END LOOP;
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;

--27
CREATE OR REPLACE FUNCTION top_packages(N INT)
RETURNS TABLE (package_id INT, num_free_registrations INT, price NUMERIC(36,2), sale_start_date DATE, sale_end_date DATE, 
    num_packages_sold INT) AS $$
BEGIN
    RETURN QUERY
        WITH num_package_table(package_id, num_free_registrations, price, sale_start_date, sale_end_date, 
            num_packages_sold) AS
            (SELECT DISTINCT P1.package_id, P1.num_free_registrations, P1.price, P1.sale_start_date, P1.sale_end_date, 
                (SELECT COUNT(*) 
                    FROM Buys B1
                    WHERE B1.package_id = P1.package_id) AS num_packages_sold
                FROM Course_packages P1
                ORDER BY (num_packages_sold, price) DESC),

            Nth_package(package_id, num_free_registrations, price, sale_start_date, sale_end_date, 
            num_packages_sold) AS
            (SELECT * FROM num_package_table
            ORDER BY (num_packages_sold, price) DESC 
            LIMIT 1 OFFSET (N - 1)),

            num_package(package_id, num_packages_sold) AS
            (SELECT N1.package_id, N1.num_packages_sold
                FROM num_package_table N1
                WHERE N1.num_packages_sold >= 
                    (SELECT N2.num_packages_sold
                        FROM Nth_package N2))
        SELECT package_id, num_free_registrations, price, sale_start_date, sale_end_date, num_packages_sold
            FROM num_package NATURAL JOIN num_package_table
            ORDER BY (num_packages_sold, price) DESC;
END;
$$ LANGUAGE plpgsql;

--29

CREATE OR REPLACE FUNCTION view_summary_report(N INT)
RETURNS TABLE (month VARCHAR, year INT, total_salary_paid NUMERIC(36,2), total_num_package_sales INT,
    total_fees_paid_credit_card NUMERIC(36,2), total_refunds NUMERIC(36,2), num_package_registrations INT) AS $$
DECLARE
    months_left INT;
    curr_month_date TIMESTAMP;
BEGIN
    months_left := N;
    curr_month_date := NOW();
    LOOP
        EXIT WHEN months_left = 0;
        SELECT to_char(curr_month_date, 'Month') INTO month;
        SELECT EXTRACT(YEAR FROM curr_month_date) INTO year;
        SELECT SUM(amount) INTO total_salary_paid
            FROM Pay_slips P1
            WHERE (SELECT EXTRACT(MONTH FROM P1.payment_date)) 
                = (SELECT EXTRACT(MONTH FROM curr_month_date));
        SELECT COUNT(*) INTO total_num_package_sales
            FROM Buys B1
            WHERE (SELECT EXTRACT(MONTH FROM B1.buys_date)) 
                = (SELECT EXTRACT(MONTH FROM curr_month_date));
        SELECT SUM(O1.fees) INTO total_fees_paid_credit_card
            FROM Registers R1, CourseOfferingSessions S1
            WHERE (SELECT EXTRACT(MONTH FROM R1.registers_date)) 
                = (SELECT EXTRACT(MONTH FROM curr_month_date))
                AND R1.sid = S1.sid;
        SELECT SUM(C1.refund_amt) INTO total_refunds
            FROM Cancels C1
            WHERE C1.refund_amt IS NOT NULL
                AND
                (SELECT EXTRACT(MONTH FROM C1.date)) 
                = (SELECT EXTRACT(MONTH FROM curr_month_date));
        SELECT COUNT(*) INTO num_package_registrations
            FROM Redeems R1
            WHERE (SELECT EXTRACT(MONTH FROM R1.redeems_date)) 
                = (SELECT EXTRACT(MONTH FROM curr_month_date));
        curr_month_date := curr_month_date - INTERVAL '1 month';
        months_left := months_left - 1;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE add_room(input_location VARCHAR, input_seating_capacity INT)
AS $$
BEGIN
    INSERT INTO Rooms(location, seating_capacity) VALUES (input_location, input_seating_capacity) ;
END;
$$ LANGUAGE plpgsql;


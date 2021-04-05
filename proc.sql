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



-- 18 
-- Does this include redeems as well?
CREATE OR REPLACE FUNCTION get_my_registrations(input_cust_id INT)
RETURNS TABLE(course_name VARCHAR, course_fees NUMERIC(36,2), session_date DATE,
session_start_hour TIME, session_duration INT, instructor_name VARCHAR) AS $$
BEGIN
    RETURN QUERY
        SELECT title, fees, session_date, start_time, duration, instructor_name
        FROM 
            (SELECT course_id, fees, session_date, start_time, duration, instructor_name
            FROM 
                (SELECT launch_date, course_id, session_date, start_time, (end_time - start_time) AS duration, name AS instructor_name
                FROM Registers NATURAL JOIN CourseOfferingSessions NATURAL JOIN Employees
                WHERE cust_id = input_cust_id
                    AND (
                        CASE
                        WHEN session_date == CURRENT_DATE THEN start_time >= CURRENT_TIME
                        WHEN session_date > CURRENT_DATE THEN TRUE
                        ELSE FALSE
                        END
                        )
                    AND depart_date IS NULL) -- just to make sure
                NATURAL JOIN CourseOfferings)
            NATURAL JOIN Courses
        ORDER BY (session_date, start_time) ASC;
END;
$$ LANGUAGE plpgsql;
        

-- 19
CREATE OR REPLACE PROCEDURE update_course_session(input_cust_id INT, input_course_id INT, new_sid INT)
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM Registers
        WHERE cust_id = input_cust_id AND course_id = input_course_id AND sid <> new_sid
        ) THEN RETURN;
    END IF;

    -- incomplete; how do i know which session to update if there are multiple registered sessions


END;
$$ LANGUAGE plpgsql;

-- 20
CREATE OR REPLACE PROCEDURE cancel_registration(input_cust_id INT, input_course_id INT)
AS $$
BEGIN 
    IF NOT EXISTS (
        SELECT 1 
        FROM Registers
        WHERE cust_id = input_cust_id AND course_id = input_course_id
        ) THEN RETURN;
    END IF;

    -- not sure if i have to check for specific sessions
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

--29

CREATE OR REPLACE FUNCTION view_summary_report(N INT)
RETURNS TABLE (month VARCHAR, year INT, total_salary_paid NUMERIC(36,2), total_num_package_sales INT,
    total_fees_paid_credit_card NUMERIC(36,2), total_refunds NUMERIC(36,2), num_package_registrations INT) AS $$
DECLARE
    months_left INT;
    curr_month_date TIMESTAMP;
BEGIN
    months_left := N;
    curr_month := NOW();
    LOOP
        EXIT WHEN months_left = 0;
        SELECT to_char(curr_month_date, 'Month') INTO month;
        SELECT EXTRACT(YEAR FROM curr_month_date) INTO year;
        total_salary_paid := (SELECT SUM(amount)
                                FROM Pay_slips P1
                                WHERE (SELECT EXTRACT(MONTH FROM P1.payment_date)) 
                                    = (SELECT EXTRACT(MONTH FROM curr_month_date)));
        


        curr_month_date := curr_month_date - INTERVAL '1 month';
        months_left := months_left - 1;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
--30
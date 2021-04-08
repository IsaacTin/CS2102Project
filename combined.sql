/**
CS2102 relational database schema for ER data model
**/
    
DROP TABLE IF EXISTS Course_packages, Credit_cards, Customers, Cancels, Registers, Redeems,
Buys, CourseOfferingSessions, CourseOfferings, Courses, Rooms, Instructors,
Administrators, Managers, CourseAreaManaged, Full_time_instructors, Part_time_instructors,
Full_time_Emp, Part_time_Emp, Employees, Pay_slips, Specializes CASCADE;

-- DONE
CREATE TABLE Course_packages (
    package_id                      INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name                            VARCHAR NOT NULL,
    price                           NUMERIC(36,2) NOT NULL, 
    sale_start_date                 DATE NOT NULL,
    sale_end_date                   DATE NOT NULL,
    num_free_registrations          INT NOT NULL,
    CONSTRAINT price_positive CHECK (price >= 0),
    CONSTRAINT sale_duration_valid CHECK (sale_end_date - sale_start_date >= 0),
    CONSTRAINT num_free_registrations_positive CHECK (num_free_registrations >= 0)
);

-- DONE
CREATE TABLE Rooms (
    rid                             INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    location                        VARCHAR NOT NULL,
    seating_capacity                INT NOT NULL
);

-- DONE
CREATE TABLE Employees (
    eid                             INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name                            VARCHAR NOT NULL,
    phone                           INT NOT NULL UNIQUE,
    address                         VARCHAR NOT NULL,
    email                           VARCHAR NOT NULL UNIQUE,
    depart_date                     DATE, /* Date has to be null if employee has not left company*/
    join_date                       DATE NOT NULL
);

-- DONE
CREATE TABLE Full_time_Emp (
    eid                             INT PRIMARY KEY REFERENCES Employees(eid) ON DELETE CASCADE,
    monthly_salary                  NUMERIC(36,2),
    CONSTRAINT monthly_salary_positive CHECK (monthly_salary >= 0)
);

-- DONE
CREATE TABLE Part_time_Emp (
    eid                             INT PRIMARY KEY REFERENCES Employees(eid) ON DELETE CASCADE,
    hourly_rate                     NUMERIC(36,2),
    CONSTRAINT hourly_rate_positive CHECK (hourly_rate >= 0)
);

-- DONE
CREATE TABLE Managers (
    eid                             INT PRIMARY KEY REFERENCES Full_time_Emp(eid) ON DELETE CASCADE
);

-- DONE
CREATE TABLE CourseAreaManaged (
    course_area_name                VARCHAR PRIMARY KEY, /*ensure 1 to 1 with CourseAreaManaged*/
    eid                             INT NOT NULL,
    FOREIGN KEY (eid) REFERENCES Managers(eid) ON DELETE CASCADE
    /* So there will only be exactly one instance of every course area here, and each one is taken by a manager, ensuring each course_area is taken by exactly 1 manager only*/
);

CREATE TABLE Instructors (
    eid                             INT PRIMARY KEY REFERENCES Employees(eid) ON DELETE CASCADE /*I removed Unique as instructors can specialze in more than one area*/
);

CREATE TABLE Specializes (
    eid                             INT REFERENCES Employees(eid) ON DELETE CASCADE,
    course_area_name                VARCHAR REFERENCES CourseAreaManaged(course_area_name) ON DELETE CASCADE,
    PRIMARY KEY (eid, course_area_name)
);

-- DONE
CREATE TABLE Part_time_instructors (
    eid                             INT PRIMARY KEY,
    FOREIGN KEY (eid) REFERENCES Instructors(eid) ON DELETE CASCADE,
    FOREIGN KEY (eid) REFERENCES Part_time_Emp(eid) ON DELETE CASCADE
);

-- DONE
CREATE TABLE Full_time_instructors (
    eid                             INT PRIMARY KEY,
    FOREIGN KEY (eid) REFERENCES Instructors(eid) ON DELETE CASCADE,
    FOREIGN KEY (eid) REFERENCES Full_time_Emp(eid) ON DELETE CASCADE
);

-- DONE
CREATE TABLE Courses (
    course_id                       INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    course_area_name                VARCHAR NOT NULL, /**name of course area, NOT NULL enforces total participation and key constraint**/
    title                           VARCHAR NOT NULL,
    description                     VARCHAR NOT NULL,
    duration                        INT NOT NULL, /**duration is in number of hours**/
    FOREIGN KEY (course_area_name) REFERENCES CourseAreaManaged(course_area_name) ON DELETE CASCADE,
    CONSTRAINT course_duration_is_more_than_zero CHECK (duration > 0)
);

-- DONE
CREATE TABLE Customers (
    cust_id                         INT UNIQUE GENERATED ALWAYS AS IDENTITY,
    name                            VARCHAR NOT NULL,
    phone                           INT NOT NULL UNIQUE,
    address                         VARCHAR NOT NULL, /* added in address cuz its needed*/
    email                           VARCHAR NOT NULL UNIQUE,
    number                          VARCHAR(16) UNIQUE, /** added inside unique to ensure each credit card is owned by only one customer*/
    PRIMARY KEY (cust_id, number)
);

-- DONE
CREATE TABLE Credit_cards (
    number                          VARCHAR(16) PRIMARY KEY,
    CVV                             INT NOT NULL,
    expiry_date                     DATE NOT NULL,
    from_date                       DATE,
    cust_id                         INT NOT NULL,
    FOREIGN KEY (cust_id) REFERENCES Customers(cust_id) ON DELETE CASCADE
);

-- DONE
CREATE TABLE Buys (
    buys_date                       DATE,
    num_remaining_redemptions       INT,
    cust_id                         INT REFERENCES Customers(cust_id),
    number                          VARCHAR(16) REFERENCES Credit_cards(number),
    package_id                      INT REFERENCES Course_packages(package_id),
    PRIMARY KEY(buys_date, cust_id, number, package_id)
);

-- DONE
CREATE TABLE Administrators (
    eid                             INT PRIMARY KEY REFERENCES Full_time_Emp(eid) ON DELETE CASCADE
);

-- DONE
CREATE TABLE CourseOfferings (
    launch_date                     DATE NOT NULL,
    start_date                      DATE,
    end_date                        DATE,
    registration_deadline           DATE NOT NULL,
    target_number_registrations     INTEGER NOT NULL,
    seating_capacity                INTEGER,
    fees                            NUMERIC(36,2) NOT NULL,
    course_id                       INT NOT NULL,
    eid                             INT NOT NULL, /* administrator id */
    PRIMARY KEY (launch_date, course_id), /*Weak entity of Offering is identified by Course*/
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (eid) REFERENCES Administrators(eid) ON DELETE CASCADE,
    CONSTRAINT target_number_registrations_positive CHECK (target_number_registrations >= 0),
    CONSTRAINT fees_positive CHECK (fees >= 0),
    CONSTRAINT registration_deadline_10_days_before_start_date CHECK (start_date - registration_deadline >= 10)
);

-- DONE
CREATE TABLE CourseOfferingSessions (
    sid                             INT, /*Took out unique here*/
    start_time                      TIME NOT NULL,
    end_time                        TIME NOT NULL,
    rid                             INT NOT NULL,
    eid                             INT NOT NULL,
    course_id                       INT NOT NULL,
    session_date                    DATE,
    launch_date                     DATE NOT NULL,
    FOREIGN KEY (rid) REFERENCES Rooms(rid),
    FOREIGN KEY (eid) REFERENCES Instructors(eid),
    FOREIGN KEY (course_id, launch_date) REFERENCES CourseOfferings(course_id, launch_date) ON DELETE CASCADE,
    PRIMARY KEY (sid, launch_date, course_id), /*Weak entity of Sessions is identified by weak entity of Offering which is identified by Course*/
    CONSTRAINT time_check CHECK (
        (CASE 
            WHEN (start_time >= TIME '09:00:00' AND end_time <= TIME '18:00:00' AND start_time < end_time) THEN
                CASE
                    WHEN (start_time BETWEEN TIME '09:00:00' AND TIME '12:00:00') THEN (end_time <= TIME '12:00:00') 
                    WHEN (end_time BETWEEN TIME '14:00:00' AND TIME '18:00:00') THEN (start_time >= TIME '14:00:00') /* I think this one should be BETWEEN '14:00:00 AND 18:00:00 cuz 6pm is 18:00:00'*/
                    ELSE FALSE
                END
            ELSE FALSE
        END
        )
    ),
    CONSTRAINT sid_more_than_1 CHECK (sid >= 1),
    CONSTRAINT session_date_after_launch_date CHECK (session_date >= launch_date)
);

-- DONE
CREATE TABLE Registers (
    registers_date                  DATE,
    cust_id                         INT REFERENCES Customers(cust_id),
    number                          VARCHAR(16) REFERENCES Credit_cards(number),
    sid                             INT NOT NULL, 
    course_id                       INT NOT NULL,
    launch_date                     DATE NOT NULL, /*add in cuz i think its needed here*/
    PRIMARY KEY(registers_date, cust_id, number, sid, course_id, launch_date),
    FOREIGN KEY (sid, course_id, launch_date) REFERENCES CourseOfferingSessions(sid, course_id, launch_date) ON UPDATE CASCADE ON DELETE CASCADE
);

-- DONE
CREATE TABLE Redeems (
    redeems_date                    DATE,
    buys_date                       DATE,
    sid                             INT,
    course_id                       INT,
    launch_date                     DATE,
    cust_id                         INT,
    number                          VARCHAR(16),
    package_id                      INT,
    FOREIGN KEY (buys_date, cust_id, number, package_id) REFERENCES Buys(buys_date, cust_id, number, package_id) ON DELETE CASCADE, -- Aggregation
    FOREIGN KEY (sid, course_id, launch_date) REFERENCES CourseOfferingSessions(sid, course_id, launch_date) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (redeems_date, buys_date, sid, cust_id, number, package_id)
);

-- DONE
CREATE TABLE Pay_slips (
    payment_date                    DATE,
    amount                          NUMERIC(36,2),
    num_work_hours                  INT, /** number of hours */
    num_work_days                   INT, /** number of days */
    eid                             INT,
    PRIMARY KEY (payment_date, eid),
    FOREIGN KEY (eid) REFERENCES Employees(eid) ON DELETE CASCADE
);

-- DONE
CREATE TABLE Cancels (
    date                            DATE,
    refund_amt                      NUMERIC(36,2),
    package_credit                  INT,
    cust_id                         INT,
    sid                             INT,
    course_id                       INT,
    launch_date                     DATE,
    PRIMARY KEY (date, cust_id, sid, launch_date, course_id),
    FOREIGN KEY (cust_id) REFERENCES Customers(cust_id) ON DELETE CASCADE,
    FOREIGN KEY (sid, course_id, launch_date) REFERENCES CourseOfferingSessions(sid, course_id, launch_date) ON DELETE CASCADE
);


/*
Constraints I think are not captured:


Isaac- I think my triggers covers the first and second constraint stated here. However, third constraint I haven't implemented yet


1) The offerings for the same course have different launch dates.

2) The seating capacity of a course session is equal to the seating capacity of the room where the session is conducted, 
and the seating capacity of a course offering is equal to the sum of the seating capacities of its sessions

3) A course offering is said to be available if the number of registrations received is no more than its seating capacity; 
otherwise, we say that a course offering is fully booked.


*/

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
DROP TRIGGER IF EXISTS check_redeems ON Redeems;
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
2. For each course offered by company, 
customer can register for at most one of its session before its registration deadline
*/

CREATE OR REPLACE FUNCTION check_register()
RETURNS TRIGGER AS $$
DECLARE
    registrationDeadline DATE;
BEGIN
    SELECT registration_deadline FROM CourseOfferings WHERE launch_date = NEW.launch_date AND course_id = NEW.course_id INTO registrationDeadline;
   IF EXISTS (
        SELECT 1 FROM Registers 
        WHERE NEW.launch_date = launch_date
        AND NEW.course_id = course_id   
        AND NEW.cust_id = cust_id     
    ) THEN
        RAISE EXCEPTION 'Cannot register for more than one session of same course offering';
        RETURN NULL;
    ELSIF (NEW.registers_date >= registrationDeadline) THEN
        RAISE EXCEPTION 'Must register before registration deadline';
        RETURN NULL;
    ELSIF EXISTS (
        SELECT 1 FROM Redeems
        WHERE NEW.cust_id = cust_id 
        AND NEW.course_id = course_id 
        AND NEW.launch_date = launch_date
    ) THEN
        RAISE EXCEPTION 'This course session of this course offering has already been redeemed by customer';
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

/*check redeems*/

CREATE OR REPLACE FUNCTION check_redeems()
RETURNS TRIGGER AS $$
DECLARE
    registrationDeadline DATE;
BEGIN
    SELECT registration_deadline FROM CourseOfferings WHERE launch_date = NEW.launch_date AND course_id = NEW.course_id INTO registrationDeadline;
    IF EXISTS (
        SELECT 1 FROM Registers 
        WHERE NEW.launch_date = launch_date
        AND NEW.course_id = course_id   
        AND NEW.cust_id = cust_id     
    ) THEN
        RAISE EXCEPTION 'Cannot register for more than one session of same course offering';
        RETURN NULL;
    ELSIF (NEW.redeems_date >= registrationDeadline) THEN 
        RAISE EXCEPTION 'Must register before registration deadline';
        RETURN NULL;
    ELSIF EXISTS (
        SELECT 1 FROM Redeems
        WHERE NEW.cust_id = cust_id 
        AND NEW.course_id = course_id 
        AND NEW.launch_date = launch_date
    ) THEN
        RAISE EXCEPTION 'This course session of this course offering has already been redeemed by customer';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_redeems
BEFORE INSERT ON Redeems
FOR EACH ROW
EXECUTE FUNCTION check_redeems();

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

/*
13. Each customer can have at most one active or partially active package.
*/
CREATE OR REPLACE FUNCTION check_customer_active_packages()
RETURNS TRIGGER AS $$
DECLARE
    numActivePackages INT;
    numPartiallyActivePackages INT;
BEGIN
    numActivePackages := (SELECT COUNT(*)
                          FROM Buys
                          WHERE NEW.cust_id = cust_id
                          AND num_remaining_redemptions >= 1 -- At least one unused session in the package
                          );
    numPartiallyActivePackages := (SELECT COUNT(*)
                                   FROM Buys B1 
                                   WHERE NEW.cust_id = B1.cust_id
                                   AND B1.num_remaining_redemptions = 0 -- All sessions in package have been redeemed
                                   AND EXISTS(SELECT 1 -- 7 days before day of registration
                                              FROM (Buys B2 JOIN Redeems R ON (B2.buys_date = R.buys_date
                                                                              AND B2.cust_id = R.cust_id
                                                                              AND B2.number = R.number
                                                                              AND B2.package_id = R.package_id))
                                              JOIN CourseOfferingSessions CS ON (R.sid = CS.sid 
                                                                                AND R.course_id = CS.course_id 
                                                                                AND R.launch_date = CS.launch_date)
                                              WHERE B2.cust_id = B1.cust_id
                                              AND B2.package_id = B1.package_id
                                              AND B2.num_remaining_redemptions = 0
                                              AND CS.session_date - CURRENT_DATE >= 7 -- At least 7 days to get refund
                                             )
                                   );

    RAISE NOTICE 'Active Packages: %', numActivePackages;
    RAISE NOTICE 'Partially Active Packages: %', numPartiallyActivePackages;

    /** At most one active or at most one partially active package */
    IF (numActivePackages = 0 AND numPartiallyActivePackages = 0) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'A customer can have at most one active or partially active package.';
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_customer_active_packages ON Buys;
CREATE TRIGGER check_customer_active_packages
BEFORE INSERT ON Buys --removed OR UPDATE since active/partially active pkgs with num_remaining_redemptions have to be updated 
FOR EACH ROW
EXECUTE FUNCTION check_customer_active_packages();

/* 14. A course offering is said to be available 
if the number of registrations received is no more than 
its seating capacity; otherwise, we say that a course offering is fully booked. */

CREATE OR REPLACE FUNCTION check_if_available_or_fully_booked_Registers()
RETURNS TRIGGER AS $$
DECLARE
    seatingCapacity INT;
    totalRegistersAndRedeems INT;
BEGIN
    SELECT (
        (SELECT COUNT(*) FROM Registers WHERE NEW.launch_date = launch_date AND NEW.course_id = course_id) 
        +
        (SELECT COUNT(*) FROM Redeems WHERE NEW.launch_date = launch_date AND NEW.course_id = course_id) 
    ) INTO totalRegistersAndRedeems;

    SELECT seating_capacity FROM CourseOfferings WHERE NEW.launch_date = launch_date AND NEW.course_id = course_id INTO seatingCapacity;

    IF (totalRegistersAndRedeems > seatingCapacity) THEN
        RAISE EXCEPTION 'Course offering is fully booked';
        RETURN NULL;
    ELSE
        RAISE NOTICE 'Course offering is still available';
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_if_available_or_fully_booked_Registers ON Registers;
CREATE TRIGGER check_if_available_or_fully_booked_Registers
AFTER INSERT OR UPDATE ON Registers
FOR EACH ROW
EXECUTE FUNCTION check_if_available_or_fully_booked_Registers();



CREATE OR REPLACE FUNCTION check_if_available_or_fully_booked_Redeems()
RETURNS TRIGGER AS $$
DECLARE
    seatingCapacity INT;
    totalRegistersAndRedeems INT;
BEGIN
    SELECT (
        (SELECT COUNT(*) FROM Registers WHERE NEW.launch_date = launch_date AND NEW.course_id = course_id) 
        +
        (SELECT COUNT(*) FROM Redeems WHERE NEW.launch_date = launch_date AND NEW.course_id = course_id) 
    ) INTO totalRegistersAndRedeems;

    SELECT seating_capacity FROM CourseOfferings WHERE NEW.launch_date = launch_date AND NEW.course_id = course_id INTO seatingCapacity;

    IF (totalRegistersAndRedeems > seatingCapacity) THEN
        RAISE EXCEPTION 'Course offering is fully booked';
        RETURN NULL;
    ELSE
        RAISE NOTICE 'Course offering is still available';
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_if_available_or_fully_booked_Redeems ON Redeems;
CREATE TRIGGER check_if_available_or_fully_booked_Redeems
AFTER INSERT OR UPDATE ON Redeems
FOR EACH ROW
EXECUTE FUNCTION check_if_available_or_fully_booked_Redeems();

/*ENDS HERE*/ 

-- 1
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
                ELSE 
                    RAISE EXCEPTION 'Each course area can only be managed by one manager';
                END IF;
            END LOOP;
        ELSIF (input_Category = 'instructor') THEN
            INSERT INTO Instructors VALUES(employeeId);
            FOREACH area IN ARRAY input_Areas
            LOOP
                INSERT INTO Specializes VALUES(employeeId, area);
            END LOOP;
            IF (input_Salary < 100) THEN /*i not sure if can compare int to numeric, and also i assume minimum monthly salary is above 1000*/ 
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



-- 2
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


-- 3
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


-- 4
/*REMB TO MAKE A TRIGGER FOR THIS'*/
CREATE OR REPLACE PROCEDURE update_credit_card(input_ID INT, input_Number VARCHAR(16), input_Date DATE, input_CVV INT)
AS $$
DECLARE
    currentActive VARCHAR(16);
BEGIN 
    SELECT number INTO currentActive FROM Credit_cards WHERE cust_id = input_ID ORDER BY from_date DESC LIMIT 1;
    INSERT INTO Credit_cards VALUES(input_Number, input_CVV, input_Date, CURRENT_DATE, input_ID); /*add trigger to confirm this*/
    UPDATE Customers
	SET number = input_Number 
    WHERE number = currentActive;
END;
$$ LANGUAGE plpgsql;



-- 5
CREATE OR REPLACE PROCEDURE add_course(input_Title VARCHAR, input_Desc VARCHAR, input_Area VARCHAR, input_Duration INT)
AS $$
BEGIN
    INSERT INTO Courses(course_area_name, title, description, duration) VALUES(input_Area, input_Title, input_Desc, input_Duration);
END;
$$ LANGUAGE plpgsql;




-- 6
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


/*TODO correct total hours worked*/
-- 7
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
    SELECT course_area_name INTO courseArea FROM Courses WHERE course_id = input_Cid;
    OPEN curs1;
    LOOP
        FETCH curs1 INTO r;
        EXIT WHEN NOT FOUND;
        CONTINUE WHEN r.course_area_name <> courseArea;
        currDate := input_StartDate;
        hours := 0;
        IF EXISTS (SELECT 1 FROM CourseOfferingSessions C WHERE r.eid = C.eid) THEN
            SELECT SUM((SELECT EXTRACT (HOUR FROM session_date + end_time)) - (SELECT EXTRACT (HOUR FROM session_date + start_time))) FROM CourseOfferingSessions C WHERE r.eid = C.eid INTO hours;
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



-- 8
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



-- 9
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
    


-- 10
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
                SELECT MIN(session_date) 
                FROM CourseOfferingSessions 
                WHERE input_Launch_date = launch_date AND input_Course_id = course_id
                ),
            end_date = (
                SELECT MAX(session_date)
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

-- 11. add_course_package: This routine is used to add a new course package for sale. 
-- The inputs to the routine include the following: package name, number of free course sessions, 
-- start and end date indicating the duration that the promotional package is available for sale, 
-- and the price of the package. The course package identifier is generated by the system. 
-- If the course package information is valid, the routine will perform the necessary updates to add the new course package.

CREATE OR REPLACE PROCEDURE add_course_package(
        name VARCHAR,
        free_sessions NUMERIC(36, 2),
        start_date DATE,
        end_date DATE,
        price NUMERIC(36, 2)
    ) AS $$ BEGIN
INSERT INTO Course_packages(
        name,
        price,
        sale_start_date,
        sale_end_date,
        num_free_registrations
    )
VALUES (name, price, start_date, end_date, free_sessions);
END;
$$ LANGUAGE plpgsql;

-- 12. get_available_course_packages: This routine is used to retrieve the course packages 
-- that are available for sale. The routine returns a table of records with the following 
-- information for each available course package: package name, number of free course sessions,
--  end date for promotional package, and the price of the package.

CREATE OR REPLACE FUNCTION get_available_course_packages() RETURNS TABLE (
        name VARCHAR,
        num_free_registrations INT,
        sale_end_date DATE,
        price NUMERIC(36, 2)
    ) AS $$ BEGIN RETURN QUERY
SELECT Course_packages.name,
    Course_packages.num_free_registrations,
    Course_packages.sale_end_date,
    Course_packages.price
FROM Course_packages
WHERE Course_packages.sale_start_date <= CURRENT_DATE
    AND Course_packages.sale_end_date >= CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;

-- 13. buy_course_package: This routine is used when a customer requests to purchase a course package. 
-- The inputs to the routine include the customer and course package identifiers. 
-- If the purchase transaction is valid, the routine will process the purchase 
-- with the necessary updates (e.g., payment).

CREATE OR REPLACE PROCEDURE buy_course_package(input_cust_id INT, input_package_id INT) AS $$ BEGIN
INSERT INTO Buys(
        buys_date,
        num_remaining_redemptions,
        cust_id,
        number,
        package_id
    )
VALUES (
        CURRENT_DATE,
        (
            SELECT num_free_registrations
            FROM Course_packages
            WHERE package_id = input_package_id
        ),
        input_cust_id,
        (
            SELECT number
            FROM Customers
            WHERE cust_id = input_cust_id
        ),
        input_package_id
    );
END;
$$ LANGUAGE plpgsql;

-- 14. get_my_course_package: This routine is used when a customer requests to 
-- view his/her active/partially active course package. The input to the routine 
-- is a customer identifier. The routine returns the following information 
-- as a JSON value: package name, purchase date, price of package, number of free sessions 
-- included in the package, number of sessions that have not been redeemed, and information 
-- for each redeemed session (course name, session date, session start hour). 
-- The redeemed session information is sorted in ascending order of session date and start hour.


-- 15. get_available_course_offerings: This routine is used to retrieve all the available 
-- course offerings that could be registered. The routine returns a table of records with 
-- the following information for each course offering: course title, course area, 
-- start date, end date, registration deadline, course fees, and the number of remaining seats. 
-- The output is sorted in ascending order of registration deadline and course title.

CREATE OR REPLACE FUNCTION get_available_course_offerings() RETURNS TABLE (
        title VARCHAR,
        course_area_name VARCHAR,
        start_date DATE,
        end_date DATE,
        registration_deadline DATE,
        fees NUMERIC(36, 2),
        remaining_seats BIGINT
    ) AS $$ BEGIN RETURN QUERY WITH cte AS (
        SELECT COUNT(sid),
            course_id
        FROM CourseOfferingSessions
        GROUP BY course_id
    ),
    -- get sid count
    cte2 AS (
        -- get all required data except sid count
        SELECT *
        FROM CourseOfferings
            NATURAL JOIN Courses
        ORDER BY registration_deadline,
            title ASC
    ),
    cte3 AS (
        -- final table with required columns
        SELECT cte2.title,
            cte2.course_area_name,
            cte2.start_date,
            cte2.end_date,
            cte2.registration_deadline,
            cte2.fees,
            (cte2.seating_capacity - cte.count) AS remaining_seats
        FROM cte
            NATURAL JOIN cte2
    )
SELECT *
FROM cte3
WHERE cte3.remaining_seats > 0;
END;
$$ LANGUAGE plpgsql;

-- 16. get_available_course_sessions: This routine is used to retrieve all the available sessions for a course offering that could be registered.
-- The input to the routine is a course offering identifier. The routine returns a table of records with the following information for 
-- each available session: session date, session start hour, instructor name, and number of remaining seats for that session. 
-- The output is sorted in ascending order of session date and start hour.

CREATE OR REPLACE FUNCTION get_available_course_sessions(input_launch_date DATE, input_course_id INT) RETURNS TABLE (
        session_date DATE,
        session_start_hour TIME,
        instructor_name VARCHAR,
        remaining_seats BIGINT
    ) AS $$ BEGIN RETURN QUERY WITH cte AS (
        --get a table of all sessions for a particular course_id
        SELECT CourseOfferingSessions.session_date,
            CourseOfferingSessions.start_time,
            Employees.name,
            Rooms.seating_capacity
        FROM CourseOfferingSessions
            NATURAL JOIN Rooms
            NATURAL JOIN Employees
        WHERE course_id = input_course_id
            AND launch_date = input_launch_date
    ),
    cte2 AS (
        -- For each session (sid), count the number of registrations
        SELECT COUNT(cust_id) as num_registrations,
            sid
        FROM Registers
        WHERE course_id = input_course_id
            AND launch_date = input_launch_date
        GROUP BY sid
    )
SELECT cte.session_date,
    cte.start_time as start_hour,
    cte.name,
    (cte.seating_capacity - cte2.num_registrations) as remaining_seats
FROM cte
    NATURAL JOIN cte2
WHERE (cte.seating_capacity - cte2.num_registrations) > 0
ORDER BY cte.session_date,
    cte.start_time;
END;
$$ LANGUAGE plpgsql;

-- 17. register_session: This routine is used when a customer requests to register for a session in a course offering. 
-- The inputs to the routine include the following: customer identifier, course offering identifier, session number, 
-- and payment method (credit card or redemption from active package). If the registration transaction is valid, 
-- this routine will process the registration with the necessary updates (e.g., payment/redemption).

CREATE OR REPLACE PROCEDURE register_session(input_cust_id INT, input_course_id INT, 
											 input_launch_date DATE, input_session_number INT,
											 input_payment_method VARCHAR) 
AS $$
DECLARE
	var_buys_date DATE;
	var_cc_number VARCHAR(16);
	var_package_id INT;
	var_sid INT;
	var_launch_date DATE;
	curr_num_registered INT;
	curr_num_redeemed INT;
	total_seats INT;
BEGIN
-- check if session is full
SELECT COUNT(*) INTO curr_num_registered FROM Registers 
	WHERE course_id = input_course_id 
	AND sid = input_session_number 
	AND launch_date = input_launch_date;
SELECT COUNT(*) INTO curr_num_redeemed FROM Redeems 
	WHERE course_id = input_course_id 
	AND sid = input_session_number 
	AND launch_date = input_launch_date;
SELECT rid INTO total_seats FROM CourseOfferingSessions 
	WHERE sid = input_session_number
	AND launch_date = input_launch_date
	AND course_id = input_course_id;
IF (total_seats - curr_num_registered - curr_num_redeemed <= 0) THEN -- shouldn't be less than, but jic
	RAISE EXCEPTION 'session is full, cannot register/redeem';
END IF;

IF input_payment_method = 'credit card' THEN
	INSERT INTO Registers (registers_date, cust_id, number, sid, course_id, launch_date)
	VALUES (CURRENT_DATE, input_cust_id, (SELECT number FROM Customers WHERE cust_id = input_cust_id), 
			input_session_number, input_course_id, input_launch_date);
ELSIF input_payment_method = 'redemption' THEN
	-- update Redeems
	SELECT buys_date, number, package_id INTO var_buys_date, var_cc_number, var_package_id
		FROM Buys WHERE cust_id = input_cust_id;
	SELECT sid, launch_date INTO var_sid, var_launch_date 
		FROM CourseOfferingSessions WHERE course_id = input_course_id;
	INSERT INTO Redeems (redeems_date, buys_date, cust_id, number, package_id, sid, course_id, launch_date)
	VALUES (CURRENT_DATE, var_buys_date, input_cust_id, var_cc_number, 
			var_package_id, var_sid, input_course_id, var_launch_date);

    -- update Buys, minus one from redemption
	-- There should only be 1 entry as each customer can have at most one active or partially active package.
	IF (SELECT COUNT(*) FROM Buys WHERE cust_id = input_cust_id AND num_remaining_redemptions > 0) = 1 THEN
		UPDATE Buys 
		SET num_remaining_redemptions = num_remaining_redemptions - 1
		WHERE cust_id = input_cust_id;
	ELSE
		RAISE EXCEPTION 'No course package found for customer';
	END IF;
ELSE
	RAISE NOTICE 'Current payment method: %. Payment method should be credit card or redemption.', input_payment_method;
END IF;
END;
$$ LANGUAGE plpgsql;

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
CREATE OR REPLACE PROCEDURE update_course_session(input_cust_id INT, input_course_id INT, input_launch_date DATE, new_sid INT)
AS $$
DECLARE
    count INT;
    num_registrations INT;
    has_space BOOLEAN;
BEGIN
    SELECT COUNT(*) INTO num_registrations
        FROM Registers
        WHERE sid = new_sid
        AND course_id = input_course_id
        AND launch_date = input_launch_date;

    IF ((SELECT COUNT(*)
        FROM Registers
        WHERE cust_id = input_cust_id 
            AND course_id = input_course_id 
            AND launch_date = input_launch_date
            AND sid <> new_sid) > 0) 
        THEN 
        -- find out if there is space in new session
        IF NOT EXISTS (SELECT 1
                        FROM Rooms R
                        WHERE R.rid = 
                            (SELECT S1.rid
                                FROM (Registers NATURAL JOIN CourseOfferingSessions) AS S1
                                WHERE S1.cust_id = input_cust_id
                                    AND S1.course_id = course_id
                                    AND S1.launch_date = input_launch_date
                                    AND S1.sid = new_sid)
                            AND R.seating_capacity >= (num_registrations + 1)
        ) THEN RAISE EXCEPTION 'Seating capacity full for Session with sid: %', new_sid;
        ELSE
            UPDATE Registers
            SET sid = new_sid
            WHERE course_id = input_course_id
                AND cust_id = input_cust_id
                AND launch_date = input_launch_date;
        END IF;
    ELSIF ((SELECT COUNT(*)
        FROM Redeems
        WHERE cust_id = input_cust_id 
            AND course_id = input_course_id
            AND launch_date = input_launch_date
            AND sid <> new_sid) > 0)
        THEN
        -- find out if there is space in new session
        IF NOT EXISTS (SELECT 1
                        FROM Rooms R
                        WHERE R.rid = 
                            (SELECT S1.rid
                                FROM (Redeems NATURAL JOIN CourseOfferingSessions) AS S1
                                WHERE S1.cust_id = input_cust_id
                                    AND S1.course_id = course_id
                                    AND S1.launch_date = input_launch_date
                                    AND S1.sid = new_sid)
                            AND R.seating_capacity >= (num_registrations + 1)
        ) THEN RAISE EXCEPTION 'Seating capacity full for Session with sid: %', new_sid;
        ELSE
            UPDATE Redeems
            SET sid = new_sid
            WHERE course_id = input_course_id
                AND cust_id = input_cust_id
                AND launch_date = input_launch_date;
        END IF;
    ELSE
        RAISE EXCEPTION 'Could not find session from course id: %, launch date: % and cust_id: %', input_course_id, input_launch_date, input_cust_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 20
CREATE OR REPLACE PROCEDURE cancel_registration(input_cust_id INT, input_course_id INT, input_launch_date DATE)
AS $$
DECLARE
    curr_session_date DATE;
    session_price NUMERIC(36,2);
    session_id INT;
    active_package_id INT;
    partially_active_package_id INT;
BEGIN 
    IF ((
        SELECT COUNT(*) 
        FROM Registers
        WHERE cust_id = input_cust_id AND course_id = input_course_id AND launch_date = input_launch_date
        ) > 0) 
        THEN 
        SELECT P1.session_date, P1.sid INTO curr_session_date, session_id
        FROM ((SELECT R1.sid
            FROM Registers R1
            WHERE R1.cust_id = input_cust_id AND R1.course_id = input_course_id AND R1.launch_date = input_launch_date) AS S1
            NATURAL JOIN
            CourseOfferingSessions) AS P1;
        SELECT fees INTO session_price
        FROM CourseOfferings
        WHERE course_id = input_course_id
            AND launch_date = input_launch_date;
    
        -- We treat fees in CourseOfferings as fees per session not fees per offering.
        -- scenario: customer cancelled, registered and cancelled same session in same day.
        IF EXISTS(
            SELECT 1
            FROM Cancels
            WHERE date = CURRENT_DATE
                AND cust_id = input_cust_id
                AND sid = session_id
                AND course_id = input_course_id
                AND launch_date = input_launch_date
        ) THEN RAISE EXCEPTION 'Cooldown: You can only cancel this registration after 1 Day';
        END IF;
        IF (curr_session_date - CURRENT_DATE > 7) THEN
            INSERT INTO Cancels (date, refund_amt, package_credit, cust_id, sid, course_id, launch_date)
            VALUES (CURRENT_DATE, 0.9 * session_price, NULL, input_cust_id, session_id, input_course_id, input_launch_date);
        ELSE
            INSERT INTO Cancels (date, refund_amt, package_credit, cust_id, sid, course_id, launch_date)
            VALUES (CURRENT_DATE, 0, NULL, input_cust_id, session_id, input_course_id, input_launch_date); -- no refunded
        END IF;
        DELETE FROM Registers
        WHERE course_id = input_course_id
            AND cust_id = input_cust_id
            AND launch_date = input_launch_date;
    ELSIF ((
        SELECT COUNT(*) 
        FROM Redeems
        WHERE cust_id = input_cust_id AND course_id = input_course_id AND launch_date = input_launch_date
        ) > 0)
        THEN
        SELECT P1.session_date, P1.sid INTO curr_session_date, session_id
        FROM ((SELECT R1.sid
            FROM Redeems R1
            WHERE R1.cust_id = input_cust_id AND R1.course_id = input_course_id AND R1.launch_date = input_launch_date) AS S1
            NATURAL JOIN
            CourseOfferingSessions) AS P1;
        active_package_id := (SELECT package_id
                              FROM Buys B JOIN Redeems R ON (B.buys_date = R.buys_date
                                                             AND B.cust_id = R.cust_id
                                                             AND B.number = R.number
                                                             AND B.package_id = R.package_id)
                              WHERE input_cust_id = B.cust_id
                              AND num_remaining_redemptions >= 1 -- At least one unused session in the package
                              );
        partially_active_package_id := (SELECT R.package_id
                                          FROM (Buys B JOIN Redeems R ON (B.buys_date = R.buys_date
                                                                           AND B.cust_id = R.cust_id
                                                                           AND B.number = R.number
                                                                           AND B.package_id = R.package_id))
                                          JOIN CourseOfferingSessions CS ON (R.sid = CS.sid 
                                                                            AND R.course_id = CS.course_id 
                                                                            AND R.launch_date = CS.launch_date)
                                          WHERE B.cust_id = input_cust_id
                                          AND B.num_remaining_redemptions = 0 -- Partially active and inactive
                                          AND CS.session_date - CURRENT_DATE >= 7 -- At least 7 days to get refund, all partially active
                                          );
        -- scenario: customer cancelled, registered and cancelled same session in same day.
        IF EXISTS(
            SELECT 1
            FROM Cancels
            WHERE date = CURRENT_DATE
                AND cust_id = input_cust_id
                AND sid = session_id
                AND course_id = input_course_id
                AND launch_date = input_launch_date
        ) THEN RAISE EXCEPTION 'Cooldown: You can only cancel this registration after 1 Day';
        END IF;
        IF (curr_session_date - CURRENT_DATE >= 7) THEN
            INSERT INTO Cancels (date, refund_amt, package_credit, cust_id, sid, course_id, launch_date)
            VALUES (CURRENT_DATE, NULL, 1, input_cust_id, session_id, input_course_id, input_launch_date);

            IF (active_package_id IS NOT NULL) THEN
                UPDATE Buys
                SET num_remaining_redemptions = num_remaining_redemptions + 1
                WHERE cust_id = input_cust_id
                    AND package_id = active_package_id; --need to check for partially active
            ELSIF (partially_active_package_id IS NOT NULL) THEN
                UPDATE Buys
                SET num_remaining_redemptions = num_remaining_redemptions + 1
                WHERE cust_id = input_cust_id
                    AND package_id = partially_active_package_id; --need to check for partially active
            END IF; 
        ELSE
            INSERT INTO Cancels (date, refund_amt, package_credit, cust_id, sid, course_id, launch_date)
            VALUES (CURRENT_DATE, NULL, 0, input_cust_id, session_id, input_course_id, input_launch_date); -- not refunded
        END IF;
        DELETE FROM Redeems
        WHERE course_id = input_course_id
            AND cust_id = input_cust_id
            AND sid = session_id
            AND launch_date = input_launch_date;
    ELSE
        RAISE EXCEPTION 'Could not find session from course id: %, launch date: % and cust_id: %', input_course_id, input_launch_date, input_cust_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

--Q21
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

--22
CREATE OR REPLACE PROCEDURE update_room(input_courseId INT, input_launchDate DATE, input_sessionId INT, input_roomId INT)
AS $$
DECLARE
    numRegistrations INT;
BEGIN
    numRegistrations := (SELECT count(*) 
                         FROM Registers
                         WHERE sid = input_sessionId
                         AND course_id = input_courseId
                         AND launch_date = input_launchDate);

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
    AND launch_date = input_launchDate
    AND (session_date + end_time) < INTERVAL '0'; -- Course session hasn't started
END;
$$ LANGUAGE plpgsql;

--23
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

--24
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
            num_work_hours := (SELECT COALESCE(
                                        SUM(
                                        (SELECT EXTRACT(HOUR FROM (COS1.session_date + COS1.end_time))) - 
                                        (SELECT EXTRACT(HOUR FROM (COS1.session_date + COS1.start_time)))
                                        ), 
                                            0) 
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

--26
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
                    WHERE B1.package_id = P1.package_id)::INT AS num_packages_sold
                FROM Course_packages P1
                ORDER BY P1.package_id DESC),

            nth_package(package_id, num_free_registrations, price, sale_start_date, sale_end_date, 
            num_packages_sold) AS
            (SELECT * FROM num_package_table N0
            ORDER BY (N0.num_packages_sold, N0.price) DESC 
            LIMIT 1 OFFSET (N - 1)),

            num_package_nth(package_id, num_packages_sold) AS
            (SELECT N1.package_id, N1.num_packages_sold
                FROM num_package_table N1
                WHERE N1.num_packages_sold >= 
                    (SELECT N2.num_packages_sold
                        FROM nth_package N2))
        SELECT S1.package_id, S1.num_free_registrations, S1.price, S1.sale_start_date, S1.sale_end_date, S1.num_packages_sold
            FROM (num_package_nth NATURAL JOIN num_package_table) AS S1
            ORDER BY (S1.num_packages_sold, S1.price) DESC;
END;
$$ LANGUAGE plpgsql;

--28
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
            FROM Registers R1, CourseOfferingSessions S1, CourseOfferings O1
            WHERE (SELECT EXTRACT(MONTH FROM R1.registers_date)) 
                = (SELECT EXTRACT(MONTH FROM curr_month_date))
                AND R1.sid = S1.sid
                AND S1.launch_date = O1.launch_date
                AND S1.course_id = O1.course_id;
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

--30
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
        manager_name  := managerRecord.name;
        num_course_areas_managed := (SELECT COUNT(*)
                                     FROM CourseAreaManaged
                                     WHERE eid = managerRecord.eid);
        total_course_offerings_managed := (SELECT COUNT(*)
                                           FROM (Courses C JOIN CourseOfferings CO ON (C.course_id = CO.course_id))
                                           JOIN CourseAreaManaged CAM ON (C.course_area_name = CAM.course_area_name)
                                           WHERE date_part('year', CO.end_date) = date_part('year', CURRENT_DATE)
                                           AND CAM.eid = managerRecord.eid
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
            IF managerRecord.eid <> courseDetailRecord.eid THEN
                CONTINUE;
            END IF;

            registrations := (SELECT COUNT(*) 
                              FROM Registers
                              WHERE course_id = courseDetailRecord.course_id
                              AND launch_date = courseDetailRecord.launch_date);

            /*Account for total registration fees paid via credit card payment*/
            registrationFee := registrations * courseDetailRecord.fees;

            cancelledRegistrations := (SELECT COUNT(*)
                                       FROM Cancels
                                       WHERE course_id = courseDetailRecord.course_id
                                       AND launch_date = courseDetailRecord.launch_date
                                       AND refund_amt IS NOT NULL
                                       );
            temporarySum := (SELECT SUM(refund_amt)
                             FROM Cancels
                             WHERE course_id = courseDetailRecord.course_id
                             AND launch_date = courseDetailRecord.launch_date
                             AND refund_amt IS NOT NULL
                             );
            IF temporarySum IS NULL THEN
                temporarySum := 0;
            END IF;

            /*Account for refunds*/
            registrationFee := registrationFee - temporarySum + (cancelledRegistrations * courseDetailRecord.fees);

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

            total_net_registration_fee := total_net_registration_fee + registrationFee;
            IF registrationFee > highestRegistrationFee THEN
                highestRegistrationFee := registrationFee;
                highestRegistrationCourse := ARRAY[courseDetailRecord.title];

            ELSIF registrationFee = highestRegistrationFee THEN
                highestRegistrationCourse := array_append(highestRegistrationCourse, courseDetailRecord.title);

            END IF;

        END LOOP;
        CLOSE courseDetailCursor;
        course_title := highestRegistrationCourse;
    END LOOP;
    CLOSE managerCursor;
END;
$$ LANGUAGE plpgsql;


DELETE FROM Course_packages; -- Empty table
-- alternate way: call add_course_package('DiomedeaLALLAA irrorata',9, '2021-03-22', '2021-05-05',  75.35);
CALL add_course_package('Nyctea scandiaca', 5, '2021-04-11', '2021-05-07', 93.52);
CALL add_course_package('Larus dominicanus', 3, '2021-04-10', '2021-04-23', 56.89);
CALL add_course_package('Gabianus pacificus', 1, '2021-03-19', '2021-04-30', 69.67);
CALL add_course_package('Ara chloroptera', 6, '2021-03-24', '2021-05-03', 70.25);
CALL add_course_package('Trachyphonus vaillantii', 5, '2021-04-05', '2021-04-29', 86.01);
CALL add_course_package('Diomedea irrorata', 9, '2021-03-22', '2021-05-05', 75.35);
CALL add_course_package('Speothos vanaticus', 1, '2021-04-06', '2021-04-23', 96.15);
CALL add_course_package('Tamiasciurus hudsonicus', 1, '2021-03-29', '2021-04-19', 70.64);
CALL add_course_package('Ephippiorhynchus mycteria', 2, '2021-04-12', '2021-04-19', 68.29);
CALL add_course_package('Pycnonotus barbatus', 9, '2021-03-28', '2021-04-22', 55.76);
CALL add_course_package('Canis mesomelas', 9, '2021-04-04', '2021-05-05', 78.15);
CALL add_course_package('Butorides striatus', 9, '2021-03-24', '2021-05-04', 67.49);
CALL add_course_package('Rhea americana', 1, '2021-04-09', '2021-05-04', 71.19);
CALL add_course_package('Eumetopias jubatus', 4, '2021-04-05', '2021-05-07', 57.73);
CALL add_course_package('Geochelone elegans', 9, '2021-03-20', '2021-04-19', 52.26);
CALL add_course_package('Myotis lucifugus', 4, '2021-04-08', '2021-05-06', 57.98);
CALL add_course_package('Salvadora hexalepis', 8, '2021-04-07', '2021-05-03', 73.42);
CALL add_course_package('Macropus giganteus', 3, '2021-04-03', '2021-05-03', 93.51);
CALL add_course_package('Dicrostonyx groenlandicus', 9, '2021-03-29', '2021-04-24', 88.71);
CALL add_course_package('Macaca fuscata', 9, '2021-03-18', '2021-04-24', 50.91);
CALL add_course_package('Butorides striatus', 5, '2021-03-26', '2021-05-10', 69.67);
CALL add_course_package('Leprocaulinus vipera', 7, '2021-04-12', '2021-04-19', 58.58);
CALL add_course_package('Sula dactylatra', 7, '2021-04-03', '2021-05-06', 50.32);
CALL add_course_package('Coluber constrictor', 9, '2021-04-03', '2021-04-21', 53.48);
CALL add_course_package('Estrilda erythronotos', 1, '2021-04-07', '2021-04-21', 70.90);
CALL add_course_package('Grus canadensis', 8, '2021-03-31', '2021-05-05', 58.45);
CALL add_course_package('Pavo cristatus', 8, '2021-03-21', '2021-04-26', 52.17);
CALL add_course_package('Papio ursinus', 4, '2021-03-22', '2021-04-25', 59.44);
CALL add_course_package('Panthera pardus', 7, '2021-03-28', '2021-05-07', 68.32);
CALL add_course_package('Pelecanus conspicillatus', 5, '2021-03-20', '2021-04-29', 70.95);

DELETE FROM Rooms; -- Empty table
CALL add_room('1 Everett Drive', 33);
CALL add_room('5 Scoville Trail', 27);
CALL add_room('81 Farragut Pass', 47);
CALL add_room('880 Shelley Plaza', 48);
CALL add_room('49021 Dovetail Drive', 14);
CALL add_room('458 Menomonie Junction', 34);
CALL add_room('7271 Gulseth Terrace', 11);
CALL add_room('541 Susan Drive', 59);
CALL add_room('97 North Parkway', 42);
CALL add_room('7 Rieder Circle', 14);
CALL add_room('3682 Rigney Road', 47);
CALL add_room('18 Anzinger Junction', 42);
CALL add_room('9 Jana Park', 54);
CALL add_room('31 Shopko Trail', 52);
CALL add_room('9 Bayside Terrace', 31);
CALL add_room('123 Ilene Way', 10);
CALL add_room('62 Macpherson Lane', 45);
CALL add_room('87 Debs Drive', 16);
CALL add_room('457 Nancy Road', 20);
CALL add_room('41599 Valley Edge Center', 60);
CALL add_room('42858 Shoshone Alley', 18);
CALL add_room('015 Burrows Pass', 14);
CALL add_room('428 Delladonna Place', 58);
CALL add_room('7 Memorial Hill', 48);
CALL add_room('239 Waxwing Circle', 58);
CALL add_room('29949 Lake View Hill', 35);
CALL add_room('330 Fieldstone Way', 27);
CALL add_room('43 Toban Place', 21);
CALL add_room('364 Calypso Street', 38);
CALL add_room('323 Oriole Terrace', 24);

DELETE FROM Employees; -- Empty table
-- Managers
CALL add_employee('Pearla Daubeny', 94950634, '2 Pepper Wood Center', 'pdaubeny0@ask.com', 36900.20, '2005-05-13', 'manager', array ['A']);
CALL add_employee('Dagmar Ciani', 97853206, '98616 Petterle Lane', 'dciani1@abc.net.au', 1000.20, '2012-07-04', 'manager', array['B']);
CALL add_employee('Hester Lambourn', 93891393, '0527 Farmco Center', 'hlambournd@ifeng.com', 10000.10, '2017-09-08', 'manager', array['C']);
CALL add_employee('Barb Togher', 87978340, '449 Cordelia Hill', 'btoghere@bravesites.com', 20000.00, '2017-09-08', 'manager', array['D']);
CALL add_employee('Humfrey Bellon', 93845329, '99 Paget Court', 'hbellonf@soundcloud.com', 30000.05, '2017-09-08', 'manager', array['E']);
CALL add_employee('Morty Geerdts', 89248154, '87756 Swallow Hill', 'mgeerdtsg@t-online.de', 6969.69, '2017-09-08', 'manager', array['F']);
CALL add_employee('Darby Idle', 94394438, '10723 Rieder Plaza', 'didleh@cbc.ca', 23000.00, '2017-09-08', 'manager', array['G']);
CALL add_employee('Evyn Johnsey', 95536304, '0 Sachs Street', 'ejohnseyi@cdbaby.com', 11000.00, '2017-09-08', 'manager', array['H']);
CALL add_employee('Issie Krochmann', 87056825, '0153 Prentice Avenue', 'ikrochmannj@si.edu', 21000.00, '2017-09-08', 'manager', array['I', 'J']);
CALL add_employee('Silvester Labarre', 97835143, '41521 North Road', 'slabarrek@patch.com', 1010.10, '2017-09-08', 'manager', array['K', 'L', 'M']);

-- Instructors - $100 for salary input means part-time employee
CALL add_employee('Stefa Gino', 81720714, '17500 Summit Junction', 'sgino2@storify.com', 10.00, '2017-11-21', 'instructor', array['A', 'B', 'C']);
CALL add_employee('Dov Sicha', 97538260, '794 Packers Trail', 'dsicha3@hugedomains.com', 20.00 , '2018-12-19', 'instructor', array['D', 'E', 'F']);
CALL add_employee('Mathilde Brewett', 86719820, '77413 Meadow Vale Crossing', 'mbrewett5@mayoclinic.com', 30.00, '2017-01-01', 'instructor', array['G', 'H', 'I']);
CALL add_employee('Mathias Shivell', 98216997, '568 Oak Valley Alley', 'mshivell6@163.com', 40.00, '2017-01-02', 'instructor', array['J', 'K', 'L']);
CALL add_employee('Tiffie McCahill', 85175436, '5648 Corben Crossing', 'tmccahill7@printfriendly.com', 50.00, '2017-11-03', 'instructor', array['M', 'A']);
CALL add_employee('Orrin Jurisch', 95604288, '14 Bultman Alley', 'ojurisch8@xinhuanet.com', 60.00, '2017-11-04', 'instructor', array['B', 'C', 'D']);
CALL add_employee('Annemarie Jenny', 94439484, '385 Hooker Road', 'ajenny9@ucla.edu', 70.00, '2017-11-05', 'instructor', array['E', 'F','G']);
CALL add_employee('Menard Yate', 97870419, '3 Kinsman Terrace', 'myatea@cisco.com', 80.00, '2017-11-06', 'instructor', array['H']);
CALL add_employee('Wendy Guerrin', 82540806, '9 Holmberg Center', 'wguerrinb@va.gov', 90.00, '2017-11-07', 'instructor', array['I']);
CALL add_employee('Maurise Bowles', 94835119, '6 Cascade Point', 'mbowlesc@infoseek.co.jp', 99.00, '2017-11-08', 'instructor', array['J']);
-- Instructors - full time, where salary input is > 100
CALL add_employee('Godfree Kroger', 87444297, '1 Vidon Court', 'gkrogerm@fema.gov', 5600.00, '2018-01-01', 'instructor', array['C']);
CALL add_employee('Evyn Trorey', 99996313, '30001 Green Junction', 'etroreyn@posterous.com', 5000.00, '2018-01-01', 'instructor', array['D']);
CALL add_employee('Jaquenetta Uman', 80555086, '37819 Homewood Alley', 'jumano@wikispaces.com', 5001.00, '2018-01-01', 'instructor', array['E']);
CALL add_employee('Juli Lathaye', 91584511, '9 Northridge Center', 'jlathayep@bravesites.com', 5002.00, '2018-01-01', 'instructor', array['F']);
CALL add_employee('Matilda Coddington', 85205616, '38190 Blue Bill Park Trail', 'mcoddingtonq@wix.com', 5003.00, '2018-01-01', 'instructor', array['G']);
CALL add_employee('Delly Ebhardt', 85452369, '2 Ridgeway Pass', 'debhardtr@amazon.co.uk', 5004.00, '2018-01-01', 'instructor', array['H']);
CALL add_employee('Ursola Philbin', 85853736, '06 Oakridge Point', 'uphilbins@blogger.com', 5005.00, '2018-01-01', 'instructor', array['I']);
CALL add_employee('Rosina Petroselli', 80052001, '47 Garrison Place', 'rpetrosellit@cmu.edu', 5006.00, '2018-01-01', 'instructor', array['J']);
CALL add_employee('Dena Tancock', 89273403, '50865 Katie Parkway', 'dtancock4@shareasale.com', 5007.00, '2018-01-01', 'instructor', array['K']);
CALL add_employee('Rubie Wenman', 84131943, '9628 Green Avenue', 'rwenmanl@webeden.co.uk', 5008.00, '2005-10-04', 'instructor', array['A', 'B', 'C']);

-- Administrators
CALL add_employee('Dexter Leverson', 83158434, '03973 Sheridan Road', 'dleverson1@wikimedia.org', 4356.25, '2019-12-28', 'administrator',NULL);
CALL add_employee('Vita Espadero', 82052377, '4 Cherokee Pass', 'vespadero2@tripadvisor.com', 3536.69, '2020-06-02', 'administrator', NULL);
CALL add_employee('Maurene Gooddie', 84661470, '284 Lyons Circle', 'mgooddie3@ycombinator.com', 3618.55, '2020-05-28', 'administrator', NULL);
CALL add_employee('Gwendolen Blaszczynski', 88356105, '94 Dwight Lane', 'gblaszczynski0@goodreads.com', 4384.3, '2019-12-14', 'administrator', NULL);
CALL add_employee('Justinn Pasque', 85178219, '7246 Ludington Circle', 'jpasque4@wordpress.org', 4333.2, '2020-06-04', 'administrator', NULL);
CALL add_employee('Caresa Antham', 86488030, '9 Loeprich Alley', 'cantham5@baidu.com', 4465.97, '2021-01-16', 'administrator', NULL);
CALL add_employee('Sheri Gilbee', 82766482, '980 Schurz Plaza', 'sgilbee6@ftc.gov', 4067.96, '2020-03-02', 'administrator', NULL);
CALL add_employee('Guenna Burland', 82875256, '6 Declaration Avenue', 'gburland7@vistaprint.com', 3774.44, '2020-04-14', 'administrator', NULL);
CALL add_employee('Eugenia Smitten', 88305276, '26 Eagan Trail', 'esmitten8@marriott.com', 3689.06, '2020-09-24', 'administrator', NULL);
CALL add_employee('Taber Gruszczak', 81507433, '0 Roth Park', 'tgruszczak9@ning.com', 3691.27, '2020-02-23', 'administrator', NULL);

-- Full_time_Emp taken into consideration from add_employee function
-- Part_time_Emp taken into consideration from add_employee function
-- Managers taken into consideration from add_employee function
-- CourseAreaManaged taken into consideration from add_employee function
-- Instructors taken into consideration from add_employee function
-- Specializes taken into consideration from add_employee function
-- Part_time_instructors taken into consideration from add_employee function
-- Full_time_instructors taken into consideration from add_employee function

DELETE FROM Courses;
CALL add_course('Fiveclub', 'Toxic eff of harmful algae and algae toxins, slf-hrm, subs', 'A', 1);
CALL add_course('Buzzbean', 'Melanocytic nevi of right upper limb, including shoulder', 'B', 2);
CALL add_course('Izio', 'Age-rel osteopor w current path fracture, unsp femur, init', 'C', 3);
CALL add_course('Npath', 'Nondisp midcervical fx l femur, subs for clos fx w nonunion', 'D', 2);
CALL add_course('Blogtags', 'Oth injuries of left shoulder and upper arm, init encntr', 'E', 1);
CALL add_course('Buzzshare', 'Unsp intracap fx r femr, subs for opn fx type I/2 w malunion', 'F', 2);
CALL add_course('Aimbo', 'Displ commnt fx shaft of ulna, r arm, 7thQ', 'A', 3);
CALL add_course('Trilia', 'Enlargement of left orbit', 'B', 3);
CALL add_course('Quimba', 'Underdosing of calcium-channel blockers', 'C', 1);
CALL add_course('Midel', 'Other fracture of shaft of radius, left arm', 'H', 2);
CALL add_course('Twitterworks', 'Malformation of placenta, unspecified, first trimester', 'J', 3);
CALL add_course('Geba', 'Injury to barefoot water-skier, sequela', 'M', 2);
CALL add_course('Gabvine', 'Animal-rider injured in collision w 2/3-whl mv', 'I', 1);
CALL add_course('Trilith', 'Superficial foreign body of other part of head, init encntr', 'G', 2);
CALL add_course('Eare', 'Nondisplaced oth extrartic fracture of l calcaneus, sequela', 'K', 3);

DELETE FROM Customers; -- Empty table
CALL add_customer('Sanders Gidley', 99820092, '78786 Steensland Park', 'sgidley0@google.co.jp', '5602250147265633', '2020-08-09', '001');
CALL add_customer('Meyer Tarzey', 87612176, '14315 Helena Park', 'mtarzey1@ucoz.ru', '5610657709090474', '2019-10-19', '002');
CALL add_customer('Webster Spaxman', 94518528, '48278 Fairfield Road', 'wspaxman2@amazon.co.uk', '5602230651814471', '2018-10-19', '892');
CALL add_customer('George Jahncke', 90421305, '14705 Atwood Court', 'gjahncke3@ustream.tv', '5602240849542561', '2017-09-09', '100');
CALL add_customer('Fritz Fawkes', 92379525, '2551 Canary Way', 'ffawkes4@samsung.com', '5610065941511739', '2026-10-19', '200');
CALL add_customer('Emmy Ridsdale', 82288253, '76513 Oak Park', 'eridsdale5@reuters.com', '5610601476073800', '2021-11-19', '234');
CALL add_customer('Yorke Tolley', 82295969, '8113 Scoville Center', 'ytolley6@jugem.jp', '5602219467996275', '2022-11-19', '224');
CALL add_customer('Inesita Keirl', 80989670, '52 Northwestern Junction', 'ikeirl7@surveymonkey.com', '5602251749948923', '2023-11-19', '111');
CALL add_customer('Hayley Bowley', 80371232, '47 Ronald Regan Court', 'hbowley8@digg.com', '5602242735189440', '2023-12-19', '112');
CALL add_customer('Dion Gebhard', 90651062, '1085 Lotheville Circle', 'dgebhard9@ftc.gov', '5602229479310241', '2023-01-19', '113');
CALL add_customer('Kev Castro', 90769230, '92456 Londonderry Park', 'kcastroa@comcast.net', '5602258275479223', '2023-02-19', '114');
CALL add_customer('Sanford Girardin', 97470262, '94175 Nevada Alley', 'sgirardinb@canalblog.com', '5602254153002112', '2023-03-19', '115');
CALL add_customer('Yankee Eake', 98043174, '16 Johnson Hill', 'yeakec@skype.com', '5602248853693311', '2023-04-19', '116');
CALL add_customer('Karyl McGreary', 92579048, '7607 Main Court', 'kmcgrearyd@soundcloud.com', '5602251427134135', '2023-05-19', '117');
CALL add_customer('Franky Ouver', 87457533, '4286 Mayfield Crossing', 'fouvere@mozilla.org', '5602231214008650', '2023-06-19', '118');
CALL add_customer('Pauly Agar', 87998820, '0 Aberg Plaza', 'pagarf@geocities.com', '5602215736244539', '2023-07-19', '119');
CALL add_customer('Maribel Blabey', 89197032, '91702 Elgar Park', 'mblabeyg@webeden.co.uk', '5602210355749256', '2023-08-19', '120');
CALL add_customer('Clo Coghlan', 96834256, '44210 Eagle Crest Drive', 'ccoghlanh@google.com.hk', '5602218964441868', '2023-09-19', '121');
CALL add_customer('Artair Mousdall', 80476520, '345 Surrey Alley', 'amousdalli@yale.edu', '5602231452172101', '2023-10-19', '122');
CALL add_customer('Mariette Cubbon', 92742855, '257 Arkansas Center', 'mcubbonj@lulu.com', '5602222546621815', '2023-11-19', '125');
CALL add_customer('Spence Rault', 89689405, '94 Independence Place', 'sraultk@earthlink.net', '5602255199953572', '2023-12-01', '126');
CALL add_customer('Cassi Vanlint', 81910481, '04 Cardinal Lane', 'cvanlintl@newyorker.com', '5602242696480846', '2023-12-02', '127');
CALL add_customer('Benny Stockin', 95301632, '32431 Golf View Street', 'bstockinm@berkeley.edu', '5602253645715075', '2023-12-03', '128');
CALL add_customer('Cary Meldon', 80270431, '40 Buell Drive', 'cmeldonn@goodreads.com', '5602231760069890', '2023-12-04', '129');
CALL add_customer('Stanfield McUre', 82232366, '466 Maywood Park', 'smcureo@howstuffworks.com', '5602251005404215', '2023-12-05', '130');
CALL add_customer('Derry Arundell', 86975680, '65 Bellgrove Street', 'darundellp@aol.com', '5602213420937658', '2023-12-06', '131');
CALL add_customer('Rriocard Olivi', 83260682, '67 Muir Terrace', 'roliviq@ocn.ne.jp', '5602227223974999', '2023-12-07', '132');
CALL add_customer('Cash Seabridge', 91573789, '35 Monterey Pass', 'cseabridger@addtoany.com', '5602222332369496', '2023-12-08', '133');
CALL add_customer('Bertine Philipeaux', 94488417, '43447 Bunker Hill Street', 'bphilipeauxs@example.com', '5602239970599127', '2023-12-09', '134');
CALL add_customer('Laraine Roeby', 98024514, '35 Russell Junction', 'lroebyt@clickbank.net', '5602234288106608', '2023-12-10', '135');

-- Credit_cards taken into consideration from add_employee function

DELETE FROM Buys;
CALL buy_course_package(1, 1);
CALL buy_course_package(2, 2);
CALL buy_course_package(3, 3);
CALL buy_course_package(4, 4);
CALL buy_course_package(5, 5);
CALL buy_course_package(6, 6);
CALL buy_course_package(7, 7);
CALL buy_course_package(8, 8);
CALL buy_course_package(9, 9);
CALL buy_course_package(10, 10);
CALL buy_course_package(11, 11);
CALL buy_course_package(12, 12);
CALL buy_course_package(13, 13);
CALL buy_course_package(14, 14);
CALL buy_course_package(15, 15);
CALL buy_course_package(16, 1);
CALL buy_course_package(17, 1);
CALL buy_course_package(18, 2);
CALL buy_course_package(19, 2);
CALL buy_course_package(20, 2);
CALL buy_course_package(21, 6);
CALL buy_course_package(22, 7);
CALL buy_course_package(23, 8);
CALL buy_course_package(24, 9);
CALL buy_course_package(25, 10);
CALL buy_course_package(26, 11);
CALL buy_course_package(27, 12);
CALL buy_course_package(28, 13);
CALL buy_course_package(29, 14);
CALL buy_course_package(30, 15);

-- Administrator taken into consideration from add_employee function

-- add_course_offering(input_Course_id INT, input_Fees NUMERIC(36,2), input_Launch_date DATE, input_Registration_deadline DATE, 
  --                  input_Eid INT, input_Target_registration INT, input_SessionDateAndTime TIMESTAMP[], input_Rid INT[])
CALL add_course_offering(2, 55, '2021-01-02', '2021-05-02', 32, 5, array['2021-06-20 15:00:00', '2021-06-11 15:00:00']::TIMESTAMP[], array[1,5]);
CALL add_course_offering(3, 60, '2021-01-03', '2021-05-03', 33, 5, array['2021-06-21 15:00:00', '2021-06-12 15:00:00']::TIMESTAMP[], array[5,6]);
CALL add_course_offering(4, 65, '2021-01-04', '2021-05-04', 34, 5, array['2021-06-22 15:00:00', '2021-06-13 15:00:00']::TIMESTAMP[], array[9,23]);
CALL add_course_offering(5, 70, '2021-01-05', '2021-05-05', 35, 5, array['2021-06-23 15:00:00', '2021-06-14 15:00:00']::TIMESTAMP[], array[5,16]);
CALL add_course_offering(6, 75, '2021-01-06', '2021-05-06', 36, 5, array['2021-06-24 15:00:00', '2021-06-15 15:00:00']::TIMESTAMP[], array[8,19]);
CALL add_course_offering(7, 80, '2021-01-07', '2021-05-07', 37, 5, array['2021-06-25 15:00:00', '2021-06-17 15:00:00']::TIMESTAMP[], array[9,10]);
CALL add_course_offering(8, 85, '2021-01-08', '2021-05-08', 38, 5, array['2021-06-26 15:00:00', '2021-06-16 15:00:00']::TIMESTAMP[], array[13,9]);
CALL add_course_offering(9, 90, '2021-01-09', '2021-05-09', 39, 5, array['2021-06-27 15:00:00', '2021-06-18 15:00:00']::TIMESTAMP[], array[2,3]);
CALL add_course_offering(1, 50, '2021-01-01', '2021-05-01', 31, 5, array['2021-06-28 15:00:00', '2021-06-19 15:00:00']::TIMESTAMP[], array[4,5]);
CALL add_course_offering(10, 95, '2021-01-10', '2021-04-10', 32, 2, array['2021-06-29 15:00:00', '2021-06-20 15:00:00']::TIMESTAMP[], array[9,10]);
CALL add_course_offering(11, 100, '2021-01-11', '2021-04-11', 31, 1, array['2021-07-25 15:00:00', '2021-07-13 15:00:00']::TIMESTAMP[], array[3,1]);
CALL add_course_offering(12, 105, '2021-01-12', '2021-04-12', 32, 2, array['2021-07-26 15:00:00', '2021-07-15 15:00:00']::TIMESTAMP[], array[3,5]);
CALL add_course_offering(13, 110, '2021-01-13', '2021-04-13', 33, 3, array['2021-07-27 15:00:00', '2021-07-17 15:00:00']::TIMESTAMP[], array[2,3]);
CALL add_course_offering(14, 115, '2021-01-14', '2021-04-14', 34, 4, array['2021-07-28 15:00:00', '2021-07-19 15:00:00']::TIMESTAMP[], array[2,1]);
CALL add_course_offering(15, 120, '2021-01-15', '2021-04-15', 40, 5, array['2021-07-29 15:00:00', '2021-07-21 15:00:00']::TIMESTAMP[], array[6,1]);

-- TODO: Registers using register_session function: 
--          register_session(input_cust_id INT, input_course_id INT, input_launch_date DATE, input_session_number INT, 'credit card') 
DELETE FROM Registers;
call register_session(1,1,'2021-01-01', 1,'credit card');			
call register_session(2,2,'2021-01-02', 1,'credit card');											 
call register_session(3,3,'2021-01-03', 1,'credit card');											 
call register_session(4,4,'2021-01-04', 1,'credit card');											 
call register_session(5,5,'2021-01-05', 1,'credit card');			
call register_session(6,6,'2021-01-06', 1,'credit card');
call register_session(7,7,'2021-01-07', 1,'credit card');
call register_session(8,8,'2021-01-08', 2,'credit card');
call register_session(9,9,'2021-01-09', 2,'credit card');
call register_session(10,10,'2021-01-10', 2,'credit card');
call register_session(11,11,'2021-01-11', 2,'credit card');	
call register_session(12,12,'2021-01-12', 2,'credit card');
call register_session(13,13,'2021-01-13', 2,'credit card');
call register_session(14,14,'2021-01-14', 2,'credit card');
call register_session(15,15,'2021-01-15', 2,'credit card');							 

-- TODO: Redeems using register_session function: 
--          register_session(input_cust_id INT, input_course_id INT, input_launch_date DATE, input_session_number INT, 'redemption') 
DELETE FROM Redeems;
call register_session(16,3,'2021-01-01',1,'redemption');
call register_session(17,3,'2021-01-02',1,'redemption');
call register_session(18,3,'2021-01-03',1,'redemption');
call register_session(19,3,'2021-01-04',1,'redemption');
call register_session(20,3,'2021-01-05',1,'redemption');
call register_session(21,3,'2021-01-06',1,'redemption');
call register_session(22,3,'2021-01-07',1,'redemption');
call register_session(23,3,'2021-01-08',1,'redemption');
call register_session(24,3,'2021-01-09',2,'redemption');
call register_session(25,3,'2021-01-10',2,'redemption');
call register_session(26,3,'2021-01-11',2,'redemption');
call register_session(27,3,'2021-01-12',2,'redemption');
call register_session(28,3,'2021-01-13',2,'redemption');
call register_session(29,3,'2021-01-14',2,'redemption');
call register_session(30,3,'2021-01-15',2,'redemption');
SELECT pay_salary();

-- TODO: Cancels using cancel_registration function
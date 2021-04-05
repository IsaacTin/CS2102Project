/**
CS2102 relational database schema for ER data model
**/
    
DROP TABLE IF EXISTS Course_packages, Credit_cards, Customers, Cancels, Registers, Redeems,
Buys, Consists, CourseOfferingSessions, CourseOfferings, Courses, Rooms, Instructors,
Administrators, Managers, CourseAreaManaged, Full_time_instructors, Part_time_instructors,
Full_time_Emp, Part_time_Emp, Employees, Pay_slips;

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
    eid                             INT UNIQUE REFERENCES Employees(eid) ON DELETE CASCADE,
    course_area_name                VARCHAR REFERENCES CourseAreaManaged(course_area_name),
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
    course_area_name                VARCHAR UNIQUE NOT NULL, /**name of course area, NOT NULL enforces total participation and key constraint**/
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

<<<<<<< HEAD
-- DONE
CREATE TABLE Registers (
    registers_date                  DATE,
    cust_id                         INT REFERENCES Customers(cust_id),
    number                          VARCHAR(16) REFERENCES Credit_cards(number),
    sid                             INT NOT NULL,
    launch_date                     DATE NOT NULL,
    course_id                       INT NOT NULL,
    FOREIGN KEY (sid, launch_date, course_id) REFERENCES CourseOfferingSessions(sid, launch_date, course_id),
    PRIMARY KEY(registers_date, cust_id, sid, course_id)
);
=======
>>>>>>> main

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
    CONSTRAINT sid_more_than_1 CHECK (sid >= 1)

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
    refund_amt                      INT,
    package_credit                  INT,
    cust_id                         INT,
    sid                             INT,
    course_id                       INT,
    launch_date                     DATE,
    PRIMARY KEY (date, cust_id, sid),
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
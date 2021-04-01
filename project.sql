/**
CS2102 relational database schema for ER data model
**/
    
DROP TABLE IF EXISTS Course_packages, Credit_cards, Customers, Cancels, Registers, Redeems,
Buys, Consists, CourseOfferingSessions, CourseOfferings, Courses, Rooms, Instructors,
Administrators, Managers, CourseAreaManaged, Full_time_instructors, Part_time_instructors,
Full_time_Emp, Part_time_Emp, Employees, Pay_slips;

-- DONE
CREATE TABLE Course_packages (
    package_id                      INT PRIMARY KEY,
    name                            VARCHAR,
    price                           INT, 
    sale_start_date                 DATE,
    sale_end_date                   DATE,
    num_free_registrations          INT 
);

-- DONE
CREATE TABLE Rooms (
    rid                             INT PRIMARY KEY,
    location                        VARCHAR,
    seating_capacity                INT
);

-- DONE
CREATE TABLE Employees (
    eid                             INT PRIMARY KEY,
    name                            VARCHAR,
    phone                           INT,
    address                         VARCHAR,
    email                           VARCHAR,
    depart_date                     DATE NOT NULL,
    join_date                       DATE NOT NULL
);

-- DONE
CREATE TABLE Full_time_Emp (
    eid                             INT PRIMARY KEY REFERENCES Employees(eid) ON DELETE CASCADE,
    monthly_salary                  NUMERIC(36,2)
);

-- DONE
CREATE TABLE Part_time_Emp (
    eid                             INT PRIMARY KEY REFERENCES Employees(eid) ON DELETE CASCADE,
    hourly_rate                     NUMERIC(36,2)
);

-- DONE
CREATE TABLE Managers (
    eid                             INT PRIMARY KEY REFERENCES Full_time_Emp(eid) ON DELETE CASCADE
);

-- DONE
CREATE TABLE CourseAreaManaged (
    course_area_name                VARCHAR PRIMARY KEY, /*ensure 1 to 1 with CourseAreaManaged*/
    eid                             INT NOT NULL,
    FOREIGN KEY (eid) REFERENCES Managers(eid)
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
    course_id                       INT PRIMARY KEY,
    course_area_name                VARCHAR UNIQUE NOT NULL, /**name of course area, NOT NULL enforces total participation and key constraint**/
    title                           VARCHAR,
    description                     VARCHAR,
    duration                        INT, /**duration is in number of hours**/
    FOREIGN KEY (course_area_name) REFERENCES CourseAreaManaged(course_area_name)
);

-- DONE
CREATE TABLE Customers (
    cust_id                         INT UNIQUE,
    phone                           INT,
    address                         VARCHAR, /* added in address cuz its needed*/
    email                           VARCHAR,
    name                            VARCHAR,
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
    FOREIGN KEY (cust_id) REFERENCES Customers(cust_id)
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
CREATE TABLE Registers (
    registers_date                  DATE,
    cust_id                         INT REFERENCES Customers(cust_id),
    number                          VARCHAR(16) REFERENCES Credit_cards(number),
    PRIMARY KEY(registers_date, cust_id, number)
);

-- DONE
CREATE TABLE Administrators (
    eid                             INT PRIMARY KEY REFERENCES Full_time_Emp(eid) ON DELETE CASCADE
);

-- DONE
CREATE TABLE CourseOfferings (
    launch_date                     DATE,
    start_date                      DATE,
    end_date                        DATE,
    registration_deadline           DATE,
    target_number_registrations     INTEGER,
    seating_capacity                INTEGER,
    fees                            NUMERIC(36,2),
    course_id                       INT NOT NULL,
    eid                             INT NOT NULL,
    PRIMARY KEY (launch_date, course_id), /*Weak entity of Offering is identified by Course*/
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (eid) REFERENCES Administrators(eid)
);

-- DONE
CREATE TABLE CourseOfferingSessions (
    sid                             INT UNIQUE,
    start_time                      TIME,
    end_time                        TIME,
    rid                             INT NOT NULL,
    eid                             INT NOT NULL,
    course_id                       INT NOT NULL,
    session_date                    DATE,
    launch_date                     DATE NOT NULL,
    FOREIGN KEY (rid) REFERENCES Rooms(rid),
    FOREIGN KEY (eid) REFERENCES Instructors(eid),
    FOREIGN KEY (course_id, launch_date) REFERENCES CourseOfferings(course_id, launch_date) ON DELETE CASCADE,
    PRIMARY KEY (sid, launch_date, course_id) /*Weak entity of Sessions is identified by weak entity of Offering which is identified by Course*/
);

-- DONE
CREATE TABLE Redeems (
    redeems_date                    DATE,
    buys_date                       DATE,
    sid                             INT NOT NULL,
    cust_id                         INT,
    number                          VARCHAR(16),
    package_id                      INT,
    FOREIGN KEY (buys_date, cust_id, number, package_id) REFERENCES Buys(buys_date, cust_id, number, package_id), -- Aggregation
    FOREIGN KEY (sid) REFERENCES CourseOfferingSessions(sid) ON UPDATE CASCADE ON DELETE CASCADE,
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
    FOREIGN KEY (eid) REFERENCES Employees(eid)
);

-- DONE
CREATE TABLE Cancels (
    date                            DATE,
    refund_amt                      INT,
    package_credit                  INT,
    cust_id                         INT,
    sid                             INT,
    PRIMARY KEY (date, cust_id, sid),
    FOREIGN KEY (cust_id) REFERENCES Customers(cust_id),
    FOREIGN KEY (sid) REFERENCES CourseOfferingSessions(sid)
);

/**
CS2102 relational database schema for ER data model
**/
    
DROP TABLE IF EXISTS Course_packages, Credit_cards, Customers, Owns, Buys, Cancels, Registers, Redeems,
Buys, Registers, Consists, Sessions, Offerings, Courses, Has, Conducts, Rooms, Instructors, Specializes,
Handles, Administrators, Manages, Managers, Course_areas, Full_time_instructors, Part_time_instructors,
Full_time_Emp, Part_time_Emp, Employees, Pay_slips;

CREATE TABLE Courses (
    course_id                       INT PRIMARY KEY,
    area                            VARCHAR UNIQUE NOT NULL, /**course area**/
    title                           VARCHAR,
    description                     VARCHAR,
    duration                        INT /**duration is in number of hours**/
    FOREIGN KEY area REFERENCES Course_areas
);

CREATE TABLE Course_packages (
    package_id                      INT PRIMARY KEY,
    name                            VARCHAR,
    price                           INT, 
    sale_start_date                 DATE,
    sale_end_date                   DATE,
    num_free_registrations          INT 
);

CREATE TABLE Course_areas (
    name                            VARCHAR PRIMARY KEY REFERENCES Manages /*to ensure 1 to 1 with manages*/,
);

CREATE TABLE Manages (
    name                            VARCHAR PRIMARY KEY REFERENCEs Course_areas/*ensure 1 to 1 with course_areas*/,
    eid                             INT NOT NULL,
    FOREIGN KEY eid REFERENCES Managers
    /* So there will only be exactly one instance of every course area here, and each one is taken by a manager, ensuring each course_area is taken by exactly 1 manager only*/
)

CREATE TABLE Credit_cards (
    number                          VARCHAR(16) PRIMARY KEY,
    CVV                             INT NOT NULL,
    expiry_date                     DATE NOT NULL,
    from_date                       DATE,
    cust_id                         INT NOT NULL,
    FOREIGN KEY (cust_id) REFERENCES Customers
);

CREATE TABLE Buys (
    buys_date                       DATE,
    num_remaining_redemptions       INT,
    cust_id                         INT REFERENCES Customers,
    number                          VARCHAR(16) REFERENCES Credit_cards,
    package_id                      INT REFERENCES Course_packages,
    PRIMARY KEY(buys_date, cust_id, number, package_id)
);

CREATE TABLE Registers (
    registers_date                  DATE,
    num_remaining_redemptions       INT,
    cust_id                         INT REFERENCES Customers,
    number                          VARCHAR(16) REFERENCES Credit_cards,
    PRIMARY KEY(registers_date, cust_id, number)
);

CREATE TABLE Redeems (
    redeems_date                    DATE,
    buys_date                       DATE,
    sid                             INT REFERENCES Sessions,
    cust_id                         INT,
    number                          INT,
    package_id                      INT,
    FOREIGN KEY (buys_date, package_id, number, cust_id) REFERENCES Buys,
    FOREIGN KEY (sid) REFERENCES Sessions,
    PRIMARY KEY (redeems_date, buys_date, sid, cust_id, number, package_id)
);

CREATE TABLE Customers (
    cust_id                         INT,
    phone                           INT,
    address                         VARCHAR, /* added in address cuz its needed*/
    email                           VARCHAR,
    name                            VARCHAR,
    number                          VARCHAR(16) UNIQUE /** added inside unique to ensure each credit card is owned by only one customer*/,
    PRIMARY KEY (cust_id, number),
    FOREIGN KEY (number) REFERENCES Credit_cards
);

CREATE TABLE Offerings (
    launch_date                     DATE,
    start_date                      DATE,
    end_date                        DATE,
    registration_deadline           DATE,
    target_number_registrations     INTEGER,
    seating_capacity                INTEGER,
    fees                            NUMERIC(36,2),
    course_id                       INT NOT NULL,
    eid                             INT NOT NULL,
    sid                             INT,
    PRIMARY KEY (launch_date, sid),
    FOREIGN KEY (sid) REFERENCES Sessions,
    FOREIGN KEY (course_id) REFERENCES Courses,
    FOREIGN KEY (eid) REFERENCES Administrators
);


CREATE TABLE Sessions (
    sid                             INT PRIMARY KEY,
    date                            DATE,
    start_time                      TIME,
    end_time                        TIME,
    rid                             INT NOT NULL,
    launch_date                     DATE NOT NULL,
    eid                             INT NOT NULL,
    FOREIGN KEY (rid) REFERENCES Rooms,
    FOREIGN KEY (eid) REFERENCES Instructors,
    FOREIGN KEY (launch_date) REFERENCES Offerings
);

CREATE TABLE Rooms (
    rid                             INT PRIMARY KEY,
    location                        VARCHAR,
    seating_capacity                INT
);

CREATE TABLE Employees (
    eid                             INT PRIMARY KEY,
    name                            VARCHAR,
    phone                           INT,
    address                         VARCHAR,
    email                           VARCHAR,
    depart_date                     DATE,
    join_date                       DATE
);

CREATE TABLE Administrators (
    eid                             INT PRIMARY KEY REFERENCES Full_time_Emp
);

CREATE TABLE Managers (
    eid                             INT PRIMARY KEY REFERENCES Full_time_Emp
);

CREATE TABLE Part_time_Emp (
    eid                             INT PRIMARY KEY REFERENCES Employees,
    hourly_rate                     NUMERIC(36,2)
);

CREATE TABLE Full_time_Emp (
    eid                             INT PRIMARY KEY REFERENCES Employees,
    monthly_salary                  NUMERIC(36,2)
);

CREATE TABLE Instructors (
    eid                             INT REFERENCES Employees,
    name                            VARCHAR REFERENCES Course_areas,
    PRIMARY KEY (eid, name) 
);

CREATE TABLE Part_time_instructors (
    eid                             INT PRIMARY KEY REFERENCES Part_time_Emp,
    FOREIGN KEY (eid) REFERENCES Instructors
);

CREATE TABLE Full_time_instructors (
    eid                             INT PRIMARY KEY REFERENCES Full_time_Emp,
    FOREIGN KEY (eid) REFERENCES Instructors    
);

/** DONE | NOT CHECKED **/
CREATE TABLE Pay_slips (
    payment_date                    DATE,
    amount                          NUMERIC(36,2),
    num_work_hours                  INT, /** number of hours */
    num_work_days                   INT, /** number of days */
    eid                             INT,
    PRIMARY KEY (payment_date, eid),
    FOREIGN KEY (eid) REFERENCES Employees
);

CREATE TABLE Cancels (
    date                            DATE,
    refund_amt                      INT,
    package_credit                  INT,
    cust_id                         INT,
    sid                             INT,
    PRIMARY KEY (date, cust_id, sid),
    FOREIGN KEY (cust_id) REFERENCES Customers,
    FOREIGN KEY (sid) REFERENCES Sessions
);

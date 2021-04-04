-- random_date_YYYY-MM-DD
CREATE OR REPLACE FUNCTION random_date()
RETURNS DATE
LANGUAGE SQL
AS $$
    SELECT (DATE '2000-01-01') + floor( (CURRENT_DATE - (DATE '2000-01-01') + 1) * random() )::INTEGER;
$$;

DELETE FROM Employees;
INSERT INTO Employees (name, phone, address, email, depart_date, join_date)
VALUES 
-- I realised only those with NULL can use random dates, unless change function, so maybe it's useless
-- random generators might generate non unique also, so idk if can use
('John Doe', 91234567, '123 Dover Road', 'johndoe@gmail.com', NULL, random_date()),
('John Deer', 81234567, '999 Dover Road', 'johndeer@gmail.com', DATE '2014-12-17', DATE '2015-12-01'),
('Alex Tan', 61234567, '5 Bishan St', 'alextan@gmail.com', DATE '2019-05-11', DATE '2011-11-01'),
('Alice Peter', 66634567, 'University Town Blk 6', 'alice@outlook.com', NULL, DATE '2011-11-01'),
('Lycia Lim', 99994567, '1 Dover Condo', 'lycialim@hotmail.com', NULL, random_date()),
('Charmaine Toh', 88884567, 'RC4 Ursa', 'charm@gmail.com', DATE '2018-01-17', DATE '2014-10-01'),
('Kel Tan', 88884567, 'KR Rabs', 'drinker@gmail.com', NULL, DATE '2013-12-01'),
('Val Chan', 88884567, 'USP nerd', 'wad@gmail.com', DATE '2015-05-05', DATE '2005-12-01'),
('Sylvia Kwok', 88884567, 'KR Rabs', 'sealvia@gmail.com', DATE '2012-12-25', DATE '2011-12-01');

-- SELECT * FROM Employees;

DELETE FROM Rooms;
INSERT INTO Rooms (location, seating_capacity)
VALUES 
('COM 1', 120),
('BIZ 2', 60),
('SCI AS6', 50),
('UTR', 200),
('UT Auditorium', 400),
('UT Atrium 1', 20),
('UT Atrium 3', 10);
-- SELECT * FROM Rooms;

DELETE FROM Customers;
INSERT INTO Customers (name, phone, address, email, number)
VALUES
('Jackie Chan', 98979695, 'Hong K St 85', 'jchan@hotmail.hk', 1234123412341234);
SELECT * FROM Customers

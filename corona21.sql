-- DROP DATABASE CORONA21;

CREATE DATABASE CORONA21;

USE CORONA21;

-- create tables and set primary and foreign keys

CREATE TABLE Person (
person_id INT PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
second_name VARCHAR(50),
surname VARCHAR(50) NOT NULL,
age INT,
telephone INT,
nationality_code CHAR(3)
);

CREATE TABLE Corona_Test (
person_id INT,
reference_nb VARCHAR(5) PRIMARY KEY,
type_of_test CHAR(3),
submitted BOOLEAN NOT NULL,
test_overdue VARCHAR(50),
FOREIGN KEY (person_id) REFERENCES Person(person_id)
);

CREATE TABLE Arrival (
person_id INT,
reference_nb VARCHAR(5),
date_of_arrival DATE NOT NULL,
mean_of_transport VARCHAR(50),
swiss_resident BOOLEAN,
FOREIGN KEY (person_id) REFERENCES Person(person_id),
FOREIGN KEY (reference_nb) REFERENCES Corona_Test(reference_nb)
);

CREATE TABLE Address (
person_id INT,
street VARCHAR(50),
home_number INT,
postal_code CHAR(4),
city VARCHAR(50),
permanent BOOLEAN,
FOREIGN KEY (person_id) REFERENCES Person(person_id)
);

CREATE TABLE Vaccination (
person_id INT,
vaccination BOOLEAN,
vaccination_name VARCHAR(50),
nb_of_doses INT,
vaccination_date DATE,
FOREIGN KEY (person_id) REFERENCES Person(person_id)
);

-- populate tables

INSERT INTO Person
(person_id, first_name, second_name,surname,age,telephone,nationality_code) 
VALUES
(1, 'Julia', 'Ewa', 'Dobczynska', 27, 123455667, 'POL'), 
(2, 'Mark', NULL, 'Smith', 68, 1231231, 'ARG'),
(3, 'Joanna', 'Maria', 'Bates', 2, NULL, 'PRT'),
(4, 'Jan', NULL , 'Jones', 99, 77793838, 'RUS'),
(5, 'Peter', 'Pan', 'May', 22, 778288888, 'LUX'),
(6, 'Carol', NULL, 'Bates', 21, 777888888, 'PRT'),
(7, 'Joe', NULL , 'Bates', 28, 777998888, 'PRT'),
(8, 'Rafael', 'Adrian', 'Ziolkowski', 31, 777778888, 'DEU'),
(9, 'Anna', NULL, 'Dark', 37, 7788888, 'GRC'),
(10, 'Anna', 'Julia', 'Black', 80, 772228888, 'CHE');

INSERT INTO Corona_Test
(person_id, reference_nb, type_of_test, submitted) 
VALUES
(1, '1111A', 'PCR', TRUE), 
(2, '2552A', NULL, FALSE),
(3, '2333A', NULL, FALSE),
(4, '4984B', NULL , FALSE),
(5, '7655C', 'ANT', TRUE),
(6, '6666B', 'PCR', TRUE),
(7, '7777G', 'PCR' , TRUE),
(8, '1234F', 'ANT', TRUE),
(9, '1457H', NULL, FALSE),
(10, '2341L', 'PCR', TRUE);

INSERT INTO Arrival
(person_id, reference_nb, date_of_arrival, mean_of_transport, swiss_resident) 
VALUES
(1, '1111A', '2021-12-16', 'bus', FALSE),
(2, '2552A', '2021-12-02', 'car', TRUE),
(3, '2333A', '2021-12-15', 'bus', FALSE),
(4, '4984B', '2021-12-13', 'bus', FALSE),
(5, '7655C', '2021-12-16', 'car', TRUE),
(6, '6666B', '2021-12-15', 'plane', TRUE),
(7, '7777G', '2021-12-05', 'plane', TRUE),
(8, '1234F', '2021-12-16', 'bus', TRUE),
(9, '1457H', '2021-12-15', NULL, FALSE),
(10, '2341L', '2021-12-12', NULL, TRUE);

INSERT INTO Address
(person_id, street, home_number, postal_code, city, permanent) 
VALUES
(1, 'Sunny', 21, 8989, 'Zurich', FALSE),
(2, 'Red', 3, 8888, 'Geneva', TRUE),
(3, 'Long', 22, 9090, 'Basel', FALSE),
(4, 'Short', 4, 7654, 'Buelach', FALSE),
(5, 'Sunny', 21, 8989, 'Zurich', TRUE),
(6, 'Yellow', 55, 1234, 'Bern', TRUE),
(7, 'Rainy', 1, 1231, 'Bruettisellen', TRUE),
(8, 'Rainy', 1, 1231, 'Bruettisellen', TRUE),
(9, 'Sunny', 21, 8989, 'Zurich', FALSE),
(10, 'Short', 4, 7654, 'Buelach', TRUE);

INSERT INTO Vaccination
(person_id, vaccination, vaccination_name, nb_of_doses, vaccination_date) 
VALUES
(1, TRUE, 'Moderna', 2, '2021-11-11'),
(2, TRUE, 'Astra', 2, '2021-11-11'),
(4, TRUE, 'Astra', 1, '2021-11-18'),
(6, FALSE, NULL, NULL, NULL),
(7, FALSE, NULL, NULL, NULL),
(8, TRUE, 'Pfeizer', 1, '2021-11-24'),
(10, TRUE, 'Astra', 3, '2021-12-12');

-- join multiple tables and create a view

CREATE VIEW corona_info as
SELECT
Person.person_id as id,
Arrival.reference_nb,
CONCAT(UPPER(Person.surname), " ", LEFT(UPPER(Person.first_name), 1), ".") as person_name,
CONCAT(Address.street, " ", Address.home_number, ", ", Address.postal_code, ", ", Address.city) as address,
Arrival.date_of_arrival,
Corona_Test.submitted as submitted_test
FROM Person
LEFT JOIN Arrival ON Arrival.person_id = Person.person_id
LEFT JOIN Address ON Address.person_id = Person.person_id
LEFT JOIN Corona_Test ON Corona_Test.person_id = Person.person_id
ORDER BY person_name;

-- display the whole corona_info view
-- SELECT * FROM corona_info;

-- select from the view only those people who arrived today and stay in Zurich [advanced]
SELECT c.id, c.person_name, c.address
FROM corona_info c
WHERE DATE(date_of_arrival) = DATE(NOW()) AND 
address LIKE ('%Zurich%');

-- create stored function which checks if a corona test was submitted maximum 7 days after arrival
CREATE TABLE Test_Status (
person_id INT PRIMARY KEY,
date_of_arrival DATE NOT NULL,
submission_date DATE,
FOREIGN KEY (person_id) REFERENCES Person(person_id)
);

INSERT INTO Test_Status
(person_id, date_of_arrival, submission_date) 
VALUES
(1,'2021-12-16', '2021-12-26'), 
(2,'2021-12-02', NULL),
(3,'2021-12-15', '2021-12-25'),
(5,'2021-12-16', NULL),
(6,'2021-12-15', '2021-12-18'),
(7,'2021-12-05', '2021-12-20');

DELIMITER //
CREATE FUNCTION Test_Overview(
    submission_date DATE,
    date_of_arrival DATE
) 
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE Test_Overview VARCHAR(50);
    IF submission_date - date_of_arrival <= 7 THEN
        SET Test_Overview = 'Test submitted in time.';
    ELSEIF submission_date IS NULL THEN
        SET Test_Overview = CONCAT('Test must be submitted on ', date_of_arrival + INTERVAL 7 DAY, " the latest.");
    ELSEIF submission_date - date_of_arrival >= 7 THEN
        SET Test_Overview = CONCAT('Test submitted ', submission_date - date_of_arrival - 7, ' days overdue.');
    END IF;
    RETURN (Test_Overview);
END//
DELIMITER ;

-- run stored function

SELECT person_id, date_of_arrival, submission_date, Test_Overview(submission_date, date_of_arrival)
FROM Test_Status

-- create trigger which ensures font consistency for inserted items [advanced]

Change Delimiter
DELIMITER //
CREATE TRIGGER Person_Before_Insert
BEFORE INSERT on Person
FOR EACH ROW
BEGIN
SET NEW.first_name = CONCAT(UPPER(SUBSTRING(NEW.first_name,1,1)),
LOWER(SUBSTRING(NEW.first_name FROM 2)));
SET NEW.second_name = CONCAT(UPPER(SUBSTRING(NEW.second_name,1,1)),
LOWER(SUBSTRING(NEW.second_name FROM 2)));
SET NEW.surname = CONCAT(UPPER(SUBSTRING(NEW.surname,1,1)),
LOWER(SUBSTRING(NEW.surname FROM 2)));
SET NEW.nationality_code = UPPER(NEW.nationality_code);
END//
Change Delimiter
DELIMITER ;

SELECT * FROM Person;
-- insert Data
INSERT INTO Person (person_id, first_name, second_name, surname, age, telephone, nationality_code)
VALUES (11, 'Anna', NULL, 'JONES', 99, 2727272, 'pol');
INSERT INTO Person (person_id, first_name, second_name, surname, age, telephone, nationality_code)
VALUES (12, 'GEORGE', 'mARK', 'clark', 33, 27288272, 'Grc');

-- create event printing out a timestamp into the monitoring table[advanced]

-- ON event_scheduler
SET GLOBAL event_scheduler = ON;
USE CORONA21;

CREATE TABLE Monitoring
(id INT NOT NULL AUTO_INCREMENT,
Last_Update TIMESTAMP,
PRIMARY KEY (id));

-- run one_time_event

Change Delimiter
DELIMITER //

CREATE EVENT one_time_event
ON SCHEDULE AT NOW() + INTERVAL 30 SECOND 
DO BEGIN
INSERT INTO Monitoring(Last_Update)
VALUES (NOW());
END//

Change Delimiter
DELIMITER ;

SELECT * FROM Monitoring;
-- Clean up (optional)
-- DROP TABLE Monitoring;
-- DROP EVENT one_time_event;

-- subquery which selects people who were vaccined with less doses than a person with an id number 1

SELECT p.person_id, CONCAT(UPPER(p.surname), " ", LEFT(UPPER(p.first_name), 1), ".") AS person_name, v.nb_of_doses
FROM Person p, Vaccination v
WHERE p.person_id = v.person_id AND v.nb_of_doses >
(SELECT v.nb_of_doses
FROM Vaccination v
WHERE v.person_id = 1);

SELECT * FROM Vaccination;
SELECT * FROM Person;
--Creating Database
CREATE DATABASE CrimeManagement;

--using database for operations
USE CrimeManagement;

--Creating tables as per given schemaCREATE TABLE

--Crime table
 create table crime(
 CrimeID INT PRIMARY KEY,
 IncidentType VARCHAR(255),
 IncidentDate DATE,
 Location VARCHAR(255),
 Description TEXT,
 Status VARCHAR(20)
);

--victim table
CREATE TABLE Victim (
 VictimID INT PRIMARY KEY,
 CrimeID INT,
 Name VARCHAR(255),
 ContactInfo VARCHAR(255),
 Injuries VARCHAR(255),
 FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

--Suspect table
CREATE TABLE Suspect (
 SuspectID INT PRIMARY KEY,
 CrimeID INT,
 Name VARCHAR(255),
 Description TEXT,
 CriminalHistory TEXT,
 FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

-- Inserting the data as per the question

-- Inserting into crime table
INSERT INTO Crime (CrimeID, IncidentType, IncidentDate, Location, Description, Status) VALUES
(1, 'Robbery', '2023-09-15', '123 Main St, Cityville', 'Armed robbery at a convenience store', 'Open'),
(2, 'Homicide', '2023-09-20', '456 Elm St, Townsville', 'Investigation into a murder case', 'Under Investigation'),
(3, 'Theft', '2023-09-10', '789 Oak St, Villagetown', 'Shoplifting incident at a mall', 'Closed');

-- Inserting into Victim table
INSERT INTO Victim (VictimID, CrimeID, Name, ContactInfo, Injuries) VALUES
(1, 1, 'John Doe', 'johndoe@example.com', 'Minor injuries'),
(2, 2, 'Jane Smith', 'janesmith@example.com', 'Deceased'),
(3, 3, 'Alice Johnson', 'alicejohnson@example.com', 'None');

-- Inserting into Suspect table
INSERT INTO Suspect (SuspectID, CrimeID, Name, Description, CriminalHistory) VALUES
(1, 1, 'Robber 1', 'Armed and masked robber', 'Previous robbery convictions'),
(2, 2, 'Unknown', 'Investigation ongoing', NULL),
(3, 3, 'Suspect 1', 'Shoplifting suspect', 'Prior shoplifting arrests');


-- Coming to the Queries 

--Q1. Select all open incidents.
SELECT*FROM Crime WHERE status Like 'Open';

--Q2. Find the total number of incidents.
SELECT COUNT(*) AS 'Total Number of incidents' FROM Crime;

--Q3. List all unique incident types.
SELECT DISTINCT IncidentType FROM Crime;

--Q4. Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'.
SELECT * FROM Crime WHERE IncidentDate BETWEEN '2023-09-01' AND '2023-09-10';	

--Q5. List persons involved in incidents in descending order of age

/*Adding Victim age column in Victim table and Suspect age column in suspect table and updating 
some data into the fields since they were not in the schema*/

ALTER TABLE Victim
ADD VictimAge INT;

ALTER TABLE Suspect
ADD SuspectAge int;

UPDATE Victim
SET VictimAge = CASE
                  WHEN VictimID=1 THEN 36
                  WHEN VictimID=2 THEN 35
		  WHEN VictimID=3 THEN 73
               END;

UPDATE Suspect
SET SuspectAge = CASE
                  WHEN SuspectID=1 THEN 64
                  WHEN SuspectID=2 THEN 30
		  WHEN SuspectID=3 THEN 67
               END;

with persons as(
SELECT VictimID AS PersonID, Name, VictimAge as person_age,persontype='Victim' FROM Victim
union
SELECT SuspectID, Name, SuspectAge,persontype='Suspect' FROM Suspect)

select personid,name,Person_age,persontype from persons
order by person_age desc;


--Q6. Find the average age of persons involved in incidents.
with avg as(
SELECT VictimAge AS age FROM Victim
union
SELECT SuspectAge FROM Suspect)
select avg(age) as 'Average age of all the people' from avg;

--Q7. List incident types and their counts, only for open cases.
SELECT IncidentType, COUNT(CrimeID) AS 'Number Of Open Cases'
FROM Crime
GROUP BY Status, IncidentType
Having Status Like 'Open';

--Q8. Find persons with names containing 'Doe'.
SELECT Name
FROM Victim
WHERE Name LIKE '%Doe%'
UNION 
SELECT Name
FROM Suspect
WHERE Name LIKE '%Doe%';

--9. Retrieve the names of persons involved in open cases and closed cases.
SELECT V.Name AS VictimName,S.Name AS SuspectName, C.Status
FROM Victim V
JOIN Crime C ON C.CrimeID = V.CrimeID
JOIN Suspect S ON S.CrimeID = C.CrimeID
WHERE C.Status IN ('Open', 'Closed');


--Q10.List incident types where there are persons aged 30 or 35 involved.
SELECT C.IncidentType 
FROM Crime C
JOIN Victim V ON C.CrimeID = V.CrimeID
JOIN Suspect S ON C.CrimeID = S.CrimeID
WHERE V.VictimAge IN (30, 35) OR S.SuspectAge IN (30, 35);

--11. Find persons involved in incidents of the same type as 'Robbery'.
SELECT Concat('Victim id=',V.VictimID) as Person_id, V.Name AS Person_name
FROM Victim V
JOIN Crime C ON C.CrimeID = V.CrimeID
WHERE C.IncidentType = 'Robbery'
union
SELECT Concat('Suspect id=',S.SuspectID), S.Name
FROM Suspect s
JOIN crime c ON S.CrimeID = C.CrimeID
WHERE C.IncidentType = 'Robbery';

--12. List incident types with more than one open case.
SELECT IncidentType, COUNT(*) AS OpenCaseCount
FROM Crime
GROUP BY IncidentType,Status
HAVING Status like 'Open' and COUNT(*) > 1;

--13. List all incidents with suspects whose names also appear as victims in other incidents.
SELECT C.CrimeID,C.IncidentType,C.IncidentDate,S.Name AS 'Person name in both victim and suspect table' 
FROM Crime C
JOIN Victim V ON V.CrimeID = C.CrimeID
JOIN Suspect S ON S.CrimeID = C.CrimeID
where S.Name in(select Name from Victim);

--14. Retrieve all incidents along with victim and suspect details.
SELECT C.*,V.*,S.*
FROM Crime C
LEFT JOIN Victim V 
ON C.CrimeID = V.CrimeID
LEFT JOIN Suspect S 
ON C.CrimeID = S.CrimeID;

--15. Find incidents where the suspect is older than any victim.
SELECT C.CrimeID, C.IncidentType, C.IncidentDate, S.SuspectAge ,V.VictimAge
FROM Crime C
LEFT JOIN Victim V 
ON C.CrimeID = V.CrimeID
LEFT JOIN Suspect S 
ON C.CrimeID = S.CrimeID
WHERE S.SuspectAge > V.VictimAge;

--16. Find suspects involved in multiple incidents.
SELECT S.Name, COUNT(C.CrimeID) AS 'Count of Incidents by the suspect'
FROM Suspect S
JOIN Crime C 
ON C.CrimeID=S.CrimeID
GROUP BY S.Name
HAVING COUNT(C.CrimeID) > 1;

--17. List incidents with no suspects involved.
SELECT C.*
FROM Crime C
LEFT JOIN Suspect S 
ON C.CrimeID = S.CrimeID
WHERE S.Name like 'Unknown';

--Q18.List all cases where at least one incident is of type 'Homicide' and all other incidents are of type 'Robbery'
SELECT C.*
FROM Crime C
WHERE IncidentType in('Homicide','Robbery');


--19. Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, or 'No Suspect' if there are none.
SELECT C.*, ISNULL(S.Name, 'No Suspect') AS SuspectName
FROM Crime C
LEFT JOIN Suspect S 
ON C.CrimeID = S.CrimeID 
AND S.Name <> 'Unknown';

--20. List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault'
SELECT S.*
FROM Suspect S
JOIN Crime C ON S.CrimeID = C.CrimeID
WHERE C.IncidentType IN ('Robbery', 'Assault');


-- Active: 1671859768936@@127.0.0.1@3306@exercise
DROP TABLE IF EXISTS Physician;
CREATE TABLE Physician (
  EmployeeID INTEGER NOT NULL,
  Name VARCHAR(30) NOT NULL,
  Position VARCHAR(30) NOT NULL,
  SSN INTEGER NOT NULL,
  CONSTRAINT pk_physician PRIMARY KEY(EmployeeID)
); 

DROP TABLE IF EXISTS Department;
CREATE TABLE Department (
  DepartmentID INTEGER NOT NULL,
  Name VARCHAR(30) NOT NULL,
  Head INTEGER NOT NULL,
  CONSTRAINT pk_Department PRIMARY KEY(DepartmentID),
  CONSTRAINT fk_Department_Physician_EmployeeID FOREIGN KEY(Head) REFERENCES Physician(EmployeeID)
);


DROP TABLE IF EXISTS Affiliated_With;
CREATE TABLE Affiliated_With (
  Physician INTEGER NOT NULL,
  Department INTEGER NOT NULL,
  PrimaryAffiliation BOOLEAN NOT NULL,
  CONSTRAINT fk_Affiliated_With_Physician_EmployeeID FOREIGN KEY(Physician) REFERENCES Physician(EmployeeID),
  CONSTRAINT fk_Affiliated_With_Department_DepartmentID FOREIGN KEY(Department) REFERENCES Department(DepartmentID),
  PRIMARY KEY(Physician, Department)
);

DROP TABLE IF EXISTS Procedures;
CREATE TABLE Procedures (
  Code INTEGER PRIMARY KEY NOT NULL,
  Name VARCHAR(30) NOT NULL,
  Cost REAL NOT NULL
);

DROP TABLE IF EXISTS Trained_In;
CREATE TABLE Trained_In (
  Physician INTEGER NOT NULL,
  Treatment INTEGER NOT NULL,
  CertificationDate DATETIME NOT NULL,
  CertificationExpires DATETIME NOT NULL,
  CONSTRAINT fk_Trained_In_Physician_EmployeeID FOREIGN KEY(Physician) REFERENCES Physician(EmployeeID),
  CONSTRAINT fk_Trained_In_Procedures_Code FOREIGN KEY(Treatment) REFERENCES Procedures(Code),
  PRIMARY KEY(Physician, Treatment)
);

DROP TABLE IF EXISTS Patient;
CREATE TABLE Patient (
  SSN INTEGER PRIMARY KEY NOT NULL,
  Name VARCHAR(30) NOT NULL,
  Address VARCHAR(30) NOT NULL,
  Phone VARCHAR(30) NOT NULL,
  InsuranceID INTEGER NOT NULL,
  PCP INTEGER NOT NULL,
  CONSTRAINT fk_Patient_Physician_EmployeeID FOREIGN KEY(PCP) REFERENCES Physician(EmployeeID)
);

DROP TABLE IF EXISTS Nurse;
CREATE TABLE Nurse (
  EmployeeID INTEGER PRIMARY KEY NOT NULL,
  Name VARCHAR(30) NOT NULL,
  Position VARCHAR(30) NOT NULL,
  Registered BOOLEAN NOT NULL,
  SSN INTEGER NOT NULL
);

DROP TABLE IF EXISTS Appointment;
CREATE TABLE Appointment (
  AppointmentID INTEGER PRIMARY KEY NOT NULL,
  Patient INTEGER NOT NULL,    
  PrepNurse INTEGER,
  Physician INTEGER NOT NULL,
  Start DATETIME NOT NULL,
  End DATETIME NOT NULL,
  ExaminationRoom TEXT NOT NULL,
  CONSTRAINT fk_Appointment_Patient_SSN FOREIGN KEY(Patient) REFERENCES Patient(SSN),
  CONSTRAINT fk_Appointment_Nurse_EmployeeID FOREIGN KEY(PrepNurse) REFERENCES Nurse(EmployeeID),
  CONSTRAINT fk_Appointment_Physician_EmployeeID FOREIGN KEY(Physician) REFERENCES Physician(EmployeeID)
);

DROP TABLE IF EXISTS Medication;
CREATE TABLE Medication (
  Code INTEGER PRIMARY KEY NOT NULL,
  Name VARCHAR(30) NOT NULL,
  Brand VARCHAR(30) NOT NULL,
  Description VARCHAR(30) NOT NULL
);


DROP TABLE IF EXISTS Prescribes;
CREATE TABLE Prescribes (
  Physician INTEGER NOT NULL,
  Patient INTEGER NOT NULL, 
  Medication INTEGER NOT NULL, 
  Date DATETIME NOT NULL,
  Appointment INTEGER,  
  Dose VARCHAR(30) NOT NULL,
  PRIMARY KEY(Physician, Patient, Medication, Date),
  CONSTRAINT fk_Prescribes_Physician_EmployeeID FOREIGN KEY(Physician) REFERENCES Physician(EmployeeID),
  CONSTRAINT fk_Prescribes_Patient_SSN FOREIGN KEY(Patient) REFERENCES Patient(SSN),
  CONSTRAINT fk_Prescribes_Medication_Code FOREIGN KEY(Medication) REFERENCES Medication(Code),
  CONSTRAINT fk_Prescribes_Appointment_AppointmentID FOREIGN KEY(Appointment) REFERENCES Appointment(AppointmentID)
);

DROP TABLE IF EXISTS Block;
CREATE TABLE Block (
  BlockFloor INTEGER NOT NULL,
  BlockCode INTEGER NOT NULL,
  PRIMARY KEY(BlockFloor, BlockCode)
); 

DROP TABLE IF EXISTS Room;
CREATE TABLE Room (
  RoomNumber INTEGER PRIMARY KEY NOT NULL,
  RoomType VARCHAR(30) NOT NULL,
  BlockFloor INTEGER NOT NULL,  
  BlockCode INTEGER NOT NULL,  
  Unavailable BOOLEAN NOT NULL,
  CONSTRAINT fk_Room_Block_PK FOREIGN KEY(BlockFloor, BlockCode) REFERENCES Block(BlockFloor, BlockCode)
);

DROP TABLE IF EXISTS On_Call;
CREATE TABLE On_Call (
  Nurse INTEGER NOT NULL,
  BlockFloor INTEGER NOT NULL, 
  BlockCode INTEGER NOT NULL,
  OnCallStart DATETIME NOT NULL,
  OnCallEnd DATETIME NOT NULL,
  PRIMARY KEY(Nurse, BlockFloor, BlockCode, OnCallStart, OnCallEnd),
  CONSTRAINT fk_OnCall_Nurse_EmployeeID FOREIGN KEY(Nurse) REFERENCES Nurse(EmployeeID),
  CONSTRAINT fk_OnCall_Block_Floor FOREIGN KEY(BlockFloor, BlockCode) REFERENCES Block(BlockFloor, BlockCode) 
);

DROP TABLE IF EXISTS Stay;
CREATE TABLE Stay (
  StayID INTEGER PRIMARY KEY NOT NULL,
  Patient INTEGER NOT NULL,
  Room INTEGER NOT NULL,
  StayStart DATETIME NOT NULL,
  StayEnd DATETIME NOT NULL,
  CONSTRAINT fk_Stay_Patient_SSN FOREIGN KEY(Patient) REFERENCES Patient(SSN),
  CONSTRAINT fk_Stay_Room_Number FOREIGN KEY(Room) REFERENCES Room(RoomNumber)
);

DROP TABLE IF EXISTS Undergoes;
CREATE TABLE Undergoes (
  Patient INTEGER NOT NULL,
  Procedures INTEGER NOT NULL,
  Stay INTEGER NOT NULL,
  DateUndergoes DATETIME NOT NULL,
  Physician INTEGER NOT NULL,
  AssistingNurse INTEGER,
  PRIMARY KEY(Patient, Procedures, Stay, DateUndergoes),
  CONSTRAINT fk_Undergoes_Patient_SSN FOREIGN KEY(Patient) REFERENCES Patient(SSN),
  CONSTRAINT fk_Undergoes_Procedures_Code FOREIGN KEY(Procedures) REFERENCES Procedures(Code),
  CONSTRAINT fk_Undergoes_Stay_StayID FOREIGN KEY(Stay) REFERENCES Stay(StayID),
  CONSTRAINT fk_Undergoes_Physician_EmployeeID FOREIGN KEY(Physician) REFERENCES Physician(EmployeeID),
  CONSTRAINT fk_Undergoes_Nurse_EmployeeID FOREIGN KEY(AssistingNurse) REFERENCES Nurse(EmployeeID)
);



INSERT INTO Physician VALUES
(1,'John Dorian','Staff Internist',111111111),
(2,'Elliot Reid','Attending Physician',222222222),
(3,'Christopher Turk','Surgical Attending Physician',333333333),
(4,'Percival Cox','Senior Attending Physician',444444444),
(5,'Bob Kelso','Head Chief of Medicine',555555555),
(6,'Todd Quinlan','Surgical Attending Physician',666666666),
(7,'John Wen','Surgical Attending Physician',777777777),
(8,'Keith Dudemeister','MD Resident',888888888),
(9,'Molly Clock','Attending Psychiatrist',999999999);

INSERT INTO Department VALUES
(1,'General Medicine',4),
(2,'Surgery',7),
(3,'Psychiatry',9);

INSERT INTO Affiliated_With VALUES
(1,1,1),
(2,1,1),
(3,1,0),
(3,2,1),
(4,1,1),
(5,1,1),
(6,2,1),
(7,1,0),
(7,2,1),
(8,1,1),
(9,3,1);

INSERT INTO Procedures VALUES
(1,'Reverse Rhinopodoplasty',1500.0),
(2,'Obtuse Pyloric Recombobulation',3750.0),
(3,'Folded Demiophtalmectomy',4500.0),
(4,'Complete Walletectomy',10000.0),
(5,'Obfuscated Dermogastrotomy',4899.0),
(6,'Reversible Pancreomyoplasty',5600.0),
(7,'Follicular Demiectomy',25.0);

INSERT INTO Patient VALUES
(100000001,'John Smith','42 Foobar Lane','555-0256',68476213,1),
(100000002,'Grace Ritchie','37 Snafu Drive','555-0512',36546321,2),
(100000003,'Random J. Patient','101 Omgbbq Street','555-1204',65465421,2),
(100000004,'Dennis Doe','1100 Foobaz Avenue','555-2048',68421879,3);

INSERT INTO Nurse VALUES
(101,'Carla Espinosa','Head Nurse',1,111111110),
(102,'Laverne Roberts','Nurse',1,222222220),
(103,'Paul Flowers','Nurse',0,333333330);


INSERT INTO Appointment VALUES
(13216584,100000001,101,1,'2008-04-24 10:00','2008-04-24 11:00','A'),
(26548913,100000002,101,2,'2008-04-24 10:00','2008-04-24 11:00','B'),
(36549879,100000001,102,1,'2008-04-25 10:00','2008-04-25 11:00','A'),
(46846589,100000004,103,4,'2008-04-25 10:00','2008-04-25 11:00','B'),
(59871321,100000004,NULL,4,'2008-04-26 10:00','2008-04-26 11:00','C'),
(69879231,100000003,103,2,'2008-04-26 11:00','2008-04-26 12:00','C'),
(76983231,100000001,NULL,3,'2008-04-26 12:00','2008-04-26 13:00','C'),
(86213939,100000004,102,9,'2008-04-27 10:00','2008-04-21 11:00','A'),
(93216548,100000002,101,2,'2008-04-27 10:00','2008-04-27 11:00','B');

INSERT INTO Medication VALUES
(1,'Procrastin-X','X','N/A'),
(2,'Thesisin','Foo Labs','N/A'),
(3,'Awakin','Bar Laboratories','N/A'),
(4,'Crescavitin','Baz Industries','N/A'),
(5,'Melioraurin','Snafu Pharmaceuticals','N/A');

INSERT INTO Prescribes VALUES
(1,100000001,1,'2008-04-24 10:47',13216584,'5'),
(9,100000004,2,'2008-04-27 10:53',86213939,'10'),
(9,100000004,2,'2008-04-30 16:53',NULL,'5');

INSERT INTO Block VALUES
(1,1),
(1,2),
(1,3),
(2,1),
(2,2),
(2,3),
(3,1),
(3,2),
(3,3),
(4,1),
(4,2),
(4,3);

INSERT INTO Room VALUES
(101,'Single',1,1,0),
(102,'Single',1,1,0),
(103,'Single',1,1,0),
(111,'Single',1,2,0),
(112,'Single',1,2,1),
(113,'Single',1,2,0),
(121,'Single',1,3,0),
(122,'Single',1,3,0),
(123,'Single',1,3,0),
(201,'Single',2,1,1),
(202,'Single',2,1,0),
(203,'Single',2,1,0),
(211,'Single',2,2,0),
(212,'Single',2,2,0),
(213,'Single',2,2,1),
(221,'Single',2,3,0),
(222,'Single',2,3,0),
(223,'Single',2,3,0),
(301,'Single',3,1,0),
(302,'Single',3,1,1),
(303,'Single',3,1,0),
(311,'Single',3,2,0),
(312,'Single',3,2,0),
(313,'Single',3,2,0),
(321,'Single',3,3,1),
(322,'Single',3,3,0),
(323,'Single',3,3,0),
(401,'Single',4,1,0),
(402,'Single',4,1,1),
(403,'Single',4,1,0),
(411,'Single',4,2,0),
(412,'Single',4,2,0),
(413,'Single',4,2,0),
(421,'Single',4,3,1),
(422,'Single',4,3,0),
(423,'Single',4,3,0);

INSERT INTO On_Call VALUES
(101,1,1,'2008-11-04 11:00','2008-11-04 19:00'),
(101,1,2,'2008-11-04 11:00','2008-11-04 19:00'),
(102,1,3,'2008-11-04 11:00','2008-11-04 19:00'),
(103,1,1,'2008-11-04 19:00','2008-11-05 03:00'),
(103,1,2,'2008-11-04 19:00','2008-11-05 03:00'),
(103,1,3,'2008-11-04 19:00','2008-11-05 03:00');

INSERT INTO Stay VALUES
(3215,100000001,111,'2008-05-01','2008-05-04'),
(3216,100000003,123,'2008-05-03','2008-05-14'),
(3217,100000004,112,'2008-05-02','2008-05-03');

INSERT INTO Undergoes VALUES
(100000001,6,3215,'2008-05-02',3,101),
(100000001,2,3215,'2008-05-03',7,101),
(100000004,1,3217,'2008-05-07',3,102),
(100000004,5,3217,'2008-05-09',6,NULL),
(100000001,7,3217,'2008-05-10',7,101),
(100000004,4,3217,'2008-05-13',3,103);

INSERT INTO Trained_In VALUES
(3,1,'2008-01-01','2008-12-31'),
(3,2,'2008-01-01','2008-12-31'),
(3,5,'2008-01-01','2008-12-31'),
(3,6,'2008-01-01','2008-12-31'),
(3,7,'2008-01-01','2008-12-31'),
(6,2,'2008-01-01','2008-12-31'),
(6,5,'2007-01-01','2007-12-31'),
(6,6,'2008-01-01','2008-12-31'),
(7,1,'2008-01-01','2008-12-31'),
(7,2,'2008-01-01','2008-12-31'),
(7,3,'2008-01-01','2008-12-31'),
(7,4,'2008-01-01','2008-12-31'),
(7,5,'2008-01-01','2008-12-31'),
(7,6,'2008-01-01','2008-12-31'),
(7,7,'2008-01-01','2008-12-31');


-- 8.1
-- Obtain the names of all physicians that have performed a medical procedure they have never been certified to perform.
SELECT NAME 
FROM
	Physician 
WHERE
	EmployeeID IN ( SELECT Physician FROM Undergoes U WHERE NOT EXISTS ( SELECT * FROM Trained_In WHERE Treatment = Procedures AND Physician = U.Physician ) ); 


-- 8.2
-- Same as the previous query, but include the following information in the results: Physician name, name of procedure, date when the procedure was carried out, name of the patient the procedure was carried out on.
SELECT
	P.NAME AS Physician,
	Pr.NAME AS `procedure`,
	U.DateUndergoes,
	Pt.NAME AS Patient 
FROM
	Physician P,
	Undergoes U,
	Patient Pt,
	Procedures Pr 
WHERE
	U.Patient = Pt.SSN 
	AND U.Procedures = Pr.CODE 
	AND U.Physician = P.EmployeeID 
	AND NOT EXISTS ( SELECT * FROM Trained_In T WHERE T.Treatment = U.Procedures AND T.Physician = U.Physician );


-- 8.3
-- Obtain the names of all physicians that have performed a medical procedure that they are certified to perform, but such that the procedure was done at a date (Undergoes.Date) after the physician's certification expired (Trained_In.CertificationExpires).
SELECT
	P.NAME 
FROM
	Physician AS P,
	Trained_In T,
	Undergoes AS U 
WHERE
	T.Physician = U.Physician 
	AND T.Treatment = U.Procedures
	AND U.DateUndergoes > T.CertificationExpires 
	AND P.EmployeeID = U.Physician

;
-- 8.4
-- Same as the previous query, but include the following information in the results: Physician name, name of procedure, date when the procedure was carried out, name of the patient the procedure was carried out on, and date when the certification expired.
SELECT
	P.NAME AS Physician,
	Pr.NAME AS `PROCEDURE`,
	U.DateUndergoes,
	Pt.NAME AS Patient,
	T.CertificationExpires 
FROM
	Physician P,
	Undergoes U,
	Patient Pt,
	Procedures Pr,
	Trained_In T 
WHERE
	U.Patient = Pt.SSN 
	AND U.Procedures = Pr.CODE 
	AND U.Physician = P.EmployeeID 
	AND Pr.CODE = T.Treatment 
	AND P.EmployeeID = T.Physician 
	AND U.DateUndergoes > T.CertificationExpires;


-- 8.5
-- Obtain the information for appointments where a patient met with a physician other than his/her primary care physician. Show the following information: Patient name, physician name, nurse name (if any), start and end time of appointment, examination room, and the name of the patient's primary care physician.
SELECT
	Pt.NAME AS Patient,
	Ph.NAME AS Physician,
	N.NAME AS Nurse,
	A.START,
	A.END,
	A.ExaminationRoom,
	PhPCP.NAME AS PCP 
FROM
	Patient Pt,
	Physician Ph,
	Physician PhPCP,
	Appointment A
	LEFT JOIN Nurse N ON A.PrepNurse = N.EmployeeID 
WHERE
	A.Patient = Pt.SSN 
	AND A.Physician = Ph.EmployeeID 
	AND Pt.PCP = PhPCP.EmployeeID 
	AND A.Physician <> Pt.PCP;


-- 8.6
-- The Patient field in Undergoes is redundant, since we can obtain it from the Stay table. There are no constraints in force to prevent inconsistencies between these two tables. More specifically, the Undergoes table may include a row where the patient ID does not match the one we would obtain from the Stay table through the Undergoes.Stay foreign key. Select all rows from Undergoes that exhibit this inconsistency.
SELECT
	* 
FROM
	Undergoes U 
WHERE
	Patient <> ( SELECT Patient FROM Stay S WHERE U.Stay = S.StayID );


-- 8.7
-- Obtain the names of all the nurses who have ever been on call for room 123.
SELECT
	N.NAME 
FROM
	Nurse N 
WHERE
	EmployeeID IN (
	SELECT
		OC.Nurse 
	FROM
		On_Call OC,
		Room R 
	WHERE
		OC.BlockFloor = R.BlockFloor 
		AND OC.BlockCode = R.BlockCode 
	AND R.RoomNumber = 123 
	);


-- 8.8
-- The hospital has several examination rooms where appointments take place. Obtain the number of appointments that have taken place in each examination room.
SELECT ExaminationRoom, COUNT(*) AS Number FROM Appointment
GROUP BY ExaminationRoom;


-- 8.9
-- Obtain the names of all patients (also include, for each patient, the name of the patient's primary care physician), such that \emph{all} the following are true:
-- 
-- The patient has been prescribed some medication by his/her primary care physician.
-- The patient has undergone a procedure with a cost larger that $5,000
-- The patient has had at least two appointment where the nurse who prepped the appointment was a registered nurse.
-- The patient's primary care physician is not the head of any department.
SELECT
	Pt.NAME,
	PhPCP.NAME 
FROM
	Patient Pt,
	Physician PhPCP 
WHERE
	Pt.PCP = PhPCP.EmployeeID 
	AND EXISTS ( 
		SELECT * FROM Prescribes Pr WHERE 
			Pr.Patient = Pt.SSN 
			AND Pr.Physician = Pt.PCP 
	) 
	AND EXISTS (
		SELECT * FROM Undergoes U, Procedures Pr WHERE 
			U.Procedures = Pr.CODE 
			AND U.Patient = Pt.SSN 
			AND Pr.Cost > 5000 
	) 
	AND 2 <= (
		SELECT COUNT( A.AppointmentID ) FROM Appointment A, Nurse N WHERE
			A.PrepNurse = N.EmployeeID 
			AND N.Registered = 1 
	) 
	AND NOT Pt.PCP IN ( 
		SELECT Head FROM Department 
	);
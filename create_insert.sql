CREATE TABLE Absence (
    ID int  NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name varchar(100)  NOT NULL,
);

INSERT INTO Absence(Name)
VALUES ('Sickness'), ('Holiday'), ('Bereavement'), ('Maternity Leave'), ('Paternity Leave'), ('Adoption Leave'), ('Training'), ('AWOL'), ('Unpaid Leave');

-----

CREATE TABLE SalaryType (
    ID int  NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Type varchar(50)  NOT NULL
);

INSERT INTO SalaryType(Type)
VALUES ('Hourly'), ('Salary');

----

CREATE TABLE ContractType (
    ID int  NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Type varchar(50)  NOT NULL,
);

INSERT INTO ContractType(Type)
VALUES ('Employment contract'), ('Commission contract'), ('Specific-task contract'), ('Intership contract');

----

CREATE TABLE Position (
    ID int  NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name varchar(150)  NOT NULL
);

INSERT INTO Position(Name)
VALUES ('Junior specjalist'), ('Specjalist'), ('Senior specjalist'), ('Manager'), ('HR officer'), ('Director');

----

CREATE TABLE Department (
    Code varchar(10) NOT NULL PRIMARY KEY,
    Name varchar(100) NOT NULL
);

INSERT INTO Department(Code, Name)
VALUES ('MRK', 'Marketing department'), ('OPR', 'Operations department'), ('FIN', 'Finance department'), ('SAL', 'Sales department'), ('HR', 'Human resource department'), ('PUR', 'Purchase department');

----

CREATE TABLE City (
    ID int NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name varchar(100)  NOT NULL
);

INSERT INTO City(Name)
VALUES ('Truro'), ('Fairmont'), ('Rock Springs'), ('Saugus'), ('Payson'), ('Sarasota'), ('Fullerton'), ('Montclair');

----

CREATE TABLE Address (
    ID int  NOT NULL IDENTITY(1,1) PRIMARY KEY,
    CityID int  NOT NULL FOREIGN KEY (CityID) REFERENCES City (ID),
    Street varchar(100) NOT NULL,
    BuildingNumber varchar(4)  NOT NULL,
    ApartmentNumber int NULL
);

INSERT INTO Address(CityID, Street, BuildingNumber, ApartmentNumber)
VALUES (1, 'Orchard Hey', '23', null), (4, 'Venlo Road', '12B', null), (5, 'Repton Downs', '1', 3),
(4, 'King John Avenue', '123', null), (8, 'Greenbank Yard', '2', 45), (2, 'Dickens Paddocks', '5A', null),
(3, 'Shrewsbury Top', '89', 90), (8, 'Blackthorn Limes', '93', null), (2, 'Baird By-Pass', '32', 9),
(8, 'Lowgate Street', '7', null), (8, 'Wansdyke Court', '19', 79), (6, 'Devon Place', '100C', 66);

----

CREATE TABLE Employee (
    ID int  NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name varchar(50)  NOT NULL,
    Surname varchar(50)  NOT NULL,
    PESEL varchar(11)  NOT NULL,
    AddressID int  NOT NULL FOREIGN KEY (AddressID) REFERENCES Address (ID)
);

INSERT INTO Employee(Name, Surname, PESEL, AddressID)
VALUES('Burhan' ,'Neal', '98110127797', 1), ('Ziva' ,'Christie', '78083155445', 3), ('Samual' ,'Pacheco', '66092551837', 7),
('Adele' ,'Sadler', '67022482267', 10), ('Jimi' ,'Humphries', '58070455358', 8), ('Eliana' ,'Trevino', '91071567912', 11),
('Caden' ,'Gale', '01321076318', 2), ('Daphne' ,'Field', '56031067332', 9), ('Keri' ,'Simons', '94101385391', 5),
('Usman' ,'Willis', '93020367598', 12), ('Cheryl' ,'Pugh', '89120554134', 4), ('Lance' ,'Nash', '86090324424', 6);

----

CREATE TABLE Contract (
    Number varchar(100)  NOT NULL PRIMARY KEY,
    ContractTypeID int  NOT NULL FOREIGN KEY (ContractTypeID) REFERENCES ContractType (ID),
    PositionID int  NOT NULL FOREIGN KEY (PositionID) REFERENCES Position (ID),
    DateFrom date  NOT NULL,
    DateTo date  NULL,
    SalaryTypeID int  NOT NULL FOREIGN KEY (SalaryTypeID) REFERENCES SalaryType (ID),
    Salary float  NOT NULL,
);

INSERT INTO Contract(Number, ContractTypeID, PositionID, DateFrom, DateTo, SalaryTypeID, Salary)
VALUES('10/234/2017', 1, 3, '02.03.2017', null, 2, '5600'),('07/985/2015', 1, 4, '15.06.2015', null, 2, '8990'), 
('97/341/2018', 2, 1, '09.01.2018', '09.04.2018', 1, '25'),('21/340/2018', 2, 2, '10.04.2018', null, 1, '37'),
('98/002/2019', 3, 5, '15.12.2019', null, 2, '5430'), ('31/420/2014', 4, 1, '01.08.2014', '30.11.2014', 2, '2500'),
('61/654/2015', 3, 6, '15.06.2015', null, 1, '120'), ('60/531/2016', 1, 5, '13.10.2016', null, 2, '4300'),
('51/056/2014', 2, 4, '15.06.2014', '16.08.2016', 1, '32'), ('00/321/2014', 1, 3, '20.03.2014', '20.05.2015', 2, '4650'),
('90/184/2016', 3, 4, '06.02.2016', null, 1, '27');

----

CREATE TABLE Employee_Contract (
    EmployeeID int  NOT NULL  FOREIGN KEY (EmployeeID) REFERENCES Employee (ID),
    ContractNumber varchar(100)  NOT NULL FOREIGN KEY (ContractNumber) REFERENCES Contract (Number),
    DepartmentCode varchar(10)  NOT NULL FOREIGN KEY (DepartmentCode) REFERENCES Department (Code),
	primary key (EmployeeID, ContractNumber)
);

INSERT INTO Employee_Contract(EmployeeID, ContractNumber, DepartmentCode)
VALUES(1, '10/234/2017', 'MRK'),(2, '07/985/2015', 'SAL'),(3, '97/341/2018', 'FIN'),(3, '21/340/2018', 'FIN'),
(4, '98/002/2019', 'SAL'),(5, '31/420/2014', 'HR'),(6, '61/654/2015', 'MRK'),(7, '60/531/2016', 'OPR'),
(8, '51/056/2014', 'OPR'),(9, '00/321/2014', 'MRK'),(10, '90/184/2016', 'HR');

----

CREATE TABLE Employee_Absence (
    EmployeeID int  NOT NULL FOREIGN KEY (EmployeeID) REFERENCES Employee (ID),
    AbsenceID int  NOT NULL FOREIGN KEY (AbsenceID) REFERENCES Absence (ID),
    DateFrom date  NOT NULL,
    DateTo date  NOT NULL,
    PRIMARY KEY  (EmployeeID, AbsenceID, DateFrom,DateTo)
);
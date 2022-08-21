-- Trigger that checks the validity of the PESEL number when trying to insert a new employee.
CREATE TRIGGER t_addEmployee ON Employee
FOR INSERT, UPDATE
AS
DECLARE @pesel varchar(11)
SELECT @pesel = pesel FROM inserted
IF ISNUMERIC(@pesel) = 0
	BEGIN
	PRINT 'PESEL must consist of digits.'
	ROLLBACK
	END 
ELSE
	BEGIN
	DECLARE @sum int = 0
	DECLARE @i int = 0

	DECLARE @weights TABLE(id INT IDENTITY(1,1), weight INT)
	INSERT INTO @weights VALUES(1),(3),(7),(9),(1),(3),(7),(9),(1),(3)

	WHILE (@i < 10)
	BEGIN
		DECLARE @weight INT = (SELECT weight FROM @weights WHERE id = @i+1)
		SET @sum = @sum + (SUBSTRING(@pesel, @i, 1) * @weight)
		SET @i = @i+1;
	END
	SET @sum = @sum % 10
	IF @sum <> SUBSTRING(@pesel, 11, 1)
		BEGIN
		ROLLBACK;
		Raiserror('Invalid PESEL', 1, 1)
		END
	END

---------------------------------------------------------------------------------------------------------------------------------------
-- A trigger that checks if absences for an employee exist on the specified dates.
CREATE TRIGGER t_existingAbsence
on Employee_Absence
FOR INSERT
AS
DECLARE @employeeID INT, @dateFrom DATE, @dateTo DATE;
SELECT @employeeID = EmployeeID, @dateFrom = DateFrom, @dateTo = DateTo FROM inserted;

IF @dateFrom > @dateTo
	BEGIN
	PRINT('The date from must be earlier than the date to.');
	ROLLBACK;
	END
ELSE IF (SELECT count(*) FROM Employee_Absence WHERE (DateFrom BETWEEN @dateFrom AND @dateTo OR DateTo BETWEEN @dateFrom AND @dateTo) AND EmployeeID = @employeeID) > 1
	BEGIN
	PRINT('The employee already has an absence at this time.');
	ROLLBACK;
	END

---------------------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER t_dateToEarlierThanDateFrom
on Contract
FOR INSERT, UPDATE
AS
DECLARE @dateFrom DATE, @dateTo DATE;
SELECT @dateFrom = DateFrom, @dateTo = DateTo FROM inserted;

IF @dateFrom > @dateTo
	BEGIN
	PRINT('The date from must be earlier than the date to.');
	ROLLBACK;
	END

---------------------------------------------------------------------------------------------------------------------------------------
-- A trigger that controls the length of absences depending on which type is selected.
CREATE TRIGGER t_lengthOfAbsence
on Employee_Absence
FOR INSERT
AS
DECLARE @employeeID INT, @absenceID INT, @dateFrom DATE, @dateTo DATE;
SELECT @employeeID = EmployeeID, @absenceID = AbsenceID, @dateFrom = DateFrom, @dateTo = DateTo FROM inserted;

DECLARE @absenceName VARCHAR(50) = (SELECT Name FROM Absence WHERE ID = @absenceID);
DECLARE @differenceInDays INT = (DATEDIFF(day, @dateFrom, @dateTo) + 1);

IF @absenceName = 'Bereavement' --dodanie sprawdzania per rok
	BEGIN
		IF @differenceInDays NOT IN (1,2)
			BEGIN
			PRINT 'During bereavement, there are 1 or 2 days off!';
			ROLLBACK;
			END
	END

IF @absenceName = 'Paternity Leave'
	BEGIN
		IF @differenceInDays > 14
			BEGIN
			PRINT 'During paternity leave, there is a maximum of 14 days off!';
			ROLLBACK;
			END
	END

IF @absenceName = 'AWOL' --dodanie sprawdzania per rok
	BEGIN
		DECLARE @numberOfDaysPerYear INT = (SELECT count(*) FROM Employee_Absence WHERE AbsenceID = 8 AND dateFrom = YEAR(@dateFrom));
		IF @numberOfDaysPerYear > 4
			BEGIN
			PRINT 'During avol, there is a maximum of 4 days off per year!';
			ROLLBACK;
			END
	END

IF @absenceName = 'Maternity Leave'
	BEGIN
		IF @differenceInDays/7 > 37
			BEGIN
			PRINT 'During maternity leave, there are:
					20 weeks - in case of birth of one child
					31 weeks - in the case of the birth of two children
					33 weeks - in the case of the birth of three children
					35 weeks - in the case of giving birth to four children
					37 weeks - in the case of giving birth to five or more children';
			ROLLBACK;
			END
	END




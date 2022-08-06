-- Kursor pobierający z kolumny 'PESEL' cyfrę oznaczającą płeć i wstawia poprawną wartość do kolumny 'Gender'
ALTER TABLE Employee 
ADD Gender varchar(1)

DECLARE c_addGenderToEmployee CURSOR FOR SELECT PESEL FROM Employee
DECLARE @pesel varchar(11)
OPEN c_addGenderToEmployee
FETCH NEXT FROM c_addGenderToEmployee INTO @pesel
WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @penultimateDigit INT = Cast(SUBSTRING(@pesel, 10, 1) AS INT)
	DECLARE @gender varchar(1)
	
	IF @penultimateDigit % 2 = 0
		SET @gender = 'F'
	ELSE 
		SET @gender = 'M'
	UPDATE Employee SET Gender = @gender WHERE PESEL = @pesel
	FETCH NEXT FROM c_addGenderToEmployee INTO @pesel
END

--CLOSE c_addGenderToEmployee
--DEALLOCATE c_addGenderToEmployee

-----------------------------------------------------------------------------------------------
-- Wyzwalacz sprawdzający poprawnosc numeru PESEL przy próbie wstawienia nowego pracownika.

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

--DROP TRIGGER t_addEmployee;

-----------------------------------------------------------------------------------------------
-- Procedura sprawdzająca czy pracownik posiada absencję w okresie, która została podana jako parametr.

CREATE PROCEDURE p_addABonusWithoutAbsenceBetween @dataFrom DATE, @dataTo DATE
AS
	DECLARE @employeeID INT, @employeeName VARCHAR(30), @employeeSurname VARCHAR(50)

	DECLARE employee CURSOR FOR SELECT ID, Name, Surname FROM Employee

	OPEN employee
	FETCH NEXT FROM employee INTO @employeeID, @employeeName, @employeeSurname
	PRINT 'Pracownicy, którzy zasługują na premię: '
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @absence INT = (SELECT count(*) FROM Employee_Absence WHERE EmployeeID = @employeeID AND DateFrom >= @dataFrom AND DateTo <= @dataTo)

		IF @absence = 0
			PRINT @employeeName + ' ' + @employeeSurname + '(id: ' + Cast(@employeeID AS VARCHAR) + ')'

		FETCH NEXT FROM employee INTO @employeeID, @employeeName, @employeeSurname
	END
	CLOSE employee
	DEALLOCATE employee


--DROP PROCEDURE p_addABonusWithoutAbsenceBetween;
--EXEC p_addABonusWithoutAbsenceBetween '2021-01-01', '2021-01-31';
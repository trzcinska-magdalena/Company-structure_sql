-- A procedure that checks whether an employee has absences in a period that has been specified as a parameter.
CREATE PROCEDURE p_addABonusWithoutAbsenceBetween @dataFrom DATE, @dataTo DATE
AS
	DECLARE @employeeID INT, @employeeName VARCHAR(30), @employeeSurname VARCHAR(50)

	DECLARE employee CURSOR FOR SELECT ID, Name, Surname FROM Employee

	OPEN employee
	FETCH NEXT FROM employee INTO @employeeID, @employeeName, @employeeSurname
	PRINT 'Employees who deserve a bonus:'
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

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- A procedure that counts and returns the monthly budget for employees with a permanent salary.
CREATE PROCEDURE p_totalMonthlyPaymentsForConstant
AS
	DECLARE @salaryTypeID INT, @salary INT
	DECLARE @total INT = 0

	DECLARE contract CURSOR FOR SELECT SalaryTypeID, Salary FROM Contract

	OPEN contract
	FETCH NEXT FROM contract INTO @salaryTypeID, @salary

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF 2 = @salaryTypeID
			SET @total = @total + @salary
		FETCH NEXT FROM contract INTO @salaryTypeID, @salary
	END
	CLOSE contract
	DEALLOCATE contract

	RETURN @total;


DECLARE @total INT
EXECUTE @total = p_totalMonthlyPaymentsForConstant
PRINT @total
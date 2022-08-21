-- A cursor that takes the gender digit from the 'PESEL' column and inserts the correct value into the 'Gender' column
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
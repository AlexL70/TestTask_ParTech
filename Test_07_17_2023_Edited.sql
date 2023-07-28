/*
Employees can work one or several shifts per business day and can have any number of breaks per business day.
According to the list of break rules, manager has to either give employees needed breaks or pay them a penalty.
Table @Timecards stores working hours (from StartDate to EndDate) for employee/businessdate.
Table @BreakRules stores 
[BreakRequiredAfter]  - minimum number of hours employee should work per business day to get a break,
[TakeBreakWithin] - maximum number of hours employee can work before break start,
[MinBreakMinutes]- minimum break duration.

Thus if employee works more then [BreakRequiredAfter] hours per business day,
break must start not later than after [TakeBreakWithin] hours of work and must not be shorter than [MinBreakMinutes].
Employee break applied to one rule cannot be applied for other rules, but may be not applied to any rule.
If we have two rules with [BreakRequiredAfter] = 6 and [BreakRequiredAfter] = 9 and employee total hours per businessdate= 10,
it means that the employee is expected to take two breaks - the first before [TakeBreakWithin] of the first rule 
and the second before [TakeBreakWithin] of the second rule. Both breaks should be not less than [MinBreakMinutes] of the corresponding rules.

In the below example we assume that break starts at EndDate of the previous shift and ends at StartDate of the current shift. 

Write a script that calculates the number of not satisfied rules for every employee/business date.
The following result set is expected:
Employee, Businessdate, NumberOfNotSatisfiedRules. 

*/

/*
To resolve it I made next changes:
	1. Made TimeCards and BreakRules tables permanent !!! Be careful - run it only on test DB !!!
	2. Added happy employee who has taken all breaks he deserves (just to make sure my algorithm works well for the happy path

Solution is implemented as T-SQL block, though in the real life it would probably be a stored procedure.
Detailed log of all required/found breaks is available so that you can see each step/decision taken by alghorithm.
In real life I would probably remove or comment PRINT statements after making sure it works as expected.

Regards,
Alexander Levinson
7/21/2023
*/

DROP TABLE TimeCards
GO
CREATE TABLE Timecards (	
		ID int Identity(1,1),	
		BusinessDate smalldatetime ,
		StartDate datetime ,
		EndDate datetime,
		Employee varchar(50)		
)
GO
DROP TABLE BreakRules
GO
CREATE TABLE BreakRules (	
	ID int Identity(1,1),	
	MinBreakMinutes int  ,
	BreakRequiredAfter  decimal(10,2) ,
	TakeBreakWithin  decimal(10,2) 
)
GO
SET NOCOUNT ON
-- fill timecards
DECLARE @Employee varchar(50)
DECLARE @BusinessDate smalldatetime

SET @Employee ='First Employee'
set @BusinessDate ='2/28/2023'
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 5:55','2/28/2023 9:24')
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 9:55','2/28/2023 16:18')
set @BusinessDate= '2/27/2023'
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/27/2023 6:00','2/27/2023 17:20')
SET @Employee ='Second Employee'
set @BusinessDate ='2/28/2023'
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 5:20','2/28/2023 8:30')
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 8:45','2/28/2023 13:03')
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 13:33','2/28/2023 17:00')
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 17:25','2/28/2023 19:00')
SET @Employee ='Third Employee'
set @BusinessDate ='2/28/2023'
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 5:10','2/28/2023 7:30')
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 7:45','2/28/2023 8:00')
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 8:20','2/28/2023 13:00')
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 13:30','2/28/2023 20:00')
SET @Employee ='Forth Employee'
set @BusinessDate ='2/26/2023'
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/26/2023 5:10','2/26/2023 7:15:42')
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/26/2023 7:45:00','2/26/2023 8:00')
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/26/2023 8:20','2/26/2023 13:00')
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/26/2023 13:29','2/26/2023 20:00')

-- Happy Employee got all breaks
SET @Employee ='Happy Employee'
set @BusinessDate ='2/28/2023'
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 3:55','2/28/2023 9:24')
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 9:55','2/28/2023 12:55')
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 13:58','2/28/2023 15:25')
INSERT INTO  Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 15:58','2/28/2023 16:18')

-- fill rules
INSERT INTO BreakRules (MinBreakMinutes ,	BreakRequiredAfter   ,	TakeBreakWithin)
Values(30,6,5)
INSERT INTO BreakRules (MinBreakMinutes ,	BreakRequiredAfter   ,	TakeBreakWithin)
Values(30,9,9)
INSERT INTO BreakRules (MinBreakMinutes ,	BreakRequiredAfter   ,	TakeBreakWithin)
Values(30,12,11)
GO

BEGIN
	DECLARE @BusinessDate smalldatetime
	DECLARE @Employee varchar(50)
	DECLARE @ShiftStart smalldatetime
	DECLARE @ShiftEnd smalldatetime
	DECLARE @RuleID int	
	DECLARE @MinBreakMinutes int
	DECLARE @BreakRequiredAfter  decimal(10,2)
	DECLARE @TakeBreakWithin  decimal(10,2)

	DECLARE @Rules TABLE (
		ID int,
		MinBreakMinutes int  ,
		BreakRequiredAfter  decimal(10,2) ,
		TakeBreakWithin  decimal(10,2) 
	)
	DECLARE @BrokenRules TABLE (
		Employee varchar(50),
		ShiftDate smalldatetime,
		RuleID int
	)
	INSERT INTO @Rules SELECT ID, MinBreakMinutes, BreakRequiredAfter, TakeBreakWithin FROM BreakRules;
	
	DECLARE CR_SHIFT CURSOR FORWARD_ONLY READ_ONLY FOR
		SELECT  tc.BusinessDate, tc.Employee, MIN(tc.StartDate), MAX(tc.EndDate)
		  FROM  TimeCards tc
		 GROUP  BY
				tc.Employee,
				tc.BusinessDate;

	DECLARE CR_RULE CURSOR FORWARD_ONLY READ_ONLY FOR
		SELECT  ID, MinBreakMinutes, BreakRequiredAfter, TakeBreakWithin
		  FROM  @Rules
		 ORDER  BY
				BreakRequiredAfter; -- it could be TakeBreakWithin, does not matter
	OPEN CR_SHIFT

	FETCH NEXT FROM CR_SHIFT INTO @BusinessDate, @Employee, @ShiftStart, @ShiftEnd

	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @ShiftLength  decimal(10,2)
		DECLARe @Hours decimal(10,2)
		DECLARE @BreakStart smalldatetime
		DECLARE @BreakEnd smalldatetime

		SET @Hours = DATEDIFF(HOUR, @ShiftStart, @ShiftEnd)
		SET @ShiftLength = @Hours + DATEDIFF(MINUTE, DATEADD(HOUR, @Hours, @ShiftStart), @ShiftEnd) / 60.0 -- length of a day shift in hours
		PRINT ''
		PRINT @Employee + ' '  + CONVERT(varchar, @ShiftStart, 113) + ' ' + CONVERT(varchar, @ShiftEnd, 113)
		PRINT 'Shift length in hours: ' + CONVERT(varchar, @ShiftLength)
		OPEN CR_RULE
			FETCH NEXT FROM CR_RULE INTO @RuleID, @MinBreakMinutes, @BreakRequiredAfter, @TakeBreakWithin
			WHILE @@FETCH_STATUS = 0
			BEGIN
				-- check if the current rule is applicable to the shift
				PRINT 'Break required: ' + CONVERT(varchar, @TakeBreakWithin) + ':' + CONVERT(varchar, @BreakRequiredAfter)
				IF @ShiftLength > @BreakRequiredAfter
				BEGIN 
					SET @BreakStart = null;
					SELECT  @BreakStart = tc.EndDate
					  FROM  TimeCards tc
					 WHERE  tc.BusinessDate = @BusinessDate
					   AND  tc.Employee = @Employee
					   AND  tc.EndDate >= DATEADD(HOUR, @TakeBreakWithin, @ShiftStart)
					   AND  tc.EndDate <= DATEADD(HOUR, @BreakRequiredAfter, @ShiftStart);

					IF NOT (@BreakStart IS NULL)
					BEGIN
						SELECT  @BreakEnd = MIN(tc.StartDate)
						  FROM  TimeCards tc
						 WHERE  tc.BusinessDate = @BusinessDate
						   AND  tc.Employee = @Employee
						   AND  tc.StartDate > @BreakStart;
					END
					ELSE
						SET @BreakEnd = null

					IF @BreakStart is null -- no break at all
					OR @BreakEnd is null
					OR DATEDIFF(MINUTE, @BreakStart, @BreakEnd) < @MinBreakMinutes -- break was shorter than minimum
					BEGIN
						INSERT INTO @BrokenRules (ShiftDate, Employee, RuleID) VALUES(@BusinessDate, @Employee, @RuleID)
					END
					ELSE 
						PRINT 'Break found: '  + CONVERT(varchar, @BreakStart, 113) + ' to ' + CONVERT(varchar, @BreakEnd, 113)

				END
				FETCH NEXT FROM CR_RULE INTO @RuleID, @MinBreakMinutes, @BreakRequiredAfter, @TakeBreakWithin
			END
		CLOSE CR_RULE
		FETCH NEXT FROM CR_SHIFT INTO @BusinessDate, @Employee, @ShiftStart, @ShiftEnd
	END
	CLOSE CR_SHIFT
	DEALLOCATE CR_SHIFT
	DEALLOCATE CR_RULE

	SELECT  ShiftDate AS BusinessDate,
			Employee,
			COUNT(RuleID) AS NumberOfNotSatisfiedRules
	  FROM  @BrokenRules
	 GROUP  BY
			ShiftDate,
			Employee
END

/*
SELECT  *
  FROM  BreakRules;

SELECT  *
  FROM  TimeCards;
*/




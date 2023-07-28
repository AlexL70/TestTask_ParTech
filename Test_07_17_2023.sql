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

DECLARE @Timecards TABLE(	
		ID int Identity(1,1),	
		BusinessDate smalldatetime ,
		StartDate datetime ,
		EndDate datetime,
		Employee varchar(50)		
)
DECLARE @BreakRules TABLE(	
	ID int Identity(1,1),	
	MinBreakMinutes int  ,
	BreakRequiredAfter  decimal(10,2) ,
	TakeBreakWithin  decimal(10,2) 
)

/*

-- fill timecards
DECLARE @Employee varchar(50)
DECLARE @BusinessDate smalldatetime

SET @Employee ='First Employee'
set @BusinessDate ='2/28/2023'
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 5:55','2/28/2023 9:24')
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 9:55','2/28/2023 16:18')
set @BusinessDate= '2/27/2023'
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/27/2023 6:00','2/27/2023 17:20')
SET @Employee ='Second Employee'
set @BusinessDate ='2/28/2023'
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 5:20','2/28/2023 8:30')
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 8:45','2/28/2023 13:03')
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 13:33','2/28/2023 17:00')
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 17:25','2/28/2023 19:00')
SET @Employee ='Third Employee'
set @BusinessDate ='2/28/2023'
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 5:10','2/28/2023 7:30')
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 7:45','2/28/2023 8:00')
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 8:20','2/28/2023 13:00')
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/28/2023 13:30','2/28/2023 20:00')
SET @Employee ='Forth Employee'
set @BusinessDate ='2/26/2023'
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/26/2023 5:10','2/26/2023 7:15:42')
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/26/2023 7:45:00','2/26/2023 8:00')
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/26/2023 8:20','2/26/2023 13:00')
INSERT INTO  @Timecards (Employee, BusinessDate,	StartDate,	EndDate)
Values(@Employee, @BusinessDate,'2/26/2023 13:29','2/26/2023 20:00')

-- fill rules
INSERT INTO @BreakRules (MinBreakMinutes ,	BreakRequiredAfter   ,	TakeBreakWithin)
Values(30,6,5)
INSERT INTO @BreakRules (MinBreakMinutes ,	BreakRequiredAfter   ,	TakeBreakWithin)
Values(30,9,9)
INSERT INTO @BreakRules (MinBreakMinutes ,	BreakRequiredAfter   ,	TakeBreakWithin)
Values(30,12,11)
*/

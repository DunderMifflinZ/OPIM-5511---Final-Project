/*This is to import the data into SAS*/
Data TEAM5.Project;
infile '/folders/myfolders/OPIM-5511---Final-Project/sasuser.v94/Cleaneddata_FermalLogis_event_type1.csv' DLM=',' Firstobs=2 DSD Truncover;
input	ROWNUM Age TurnOver Type BusinessTravel DailyRate Department :$22. DistanceFromHome Edu EducationField :$16.
		EnvironmentSatisfaction Gender HourlyRate JobInvolvement JobLevel JobRole :$25. JobSatisfaction MaritalStatus MonthlyIncome MonthlyRate 
		NumCompaniesWorked OverTime PercentSalaryHike PerformanceRating RelationshipSatisfaction StockOpOptionLevel TotalWorkingYears 
		TrainingTimesLastYear WorkLifeBalance YearsAtCompany YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager AvgBonus $12;
Run;


/*Creating a Column to specify the type of turnover*/

data TEAM5.Project2;
	length turnoverType $25.;
	set TEAM5.Project;

	if turnover=1 then
		;
	if type=1 then
		turnoverType="Retirement";
	else if type=2 then
		turnoverType="Voluntary Resignation";
	else if type=3 then
		turnoverType="Involuntary Resignation";
	else if type=4 then
		turnoverType="Job Termination";
	else
		turnoverType="No turnover";	
	If AvgBonus = "Not Eligible" then AvgBonus=0;
run;

/*Frequency of each type of event*/

proc freq data=TEAM5.Project2;
	where turnoverType ne 'No turnover';
	tables Type /chisq;
run;



/*Creating Columns for the different variables*/

DATA TEAM5.Project2;
	SET TEAM5.Project2;

	IF StockOpOptionLevel>0 then
		StockOp='Yes';
	else
		StockOp='No';

	IF Education=3 or Education=4 or Education=5 then
		HigherEducation='Yes';
	Else
		HigherEducation='No';

	IF JobSatisfaction>=3 then
		EmpSatisfied='Yes';
	Else
		EmpSatisfied='No';

	IF JobInvolvement>=3 then
		EmpInvolved='Yes';
	Else
		EmpInvolved='No';
run;

/*Dropping the first two columns and Over18 EmployeeCount EmployeeNumber  in the data set , as they have only the serial numbers
and 0 variance among data*;

DATA Project2.FermaLogis(DROP=','n X Over18 EmployeeCount EmployeeNumber i);
	SET Project2.FermaLogis;
RUN; */

/*reordering the data to get censored to the begining;

data Project2.FermaLogis;
	retain turnoverType;
	retain YearsAtCompany;
	set Project2.FermaLogis;
run; */

*calculating the cumulative bonus effect;

DATA TEAM5.Project2;
	SET TEAM5.Project2;
	ARRAY bonus_(*) bonus_1-bonus_40;
	ARRAY cum(*) cum1-cum40;
	cum1=bonus_1;

	DO i=2 TO 40;
		cum(i)=cum(i-1)+bonus_(i);
	END;
run;

*Hazard and Survival Curves rate by stratifying with StockOp levels of an employee in fermalogis;
*Retiring employees;

/*mean median min max for the YearsAtCompany*/
PROC MEANS DATA=TEAM5.Project2 n mean median min max; 
	VAR YearsAtCompany;
RUN;

Ods graphics on;
proc lifetest data=TEAM5.Project2 plots=(S H) method=LIFE;
	/*INTERVALS= 10 20 30 40 41;*/
	TIME YearsAtCompany*Type(0, 2, 3, 4);
	strata StockOp;
	title "Survival curves of Retirement type with respect to StockOp";
run;
Ods graphics off;

*Hazard and Survival Curves rate by stratifying with StockOp;
*Voluntary Resignation;
Ods graphics on;
proc lifetest data=TEAM5.Project2 plots=(S H) method=LIFE;
	TIME YearsAtCompany*Type(0, 1, 3, 4);
	strata StockOp;
	title "Survival Curves of  TurnOver Type = 'Voluntary Resignation' Against StockOp";
run;
Ods graphics off;

*Hazard and Survival Curves rate by stratifying with StockOp;
*Involuntary Resignation;
Ods graphics on;
proc lifetest data=TEAM5.Project2 plots=(S H) method=LIFE;
	TIME YearsAtCompany*Type(0, 1, 2, 4);
	strata StockOp;
	title "Survival curves of Involuntary Resignation type with respect to StockOp";
run;
Ods graphics off;

*Hazard and Survival Curves rate by stratifying with StockOp;
*Job Termination;
Ods graphics on;
proc lifetest data=TEAM5.Project2 plots=(S H) method=LIFE;
	TIME YearsAtCompany*Type(0, 1, 2, 3);
	strata StockOp;
	title "Survival curves of Job Termination type with respect to StockOp";
run;
Ods graphics off;

*plotting the Business Travel* ;
Ods graphics on;
Proc sgplot data=TEAM5.Project2;
	vbar TurnoverType /group=BusinessTravel;
	/*Title 'SGPLOT :Business Travel Effect on event';*/
	where TurnoverType ne 'No turnover';
run;
Ods graphics off;

*plotting to identify Job satisfaction effect on event types* ;
Ods graphics on;
Proc sgplot data=TEAM5.Project2;
	vbar TurnoverType /group=EmpSatisfied;
	Title 'SGPLOT :Job satisfaction Analysis';
	where TurnoverType ne 'No turnover';
run;

*plotting to identify Overtime effect on event type*;

Proc sgplot data=TEAM5.Project2;
	vbar TurnoverType /group=Overtime;
	Title 'SGPLOT :Overtime Effect on Turnover types';
	where TurnoverType ne 'No turnover';
run;

*plotting to identify Education effect on event typ ;
Ods graphics on;
Proc sgplot data=TEAM5.Project2;
	vbar TurnoverType /group=EducationField;
	/*Title 'SGPLOT :Education Vs Turnover types';*/
	where TurnoverType ne 'No turnover';
run;

*plotting to identify Gender effect on event typ ;
Ods graphics on;
Proc sgplot data=TEAM5.Project2;
	vbar TurnoverType /group=Gender;
	Title 'SGPLOT :Gender  Vs Turnover types';
	where TurnoverType ne 'No turnover';
run;
Ods graphics off;

*plotting frequency plot to check gender frequency on event type ;
Ods graphics on;
PROC FREQ DATA=TEAM5.Project2;
	TABLES Type*TurnoverType/ CHISQ plots=freqplot;
	TITLE ' Frequnecy Plot: Gender vs Turnover types';
	where TurnoverType ne 'No turnover';
RUN;
Ods graphics off;

*Checking for non proportional variables using assess statement for martingale residuals ;
Ods graphics on;
PROC phreg DATA=TEAM5.Project2;
	where YearsAtCompany>1;
	class BusinessTravel Department EducationField EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime
JobRole JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction StockOpOptionLevel WorkLifeBalance
TrainingTimesLastYear StockOp HigherEducation;
	MODEL YearsAtCompany*Type(0)=Age BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobRole JobSatisfaction DistanceFromHome 
		NumCompaniesWorked OverTime TotalWorkingYears YearsInCurrentRole Jobrole 
		StockOp;
	title PHreg validation model/ties=efron;
	ASSESS PH/resample;
	title PHreg Non Proportional check model;
RUN;
Ods graphics off;
*Checking for time dependent variables/ non proportional with Schoenfeld residuals;
Ods graphics on;
PROC phreg DATA=TEAM5.Project2;
	where YearsAtCompany>1;
	class BusinessTravel Department EducationField EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime
JobRole JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction StockOpOptionLevel WorkLifeBalance
TrainingTimesLastYear StockOp HigherEducation;
	MODEL YearsAtCompany*Type(0)=BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobRole JobSatisfaction DistanceFromHome 
		NumCompaniesWorked OverTime TotalWorkingYears YearsInCurrentRole Jobrole 
		StockOp trainingtimeslastyear /ties=efron;
	OUTPUT OUT=TimeDeptVarMod RESSCH=age BusinessTravel 
		EnvironmentSatisfaction JobInvolvement OverTime JobRole JobSatisfaction 
		DistanceFromHome NumCompaniesWorked OverTime TotalWorkingYears 
		YearsInCurrentRole Jobrole StockOp;
	title PHreg validation model;
RUN;
Ods graphics off;
DATA TimeDeptVarMod;
	SET TEAM5.Project2;
	id=_n_;
RUN;

/*find the correlations with years in thecompany and it's functions */
DATA CorrTimeDeptVarMod;
	SET TimeDeptVarMod;
	logYearsAtCompany=log(YearsAtCompany);
	YearsAtCompany2=YearsAtCompany*YearsAtCompany;
Ods graphics on;
PROC CORR data=CorrTimeDeptVarMod;
	VAR YearsAtCompany logYearsAtCompany YearsAtCompany2;
	WITH DistanceFromHome NumCompaniesWorked TotalWorkingYears YearsInCurrentRole;
RUN;
Ods graphics off;
*Residuals of Number of Companies Worked vs Years At Company;
Ods graphics on;
proc sgplot data=TimeDeptVarMod;
	scatter x=YearsAtCompany y=NumCompaniesWorked / datalabel=id;
	title residuals of Number of Companies Worked vs Years At Company;
	*Residuals of Total Working Years vs Years At Company;
Run;
Ods graphics off;
Ods graphics on;
proc sgplot data=TimeDeptVarMod;
	scatter x=YearsAtCompany y=TotalWorkingYears / datalabel=id;
	title Total Working Years vs Years At Company;
	*Residuals of Years In Current role vs Years At Company;
Run; Ods graphics off;

Ods graphics on;
proc sgplot data=TimeDeptVarMod;
	scatter x=YearsAtCompany y=YearsInCurrentRole/ datalabel=id;
	title Years In Current role vs Years At Company;
run;
Ods graphics off;

*adding interactions for non proportional variables using YearsAtCompany ;

/*PROC phreg DATA=TEAM5.Project2;
	class BusinessTravel Department EducationField EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime
JobRole JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction StockOpOptionLevel WorkLifeBalance
TrainingTimesLastYear StockOp HigherEducation;
	MODEL YearsAtCompany*Type(0)=BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobRole JobSatisfaction DistanceFromHome OverTime 
		Jobrole StockOp  TotalWorkingYears YearsInCurrentRole 
		NumCompaniesWorked TimeIntercatWorkingYears TimeIntercatCurrentRole 
		TimeIntercatNumCompaniesWorked trainingtimeslastyear/ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg interaction model;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmpBonus=cum[YearsAtCompany-1];
	else
		EmpBonus=bonus_1;
RUN;

*Checking number of employees left in each type;

PROC FREQ DATA=Project2.FermaLogis;
	TABLES Type*turnoverType / CHISQ plots=freqplot;
	TITLE 'employees left in each type ';
RUN;
*/
/*Graphically test for linear relation between type hazards*/
DATA Type1Retirement;
	/*create Retirementexit data*/
	SET TEAM5.Project2;
	event=(Type=1);

	turnoverType='Retirement';

DATA Type2VoluntaryResign;
	/*create Voluntary Resignation exit data*/
	SET TEAM5.Project2;
	event=(Type=2);
	turnoverType='Voluntary Resignation';

DATA Type3InvolResign;
	/*create Involuntary Resignation  exit data*/
	SET TEAM5.Project2;
	event=(Type=3);
	turnoverType='Involuntary Resignation';

DATA Type4JobTerm;
	/*create Job Termination  exit data*/
	SET TEAM5.Project2;
	event=(Type=4);
	turnoverType='Job Termination';

Data JobTypeCombo;
	set Type1Retirement Type2VoluntaryResign Type3InvolResign Type4JobTerm;

	/*Graphically test for linear relation between type hazards*/
Ods graphics on;
PROC LIFETEST DATA=JobTypeCombo method=life PLOTS=(LLS);
	/*LLS plot is requested*/
	TIME YearsAtCompany*event(0);
	STRATA turnoverType /diff=all;
RUN;
Ods graphics off;



/*The Below is not yet complete.... Not sure if it will be used as part of the analysis or not*/

*Implementing phreg using programming step for all the turnover types in one model;
Ods graphics on;
PROC phreg DATA=TEAM5.Project2;
	class BusinessTravel Department EducationField EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime
JobRole JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction StockOpOptionLevel WorkLifeBalance
TrainingTimesLastYear StockOp HigherEducation;
	MODEL YearsAtCompany*Type(0)=BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobRole JobSatisfaction DistanceFromHome 
		NumCompaniesWorked OverTime TotalWorkingYears YearsInCurrentRole Jobrole 
		StockOp /*EmpBonus*/ TimeIntercatWorkingYears TimeIntercatCurrentRole 
		TimeIntercatNumCompaniesWorked TrainingTimesLastYear/ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmpBonus=cum[YearsAtCompany-1];
	else
		EmpBonus=bonus_1;
RUN;
Ods graphics off;
*Implementing phreg using programming step for the type Retirement;
Ods graphics on;
PROC phreg DATA=TEAM5.Project2;
	class BusinessTravel Department EducationField EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime
JobRole JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction StockOpOptionLevel WorkLifeBalance
TrainingTimesLastYear StockOp HigherEducation;
	MODEL YearsAtCompany*Type(0, 2, 3, 4)=Age BusinessTravel 
		EnvironmentSatisfaction JobInvolvement OverTime JobRole JobSatisfaction 
		DistanceFromHome NumCompaniesWorked OverTime TotalWorkingYears 
		YearsInCurrentRole Jobrole StockOp TimeIntercatWorkingYears 
		TimeIntercatCurrentRole TimeIntercatNumCompaniesWorked /ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg Retirement Event Type Model;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmpBonus=cum[YearsAtCompany-1];
	else
		EmpBonus=bonus_1;
RUN;
Ods graphics off;

*Implementing phreg using programming step for the type Termination;
Ods graphics on;

RUN;
Ods graphics off;
DATA LogRatioTest_PHregTime;
	Nested=2221.764;
	Retirement=128.640;
	VoluntaryResignation=971.656;
	InVoluntaryResignation=499.934;
	Termination=379.974;
	Total=Retirement+ VoluntaryResignation+InVoluntaryResignation+Termination;
	Diff=Nested - Total;
	P_value=1 - probchi(Diff, 66);
	*30-(30+17+30+29coef. in 3 models - 26coef. in nested;
RUN;

PROC PRINT DATA=LogRatioTest_PHregTime;
	FORMAT P_Value 5.3;
	title total nested vs individual hypothesis;
RUN;
Ods graphics off;
*checking involuntry  resignation and job termination;
Ods graphics on;
PROC phreg DATA=TEAM5.Project2;
	class BusinessTravel Department EducationField EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime
JobRole JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction StockOpOptionLevel WorkLifeBalance
TrainingTimesLastYear StockOp HigherEducation;
	MODEL YearsAtCompany*Type(0, 1, 2)=BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobSatisfaction DistanceFromHome NumCompaniesWorked 
		OverTime TotalWorkingYears YearsInCurrentRole Jobrole StockOp  
		TimeIntercatWorkingYears TimeIntercatCurrentRole 
		TimeIntercatNumCompaniesWorked /ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg model for involuntary resignation and job termination;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmpBonus=cum[YearsAtCompany-1];
	else
		EmpBonus=bonus_1;
RUN;


*Implementing phreg using programming step for the type Voluntary Resignation/ Turnover;

PROC phreg DATA=TEAM5.Project2;
	class BusinessTravel Department EducationField EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime
JobRole JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction StockOpOptionLevel WorkLifeBalance
TrainingTimesLastYear StockOp HigherEducation;
	MODEL YearsAtCompany*Type(0, 1, 3, 4)=BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobSatisfaction DistanceFromHome NumCompaniesWorked 
		OverTime TotalWorkingYears YearsInCurrentRole Jobrole StockOp  
		TimeIntercatWorkingYears TimeIntercatCurrentRole 
		TimeIntercatNumCompaniesWorked /ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg model for involuntary resignation and job termination;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmpBonus=cum[YearsAtCompany-1];
	else
		/*EmpBonus=cum1;*/
		EmpBonus=bonus_1;
RUN;



Ods graphics off;
*checking involuntry  resignation and job termination;

DATA LRTest;
	Nested=916.165;
	InVoluntaryResignation=499.944;
	Termination=379.74;
	Total=InVoluntaryResignation+Termination;
	Diff=Nested - Total;
	P_value=1 - probchi(Diff, 30);
	*26*2coef. in 2 models - 26coef. in nested;
RUN;

*checking involuntry  resignation and job termination;

PROC PRINT DATA=LRTest;
	FORMAT P_Value 5.3;
	title nested(involuntry, termination) vs individual hypothesis;
RUN;

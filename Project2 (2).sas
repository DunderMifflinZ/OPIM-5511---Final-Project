/*This is to import the data into SAS*/
Data TEAM5.Project;
infile '/folders/myfolders/sasuser.v94/Cleaneddata_FermalLogis_event_type1.csv' DLM=',' Firstobs=2 DSD Truncover;
input	ROWNUM Age Tur0ver Type BusinessTravel DailyRate Department :$22. DistanceFromHome Edu EducationField :$16.
		EnvironmentSatisfaction Gender HourlyRate JobInvolvement JobLevel JobRole :$25. JobSatisfaction MaritalStatus MonthlyIncome MonthlyRate 
		NumCompaniesWorked OverTime PercentSalaryHike PerformanceRating RelationshipSatisfaction StockOptionLevel TotalWorkingYears 
		TrainingTimesLastYear WorkLifeBalance YearsAtCompany YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager AvgBonus $12;
Run;

Proc Print Data=team5.project;
Run;


/*Frequecy of Turnover 0 = No turnover 1= Turnover */

Proc Freq data=TEAM5.Project;
	tables Tur0ver /chisq;
	Title Bold "Frequency of Turnover";
	Footnote "0 = No Turnover, 1 = Turnover"
	Run;
	
PROC FREQ DATA=TEAM5.Project2;
	TABLES Gender*Tur0ver/ CHISQ plots=freqplot;
	TITLE ' Frequnecy Plot: Gender vs Turnover';
RUN;
	
/*The Code Below is to create the necessary Categorical Columns using the data dictionary*/
DATA TEAM5.Project2;
	SET TEAM5.Project;
	Length EnvirRatingCat $9 EduLevel $13 PerformanceCategory $11 RelationshipCategory $9 JInvolvementCategory $9 WLBCategory $6;

	If Edu=1 then EduLevel="Below College";
	Else If Edu=2 then EduLevel="College";
	Else If Edu=3 then EduLevel="Bachelor";
	Else If Edu=4 then EduLevel="Master";
	Else If Edu=5 then EduLevel="Doctor";
	
	If EnvironmentSatisfaction=1 then EnvirRatingCat="Low";
	Else If EnvironmentSatisfaction=2 then EnvirRatingCat="Medium";
	Else If EnvironmentSatisfaction=3 then EnvirRatingCat="High";
	Else If EnvironmentSatisfaction=4 then EnvirRatingCat ="Very High";
	
	If PerformanceRating =1 then PerformanceCategory="Low";
	Else If PerformanceRating=2 then PerformanceCategory="Good";
	Else If PerformanceRating=3 then PerformanceCategory="Excellent";
	Else If PerformanceRating=4 then PerformanceCategory ="Outstanding";
	
	If RelationshipSatisfaction=1 then RelationshipCategory="Low";
	Else If RelationshipSatisfaction=2 then RelationshipCategory="Medium";
	Else If RelationshipSatisfaction=3 then RelationshipCategory="High";
	Else If RelationshipSatisfaction=4 then RelationshipCategory ="Very High"; 
	
	If JobInvolvement=1 then JInvolvementCategory="Low";
	Else If JobInvolvement=2 then JInvolvementCategory="Medium";
	Else If JobInvolvement=3 then JInvolvementCategory="High";
	Else If JobInvolvement=4 then JInvolvementCategory ="Very High"; 
	
	If WorkLifeBalance=1 then WLBCategory="Bad";
	Else If WorkLifeBalance=2 then WLBCategory="Good";
	Else If WorkLifeBalance=3 then WLBCategory="Better";
	Else If WorkLifeBalance=4 then WLBCategory ="Best";
	
	If AvgBonus = "Not Eligible" then AvgBonus=0;
	
Run;

/*reordering the data to get censored to the begining*/

data TEAM5.Project2;
	retain Type;
	retain YearsAtCompany;
	set TEAM5.Project2;
Run;

/*mean median min max for the YearsAtCompany*/
PROC MEANS DATA=TEAM5.Project2 n mean median min max; 
	VAR YearsAtCompany;
RUN;

	/*Hazard and Survival Curves rate by stratifying with Education Level of an employee in fermalogis*/

ods graphics on;	
proc Lifetest data=TEAM5.Project2 plots=(S H) method=LIFE;
	TIME YearsAtCompany*Type(0, 2, 3, 4);
	strata EduLevel /adjust=tukey;
	title "Survival curves of Turnover type with respect to Education Level";
Run;
ods graphics off;

/*Hazard and Survival Curves rate by stratifying with Gender of an employee in fermalogis*/
ods graphics on;	
proc Lifetest data=TEAM5.Project2 plots=(S H) method=LIFE;
	TIME YearsAtCompany*Type(0, 2, 3, 4);
	strata Gender /adjust=tukey;
	title "Survival curves of Turnover type with respect to Gender";
Run;
ods graphics off;

/*Hazard and Survival Curves rate by stratifying with EnvironmentSatisfaction(EnvirRatingCat)*/
ods graphics on;	
proc Lifetest data=TEAM5.Project2 plots=(S H) method=LIFE;
	TIME YearsAtCompany*Type(0, 2, 3, 4);
	strata EnvirRatingCat /adjust=tukey;
	title "Survival curves of Turnover type with respect to EnvironmentSatisfactionl";
Run;
ods graphics off;

/*Hazard and Survival Curves rate by stratifying with PerformanceRating(PerformanceCategory)*/
ods graphics on;	
proc Lifetest data=TEAM5.Project2 plots=(S H) method=LIFE;
	TIME YearsAtCompany*Type(0, 2, 3, 4);
	strata PerformanceCategory /adjust=tukey;
	title "Survival curves of Turnover type with respect to PerformanceRating";
Run;
ods graphics off;

/*Hazard and Survival Curves rate by stratifying with RelationshipSatisfaction(RelationshipCategory)*/
ods graphics on;	
proc Lifetest data=TEAM5.Project2 plots=(S H) method=LIFE;
	TIME YearsAtCompany*Type(0, 2, 3, 4);
	strata RelationshipCategory /adjust=tukey;
	title "Survival curves of Turnover type with respect to RelationshipSatisfaction";
Run;
ods graphics off;

/*Hazard and Survival Curves rate by stratifying with JobInvolvement(PerformanceCategory)*/
ods graphics on;	
proc Lifetest data=TEAM5.Project2 plots=(S H) method=LIFE;
	TIME YearsAtCompany*Type(0, 2, 3, 4);
	strata JInvolvementCategory /adjust=tukey;
	title "Survival curves of Turnover type with respect to JobInvolvement";
Run;
ods graphics off;

/*Hazard and Survival Curves rate by stratifying with WorkLifeBalance(WLBCategory)*/
ods graphics on;	
proc Lifetest data=TEAM5.Project2 plots=(S H) method=LIFE;
	TIME YearsAtCompany*Type(0, 2, 3, 4);
	strata WLBCategory /adjust=tukey;
	title "Survival curves of Turnover type with respect to WorkLifeBalance";
Run;
ods graphics off;

/*Gender Turnover Frequency plot*/
PROC FREQ DATA=TEAM5.Project2;
	TABLES Gender*Tur0ver/ CHISQ plots=freqplot;
	TITLE ' Frequnecy Plot: Gender vs Turnover';
RUN;

/*we are finding out the likelihood values of models with different distributions
and writing them into Compare_Models DATA Step below.*/
PROC LIFEREG DATA=TEAM5.Project2;
	CLASS EduLevel;
	MODEL YearsAtCompany*Type(0, 2, 3, 4) = Gender Age DistanceFromHome JobLevel OverTime MaritalStatus 
						   WorkLifeBalance YearsInCurrentRole HourlyRate RelationshipSatisfaction 
						   MonthlyIncome EduLevel/distribution=exponential;


PROC LIFEREG DATA=TEAM5.Project2;
	CLASS EduLevel;
	MODEL YearsAtCompany*Type(0, 2, 3, 4) = Gender Age DistanceFromHome JobLevel OverTime MaritalStatus 
						   WorkLifeBalance YearsInCurrentRole HourlyRate RelationshipSatisfaction 
						   MonthlyIncome EduLevel/distribution=weibull;
						   
PROC LIFEREG DATA=TEAM5.Project2;
	CLASS EduLevel;
	MODEL YearsAtCompany*Type(0, 2, 3, 4) = Gender Age DistanceFromHome JobLevel OverTime MaritalStatus 
						   WorkLifeBalance YearsInCurrentRole HourlyRate RelationshipSatisfaction 
						   MonthlyIncome EduLevel/distribution=lognormal;
						   
PROC LIFEREG DATA=TEAM5.Project2;
	CLASS EduLevel;
	MODEL YearsAtCompany*Type(0, 2, 3, 4) = Gender Age DistanceFromHome JobLevel OverTime MaritalStatus 
						   WorkLifeBalance YearsInCurrentRole HourlyRate RelationshipSatisfaction 
						   MonthlyIncome EduLevel/distribution=gamma;
						   


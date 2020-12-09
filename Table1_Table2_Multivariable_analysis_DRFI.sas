/***************Choose Libname***************/ 

	Libname TSiGr '//.psf/Home/Documents\My SAS Files\Analysis\Tumor Grade, Size, PR and Ki67';

/***************Import STO-3***************/ 

	Proc import datafile= "\\.psf\Home\Documents\My SAS Files\data\Sto3_uppdfu_190312_Final.xlsx"
	Out=TSiGr.org DBMS=XLSX replace;
	Run; 


/*************** Select only ER positive patients ***************/  

	Data TSiGr.TERpos;
	Set TSiGr.org;
	If ERstatus_WT='Positive';
	run;

/*************** Select only HER2 negative patients ***************/ 

	Data TSiGr.TERposHER2neg;
	Set TSiGr.TERpos;
	If HER2status_WT='Negative';
	run;

	
/*************** TUMOR SIZE ***************/  

	/* Only select patients that have tumor size */

	Data TSiGr.TsizeERposHER2negnomissing;
	Set TSiGr.TERposHER2neg;
	If size20nm = '99' then delete;
	run;

	/* Create tumor size categories */  

	Proc sort data=TSiGr.TsizeERposHER2negnomissing;
	by MMNM;
	run;

	Proc print data=TSiGr.TsizeERposHER2negnomissing;
	var MMNM;
	run; 

	Data TSiGr.TsizeERposHER2negnomissingCat;
	set TSiGr.TsizeERposHER2negnomissing;
 
	Tsize=.; 
	If MMNM =<10 then Tsize=0;
	Else if 11 <= MMNM =< 20 then Tsize=1;
 	Else if MMNM >20 then Tsize=2;
	run;

	Proc print data=TSiGr.TsizeERposHER2negnomissingCat;
	var MMNM Tsize;
	run; 

	Proc freq data=TSiGr.TsizeERposHER2negnomissingCat;
	tables Tsize;
	run;

	/*Number of events*/

	Proc freq data=TSiGr.TsizeERposHER2negnomissingCat;
	tables MetBC25yr_16*Tsize;
	run;

	/*Cox proportional hazard analysis - Metastasis free survival*/

	Proc phreg data=TSiGr.TsizeERposHER2negnomissingCat; 
	Class Tsize (ref='2' param=ref) Tamoxifen (ref='0' param=ref) PRStatus_WT(ref='Positive' param=ref)Ki67Status_WT(ref='Negative' param=ref)
	Gradenm(ref='2' param=ref)YR1_5(ref='3' param=ref)Age10(ref='2' param=ref);
	Model Met_25yr_16*MetBC25yr_16(0)= Tsize Tamoxifen PRStatus_WT KI67Status_WT Gradenm YR1_5 Age10/ risklimits;
	run;

	/*Select only T1a/bN0*/

	Data TSiGr.T1a;
	set TSiGr.TsizeERposHER2negnomissingCat;
	If Tsize=0;
	run;

	/*number treated vs untreated*/

	proc freq data= TSiGr.T1a;
	tables Tsize*Tamoxifen;
	run;

	/*number of events*/

	proc freq data= TSiGr.T1a;
	tables MetBC25yr_16*Tamoxifen;
	run;

	/*Cox proportional hazard analysis - Metastasis free survival*/

	Proc phreg data=TSiGr.T1a; 
	Class Tamoxifen (ref='0' param=ref) PRStatus_WT(ref='Positive' param=ref)Ki67Status_WT(ref='Negative' param=ref)
		Gradenm(ref='2' param=ref) YR1_5(ref='3' param=ref)Age10(ref='2' param=ref);
	Model Met_25yr_16*MetBC25yr_16(0)= Tamoxifen PRstatus_WT Ki67status_WT Gradenm YR1_5 age10/risklimits;
	Run;


	/*Select only T1cN0*/

	Data TSiGr.T1c;
	set TSiGr.TsizeERposHER2negnomissingCat;
	If Tsize=1;
	run;

	/*Treated vs. untreated*/

	proc freq data= TSiGr.T1c;
	tables Tsize*Tamoxifen;
	run;

	/*number of events*/

	proc freq data= TSiGr.T1c;
	tables MetBC25yr_16*Tamoxifen;
	run;

	/*Cox proportional hazard analysis - Metastasis free survival*/

	Proc phreg data=TSiGr.T1c; 
	Class Tamoxifen (ref='0' param=ref) PRStatus_WT(ref='Positive' param=ref)Ki67Status_WT(ref='Negative' param=ref)
		Gradenm(ref='2' param=ref) YR1_5(ref='3' param=ref)Age10(ref='2' param=ref);
	Model Met_25yr_16*MetBC25yr_16(0)= Tamoxifen PRstatus_WT Ki67status_WT Gradenm YR1_5 age10/risklimits;
	Run;

	/*Select only T2N0*/

	Data TSiGr.T2N0;
	set TSiGr.TsizeERposHER2negnomissingCat;
	If Tsize=2;
	run;

	/*treated vs untreated*/

	proc freq data= TSiGr.T2N0;
	tables Tsize*Tamoxifen;
	run;

	/*number of events*/

	proc freq data= TSiGr.T2N0;
	tables MetBC25yr_16*Tamoxifen;
	run;

	/*Cox proportional hazard analysis - Metastasis free survival*/

	Proc phreg data=TSiGr.T2N0; 
	Class Tamoxifen (ref='0' param=ref) PRStatus_WT(ref='Positive' param=ref)Ki67Status_WT(ref='Negative' param=ref)
		Gradenm(ref='2' param=ref) YR1_5(ref='3' param=ref)Age10(ref='2' param=ref);
	Model Met_25yr_16*MetBC25yr_16(0)= Tamoxifen PRstatus_WT Ki67status_WT Gradenm YR1_5 age10/risklimits;
	Run;

/*************** TUMOR GRADE ***************/  

	/* Only select patients that have tumor grade */

	Data TSiGr.TgradeERposHER2negnomissing;
	Set TSiGr.TERposHER2neg;
	If Gradenm = 99 then delete;
	run;

	/*Frequency table for the variable tumor grade*/

	proc freq data=TSiGr.TgradeERposHER2negnomissing;                                                                             
	tables Gradenm;
	run;

	/*Number of events*/

	proc freq data=TSiGr.TgradeERposHER2negnomissing;                                                                             
	tables MetBC25yr_16*Gradenm;
	run;


	/*Cox proportional hazard analysis - Metastasis free survival*/

	Proc phreg data=TSiGr.TgradeERposHER2negnomissing; 
	Class Gradenm(ref='3' param=ref) Tamoxifen (ref='0' param=ref) PRStatus_WT(ref='Positive' param=ref)Ki67Status_WT(ref='Negative' param=ref)
	size20nm(ref='1' param=ref)YR1_5(ref='3' param=ref)Age10(ref='2' param=ref);
	Model Met_25yr_16*MetBC25yr_16(0)= Gradenm Tamoxifen PRStatus_WT KI67Status_WT Size20nm YR1_5 Age10/ risklimits;
	run;

	/*Select only Tumor grade 1*/

	Data TSiGr.grade1;
	set TSiGr.TgradeERposHER2negnomissing;
	If Gradenm=1;
	run;

	/*Treated vs. Untreated*/

	proc freq data= TSiGr.grade1;
	tables Gradenm*Tamoxifen;
	run;

	/*Number of events*/

	proc freq data= TSiGr.grade1;
	tables MetBC25yr_16*Tamoxifen;
	run;

	/*Cox proportional hazard analysis - Metastasis free survival*/

	Proc phreg data=TSiGr.grade1; 
	Class Tamoxifen (ref='0' param=ref) PRStatus_WT(ref='Positive' param=ref)Ki67Status_WT(ref='Negative' param=ref)
	size20nm(ref='0' param=ref)YR1_5(ref='3' param=ref)Age10(ref='2' param=ref);
	Model Met_25yr_16*MetBC25yr_16(0)= Tamoxifen PRStatus_WT KI67Status_WT Size20nm YR1_5 Age10/ risklimits;
	run;

	/*Select only Tumor grade 2*/

	Data TSiGr.grade2;
	set TSiGr.TgradeERposHER2negnomissing;
	If Gradenm=2;
	run;

	/*Treated vs. untreated*/

	proc freq data= TSiGr.grade2;
	tables Gradenm*Tamoxifen;
	run;

	/*Number of events*/

	proc freq data= TSiGr.grade2;
	tables MetBC25yr_16*Tamoxifen;
	run;

	/*Cox proportional hazard analysis - Metastasis free survival*/

	Proc phreg data=TSiGr.grade2; 
	Class Tamoxifen (ref='0' param=ref) PRStatus_WT(ref='Positive' param=ref)Ki67Status_WT(ref='Negative' param=ref)
	size20nm(ref='0' param=ref)YR1_5(ref='3' param=ref)Age10(ref='2' param=ref);
	Model Met_25yr_16*MetBC25yr_16(0)= Tamoxifen PRStatus_WT KI67Status_WT Size20nm YR1_5 Age10/ risklimits;
	run;

	/*Select only Tumor grade 3*/

	Data TSiGr.grade3;
	set TSiGr.TgradeERposHER2negnomissing;
	If Gradenm=3;
	run;

	/*Treated vs Untreated*/

	proc freq data= TSiGr.grade3;
	tables Gradenm*Tamoxifen;
	run;

	/*Number of events*/

	proc freq data= TSiGr.grade3;
	tables MetBC25yr_16*Tamoxifen;
	run;

	/*Cox proportional hazard analysis - Metastasis free survival*/

	Proc phreg data=TSiGr.grade3; 
	Class Tamoxifen (ref='0' param=ref) PRStatus_WT(ref='Positive' param=ref)Ki67Status_WT(ref='Negative' param=ref)
	size20nm(ref='0' param=ref)YR1_5(ref='3' param=ref)Age10(ref='2' param=ref);
	Model Met_25yr_16*MetBC25yr_16(0)= Tamoxifen PRStatus_WT KI67Status_WT Size20nm YR1_5 Age10/ risklimits;
	run;
	

/*************** PR status ***************/  

	/* Only select patients that have PR status : 559 observations */

	Data TSiGr.PRERposHER2negnomissing;
	Set TSiGr.TERposHER2neg;
	If PrStatus_WT= 'Unknown' then delete;
	run;

	/*Frequency table for the variable PR*/

	proc freq data=TSiGr.PRERposHER2negnomissing;                                                                             
	tables PrStatus_WT;
	run;

	/*Number of events*/

	proc freq data=TSiGr.PRERposHER2negnomissing;                                                                             
	tables MetBC25yr_16*PrStatus_WT;
	run;
 
	/*Cox proportional hazard analysis - Metastasis free survival*/

	Proc phreg data=TSiGr.PRERposHER2negnomissing; 
	Class Prstatus_WT(ref='Negative' param=ref)Tamoxifen(ref='0' param=ref) Ki67status_WT (ref='Negative' param=ref)
		size20nm(ref='0' param=ref)Gradenm(ref='1' param=ref)YR1_5(ref='3' param=ref)Age10(ref='2' param=ref);
	Model Met_25yr_16*MetBC25yr_16(0)= PRStatus_WT Tamoxifen KI67Status_WT Size20nm Gradenm YR1_5 Age10/ risklimits;
	run;

	/*Select only PR positive*/

	Data TSiGr.PRpos;
	set TSiGr.PRERposHER2negnomissing;
	If Prstatus_WT='Positive';
	run;

	/*treated vs. untreated*/

	proc freq data= TSiGr.PRpos;
	tables Prstatus_WT*Tamoxifen;
	run;

	/*Number of events*/

	proc freq data= TSiGr.PRpos;
	tables MetBC25yr_16*Tamoxifen;
	run;

	/*Cox proportional hazard analysis - Metastasis free survival*/

	Proc phreg data=TSiGr.PRpos; 
	Class Tamoxifen(ref='0' param=ref) Ki67status_WT (ref='Negative' param=ref)
		size20nm(ref='0' param=ref)Gradenm(ref='1' param=ref)YR1_5(ref='3' param=ref)Age10(ref='2' param=ref);
	Model Met_25yr_16*MetBC25yr_16(0)=  Tamoxifen KI67Status_WT Size20nm Gradenm YR1_5 Age10/ risklimits;
	run;

	
	/*Select only PR negative*/

	Data TSiGr.PRneg;
	set TSiGr.PRERposHER2negnomissing;
	If Prstatus_WT='Negative';
	run;

	/*number of events*/

	proc freq data= TSiGr.PRneg;
	tables Tamoxifen;
	run;

	proc freq data= TSiGr.PRneg;
	tables MetBC25yr_16*Tamoxifen;
	run;

	/*Cox proportional hazard analysis - Metastasis free survival*/

	Proc phreg data=TSiGr.PRneg; 
	Class Tamoxifen(ref='0' param=ref) Ki67status_WT (ref='Negative' param=ref)
		size20nm(ref='0' param=ref)Gradenm(ref='1' param=ref)YR1_5(ref='3' param=ref)Age10(ref='2' param=ref);
	Model Met_25yr_16*MetBC25yr_16(0)=  Tamoxifen KI67Status_WT Size20nm Gradenm YR1_5 Age10/ risklimits;
	run;


/*************** KI67 status  ***************/  

	/* Only select patients that have KI67 status : 535 observations */

	Data TSiGr.Ki67ERposHER2negnomissing;
	Set TSiGr.TERposHER2neg;
	If Ki67Status_WT= 'Unknown' then delete;
	run;

	/*Frequency table for the variable tumor grade*/

	proc freq data=TSiGr.Ki67ERposHER2negnomissing;                                                                             
	tables Ki67Status_WT;
	run;

	/*Number of events*/

	proc freq data=TSiGr.Ki67ERposHER2negnomissing;                                                                             
	tables MetBC25yr_16*Ki67Status_WT;
	run;

	Proc phreg data=TSiGr.Ki67ERposHER2negnomissing; 
	Class Ki67status_WT (ref='Negative' param=ref) Tamoxifen(ref='0' param=ref) Prstatus_WT(ref='Negative' param=ref)
		size20nm(ref='0' param=ref)Gradenm(ref='1' param=ref)YR1_5(ref='3' param=ref)Age10(ref='2' param=ref);
	Model Met_25yr_16*MetBC25yr_16(0)= KI67Status_WT Tamoxifen PRStatus_WT  Size20nm Gradenm YR1_5 Age10/ risklimits;
	run;

	/*Select only KI67 positive*/

	Data TSiGr.KI67pos;
	set TSiGr.Ki67ERposHER2negnomissing;
	If Ki67status_WT='Positive';
	run;

	/*Treated vs untreated*/

	proc freq data= TSiGr.KI67pos;
	tables Tamoxifen;
	run;

	/*Number of events*/

	proc freq data= TSiGr.KI67pos;
	tables MetBC25yr_16*Tamoxifen;
	run;

	/*Cox proportional hazard analysis - Metastasis free survival*/

	Proc phreg data=TSiGr.KI67pos;
	Class Tamoxifen(ref='0' param=ref) Prstatus_WT(ref='Negative' param=ref)
		size20nm(ref='0' param=ref)Gradenm(ref='1' param=ref)YR1_5(ref='3' param=ref)Age10(ref='2' param=ref);
	Model Met_25yr_16*MetBC25yr_16(0)= Tamoxifen PRStatus_WT  Size20nm Gradenm YR1_5 Age10/ risklimits;
	run;

	/*Select only KI67 negative*/

	Data TSiGr.KI67neg;
	set TSiGr.Ki67ERposHER2negnomissing;
	If Ki67status_WT='Negative';
	run;

	/*Treated vs untreated*/

	proc freq data= TSiGr.KI67neg;
	tables Ki67status_WT*Tamoxifen;
	run;

	/*Number of events*/

	proc freq data= TSiGr.KI67neg;
	tables MetBC25yr_16*Tamoxifen;
	run;

	/*Cox proportional hazard analysis - Metastasis free survival*/

	Proc phreg data=TSiGr.KI67neg;
	Class Tamoxifen(ref='0' param=ref) Prstatus_WT(ref='Negative' param=ref)
		size20nm(ref='0' param=ref)Gradenm(ref='1' param=ref)YR1_5(ref='3' param=ref)Age10(ref='2' param=ref);
	Model Met_25yr_16*MetBC25yr_16(0)= Tamoxifen PRStatus_WT  Size20nm Gradenm YR1_5 Age10/ risklimits;
	run;

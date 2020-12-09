/***************Choose Libname****************/

Libname TSiGr "\\.psf\Home\Documents\My SAS Files\Analysis\Tumor Grade, Size, PR and Ki67";


/***************Import STO-3 ***************/ 

	Proc import datafile= "\\.psf\Home\Documents\My SAS Files\data\Sto3_uppdfu_190312_Final.xlsx"
	Out=TSiGr.org DBMS=XLSX replace;
	Run; 

/*************** Select only ER positive patients ***************/  

	Data TSiGr.TERpos;
	Set TSiGr.org;
	If ERstatus_WT='Positive';
	run;

/*************** Select only HER2 negative patients  ***************/ 

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

/*************** TUMOR GRADE ***************/  

	/* Only select patients that have tumor grade */

	Data TSiGr.TgradeERposHER2negnomissing;
	Set TSiGr.TERposHER2neg;
	If Gradenm = 99 then delete;
	run;

/*************** PR status ***************/  

	/* Only select patients that have PR status */

	Data TSiGr.PRERposHER2negnomissing;
	Set TSiGr.TERposHER2neg;
	If PrStatus_WT= 'Unknown' then delete;
	run;


/*************** KI67 status ***************/  

	/* Only select patients that have KI67 status */

	Data TSiGr.Ki67ERposHER2negnomissing;
	Set TSiGr.TERposHER2neg;
	If Ki67Status_WT= 'Unknown' then delete;
	run;

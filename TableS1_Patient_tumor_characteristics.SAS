/***************Choose Libname***************/ 

Libname TSiGr '//.psf/Home/Documents\My SAS Files\Analysis\Tumor Grade, Size, PR and Ki67';

/***************Import STO-3 : 727 observations ***************/ 

	Proc import datafile= "\\.psf\Home\Documents\My SAS Files\data\Sto3_uppdfu_190312_Final.xlsx"
	Out=TSiGr.org DBMS=XLSX replace;
	Run; 


/*************** Select only ER positive patients : 593 observations ***************/  

	Data TSiGr.TERpos;
	Set TSiGr.org;
	If ERstatus_WT='Positive';
	run;

/*************** Select only HER2 negative patients : 565 observations ***************/ 

	Data TSiGr.TERposHER2neg;
	Set TSiGr.TERpos;
	If HER2status_WT='Negative';
	run;


/*************** Patient and tumor characteristics at primary breast cancer diagnosis by treatment arm : 565 observations  ***************/  

/*Tamoxifen*/

	proc freq data=TSiGr.TERposHER2neg;
	tables tamoxifen /fisher;
	run;

/*Calendar period of primary diagnosis*/

	proc freq data=TSiGr.TERposHER2neg;
	tables yr1_10*tamoxifen /fisher;
	run;

/*Age at primary diagnosis, year*/

	proc freq data=TSiGr.TERposHER2neg;
	tables age10*tamoxifen /fisher;
	run;

/*Tumor Size*/

	/*Create categories for Tumor size*/

	/* Only select patients that have tumor size : 559 observations */

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

	/*Tsize frequency*/

	proc freq data=TSiGr.TsizeERposHER2negnomissingCat;
	tables Tsize*tamoxifen /fisher;
	run;

/*Tumor Grade*/

	/*Radera grade with unknown status*/
	
	Data TSiGr.TERposHER2neg_nomissinggrade;
	Set TSiGr.TERposHER2neg;
	If gradenm=99 then delete;
	run;

	/*Tumor grade frequency*/

	proc freq data=TSiGr.TERposHER2neg_nomissinggrade;
	tables gradenm*tamoxifen /fisher;
	run;

/*Progesterone receptor - PR*/

	/*Radera PR with unknown status*/

	Data TSiGr.TERposHER2neg_nomissingPR;
	Set TSiGr.TERposHER2neg;
	If PRstatus_WT='Unknown' then delete;
	run;

	/*PR frequency*/

	proc freq data=TSiGr.TERposHER2neg_nomissingPR;
	tables PRstatus_WT*tamoxifen /fisher;
	run;


/*KI-67*/

	/*Radera Ki-67 with unknown status*/

	Data TSiGr.TERposHER2neg_nomissingki67;
	Set TSiGr.TERposHER2neg;
	If ki67status_WT='Unknown' then delete;
	run;

	/*Ki67 frequency*/

	proc freq data=TSiGr.TERposHER2neg_nomissingki67;
	tables Ki67status_WT*tamoxifen /fisher;
	run;

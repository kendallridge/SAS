/* model validation */

/*
variables from model:
	- response vars
	- predictor vars
	- method
	- select
	- stop
	- choose

variables from glmselect:
	- obs read
	- obs used
	- step
	- variable
	- paramEstimates
	- criterionValue
*/

/*cleaning modelInfo table*/
proc sql;
	create table modelInfoB as
	select Label1, cValue1
	from work.modelinfo
	where cValue1 eq 'AIC'
		or cValue1 eq 'Stepwise';
quit;

proc transpose data=modelInfoB 
	out=modelInfoC(drop=_name_);
	var cValue1;
	id Label1;
run;

/*cleaning NObs table*/
proc sql;
	create table NobsB as
	select NObsRead, NObsUsed
	from work.NObs
	where label like '%Read';
quit;

/*cleaning parameters table

join paramters and selection table on
parameters.effect and select.effectentered
*/

proc sql;
	create table paramselect as
	select step, parameter, criterionvalue, 
quit;

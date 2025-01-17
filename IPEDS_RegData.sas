libname IPEDS '~/IPEDS';
libname GITHUB '~/GITHUB';
%let rc=%sysfunc(dlgcdir('~'));
options fmtsearch=(IPEDS);

/* 
gradrates table:
	unitid, cohort, rate 

characteristics table:
	iclevel, control, hloffer, locale, instcat
	c21enprf, cbsatype

aid calculated columns:
	GrantRate > uagrntn / scfa2
	GrantAvg > uagrntt / scfa2
	PellRate > upgrntn / scfa2
	LoanRate > ufloann / scfa2
	LoanAvg > ufloant / scfa2

tuition and costs table:
	tuition1, fee1, tuition2, fee2, tuition3, fee3
	room, roomcap, board, roomamt, boardamt

salary + aid calculated columns:
	AvgSalary > sa09mot--Salaries / sa09mct--Salaries
	StuFacRatio > scfa2--Aid / sa09mct--Salaries

 */

proc sql;
	create table regdata as
	select 
		/*grad rate columns*/
		gr.unitid, cohort, rate,

		/*characteristics columns*/
		iclevel format=iclevel., 
		control format=control.,
		hloffer format=hloffer.,
		locale format=locale.,
		instcat format=instcat., 
		c21enprf format=c21enprf.,
		cbsatype format=cbsatype.,

		/*aid calculated columns*/
		(uagrntn/scfa2) as GrantRate format=percent8.2,
		(uagrntt/scfa2) as GrantAvg,
		(upgrntn/scfa2) as PellRate format=percent8.2,
		(ufloann/scfa2) as LoanRate format=percent8.2,
		(ufloant/scfa2) as LoanAvg,

		/*tuition and costs columns*/
		tuition1, fee1, tuition2, fee2, tuition3, fee3,
		room format=room., roomcap, board format=board.,
		roomamt, boardamt,

		/*salary + aid calculated columns*/
		(sa09mot/sa09mct) as AvgSalary,
		(scfa2/sa09mct) as StuFacRatio format=8.1
	
	from ipeds.gradrates as gr
		inner join (ipeds.characteristics as c
			inner join (ipeds.aid as a 
				inner join (ipeds.tuitionandcosts as tc
					inner join ipeds.salaries as s
						on tc.unitid = s.unitid)
					on a.unitid = tc.unitid)
			on c.unitid=a.unitid)
		on gr.unitid = c.unitid;
quit;


proc copy in=work out=git;
    select regdata;
run; 
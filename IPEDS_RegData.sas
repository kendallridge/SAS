libname IPEDS '~/IPEDS';
libname GITHUB '~/GITHUB';
%let rc=%sysfunc(dlgcdir('~'));
options fmtsearch=(IPEDS);

/*lets you run code file without opening it

could have issues with file structure/ folders, etc*/
%include '~/IPEDS/Graduation Spec Generator.sas';

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
	CALCULATED:
	InDistrictT > 1 if tuition1 is different from tuition2, 0 if not
	InDistrictTDiff > Absolute difference between tuition2 and tuition1
	InDistrictF > 1 if fee1 is different from fee2, 0 if not
	InDistrictFDiff > Absolute difference between fee2 and fee1
	InStateT > Rename of Tuition2
	InStateF > Rename of Fee2
	OutStateT > 1 if tuition3 is different from tuition2, 0 if not
	OutStateTDiff > Absolute difference between tuition3 and tuition2
	OutStateF > 1 if fee3 is different from fee2, 0 if not
	OutStateFDiff > Absolute difference between fee3 and fee2
	Housing > room; Map to 0 for no, 1 for yes
	ScaledHousingCap > roomcap / scfa2 (from Aid table)
	board > Remap no to zero, leave other levels as in original encoding
	roomamt > Change missings to zero when board is no
	boardamt > Change missings to zero when board is no

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
		iclevel, 
		control,
		hloffer,
		locale,
		instcat, 
		c21enprf,
		cbsatype,

		/*aid calculated columns*/
		(uagrntn/scfa2) as GrantRate format=percent8.2,
		(uagrntt/scfa2) as GrantAvg,
		(upgrntn/scfa2) as PellRate format=percent8.2,
		(ufloann/scfa2) as LoanRate format=percent8.2,
		(ufloant/scfa2) as LoanAvg,

		/*tuition and costs columns*/
		case 
			when tuition1 eq tuition2 then 0
			when tuition1 ne tuition2 then 1
		end as InDistrictT,
		(abs(tuition2 - tuition1)) as InDistrictTDiff,
		case 
			when fee1 eq fee2 then 0
			when fee1 ne fee2 then 1
		end as InDistrictF,
		(abs(fee2 - fee1)) as InDistrictFDiff,
		tuition2 as InStateT, fee2 as InStateF,
		case 
			when tuition3 eq tuition2 then 0
			when tuition3 ne tuition2 then 1
		end as OutStateT,
		(abs(tuition3 - tuition2)) as OutStateTDiff,
		case 
			when fee3 eq fee2 then 0
			when fee3 ne fee2 then 1
		end as OutStateF,
		(abs(fee3 - fee2)) as OutStateFDiff,
		case
			when room eq 2 then 0
			when room eq 1 then 1
			else room
		end as Housing,
		(roomcap / scfa2) as ScaledHousingCap,
		case
			when board eq 3 then 0
			else board
		end as board, 
		case
			when board eq 3 then roomamt eq 0
			else roomamt
		end as roomamt,
		case
			when board eq 3 then boardamt eq 0
			else boardamt
		end as boardamt,

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

proc compare base=work.regdata
	compare=work.model_data;
run;
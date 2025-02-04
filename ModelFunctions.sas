/*
based off data set generated from IPEDS: 
	RegModel Data and Model Selection for IPEDS.sas
*/

%macro ModelSelect(library=work, dataset=, class=, response=, quant=, 
					method=stepwise, select=aic, stop=aic, choose=sbc);
	proc glmselect data=&library .&dataset; /*have to include space or extra . for library ref to work*/
		class &class;
		model &response = &class &quant /
				selection=&method(select=&select stop=&stop choose=&choose);
		ods output modelInfo=modelInfo2
							NObs=Obs2
							SelectionSummary=Selection
							ParameterEstimates=Estimates;
	run;
%mend;

options mprint;
%ModelSelect(dataset=regmodel, class=iclevel--c21enprf board, response=rate,
				quant=cohort grantrate--InStateF roomamt--scaledHousingCap)


/* any time you want to reference a macro variable inside a literal value (quoted string)
		you HAVE to use double quotes

	single quotes treated as absolute literal and will not scan for any other language triggers
		(& in this case)
	double quotes will scan for this and identify &class as a macro variable*/






/*to allow two way interaction:
	model response = A|B|C|D ... @2

	you can use @1 and it will be no interaction
	useful if you want to set this as a parameter

	you can code model features as | separated list and use the @num
	to toggle interaction on or off

	how to code this in macro function? not a great way with class variables
		needs space separated list in class statement, but a pipe separated list 
		if you want to allow interactions in the model response statement
			what is macro equivalent to tranword function??



	other note: use categorical features in class statement?
*/
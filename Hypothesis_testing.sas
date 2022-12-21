libname statis "/home/u60685151/BAN100ZBB";

proc import datafile="/home/u60685151/BAN100ZBB/File_Birth.xlsx" dbms=xlsx 
		replace out=statis.birth;
	getnames=yes;
run;

data birth;
	set statis.file_birth;
run;

proc ttest data=birth H0=3360;
	var weight;
Run;

title "Hypothesis testing for Non MOMSMOKE - No difference in weight - Fail";

proc ttest data=birth H0=0;
	where momsmoke=0;
	var weight;
run;


title "Hypothesis testing for Non BLACK mothers - No differnce in weight Fail";

proc ttest data=birth H0=0;
	where black=0;
	var weight;
run;


title "Hypothesis testing for UNMARRIED - No differnce in weight Fail";

proc ttest data=birth H0=0;
	where married=0;
	var weight;
run;

title 
	"Hypothesis testing for mothers with NO BOy - No differnce in weight Fail";

proc ttest data=birth H0=0;
	where boy=0;
	var weight;
run;



proc sort data=birth;
	by weight;
run;

/*For confirming the result and variation Alternate Hypothesis is also done*/;
title "Alternate Hypothesis testing for Smoking mothers - Failed";

proc means data=birth;
	var weight;
	class momsmoke;
run;

proc means data=birth;
	var weight;
	class black;
run;

proc means data=birth;
	var weight;
	class married;
run;

proc means data=birth;
	var weight;
	class boy;
run;


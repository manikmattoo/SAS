FILENAME REFFILE '/home/u60694146/BAN130ZBB/BAN130/FlightDelays.xlsx';

PROC IMPORT DATAFILE=REFFILE DBMS=XLSX OUT=flights;
RUN;

title "Contents of the Dataset";
proc contents data=flights;
run;

title "Listing of observations";
proc print data=flights(obs=100);
run;


*Section A;
*Step 1;

proc format;
	value missingcount .='missing' other='notmissing';
	value $Missingchar ' '='Missing' other='NonMissing';
run;

proc freq data=flights;
	table CRS_DEP_TIME DEP_TIME DISTANCE FL_DATE FL_NUM carrier dest flight_status
		origin tail_num Weather DAY_WEEK DAY_OF_MONTH /missing ;
	format CRS_DEP_TIME missingcount.  DEP_TIME missingcount.  DISTANCE 
		missingcount. FL_DATE missingcount. FL_NUM missingcount. Weather 
		missingcount. DAY_WEEK missingcount. DAY_OF_MONTH 
		missingcount. carrier $missingchar. dest $missingchar. 
		flight_status $missingchar. origin $missingchar. tail_num $missingchar.;
run;

proc means data=flights nmiss n;
run;

data flights;
	set flights;

	if missing(crs_dep_time) or missing(dep_time) or missing(distance) or 
		missing(fl_date) or missing(fl_num) or missing(carrier) or missing(dest) or 
		missing(dest) or missing(flight_status) or missing(origin) or 
		missing(tail_num) then
			delete;
run;

proc means data=flights nmiss n;
run;

proc freq data=flights;
	tables CARRIER DEST Flight_status ORIGIN TAIL_NUM;
run;

/* Cleaning of the Data */

data flights;
	set flights;
	departure_time=input(put(dep_time, z4.), hhmmss4.);
	format departure_time time5.;
	crs_departure_time=input(put(crs_dep_time, z4.), hhmmss4.);
	format crs_departure_time time5.;
	drop dep_time crs_dep_time;
	rename departure_time=dep_time;
	rename crs_departure_time=crs_dep_time;
run;


/*----------Q2------------------*/

data flightdelays replace;
		set flights;
	where Origin="BWI";

	if Flight_status="delayed" then
		DelayedFlight=1;
	else if Flight_status="ontime" then
		DelayedFlight=0;
run;

proc print data=flightdelays;
run;

/*----------------Q3) Calculating delay-----------------*/

data flight_delay;
	set flights;
	where flight_status="delayed";
	if flight_status="delayed" then
		Delayed_time=Dep_time - crs_dep_time;
		format Delayed_time time5.;
	else Delayed_time=0;
	
run;

proc sql;
 title 'Avg Delay per day for each Airport'; 
create table AvgDelay as
   select  day_week, Origin, avg(delayed_time) AS Average_DelayTime
      from flight_delay
      group by origin;    
run;

data AvgDelay replace;
  set AvgDelay;
   Avg_DelayTime=input(put(Average_DelayTime, z4.), hhmmss4.);
   format Avg_DelayTime time5.;  
run;
	
proc print data=AvgDelay;
run;

/*----------------Q3-Vertical Bar Chart -----------------*/

proc sgplot data=AvgDelay ;
    yaxis label="delayed_avg";
    vbar day_week / group=origin groupdisplay=cluster response=Avg_DelayTime;
run;

/*---------------Q4- number of flights per day for US Carrier ------------------*/

proc sql;
create table flight_count as 
	select count(distinct fl_num) as flight_count, carrier, fl_date 
	from flights 
	group by carrier, fl_date;
run;

Title "Flights per day for Carrier US";
proc sgplot data=flight_count;
	where carrier="US";
	scatter y=flight_count x=fl_date;
run;

/*---------------Q4-mean number of flights per day for each Carrier ------------------*/

proc sql;	
create table mean_flights as 
    select round(avg(flight_count)) as mean_flights, carrier 
    from flight_count 
    group by carrier;
run;	

Title "Average flights per day by Carrier";
proc sgplot data=mean_flights;
	yaxis label="mean_flights" max=25;
	vbar carrier / response=mean_flights;
run;

/*------------Q5-histogram for each of the quantitative variables---------------*/


proc univariate data=flights;
	var distance;
	histogram;
run;

/*-------------6)-Pivot tables--------------*/

ods noproctitle;
ods graphics / imagemap=on;
title "Flight status by Origin";

proc means data=WORK.flights nonobs chartype n vardef=df;
	var FL_NUM;
	class ORIGIN Flight_status;
run;

title "Flight Status for each carrier";

proc means data=WORK.flights nonobs chartype n vardef=df;
	var FL_NUM;
	class Flight_status CARRIER;
run;

title "Destination and distance affecting flight status ";

proc means data=WORK.flights nonobs chartype n vardef=df;
	var FL_NUM;
	class Flight_status DEST DISTANCE;
run;

title "Weather affecting flight status";

proc means data=WORK.flights nonobs chartype n vardef=df;
	var FL_NUM;
	class  Weather Flight_status ORIGIN;
run;


/*----B) Advance section-----*/

/*1---Data Reduction*/

data Reduced_dataset replace ;
	set flights (drop= DAY_OF_MONTH TAIL_NUM) ;
run;

Title "Reduced Dataset for Analysis";
proc print data=Reduced_dataset;
run;

proc export data=work.Reduced_dataset
    outfile="/home/u60694146/BAN130ZBB/BAN130/flights_reduced.csv"
    dbms=csv;
run;

/*1---Data Conversion---*/

data FlightDelaysTrainingData1 replace;
	set work.Reduced_dataset;

	if carrier="CO" then
		carrier_num=1;
	else if carrier='DH' then
		carrier_num=2;
	else if carrier='DL' then
		carrier_num=3;
	else if carrier='MQ' then
		carrier_num=4;
	else if carrier='OH' then
		carrier_num=5;
	else if carrier='RU' then
		carrier_num=6;
	else if carrier='US' then
		carrier_num=7;
	else if carrier='UA' then
		carrier_num=9;

	if origin="BWI" then
		origin_num=1;
	else if origin="DCA" then
		origin_num=2;
	else if origin="IAD" then
		origin_num=3;

	if dest="EWR" then
		dest_num=1;
	else if dest="JFK" then
		dest_num=2;
	else if dest="LGA" then
		dest_num=3;
		
	if Flight_status="delayed" then
		DelayedFlight=1;
	else if Flight_status="ontime" then
		DelayedFlight=0;
		
	drop carrier origin dest Flight_status;
run;

Title "Data Conversion";
proc print data=FlightDelaysTrainingData1(obs=15);
run;
















































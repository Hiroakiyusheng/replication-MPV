/*
Create working 1980-2012 dataset
*/ 

cd "../../data/CEX"
use mtabdata.dta, clear

gen month = real(REF_MO)
gen year  = real(REF_YR)

replace year = 1900+year if year<1900
drop if year<1979
drop REF*

gen tsdate = ym(year, month)
format tsdate %tm

ren cons totnd 
ren educ educa
gen other=durables+health+educa
gen tot1 =totnd+educa+health
gen consumption_nondurables = totnd
gen total_consumption =totnd+other 
drop if foodin==0
drop if totnd==.|totnd==0 

* Keep only those with 12 months of records
egen n=sum(family!=.), by(family) 
tab n
drop if n<12 
drop n

sort family tsdate
by family: gen n = _n
gen wave =0
replace wave = 1 if n<4
replace wave =2 if n>3 &n<7
replace wave =3 if n>6 & n<10
replace wave = 4 if n>9
tab wave
drop n

/*
gen origyear = year
egen maxyear = max(year), by(family)

egen minyear = min(year), by(family)
gen  aux = year ==maxyear
egen maux = sum(aux), by(family)
sort family year month
replace year = minyear if maux<=6
replace year = maxyear if maux>6
*/

collapse (sum) total_consumption consumption_nondurables foodin foodout totnd homevalue educa health othexp nd_extra reasexp durables vehicle (min) year, by(family wave) 
save mtabdata_collapsed, replace

use fmlydata,clear

gen complete=RESPSTAT=="1"
gen region=real(REGION)
ren FAM_S ncomp
gen famtype=real(FAM_TY)
ren FINCB incbtax   /*Amount of CU income before taxes*/
ren FINCA incatax
ren PERS comp18
ren SEX_REF sex
ren wages salaryh
ren wagesw salarywh
ren FINLWT21 weight

ren QINTRVYR survey_year
destring survey_year, replace
replace survey_year = 1900+survey_year if survey_year<=95
destring QINTRVMO,replace
ren QINTRVMO survey_month

sort family survey_year survey_month
by family: gen n = _n
gen wave =0
replace wave = 1 if n==1
replace wave =2 if n==2
replace wave =3 if n==3
replace wave = 4 if n==4
tab wave

sort family
merge m:1 family wave using mtabdata_collapsed
drop if _merge!=3 
drop _merge

egen maxint=max(intno),by(family)   /*interview number:2-5*/
gen maxint1=maxint-1 
sort family intno
qui by family:gen     inc=incbtax   if intno==maxint  & incbtax!=0
qui by family:replace inc=incbtax   if intno==maxint1 & inc[_n+1]==. & intno!=intno[_n+1]

egen income    =max(inc),by(family)

gen salh = salaryh if intno == maxint
gen salw = salaryw if intno == maxint 

gen tot_sal = salaryh+salaryw 

egen income_labor = mean(tot_sal), by(family) 

drop maxint* 
*egen maxint=max(intno),by(family)
*keep if intno==maxint

rename family household_id

rename sex hh_sex
destring hh_sex, replace force
rename age hh_age
rename ncomp family_size
rename BLS_UR urban_rural
destring urban_rural, replace force

rename MARITAL marital
destring marital, replace force
replace marital = 2 if marital>=2 

rename race hh_race
destring hh_race, replace force
replace hh_race = 1 if hh_race>=3 & hh_race <=5 // asians, native americans, pacific islander code as white 
replace hh_race = 2 if hh_race==5  // mixed race code as black 

gen survey_name = ""
	replace survey_name = "Survey of Consumer Expenditures"
rename income total_income
gen unemp =0
replace unemp=1 if UNEMPLX!=.&UNEMPLX!=0
*keep survey_year survey_name year *_year *_month wave household_id region urban_rural total_consumption consumption_nondurables total_income income_labor income_transfers marital hh_sex hh_age hh_race family_size unemp weight
order survey_year survey_name year *_year *_month household_id region urban_rural total_consumption consumption_nondurables total_income income_labor income_transfers marital hh_sex hh_age hh_race family_size unemp weight
save CEX_1980_2012, replace  

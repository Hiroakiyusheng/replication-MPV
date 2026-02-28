** Generate Table 3: Experience Effects and Expectations
clear 
clear mata 
clear matrix 
set more off 
set matsize 11000 
set maxvar 24000 
clear mata 

use "../../raw/MSC/ms_all_1953_2018.dta", clear  
keep yyyy yyyymm age ehsgrd eclgrd income sex marry yyyy age bexp pexp dur unemp wt

* Create year born variable for merging 
gen year_born=yyyy-age

drop if age < 18

merge m:1 yyyy year_born using "../../data/MSC/generated_years_lag"
rename _merge _merge_ldavg
drop if _merge_ldavg==2

merge m:1 yyyy using "../../raw/nat_UE_1890_2017"
drop if _merge==2
drop _merge
 
* Clean socioeconomic variables
* Make marry variable a married dummy (remember marry=2 (is married), marry=1 (not married))
gen married=marry-1
replace married=0 if married==.
* Make sex variable a female dummy (remember female=2, male=1)
gen female=sex-1
replace female =0 if female==.
gen ln_income=log(income)

sum experience_lambda1_lag, detail
gen ldavgexp_civ_unemp_p10=r(p10)
gen ldavgexp_civ_unemp_p90=r(p90)

********************************************************************************
* Now looking ahead – do you think that a year from now you will be better off financially, or worse off, or just about the same as now?
****** 1 means better off, 3 Same, 5 worse off
gen pexp_dum=pexp
replace pexp_dum=0 if pexp==5
replace pexp_dum=1 if pexp==3
tab pexp_dum

eststo clear
eststo: xi: reg pexp_dum experience_lambda1_lag  UE_rate i.yyyy i.age [pweight=wt], robust
estadd scalar difb =_b[experience_lambda1_lag]*ldavgexp_civ_unemp_p90- _b[experience_lambda1_lag]*ldavgexp_civ_unemp_p10

eststo: xi: reg pexp_dum experience_lambda1_lag  UE_rate ln_income i.yyyy i.age [pweight=wt], robust
estadd scalar difb =_b[experience_lambda1_lag]*ldavgexp_civ_unemp_p90- _b[experience_lambda1_lag]*ldavgexp_civ_unemp_p10

eststo: xi: reg pexp_dum experience_lambda1_lag  UE_rate ehsgrd eclgrd ln_income female married i.yyyy i.age [pweight=wt], robust
estadd scalar difb =_b[experience_lambda1_lag]*ldavgexp_civ_unemp_p90- _b[experience_lambda1_lag]*ldavgexp_civ_unemp_p10

*********************************************************************************
* Generally speaking, do you think now is a good or bad time for people to buy major household items?
****** 1 means yes, 3 Same, 5 no
gen dur_dum=dur
replace dur_dum=0 if dur==5
replace dur_dum=1 if dur==3
tab dur_dum

eststo: xi: reg dur_dum experience_lambda1_lag  UE_rate i.yyyy i.age [pweight=wt], robust
estadd scalar difb =_b[experience_lambda1_lag]*ldavgexp_civ_unemp_p90- _b[experience_lambda1_lag]*ldavgexp_civ_unemp_p10

eststo: xi: reg dur_dum experience_lambda1_lag  UE_rate ln_income i.yyyy i.age [pweight=wt], robust
estadd scalar difb =_b[experience_lambda1_lag]*ldavgexp_civ_unemp_p90- _b[experience_lambda1_lag]*ldavgexp_civ_unemp_p10

eststo: xi: reg dur_dum experience_lambda1_lag  UE_rate ehsgrd eclgrd ln_income female married i.yyyy i.age [pweight=wt], robust
estadd scalar difb =_b[experience_lambda1_lag]*ldavgexp_civ_unemp_p90- _b[experience_lambda1_lag]*ldavgexp_civ_unemp_p10


esttab using "../../Tables/table_3.tex", keep(experience_lambda1_lag UE_rate ln_income) se star( * 0.10 ** 0.05 *** 0.010) r2 b(3)  replace 



** Generate Table 3: Experience Effects and Expectations
clear
set more off
*cd to "./Replication/code/CEX"

import excel "../../raw/unemployment_raw_q.xlsx", firstrow clear
save "../../raw/unemployment_raw_q", replace

use "../../data/CEX/CEX_1980_2012", clear
gen tsdate = yq(survey_year, wave)
format tsdate %tq
rename survey_year panel_year
ren wave panel_q
drop if total_income <2000
gen birth_year=panel_year-hh_age
gen birth_q=1
ren panel_year panel_year_old
gen panel_year = panel_year_old-1
merge m:1 panel_year panel_q birth_year birth_q using "../../data/CEX/generated_quarters_lag", keepusing(experience_lambda1_lag)
drop if _merge==2
drop _merge
sort panel_year panel_q
merge m:1 panel_year panel_q using "../../raw/unemployment_raw_q"
drop if _merge ==2
drop _merge
drop panel_year
ren panel_year_old panel_year
destring school, replace

tsset household_id tsdate
gen consum_durable = total_consumption - consumption_nondurables
gen income = ln(total_income)
gen consump = ln(total_consumption)
gen consump_nd = ln(consumption_nondurables)
gen consump_d = ln(consum_durable)
gen female=0
replace female=1 if hh_sex==2
gen marry =0
replace marry =1 if marital ==1

foreach var of varlist consump consump_nd consump_d consum_durable experience_lambda1_lag Civilianunemploymentrate income hh_age marry female school hh_race family_size unemp region weight birth_year {
	drop if `var'==.
}

est clear
estpost tabstat hh_age family_size total_consumption consum_durable consumption_nondurables total_income experience_lambda1_lag, ///
c(stat) stat(mean sd p10 p50 p90 n)

esttab using "../../Tables/table_a15.tex", replace ////
 cells("mean sd p10 p50 p90 count")   nonumber ///
  nomtitle nonote noobs label booktabs ///
  collabels("Mean" "SD" "p10" "p50" "p90" "N")  ///
  title("Summary Statistics (CEX)")

mata: mata set matafavor speed, perm
egen double yrcoh=group(panel_year birth_year)
gen yq = yq(panel_year, panel_q)
egen double yrqrt=group(panel_year panel_q)

eststo clear
eststo:areg consump experience_lambda1_lag Civilianunemploymentrate income i.hh_age marry female i.school i.hh_race family_size unemp i.region [pweight=weight], absorb(yq) robust cluster (birth_year)
eststo:areg consump_d experience_lambda1_lag Civilianunemploymentrate income i.hh_age marry female i.school i.hh_race family_size unemp i.region [pweight=weight], absorb(yq) robust cluster (birth_year)
eststo:areg consump_nd experience_lambda1_lag Civilianunemploymentrate income i.hh_age marry female i.school i.hh_race family_size unemp i.region [pweight=weight], absorb(yq) robust cluster (birth_year)
esttab using "../../Tables/table_a16.csv", keep(experience_lambda1_lag) se r2 b(3) starlevels( * 0.10 ** 0.05 *** 0.010) replace 

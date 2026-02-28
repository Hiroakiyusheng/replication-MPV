clear
set more off
*cd "./Replication/code/Nielsen"

use "../../data/panelist_totalexp_m", clear
keep if panel_year>2003&panel_year<2013
merge m:1 yrmon using "../../raw/PCEPI"
drop if _merge!=3
drop _merge
replace totalexp = totalexp/inflation

bysort household_code: gen index = _N
tab index

gen age_male = panel_year-female_head_yrborn
gen age_female = panel_year-female_head_yrborn
drop if age_male==.
drop if age_male >75 | age_male<25


gen flag = 0
replace flag =1 if (age_male==25 & panel_year==2005 & index==96) | (age_male==25 & panel_year==2006 & index==84)| (age_male==25 & panel_year==2007 & index==72) ///
| (age_male==25 & panel_year==2008 & index==60)| (age_male==25 & panel_year==2009 & index==48)| (age_male==25 & panel_year==2010 & index==36) ///
| (age_male==25 & panel_year==2011 & index==24) | (age_male==25 & panel_year==2012 & index==12)
replace flag =1 if (age_male==75 & panel_year==2011 & index==96) | (age_male==75 & panel_year==2010 & index==84)| (age_male==75 & panel_year==2009 & index==72) ///
| (age_male==75 & panel_year==2008 & index==60)| (age_male==75 & panel_year==2007 & index==48)| (age_male==75 & panel_year==2006 & index==36) ///
| (age_male==75 & panel_year==2005 & index==24) | (age_male==75 & panel_year==2004 & index==12)
drop if index !=108 & flag==0

gen age_group = 1 if age_male<40
replace age_group =2 if age_male>=40 & age_male<=60
replace age_group = 3 if age_male>60

levelsof yrmon, local(time)
gen totalexp_avg = .
gen totalexp_age_avg = .
foreach i of local time {
	egen temp1 = wtmean(totalexp) if (yrmon==`i'|yrmon==`i'+1|yrmon==`i'+2|yrmon==`i'+3|yrmon==`i'+4|yrmon==`i'+5) & yrmon<=630, weight(projection_factor)
	bysort age_group:egen temp2 = wtmean(totalexp) if (yrmon==`i'|yrmon==`i'+1|yrmon==`i'+2|yrmon==`i'+3|yrmon==`i'+4|yrmon==`i'+5) & yrmon<=630, weight(projection_factor)
	replace totalexp_avg = temp1 if yrmon==`i'+5
	replace totalexp_age_avg = temp2 if yrmon==`i'+5
	drop temp1 temp2
	}
gen totalexp_diff = totalexp_age_avg- totalexp_avg
gen totalexp_diff_p = totalexp_age_avg/totalexp_avg-1

collapse totalexp_diff totalexp_diff_p, by (yrmon age_group)
keep totalexp_diff totalexp_diff_p yrmon age_group
reshape wide totalexp_diff totalexp_diff_p, i(yrmon) j(age_group)
line totalexp_diff1 totalexp_diff2 totalexp_diff3 yrmon, ytitle("Deviation from Mean Expenditure ($)") xtitle("") lpattern(solid longdash dash_dot) legend(label(1 "Age<40") label(2 "Age 40 to 60") label(3 "Age>60")) graphregion(color(white))
graph export "../../Figures/figure_B4.pdf", replace

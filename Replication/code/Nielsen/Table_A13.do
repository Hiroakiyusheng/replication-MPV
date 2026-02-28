clear
set more off
set matsize 11000
mata: mata set matafavor speed, perm
*cd "./Replication/code/Nielsen"

*********************************************************************
*---------------------------------------------*
/* Table A13 Part 1 */
*---------------------------------------------*

use "../../data/Nielsen/panelist_totalexp_m", clear
drop kitchen_* tv_* household_internet_* member_* dup*
sort household_code panel_year month
by household_code: gen tag = _n
gen proj = projection_factor if tag==1
spread proj, by (household_code)
replace projection_factor = proj 
drop proj tag

merge m:1 male_head_yrborn male_head_mborn panel_year month using "../../data/Nielsen/generated_months_lag", keepusing(experience_lambda1_lag experience_lambda3_lag)
drop if _merge==2
drop _merge

merge m:1 panel_year month using "../../raw/unemployment_raw_m"
drop if _merge ==2
drop _merge
gen unempdif = Civilianunemploymentrate - value
gen unempdif2 = value - Civilianunemploymentrate
*---------------------------------------------*
/* Generate household control variables*/
*---------------------------------------------*
replace household_income = 27 if household_income >27
gen int HH_income =0
	replace HH_income=1 if inlist(household_income,3,4,6,8,10,11) // <20,000
	replace HH_income=2 if inlist(household_income,13,15,16) // <40,000
	replace HH_income=3 if inlist(household_income,18,19,21) // <60,000
	replace HH_income=4 if inlist(household_income,23,26) // <100,000
	replace HH_income=5 if inlist(household_income,27,28,29,30) // 100,000+
	la define HH_inc 0 "Missing obs" 1 "<20K" 2 "<40K" 3 "<60K" 4 "<100K" 5 "+100K"
	la val HH_income HH_inc
	la var HH_income "Households income"

gen marry = 0
replace marry = 1 if marital_status ==1
gen house = 0 
replace house = 1 if type_of_residence==1 

*---------------------------------------------*
/* Generate variables for regression */
*---------------------------------------------*
tsset household_code yrmon
replace totalexp = log(totalexp_trip)

gen hprice = log(homepr_all)
gen wealth_house = hprice *house
egen yrmon_hh = group(yrmon household_code)


gen age = panel_year - male_head_yrborn
drop if age>75 &age!=.
drop if age<25& age!=.
gen agesq = age^2
gen Unemp = 0
replace Unemp = 1 if male_head_occupation==12 & age<65

foreach var of varlist totalexp experience_lambda1_lag experience_lambda3_lag Unemp value house hprice wealth_house f.HH_income household_size male_head_education marry race projection_factor age yrmon household_code dma_code {
	drop if `var'==.
}


est clear
estpost tabstat age household_size totalexp_trip household_income experience_lambda1_lag  experience_lambda3_lag, ///
c(stat) stat(mean sd p10 p50 p90)

esttab using "../../Tables/table_a13_part1.tex", replace ////
 cells("mean sd p10 p50 p90")   nonumber ///
  nomtitle nonote noobs label booktabs ///
  collabels("Mean" "SD" "p10" "p50" "p90")  ///
  title("Summary Statistics (Nielsen), Part 1")
  
*********************************************************************
*---------------------------------------------*
/* Table A13 Part 2 */
*---------------------------------------------*
use "../../data/panelist_storerank_m", clear
bysort household_code: gen tag = _n
gen proj = projection_factor if tag==1
spread proj, by (household_code)
replace projection_factor = proj 
drop proj tag
*---------------------------------------------*
/* Generate household control variables*/
*---------------------------------------------*
replace household_income = 27 if household_income >27
gen int HH_income =0
	replace HH_income=1 if inlist(household_income,3,4,6,8,10,11) // <20,000
	replace HH_income=2 if inlist(household_income,13,15,16) // <40,000
	replace HH_income=3 if inlist(household_income,18,19,21) // <60,000
	replace HH_income=4 if inlist(household_income,23,26) // <100,000
	replace HH_income=5 if inlist(household_income,27,28,29,30) // 100,000+
	la define HH_inc 0 "Missing obs" 1 "<20K" 2 "<40K" 3 "<60K" 4 "<100K" 5 "+100K"
	la val HH_income HH_inc
	la var HH_income "Households income"
	
gen marry = 0
replace marry = 1 if marital_status ==1
gen house = 0 
replace house = 1 if type_of_residence==1 
gen unempdif = Civilianunemploymentrate - value
gen unempdif2 = value - Civilianunemploymentrate

merge m:1 male_head_yrborn male_head_mborn panel_year month using "../../data/generated_months_lag", keepusing(experience_lambda1_lag)
drop if _merge==2
drop _merge

tsset household_code date
egen yrmon_hh = group(yrmon household_code)
drop if totalprice<50
drop if upc<5

gen age = panel_year - male_head_yrborn
drop if age>75 &age!=.
drop if age<25& age!=.
gen agesq = age^2
gen Unemp = 0
replace Unemp = 1 if male_head_occupation==12 & age<65

gen hprice = log(homepr_all)
gen wealth_house = hprice *house

foreach var of varlist onsale coupon_use experience_lambda1_lag Unemp value house hprice wealth_house f.HH_income household_size male_head_education marry race projection_factor age yrmon household_code dma_code {
	drop if `var'==.
}

estpost tabstat onsale coupon_use, ///
c(stat) stat(mean sd p10 p50 p90)

esttab using "../../Tables/table_a13_part2.tex", replace ////
 cells("mean sd p10 p50 p90")   nonumber ///
  nomtitle nonote noobs label booktabs ///
  collabels("Mean" "SD" "p10" "p50" "p90")  ///
  title("Summary Statistics (Nielsen), Part 2")
  
********************************************************************************  
*---------------------------------------------*
/* Table A13 Part 3 */
*---------------------------------------------*
use "../../data/panelist_goodrank_m", clear
bysort household_code: gen tag = _n
gen proj = projection_factor if tag==1
spread proj, by (household_code)
replace projection_factor = proj 
drop proj tag
*---------------------------------------------*
/* Generate household control variables*/
*---------------------------------------------*
merge m:1 male_head_yrborn male_head_mborn panel_year month using "../../data/generated_months_lag", keepusing(experience_lambda1_lag experience_lambda3_lag)
drop if _merge==2
drop _merge

replace household_income = 27 if household_income >27
gen int HH_income =0
	replace HH_income=1 if inlist(household_income,3,4,6,8,10,11) // <20,000
	replace HH_income=2 if inlist(household_income,13,15,16) // <40,000
	replace HH_income=3 if inlist(household_income,18,19,21) // <60,000
	replace HH_income=4 if inlist(household_income,23,26) // <100,000
	replace HH_income=5 if inlist(household_income,27,28,29,30) // 100,000+
	la define HH_inc 0 "Missing obs" 1 "<20K" 2 "<40K" 3 "<60K" 4 "<100K" 5 "+100K"
	la val HH_income HH_inc
	la var HH_income "Households income"

gen marry = 0
replace marry = 1 if marital_status ==1
gen house = 0 
replace house = 1 if type_of_residence==1
gen unempdif = Civilianunemploymentrate - value
gen unempdif2 = value - Civilianunemploymentrate

tsset household_code date
egen yrmon_hh = group(yrmon household_code)
egen mon_hh = group(month household_code)
egen yr_hh = group(panel_year household_code)

drop if expend <50

gen age = panel_year - male_head_yrborn
drop if age>75 &age!=.
drop if age<25& age!=.
gen agesq = age^2
gen Unemp = 0
replace Unemp = 1 if male_head_occupation==12 & age<65

gen hprice = log(homepr_all)
gen wealth_house = hprice *house
gen unitprice = ln(R_unitprice/(1-R_unitprice))  

foreach var of varlist R_unitprice experience_lambda1_lag Unemp value house hprice wealth_house f.HH_income household_size male_head_education marry race projection_factor age yrmon household_code dma_code {
	drop if `var'==.
}

estpost tabstat R_unitprice, ///
c(stat) stat(mean sd p10 p50 p90)

esttab using "../../Tables/table_a13_part3.tex", replace ////
 cells("mean sd p10 p50 p90")   nonumber ///
  nomtitle nonote noobs label booktabs ///
  collabels("Mean" "SD" "p10" "p50" "p90")  ///
  title("Summary Statistics (Nielsen), Part 3")

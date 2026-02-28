clear
set more off
*cd "./Replication/code/Nielsen"

use "../../data/Nielsen/panelist_totalexp_m", clear
drop kitchen_* tv_* household_internet_* member_* dup*
sort household_code panel_year month
by household_code: gen tag = _n
gen proj = projection_factor if tag==1
spread proj, by (household_code)
replace projection_factor = proj 
drop proj tag
replace household_income = 27 if household_income >27
gen marry = 0
replace marry = 1 if marital_status ==1
sort panel_year month
merge m:1 male_head_yrborn male_head_mborn panel_year month using "../../data/Nielsen/generated_months_lag", keepusing(experience_lambda1_lag)
drop if _merge==2
drop _merge
merge m:1 panel_year month using "../../raw/unemployment_raw_m"
drop if _merge ==2
drop _merge

gen age_male = panel_year-male_head_yrborn
gen age_female = panel_year-female_head_yrborn
egen yrmon_hh = group(yrmon household_code)

drop if age_male==.
drop if age_male >75 |age_male<25  
tsset household_code yrmon
gen unempd = ln(value) - ln(l.value)
gen unempd_nat = ln(Civilianunemploymentrate) - ln(l.Civilianunemploymentrate)
gen dif = value- Civilianunemploymentrate
gen totalexpd = ln(totalexp)-ln(l.totalexp)
gen age_unempd = unempd*age_male
gen age_unempdnat = unempd_nat*age_male
gen unempd_nat_pos =0
replace unempd_nat_pos = unempd_nat*-1 if unempd_nat<0 /*unemployment decreased*/
gen unempd_nat_neg =0
replace unempd_nat_neg = unempd_nat if unempd_nat>0
gen unempd_nat_pos_age =age_male*unempd_nat_pos
gen unempd_nat_neg_age =age_male*unempd_nat_neg
gen unempd_loc_pos =0
replace unempd_loc_pos = unempd*-1 if unempd<0 /*condition improve*/
gen unempd_loc_neg =0
replace unempd_loc_neg = unempd if unempd>0 /*condition deteriorate*/
gen unempd_loc_pos_age =age_male*unempd_loc_pos
gen unempd_loc_neg_age =age_male*unempd_loc_neg


tsset household_code yrmon

eststo clear
eststo: reghdfe  totalexpd unempd_nat_pos_age unempd_nat_neg_age unempd_loc_pos unempd_loc_neg fi.household_income household_size male_head_education marry i.race i.age_male i.dma_code [pweight=projection_factor], absorb(yrmon) vce(cluster household_code)
eststo: reghdfe  totalexpd unempd_nat_pos_age unempd_nat_neg_age unempd_loc_pos unempd_loc_neg fi.household_income household_size male_head_education marry i.race i.age_male i.dma_code [pweight=projection_factor], absorb(yrmon household_code) vce(cluster household_code)
eststo: reghdfe  totalexpd unempd_loc_pos unempd_loc_pos_age unempd_loc_neg unempd_loc_neg_age fi.household_income household_size male_head_education marry i.race i.age_male i.dma_code  [pweight=projection_factor], absorb(yrmon) vce(cluster household_code)
eststo: reghdfe  totalexpd unempd_loc_pos unempd_loc_pos_age unempd_loc_neg unempd_loc_neg_age fi.household_income household_size male_head_education marry i.race i.age_male i.dma_code  [pweight=projection_factor], absorb(yrmon household_code) vce(cluster household_code)
eststo: reghdfe  totalexpd unempd_nat_pos_age unempd_nat_neg_age unempd_loc_pos unempd_loc_pos_age unempd_loc_neg unempd_loc_neg_age fi.household_income household_size male_head_education marry i.race i.age_male i.dma_code  [pweight=projection_factor], absorb(yrmon) vce(cluster household_code)
eststo: reghdfe  totalexpd unempd_nat_pos_age unempd_nat_neg_age unempd_loc_pos unempd_loc_pos_age unempd_loc_neg unempd_loc_neg_age fi.household_income household_size male_head_education marry i.race i.age_male i.dma_code  [pweight=projection_factor], absorb(yrmon household_code) vce(cluster household_code)
esttab using Table_b18.csv.csv, keep(unempd_nat_pos_age unempd_nat_neg_age unempd_loc_pos unempd_loc_pos_age unempd_loc_neg unempd_loc_neg_age) se star( * 0.10 ** 0.05 *** 0.010) r2 replace 



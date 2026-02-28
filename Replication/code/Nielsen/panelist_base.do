clear
set more off
cd "./Replication/code/Nielsen"

use "../../raw/panelists_2004", clear
forval i=2005/2013 {
	append using "../../raw/panelists_`i'", force
}
replace male_head_birth = "" if panel_year==2004|panel_year==2005|panel_year==2006|panel_year==2007|panel_year==2010
replace female_head_birth = "" if panel_year==2004|panel_year==2005|panel_year==2006|panel_year==2007|panel_year==2010
merge 1:1 panel_year household_code using "../../raw/panel_birth_corrected", update replace nogen 
sort household_code panel_year
by household_code: gen dup1 = _N
by household_code: gen dup2 = _n
tab dup1
gen male_head_yrborn = substr(male_head_birth,1,4)
destring male_head_yrborn, force replace
gen female_head_yrborn = substr(female_head_birth,1,4)
destring female_head_yrborn, force replace
gen male_head_mborn = substr(male_head_birth,-2,.)
destring male_head_mborn, replace
gen female_head_mborn = substr(female_head_birth,-2,.)
destring female_head_mborn, replace
gen male_head_qborn =1 if male_head_mborn<4
replace male_head_qborn =2 if male_head_mborn>3 & male_head_mborn<7
replace male_head_qborn =3 if male_head_mborn>6 & male_head_mborn<10
replace male_head_qborn =4 if male_head_mborn>9
gen female_head_qborn = male_head_qborn
sort household_code panel_year
compress
save "../../data/Nielsen/panelist_base", replace




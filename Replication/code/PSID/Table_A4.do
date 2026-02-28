** Generate Table A.4: Consumption (PSID), Alternative Experience Measure: Spousal Experience
clear 
est clear
clear mata 
clear matrix 
set more off 
set matsize 11000 
set maxvar 24000 
clear mata 
capture log close 

use "./Table_A4/psid_new_final_spouses.dta", clear  


keep if tag_10_90==1
sort ID year
by ID:gen num = _N
drop if num==1

local ctrl income income2 l1_income l1_income2 liquid_wealth liquid2 illiquid_wealth illiquid2 couple


/* Column 1 */
reghdfe total exp_personal_hh GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_A4.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_personal_hh) dec(3) nonotes nocons replace 
estimates store EQ1, title(EQ1)

/* Column 2 */
reghdfe total exp_state_nat_hh GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_A4.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_state_nat_hh) dec(3) nonotes nocons append 
estimates store EQ2, title(EQ2)


/* Column 3 */
reghdfe total exp_state_nat_hh exp_personal_hh GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_A4.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_personal_hh exp_state_nat_hh) dec(3) nonotes nocons append 
estimates store EQ3, title(EQ3)


/* Column 4 */
reghdfe total exp_personal_hh_l3 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_A4.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_personal_hh_l3) dec(3) nonotes nocons append 
estimates store EQ4, title(EQ4)

/* Column 5 */
reghdfe total exp_state_nat_hh_l3 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_A4.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_state_nat_hh_l3) dec(3) nonotes nocons append
estimates store EQ5, title(EQ5)


/* Column 6 */
reghdfe total exp_state_nat_hh_l3 exp_personal_hh_l3 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_A4.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_state_nat_hh_l3 exp_personal_hh_l3) dec(3) nonotes nocons append 
estimates store EQ6, title(EQ6)



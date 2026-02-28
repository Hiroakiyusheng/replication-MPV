** Generate Table A.5: Consumption (PSID), Alternative Clustering Units

clear 
est clear
clear mata 
clear matrix 
set more off 
set matsize 11000 
set maxvar 24000 
clear mata 
capture log close 


/* Upload data */
use "../../data/PSID/psid_new_final_lag_LS.dta", clear  
keep if tag_10_90==1
sort ID year
by ID:gen num = _N
drop if num==1


local ctrl income income2 l1_income l1_income2 liquid_wealth liquid2 illiquid_wealth illiquid2


/* Column 1 */
reghdfe total exp_personal_lagged_1 exp_state_nat_lagged_1 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort year) 
outreg2 using "../../Tables/table_A5.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) addtext(Clustering Unit, Cohort&Year) keep(exp_personal_lagged_1 exp_state_nat_lagged_1) dec(3) nonotes nocons replace
estimates store EQ1, title(EQ1)


/* Column 2 */
reghdfe total exp_personal_lagged_1 exp_state_nat_lagged_1 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(ID) 
outreg2 using "../../Tables/table_A5.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) addtext(Clustering Unit, HH)  keep(exp_personal_lagged_1 exp_state_nat_lagged_1) dec(3) nonotes nocons append 
estimates store EQ2, title(EQ2)


/* Column 3 */
reghdfe total exp_personal_nat_l3 exp_state_nat_lagged_l3  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort year) 
outreg2 using "../../Tables/table_A5.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All)  addtext(Clustering Unit, Cohort&Year) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3 ) dec(3) nonotes nocons append 
estimates store EQ3, title(EQ3)


/* Column 4 */
reghdfe total exp_personal_nat_l3 exp_state_nat_lagged_l3  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(ID) 
outreg2 using "../../Tables/table_A5.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) addtext(Clustering Unit, HH) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3 ) dec(3) nonotes nocons append 
estimates store EQ4, title(EQ4)


** Generate Table A.9: Consumption (PSID), Additional Income Controls

clear 
est clear
clear mata 
clear matrix 
set more off 
set matsize 11000 
set maxvar 24000 
clear mata 
capture log close 



use "../../data/PSID/psid_new_final_lag_LS.dta", clear  
keep if tag_10_90==1
sort ID year
by ID:gen num = _N
drop if num==1

local ctrl_1 income income2 income3 income4 l1_income l1_income2 l1_income3 l1_income4 liquid_wealth liquid2 illiquid_wealth illiquid2
local ctrl_2 i.l1_income_q5_10_90 i.income_q5_10_90 income income2 l1_income l1_income2 liquid_wealth liquid2 illiquid_wealth illiquid2
local ctrl_3 i.l1_income_q10_10_90 i.income_q10_10_90 income income2 l1_income l1_income2 liquid_wealth liquid2 illiquid_wealth illiquid2
local ctrl_4 i.xinc i.xl1inc income income2 l1_income l1_income2 liquid_wealth liquid2 illiquid_wealth illiquid2


/* Column 1 */
areg total exp_personal_lagged_1 exp_state_nat_lagged_1 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl_1' i.HD_RACE i.HEAD_EDU i.age i.GSA i.year, absorb(ID) vce (cluster cohort) 
outreg2 using "../../Tables/table_a9.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_personal_lagged_1 exp_state_nat_lagged_1) dec(3) nonotes nocons replace 
estimates store EQ1, title(EQ1)


/* Column 2 */
reghdfe total exp_personal_lagged_1 exp_state_nat_lagged_1  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl_2' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_a9.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_personal_lagged_1 exp_state_nat_lagged_1) dec(3) nonotes nocons append 
estimates store EQ2, title(EQ2)


/* Column 3 */
reghdfe total exp_personal_lagged_1 exp_state_nat_lagged_1  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl_3' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_a9.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_personal_lagged_1 exp_state_nat_lagged_1) dec(3) nonotes nocons append 
estimates store EQ3, title(EQ3)


/* Column 4 */
reghdfe total exp_personal_lagged_1 exp_state_nat_lagged_1  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl_4' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_a9.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_personal_lagged_1 exp_state_nat_lagged_1) dec(3) nonotes nocons append 
estimates store EQ4, title(EQ4)

/* Column 5 */
areg total exp_personal_nat_l3 exp_state_nat_lagged_l3 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl_1' i.HD_RACE i.HEAD_EDU i.age i.GSA i.year, absorb(ID) vce (cluster cohort) 
outreg2 using "../../Tables/table_a9.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3) dec(3) nonotes nocons append 
estimates store EQ5, title(EQ5)


/* Column 6 */
reghdfe total exp_personal_nat_l3 exp_state_nat_lagged_l3  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl_2' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_a9.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3) dec(3) nonotes nocons append 
estimates store EQ6, title(EQ6)


/* Column 7 */
reghdfe total exp_personal_nat_l3 exp_state_nat_lagged_l3  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl_3' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_a9.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3) dec(3) nonotes nocons append 
estimates store EQ7, title(EQ7)


/* Column 8 */
reghdfe total exp_personal_nat_l3 exp_state_nat_lagged_l3  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl_4' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_a9.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3) dec(3) nonotes nocons append 
estimates store EQ8, title(EQ8)


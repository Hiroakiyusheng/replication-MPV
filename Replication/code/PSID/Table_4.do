** Generate Table 4: Experience Effects and Future Income
clear 
est clear 
clear mata 
clear matrix 
set more off 
set matsize 11000 
set maxvar 24000 
capture log close 

use "../../data/PSID/psid_new_final_lag_LS.dta", clear  

keep if tag_10_90==1
sort ID year
by ID:gen num = _N
drop if num==1


local ctrl income income2 l1_income l1_income2 liquid_wealth liquid2 illiquid_wealth illiquid2

xtset ID seq

reghdfe f2.income exp_personal_lagged_1 exp_state_nat_lagged_1  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(ID age GSA year ) cluster(cohort) 
outreg2 using "../../Tables/table_4.tex", excel ctitle (Future Income t+2) keep(exp_personal_lagged_1 exp_state_nat_lagged_1 ) dec(3) nonotes nocons replace
estimates store EQ1, title(EQ1)

reghdfe f3.income exp_personal_lagged_1 exp_state_nat_lagged_1  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(ID age GSA year ) cluster(cohort) 
outreg2 using "../../Tables/table_4.tex", excel ctitle (Future Income t+4) keep(exp_personal_lagged_1 exp_state_nat_lagged_1 ) dec(3) nonotes nocons append 
estimates store EQ2, title(EQ2)

reghdfe f4.income exp_personal_lagged_1 exp_state_nat_lagged_1  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(ID age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_4.tex", excel ctitle (Future Income t+6) keep(exp_personal_lagged_1 exp_state_nat_lagged_1 ) dec(3) nonotes nocons append 
estimates store EQ3, title(EQ3)

reghdfe f5.income exp_personal_lagged_1 exp_state_nat_lagged_1  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(ID age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_4.tex", excel ctitle (Future Income t+8) keep(exp_personal_lagged_1 exp_state_nat_lagged_1 ) dec(3) nonotes nocons append 
estimates store EQ4, title(EQ4)

reghdfe f6.income exp_personal_lagged_1 exp_state_nat_lagged_1  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(ID age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_4.tex", excel ctitle (Future Income t+10) keep(exp_personal_lagged_1 exp_state_nat_lagged_1 ) dec(3) nonotes nocons append 
estimates store EQ5, title(EQ5)


reghdfe f2.income exp_personal_nat_l3 exp_state_nat_lagged_l3   GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(ID age GSA year ) cluster(cohort) 
outreg2 using "../../Tables/table_4.tex", excel ctitle (Future Income t+2) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3  ) dec(3) nonotes nocons append
estimates store EQ6, title(EQ6)

reghdfe f3.income exp_personal_nat_l3 exp_state_nat_lagged_l3   GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(ID age GSA year ) cluster(cohort) 
outreg2 using "../../Tables/table_4.tex", excel ctitle (Future Income t+4) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3  ) dec(3) nonotes nocons append 
estimates store EQ7, title(EQ7)

reghdfe f4.income exp_personal_nat_l3 exp_state_nat_lagged_l3   GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(ID age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_4.tex", excel ctitle (Future Income t+6) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3  ) dec(3) nonotes nocons append 
estimates store EQ8, title(EQ8)

reghdfe f5.income exp_personal_nat_l3 exp_state_nat_lagged_l3   GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(ID age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_4.tex", excel ctitle (Future Income t+8) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3  ) dec(3) nonotes nocons append 
estimates store EQ9, title(EQ9)

reghdfe f6.income exp_personal_nat_l3 exp_state_nat_lagged_l3   GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU , absorb(ID age GSA year ID) cluster(cohort) 
outreg2 using "../../Tables/table_4.tex", excel ctitle (Future Income t+10) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3  ) dec(3) nonotes nocons append 
estimates store EQ10, title(EQ10)

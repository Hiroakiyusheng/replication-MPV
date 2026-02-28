** Generate Table 7: Experience Effects and Consumption, GMM regressions

clear 
est clear 
clear mata 
clear matrix 
set more off 
set matsize 11000 
set maxvar 24000 
clear mata 
mata: mata set matafavor speed, perm
cap log close


use "../../data/PSID/psid_new_final_lag_LS.dta", clear 
keep if tag_10_90==1
sort ID year
by ID:gen num = _N
drop if num==1

local ctrl income income2 l1_income l1_income2 liquid_wealth liquid2 illiquid_wealth illiquid2

xtset ID seq


xtabond2 total l.total  exp_personal_lagged_1 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU i.age i.year i.GSA, ///
		 gmm(L.total) iv(exp_personal_lagged_1 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU i.age i.year i.GSA) ///
		 robust cluster(cohort) 
predict totalp if e(sample) 
corr total totalp if e(sample) 
di r(rho)^2
estadd scalar R2=r(rho)^2
outreg2 using "../../Tables/table_A7.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_personal_lagged_1) dec(3) nonotes nocons replace
estimates store EQ1, title(EQ1)

xtabond2 total l.total  exp_state_nat_lagged_1 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU i.age i.year i.GSA, ///
		 gmm(L.total) iv(exp_state_nat_lagged_1 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU i.age i.year i.GSA) ///
		 robust cluster(cohort) 
drop totalp		
predict totalp if e(sample) 
corr total totalp if e(sample) 
di r(rho)^2
estadd scalar R2=r(rho)^2
outreg2 using "../../Tables/table_a7.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_state_nat_lagged_1) dec(3) nonotes nocons append
estimates store EQ2, title(EQ2)

xtabond2 total l.total exp_state_nat_lagged_1 exp_personal_lagged_1 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU i.age i.year i.GSA, ///
		 gmm(L.total) iv(exp_state_nat_lagged_1 exp_personal_lagged_1 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU i.age i.year i.GSA) ///
		 robust cluster(cohort) 
drop totalp
predict totalp if e(sample) 
corr total totalp if e(sample) 
di r(rho)^2
estadd scalar R2=r(rho)^2
outreg2 using "../../Tables/table_A7.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_state_nat_lagged_1 exp_personal_lagged_1) dec(3) nonotes nocons append
estimates store EQ3, title(EQ3)


xtabond2 total l.total  exp_personal_nat_l3 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU i.age i.year i.GSA, ///
		 gmm(L.total) iv(exp_personal_nat_l3 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU i.age i.year i.GSA) ///
		 robust cluster(cohort) 
drop totalp
predict totalp if e(sample) 
corr total totalp if e(sample) 
di r(rho)^2
estadd scalar R2=r(rho)^2
outreg2 using "../../Tables/table_A7.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_personal_nat_l3) dec(3) nonotes nocons append
estimates store EQ4, title(EQ4)

xtabond2 total l.total  exp_state_nat_lagged_l3 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU i.age i.year i.GSA, ///
		 gmm(L.total) iv(exp_state_nat_lagged_l3 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU i.age i.year i.GSA) ///
		 robust cluster(cohort) 
drop totalp
predict totalp if e(sample) 
corr total totalp if e(sample) 
di r(rho)^2
estadd scalar R2=r(rho)^2
outreg2 using "../../Tables/table_A7.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_state_nat_lagged_l3) dec(3) nonotes nocons append
estimates store EQ5, title(EQ5)

xtabond2 total l.total exp_state_nat_lagged_l3 exp_personal_nat_l3 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU i.age i.year i.GSA, ///
		 gmm(L.total) iv(exp_state_nat_lagged_l3 exp_personal_nat_l3 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state `ctrl' i.HD_RACE i.HEAD_EDU i.age i.year i.GSA) ///
		 robust cluster(cohort) 
drop totalp
predict totalp if e(sample) 
corr total totalp if e(sample) 
di r(rho)^2
estadd scalar R2=r(rho)^2
outreg2 using "../../Tables/table_A7.tex", excel title (Dependent: Log Consumption Value) ctitle (Consumption_All) keep(exp_state_nat_lagged_l3 exp_personal_nat_l3) dec(3) nonotes nocons append
estimates store EQ6, title(EQ6)

esttab EQ1 EQ2 EQ3 EQ4 EQ5 EQ6 using "../../Tables/table_A7", ///
csv b(3) se(3) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) keep(exp_state_nat_lagged_1 exp_personal_lagged_1 exp_state_nat_lagged_l3 exp_personal_nat_l3) nogap replace scalars(R2) stats() 


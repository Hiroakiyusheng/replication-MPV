** Generate Table 5: Experience Effects and Future Income Volatility

clear 
est clear
clear mata 
clear matrix 
set more off 
clear mata 
capture log close 

use "../../data/PSID/psid_new_final_lag_LS.dta", clear  
keep if tag_10_90==1
sort ID year
by ID:gen num = _N
drop if num==1

xtset ID year

local ctrl income income2 l1_income l1_income2 liquid_wealth liquid2 illiquid_wealth illiquid2


/*excess log income*/
	egen min_income = min (INCOME_TOTAL_FAM)
	gen positive_min_income = INCOME_TOTAL_FAM - min_income + .1
	gen log_positive_min_income = log(positive_min_income)

	reghdfe log_positive_min_income GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP liquid_wealth illiquid_wealth i.HD_RACE i.HEAD_EDU, absorb(FE_AGE=age FE_REGION_YEAR=region_year FE_GSA=GSA) cluster(cohort) resid
	predict excess_l1_income, residuals
	by ID: gen excess_l1_income_lead2 = excess_l1_income[_n+2] if year+2 == year[_n+2]
	by ID: replace excess_l1_income_lead2 = excess_l1_income[_n+1] if year+2 == year[_n+1]

	by ID: gen excess_l1_income_lag4 = excess_l1_income[_n-4] if year-4 == year[_n-4]
	by ID: replace excess_l1_income_lag4 = excess_l1_income[_n-3] if year-4 == year[_n-3]
	by ID: replace excess_l1_income_lag4 = excess_l1_income[_n-2] if year-4 == year[_n-2]
	by ID: replace excess_l1_income_lag4 = excess_l1_income[_n-1] if year-4 == year[_n-1]

	by ID: gen excess_l1_income_lag2 = excess_l1_income[_n-2] if year-2 == year[_n-2]
	by ID: replace excess_l1_income_lag2 = excess_l1_income[_n-1] if year-2 == year[_n-1]

	gen twolagchange = excess_l1_income - excess_l1_income_lag2
	gen sixlagchange = excess_l1_income_lead2 - excess_l1_income_lag4

	gen permanent_change = twolagchange*sixlagchange
	gen square_change = twolagchange^2

	by ID: gen permanent_change_lag2 = permanent_change[_n-2] if year-2 == year[_n-2]
	by ID: replace permanent_change_lag2 = permanent_change[_n-1] if year-2 == year[_n-1]

	by ID: gen square_change_lag2 = square_change[_n-2] if year-2 == year[_n-2]
	by ID: replace square_change_lag2 = square_change[_n-1] if year-2 == year[_n-1]


	by ID: gen f2_permanent_change = permanent_change[_n+2] if year+2 == year[_n+2]
	by ID: replace f2_permanent_change = permanent_change[_n+1] if year+2 == year[_n+1]

	by ID: gen f4_permanent_change = permanent_change[_n+4] if year+4 == year[_n+4]
	by ID: replace f4_permanent_change = permanent_change[_n+3] if year+4 == year[_n+3]
	by ID: replace f4_permanent_change = permanent_change[_n+2] if year+4 == year[_n+2]
	by ID: replace f4_permanent_change = permanent_change[_n+1] if year+4 == year[_n+1]

	by ID: gen f6_permanent_change = permanent_change[_n+6] if year+6 == year[_n+6]
	by ID: replace f6_permanent_change = permanent_change[_n+5] if year+6 == year[_n+5]
	by ID: replace f6_permanent_change = permanent_change[_n+4] if year+6 == year[_n+4]
	by ID: replace f6_permanent_change = permanent_change[_n+3] if year+6 == year[_n+3]
	by ID: replace f6_permanent_change = permanent_change[_n+2] if year+6 == year[_n+2]
	by ID: replace f6_permanent_change = permanent_change[_n+1] if year+6 == year[_n+1]

	by ID: gen f2_square_change = square_change[_n+2] if year+2 == year[_n+2]
	by ID: replace f2_square_change = square_change[_n+1] if year+2 == year[_n+1]

	by ID: gen f4_square_change = square_change[_n+4] if year+4 == year[_n+4]
	by ID: replace f4_square_change = square_change[_n+3] if year+4 == year[_n+3]
	by ID: replace f4_square_change = square_change[_n+2] if year+4 == year[_n+2]
	by ID: replace f4_square_change = square_change[_n+1] if year+4 == year[_n+1]

	by ID: gen f6_square_change = square_change[_n+6] if year+6 == year[_n+6]
	by ID: replace f6_square_change = square_change[_n+5] if year+6 == year[_n+5]
	by ID: replace f6_square_change = square_change[_n+4] if year+6 == year[_n+4]
	by ID: replace f6_square_change = square_change[_n+3] if year+6 == year[_n+3]
	by ID: replace f6_square_change = square_change[_n+2] if year+6 == year[_n+2]
	by ID: replace f6_square_change = square_change[_n+1] if year+6 == year[_n+1]

	reghdfe f2_permanent_change exp_personal_lagged_1 exp_state_nat_lagged_1  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort)
   outreg2 using "../../Tables/table_5_lambda1.tex", excel title (Dependent: Variance of Income) ctitle (Permanent, t+2) keep(exp_personal_lagged_1 exp_state_nat_lagged_1 ) dec(3) nonotes nocons replace
estimates store EQ1, title(EQ1)

	reghdfe f2_square_change exp_personal_lagged_1 exp_state_nat_lagged_1  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort)
  outreg2 using "../../Tables/table_5_lambda1.tex", excel title (Dependent: Variance of Income) ctitle (Transitory, t+2) keep(exp_personal_lagged_1 exp_state_nat_lagged_1 ) dec(3) nonotes nocons append
estimates store EQ2, title(EQ2)

	reghdfe f4_permanent_change exp_personal_lagged_1 exp_state_nat_lagged_1 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort)
   outreg2 using "../../Tables/table_5_lambda1.tex", excel title (Dependent: Variance of Income) ctitle (Permanent, t+4) keep(exp_personal_lagged_1 exp_state_nat_lagged_1 ) dec(3) nonotes nocons append
estimates store EQ3, title(EQ3)

	reghdfe f4_square_change exp_personal_lagged_1 exp_state_nat_lagged_1  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort)
  outreg2 using "../../Tables/table_5_lambda1.tex", excel title (Dependent: Variance of Income) ctitle (Transitory, t+4) keep(exp_personal_lagged_1 exp_state_nat_lagged_1  ) dec(3) nonotes nocons append
estimates store EQ4, title(EQ4)

	reghdfe f6_permanent_change exp_personal_lagged_1 exp_state_nat_lagged_1  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort)
   outreg2 using "../../Tables/table_5_lambda1.tex", excel title (Dependent: Variance of Income) ctitle (Permanent, t+6) keep(exp_personal_lagged_1 exp_state_nat_lagged_1 ) dec(3) nonotes nocons append
estimates store EQ5, title(EQ5)

	reghdfe f6_square_change exp_personal_lagged_1 exp_state_nat_lagged_1  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort)
  outreg2 using "../../Tables/table_5_lambda1.tex", excel title (Dependent: Variance of Income) ctitle (Transitory, t+6) keep(exp_personal_lagged_1 exp_state_nat_lagged_1 ) dec(3) nonotes nocons append
estimates store EQ6, title(EQ6)


	reghdfe f2_permanent_change exp_personal_nat_l3 exp_state_nat_lagged_l3  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort)
   outreg2 using "../../Tables/table_5_lambda3.tex", excel title (Dependent: Variance of Income) ctitle (Permanent, t+2) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3 ) dec(3) nonotes nocons replace
estimates store EQ7, title(EQ7)

	reghdfe f2_square_change exp_personal_nat_l3 exp_state_nat_lagged_l3  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort)
  outreg2 using "../../Tables/table_5_lambda3.tex", excel title (Dependent: Variance of Income) ctitle (Transitory, t+2) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3 ) dec(3) nonotes nocons append
estimates store EQ8, title(EQ8)

	reghdfe f4_permanent_change exp_personal_nat_l3 exp_state_nat_lagged_l3  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort)
   outreg2 using "../../Tables/table_5_lambda3.tex", excel title (Dependent: Variance of Income) ctitle (Permanent, t+4) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3 ) dec(3) nonotes nocons append
estimates store EQ9, title(EQ9)

	reghdfe f4_square_change exp_personal_nat_l3 exp_state_nat_lagged_l3  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort)
  outreg2 using "../../Tables/table_5_lambda3.tex", excel title (Dependent: Variance of Income) ctitle (Transitory, t+4) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3 ) dec(3) nonotes nocons append
estimates store EQ10, title(EQ10)

	reghdfe f6_permanent_change exp_personal_nat_l3 exp_state_nat_lagged_l3  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort)
   outreg2 using "../../Tables/table_5_lambda3.tex", excel title (Dependent: Variance of Income) ctitle (Permanent, t+6) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3 ) dec(3) nonotes nocons append
estimates store EQ11, title(EQ11)

	reghdfe f6_square_change exp_personal_nat_l3 exp_state_nat_lagged_l3  GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP `ctrl' i.HD_RACE i.HEAD_EDU , absorb(age GSA year ID) cluster(cohort)
  outreg2 using "../../Tables/table_5_lambda3.tex", excel title (Dependent: Variance of Income) ctitle (Transitory, t+6) keep(exp_personal_nat_l3 exp_state_nat_lagged_l3 ) dec(3) nonotes nocons append
estimates store EQ12, title(EQ12)


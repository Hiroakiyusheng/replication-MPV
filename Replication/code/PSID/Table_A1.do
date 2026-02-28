** Generate Table A1: Summary Statistics (PSID), Full Sample

clear 
est clear 
clear mata 
clear matrix 
set more off 
set matsize 11000 
set maxvar 24000 
clear mata 

use "../../data/PSID/psid_new_final_lag_LS.dta", clear  
sort ID year
by ID:gen num = _N
drop if num==1
replace exp_personal_lagged_1 = exp_personal_lagged_1*100
replace exp_personal_nat_l3=exp_personal_nat_l3*100

ren age Age
ren FAM_NUM_TOTAL Household_Size
ren TOTAL_CONSUMP1 Household_Total_Consumption
ren INCOME_TOTAL_FAM Total_Income
ren LIQUID_WEALTH Household_Liquid_Wealth
ren ILLIQUID_WEALTH Household_Illiquid_Wealth
ren WEALTH_TOTAL Household_Total_Wealth
ren exp_personal_lagged_1 Unempl_Exp_Personal_lambda1
ren exp_personal_nat_l3 Unempl_Exp_Personal_lambda3
ren exp_state_nat_lagged_1 Unempl_Macro_lambda1
ren exp_state_nat_lagged_l3 Unempl_Macro_lambda3

est clear
estpost tabstat Age Household_Size Household_Total_Consumption Total_Income Household_Liquid_Wealth Household_Illiquid_Wealth ///
Household_Total_Wealth Unempl_Exp_Personal_lambda1 Unempl_Exp_Personal_lambda3 Unempl_Macro_lambda1 Unempl_Macro_lambda3, ///
c(stat) stat(mean sd p10 p50 p90 n)

esttab using "../../Tables/table_A1.tex", replace ////
 cells("mean sd p10 p50 p90 count")   nonumber ///
  nomtitle nonote noobs label booktabs ///
  collabels("Mean" "SD" "p10" "p50" "p90" "N")  ///
  title("Summary Statistics (PSID)")
  

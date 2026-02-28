** Generate Inputs for Figure 1: Examples of Experience Shocks from the Recession (PSID)

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
keep if ID==30519 | ID==50564 | ID==12586
keep if year==2007 | year==2013
gen ConsumpPerPerson=TOTAL_CONSUMP1/FAM_NUM_TOTAL
keep ID FAM_STATE_FIPS HEAD_AGE year exp_state_nat_lagged_1 ConsumpPerPerson
sort ID year
by ID: gen ConsumpPerPerson_g= (ConsumpPerPerson/ConsumpPerPerson[_n-1]-1)*100

export excel "../../Figures/figure_1_input.xlsx", firstrow(varlabels) replace

* Generated lagged experience measures
clear
set more off
* cd to "./Replication/code/exp_measures"	

*********************************************************************************
use "../../data/MSC/generated_years", clear
ren birth_year year_born
ren current_year yyyy

ren experience_lambda1_0 experience_lambda1
ren experience_lambda2_0 experience_lambda2
ren experience_lambda3_0 experience_lambda3
sort year_born yyyy
by year_born: gen experience_lambda1_lag= experience_lambda1[_n-1]
by year_born: gen experience_lambda2_lag= experience_lambda2[_n-1]
by year_born: gen experience_lambda3_lag= experience_lambda3[_n-1]

save "../../data/MSC/generated_years_lag", replace

*********************************************************************************
use "../../data/Nielsen/generated_months", clear

ren current_year panel_year 
ren current_term month
ren birth_year male_head_yrborn
ren birth_term male_head_mborn

sort male_head_yrborn male_head_mborn panel_year month
by male_head_yrborn male_head_mborn: gen experience_lambda1_lag=experience_lambda1_0[_n-1]
by male_head_yrborn male_head_mborn: gen experience_lambda3_lag=experience_lambda3_0[_n-1]

save "../../data/Nielsen/generated_months_lag",replace

*********************************************************************************
use "../../data/CEX/generated_quarters", clear

ren birth_term birth_q
ren current_year panel_year
ren current_term panel_q

sort birth_year birth_q panel_year panel_q
by birth_year birth_q: gen experience_lambda1_lag=experience_lambda1_0[_n-1]
by birth_year birth_q: gen experience_lambda3_lag=experience_lambda3_0[_n-1]
by birth_year birth_q: gen experience_lambda15_lag=experience_lambda1_5[_n-1]
by birth_year birth_q: gen experience_lambda2_lag=experience_lambda2_0[_n-1]

save "../../data/CEX/generated_quarters_lag",replace

set more off
clear

eststo clear

// You must manuall set education level (L/H/M)
global education_level "M"

//make tempfile
tempfile low_hold

//for each model type, each learning type and each learning parameter
foreach y in "1" "3" {
	foreach w in "consumption_scarring" {
		foreach x in "reg_data-beh_" {
		
//			first create the mixed education data
			import delimited "../../data/simulations/`w'/low_educ/`x'`y'.csv", clear
			
			gen educ = 0
			
			save `low_hold', replace

			import delimited "../../data/simulations/`w'/high_educ/`x'`y'.csv", clear

			gen educ = 1
			
			append using `low_hold'
			
//			keep 70% of simulations
			drop if id > 7000 & educ == 0
			drop if id <= 7000 & educ == 1
			
//			drop retirement
			drop if period > 160
			
//			log variables
			foreach z in consumption assets income {
				replace `z' = ln(`z')
			}
			
			label var consumption "Consumption"
			label var assets "Wealth"
			label var income "Income"
			label var p_delta "Unempl. Exp."
			
			if "`x'" == "reg_data_" {
				global learning_type "Rational"
			}
			else {
				global learning_type "EBL"
			}
			
			if "`w'" == "straight_pistaferri" {
				global consumption_scarring "Baseline"
			}
			else {
				global consumption_scarring "Extended"
			}

			
			xtset id period
			
			forvalues i = 8(8)40 {

				reghdfe F`i'.income p_delta income assets, absorb(period educ) cluster(period)
		// 		estadd local all_or_adj "All"
				estadd local lambda "`y'"
				estadd local B_or_R "$learning_type"
				estadd local educ_lvl "$education_level"
				estadd local cons_s   "$consumption_scarring"	
				estadd local C_or_Reg "Yes"
				estadd local P_FE "Yes"
				eststo

			}
		}
	}
}

esttab using "../../Tables/table_c2.csv",  replace label b(%8.3f) t  nocon nostar ///
keep(p_delta) ///
s(lambda B_or_R cons_s C_or_Reg P_FE r2 N, label("Lambda" "Rational or EBL" "Model" "Period Clustered SE" "Period (Age) FE" "R2"))

esttab using "../../Tables/table_c2.tex", replace label nocon nostar ///
keep(p_delta) ///
s(lambda B_or_R cons_s C_or_Reg P_FE r2 N, label("Lambda" "Rational or EBL" "Model" "Period Clustered SE" "Period (Age) FE" "$ R^2$"))

eststo clear

/************************************************************************************************
  cd to the folder that stores this code: cd "./Replication/code/PSID/Table_A4"
  
  Input: "psid_new_with_exp_allf_lagged_spouse.dta"
		 
  Output: "psid_new_final_spouses.dta"

************************************************************************************************/
clear 
clear mata 
clear matrix 
set more off 
set matsize 11000 
set maxvar 24000 
clear mata 
capture log close 


/* Upload data */
use "psid_new_with_exp_allf_lagged_spouse.dta", clear  


/* Drop immigrant sample - 5051 obs. dropped */
drop if Fam_ID > 3000 & Fam_ID < 5000 


/* Keep 25 <= age <= 75  - 36648 obs. dropped */
drop if age < 25 | age >75  


/* Create weighted experience measure */
sort INTERVIEW_ID year 
by INTERVIEW_ID year: egen exp_personal_hh = mean(exp_personal_lagged_1) 
by INTERVIEW_ID year: egen exp_state_nat_hh = mean(exp_state_nat_lagged_1) 
by INTERVIEW_ID year: egen exp_personal_hh_l3 = mean(exp_personal_nat_l3) 
by INTERVIEW_ID year: egen exp_state_nat_hh_l3 = mean(exp_state_nat_lagged_l3) 
duplicates tag INTERVIEW_ID year, gen(couple) 

/* Keep heads only */
drop if HEAD != 1 
drop SPOUSE 	

/* Generating lagged income */
sort ID year  
bysort ID: gen seq = _n 
xtset ID seq 
gen L1_INCOME = L1.INCOME_TOTAL_FAM 

/* Define Unemployment */
gen UNEMP = 0 if EMPLOY_STATUS == 1 | EMPLOY_STATUS == 4 | EMPLOY_STATUS == 5 ///
 | EMPLOY_STATUS == 6 | EMPLOY_STATUS == 7 | EMPLOY_STATUS == 2 
replace UNEMP = 1 if EMPLOY_STATUS == 3 


/* Drop observations with variables missing */
drop if FOOD_C ==. 
drop if GSA ==. 
drop if FAM_REGION == 6 
drop if HEAD_EDU ==. | UNEMP ==. | HD_RACE == . 
drop if L1_INCOME ==. 


/* Divide wealth into liquid and illiquid */		
gen     LIQUID_WEALTH = . 
replace LIQUID_WEALTH = CHECK_SAVING + STOCK - DEBT if year != 2013 
replace LIQUID_WEALTH = CHECK_SAVING + STOCK - DEBT + FARMBUS_DEBT_13 + ///
		REALESTATE_DEBT_13 if year == 2013 
gen     ILLIQUID_WEALTH = . 
replace ILLIQUID_WEALTH = FARM_BUS + OTHER_REAL_ESTATE + VEHICLE_VALUE + OTHER_ASSET_VALUE + ///
		HOME_EQUITY_VALUE if year == 1984 | year == 1994 
replace ILLIQUID_WEALTH = FARM_BUS + OTHER_REAL_ESTATE + VEHICLE_VALUE + OTHER_ASSET_VALUE + ///
		HOME_EQUITY_VALUE + ANNUITY_IRA if year >= 1999 & year != 2013 
replace ILLIQUID_WEALTH = FARM_BUS + OTHER_REAL_ESTATE + VEHICLE_VALUE + OTHER_ASSET_VALUE + ///
		ANNUITY_IRA - FARMBUS_DEBT_13 - REALESTATE_DEBT_13 + HOME_EQUITY_VALUE if year == 2013 

 
/* Adjust for inflation using PCE, using 2013 dollars */ 
gen PCE2013 = PCE if year == 2017   
rename PCE2013 PCE2013ORIGINAL 
egen   PCE2013 = median(PCE2013ORIGINAL) 
gen FOOD_C_A = FOOD_C * PCE2013/PCE 
gen FDHM_A = FDHM * PCE2013/PCE 
gen FDOUT_A = FDOUT * PCE2013/PCE 
gen TOTAL_CONSUMP1_A = TOTAL_CONSUMP1 * PCE2013/PCE 
gen HOUS_A = HOUS * PCE2013/PCE 
gen CHILD_A = CHILD * PCE2013/PCE 
gen HEALTH_A = HEALTH * PCE2013/PCE 
gen TRAN_A = TRAN * PCE2013/PCE 
gen ED_A = ED * PCE2013/PCE 
gen INCOME_TOTAL_FAM_A = INCOME_TOTAL_FAM * PCE2013/PCE 
gen WEALTH_TOTAL_A = WEALTH_TOTAL * PCE2013/PCE 
gen LIQUID_WEALTH_A = LIQUID_WEALTH * PCE2013/PCE 
gen ILLIQUID_WEALTH_A = ILLIQUID_WEALTH * PCE2013/PCE 


/* Delete singletons */
duplicates tag ID, gen(tag) 
sort ID year 
by ID: gen _obs = _n 
by ID: gen _OBS = _N 
label variable _obs "ID order by year" 
label variable _OBS "ID toal obs." 
drop if tag == 0 
drop tag 


/* Take log of consumption */

gen food = log(FOOD_C + 0.1) 
gen fdhm = log(FDHM + 0.1) 
gen fdout = log(FDOUT + 0.1) 
gen hous = log(HOUS + 368.51)  
* the lowest value is -368.41 
gen child = log(CHILD + 216.75) 
* the lowest value is -216.65 
gen health = log(HEALTH + 18.3) 
* the lowest value is -18.2 
gen ed = log(ED + 0.1) 
gen tran = log(TRAN + 0.1) 
gen total = log(TOTAL_CONSUMP1 + 0.1) 


/* Adding constant before taking log */
  	gen liquid_wealth = log(LIQUID_WEALTH + 8926000.1) /* the lowest value of LIQUID_WEALTH is -2900000 */
	gen illiquid_wealth = log(ILLIQUID_WEALTH + 359946.1) /* the lowest value of ILLIQUID_WEALTH is -1855000 */
	gen total_wealth = log(WEALTH_TOTAL + 2320000.1) /* the lowest value of TOTAL_WEALTH is -1860400 */
	gen income = log(INCOME_TOTAL_FAM + 84022.1) /* the lowest income value is -99265 */
	gen l1_income = log(L1_INCOME + 84022.1) /* the lowest income value is -99265 */

/* Generate group dummies */
egen state_year = group(GSA year) 
egen region_year = group(FAM_REGION year) 
gen GENDER = GENDER_INDIVIDUAL -1 
gen cohort = year - age 
egen cohort_year = group(cohort year) 
egen ID_year = group(ID year) 


/* Generating 5 quantiles */
#delimit cr
foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017 {
	  xtile liquid`x' = liquid_wealth if year == `x', nq(5)
	}
	  gen liquid_q5 =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace liquid_q5 = liquid`x' if year == `x'
	  drop liquid`x'
	}
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  xtile illiquid`x' = illiquid_wealth if year == `x', nq(5)
	}
	  gen illiquid_q5 =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace illiquid_q5 = illiquid`x' if year == `x'
	  drop illiquid`x'
	}
	

foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  xtile income`x' = income if year == `x', nq(5)
	}
	  gen income_q5 =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace income_q5 = income`x' if year == `x'
	  drop income`x'
	}
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  xtile l1_income`x' = l1_income if year == `x', nq(5)
	}
	  gen l1_income_q5 =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace l1_income_q5 = l1_income`x' if year == `x'
	  drop l1_income`x'
	}
	
/* Generating 50 quantiles */

foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  xtile liquid`x' = liquid_wealth if year == `x', nq(50)
	}
	  gen liquid_q50 =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace liquid_q50 = liquid`x' if year == `x'
	  drop liquid`x'
	}
foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  xtile income`x' = income if year == `x', nq(50)
	}
	  gen income_q50 =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace income_q50 = income`x' if year == `x'
	  drop income`x'
	}

gen xinc = (income_q50==1)
replace xinc = 2 if income_q50==2
replace xinc = 3 if income_q50==3
replace xinc = 4 if income_q50==4
replace xinc = 5 if income_q50==5
replace xinc = 6 if income_q50==46
replace xinc = 7 if income_q50==47
replace xinc = 8 if income_q50==48
replace xinc = 9 if income_q50==49
replace xinc = 10 if income_q50==50

gen xliq = (liquid_q50==1)
replace xliq = 2 if liquid_q50==2
replace xliq = 3 if liquid_q50==3
replace xliq = 4 if liquid_q50==4
replace xliq = 5 if liquid_q50==5
replace xliq = 6 if liquid_q50==46
replace xliq = 7 if liquid_q50==47
replace xliq = 8 if liquid_q50==48
replace xliq = 9 if liquid_q50==49
replace xliq = 10 if liquid_q50==50
	

/* Generating 5_95 tag */
foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  xtile income`x' = income if year == `x', nq(20)
	}
	  gen income_d =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace income_d = income`x' if year == `x'
	  drop income`x'
	}

gen tag_5_95 = (income_d>1)
replace tag_5_95 = 0 if income_d==20
gen tag_10_90 = (income_d>2)
replace tag_10_90 = 0 if income_d>18
drop income_d 

/* Generatin log sq. variables */
gen income2 = income^2
gen l1_income2 = l1_income^2
gen liquid2 = liquid_wealth^2 
gen illiquid2 = illiquid_wealth^2 
gen income3 = income^3
gen l1_income3 = l1_income^3
gen liquid3 = liquid_wealth^3 
gen illiquid3 = illiquid_wealth^3 
gen income4 = income^4
gen l1_income4 = l1_income^4
gen liquid4 = liquid_wealth^4 
gen illiquid4 = illiquid_wealth^4 

/* Appendix */
gen wealth = log(WEALTH_TOTAL + 1860400.1) 
gen housing = log(HOME_EQUITY_VALUE + 908000.1) 
gen other = log(WEALTH_EXCLUDE_EQUITY + 1991000.1)
gen WEALTH_DB = WEALTH_TOTAL + TOTAL_DEBT 
gen wealth_db = log(WEALTH_DB + 0.1)
gen total_debt = log(TOTAL_DEBT + 0.1)
gen LIQUID_WEALTH_P = CHECK_SAVING + STOCK
gen liquid_wealth_p = log(LIQUID_WEALTH_P + 0.1)
replace DEBT = DEBT - FARMBUS_DEBT_13 - REALESTATE_DEBT_13 if year == 2013
gen debt = log(DEBT + 0.1)
	

foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
  xtile liquid`x' = LIQUID_WEALTH if year == `x', nq(10)
}
  gen liquid_q10 =.
foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
  replace liquid_q10 = liquid`x' if year == `x'
  drop liquid`x'
}
foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
  xtile income`x' = income if year == `x', nq(10)
}
  gen income_q10 =.
foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
  replace income_q10 = income`x' if year == `x'
  drop income`x'
}
	

replace exp_personal_hh = exp_personal_hh/100
replace exp_personal_hh_l3=exp_personal_hh_l3/100

	
save "psid_new_final_spouses.dta", replace 



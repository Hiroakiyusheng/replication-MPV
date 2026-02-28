/************************************************************************************************
  Input: "../../data/PSID/psid_new_with_exp_allf_lagged.dta"
		 
  Output: "../../data/PSID/psid_new_final_lag_LS.dta"

  cd to the folder that stores this code: cd "./Replication/code/PSID"
************************************************************************************************/

clear 
clear mata 
clear matrix 
set more off 
set matsize 11000 
set maxvar 24000 
clear mata 
capture log close 

use "../../data/PSID/psid_new_with_exp_allf_lagged.dta", clear 


    drop if Fam_ID > 3000 & Fam_ID < 5000 /* drop Immigrant Sample */
    drop if age < 25 | age >75 

	sort ID year
	bysort ID: gen seq = _n
    xtset ID seq
	gen L1_INCOME = L1.INCOME_TOTAL_FAM
	****************************
	
	** lagged unemployment controls **
    gen UNEMP = 0 if EMPLOY_STATUS == 1 | EMPLOY_STATUS == 4 | EMPLOY_STATUS == 5 | EMPLOY_STATUS == 6 ///
      | EMPLOY_STATUS == 7 | EMPLOY_STATUS == 2
    replace UNEMP = 1 if EMPLOY_STATUS == 3
	gen L1_UNEMP = L1.UNEMP
	gen L2_UNEMP = L2.UNEMP
	gen L3_UNEMP = L3.UNEMP
		
  /* drop observations with variables missing */
	ren exp_personal_nat2 exp_personal_lagged_1 
	drop if FOOD_C ==.
	drop if GSA ==.
	drop if FAM_REGION == 6
	drop if exp_state_nat_lagged_1 == .
	drop if exp_personal_lagged_1 == .
	drop if HEAD_EDU ==. | UNEMP ==. | HD_RACE == .
	drop if L1_INCOME ==.
	drop if L1_UNEMP == . | L2_UNEMP == . | L3_UNEMP == .
	
  /* divide wealth into liquid and illiquid */	
	gen LIQUID_WEALTH = .
	replace LIQUID_WEALTH = CHECK_SAVING + STOCK - DEBT if year != 2013 
	replace LIQUID_WEALTH = CHECK_SAVING + STOCK - DEBT + FARMBUS_DEBT_13 + REALESTATE_DEBT_13 if year == 2013
	gen ILLIQUID_WEALTH = .
	replace ILLIQUID_WEALTH = FARM_BUS + OTHER_REAL_ESTATE + VEHICLE_VALUE + OTHER_ASSET_VALUE + HOME_EQUITY_VALUE if year == 1984 | year == 1994
	replace ILLIQUID_WEALTH = FARM_BUS + OTHER_REAL_ESTATE + VEHICLE_VALUE + OTHER_ASSET_VALUE + HOME_EQUITY_VALUE + ANNUITY_IRA if year >= 1999 & year != 2013
	replace ILLIQUID_WEALTH = FARM_BUS + OTHER_REAL_ESTATE + VEHICLE_VALUE + OTHER_ASSET_VALUE + ANNUITY_IRA ///
	  - FARMBUS_DEBT_13 - REALESTATE_DEBT_13 + HOME_EQUITY_VALUE if year == 2013

		
	gen PCE2013 = PCE if year == 2017   /* adjust for inflation using PCE, using 2013 dollars */
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
	  	
	
	duplicates tag ID, gen(tag)
	drop if tag == 0 /* singletons */
	drop tag
	
	    	
/* MAIN REGRESSIONS -- REGRESSIONS IN THE MAIN TEXT */
  /* take log of consumption */
	gen food = log(FOOD_C + 0.1)
	gen fdhm = log(FDHM + 0.1)
	gen fdout = log(FDOUT + 0.1)
	gen hous = log(HOUS + 0.1) /* the lowest value is -368.41 */
	gen child = log(CHILD + 216.65) /* the lowest value is -216.65 */
	gen health = log(HEALTH + 0.1) /* the lowest value is -18.2 */
	gen ed = log(ED + 0.1)
	gen tran = log(TRAN + 0.1)
	gen total = log(TOTAL_CONSUMP1 + 0.1)
  /* adding constant before taking log */
  	gen liquid_wealth = log(LIQUID_WEALTH + 8926000.1) /* the lowest value of LIQUID_WEALTH is -2900000 */
	gen illiquid_wealth = log(ILLIQUID_WEALTH + 359946.1) /* the lowest value of ILLIQUID_WEALTH is -1855000 */
	gen total_wealth = log(WEALTH_TOTAL + 2320000.1) /* the lowest value of TOTAL_WEALTH is -1860400 */
	gen income = log(INCOME_TOTAL_FAM + 84022.1) /* the lowest income value is -99265 */
	gen l1_income = log(L1_INCOME + 84022.1) /* the lowest income value is -99265 */
	
	
  /* generate group dummies */
    egen state_year = group(GSA year)
    egen region_year = group(FAM_REGION year)
	gen GENDER = GENDER_INDIVIDUAL -1
    gen cohort = year - age

   /* generating 2nd order var */
   gen income2 = income^2
   gen l1_income2 = l1_income^2
   gen liquid2 = liquid^2
   gen illiquid2 = illiquid^2
   
   
foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  xtile income`x' = income if year == `x', nq(20)
	}
	  gen income_d =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace income_d = income`x' if year == `x'
	  drop income`x'
	}
	
gen tag_5_95 = (income_d>1)
replace tag_5_95 = 0 if income_d>19	
gen tag_10_90 = (income_d>2)
replace tag_10_90 = 0 if income_d>18

#delimit ;
/* Generatin high order variables */
gen income3 = income^3;
gen l1_income3 = l1_income^3;
gen liquid3 = liquid_wealth^3 ;
gen illiquid3 = illiquid_wealth^3 ;
gen income4 = income^4;
gen l1_income4 = l1_income^4;
gen liquid4 = liquid_wealth^4 ;
gen illiquid4 = illiquid_wealth^4 ;


/* Appendix */
gen wealth = log(WEALTH_TOTAL + 2320000.1) ;
gen housing = log(HOME_EQUITY_VALUE + 908000.1) ;
gen other = log(WEALTH_EXCLUDE_EQUITY + 3050000.1);
gen WEALTH_DB = WEALTH_TOTAL + TOTAL_DEBT ;
gen wealth_db = log(WEALTH_DB + 0.1);
gen total_debt = log(TOTAL_DEBT + 0.1);
gen LIQUID_WEALTH_P = CHECK_SAVING + STOCK;
gen liquid_wealth_p = log(LIQUID_WEALTH_P + 0.1);
replace DEBT = DEBT - FARMBUS_DEBT_13 - REALESTATE_DEBT_13 if year == 2013;
gen debt = log(DEBT + 0.1);
	
bysort year: egen LIQUID_WEALTH_med = median(LIQUID_WEALTH) ;
bysort year: egen ILLIQUID_WEALTH_med = median(ILLIQUID_WEALTH) ;
bysort year: egen WEALTH_med = median(WEALTH_TOTAL) ;
gen liquid_wealth_low = (LIQUID_WEALTH<LIQUID_WEALTH_med) ;
gen mexp_wealth = exp_state_nat_lagged_1*liquid_wealth_low ; 
gen pexp_wealth = exp_personal_lagged_1*liquid_wealth_low ;
	
#delimit cr
foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  xtile liquid`x' = liquid_wealth if year == `x', nq(10)
	}
	  gen liquid_q10_10_90 =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace liquid_q10_10_90 = liquid`x' if year == `x'
	  drop liquid`x'
	}

foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
  xtile illiquid`x' = illiquid_wealth if year == `x', nq(10)
}
  gen illiquid_q10_10_90 =.
foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
  replace illiquid_q10_10_90 = illiquid`x' if year == `x'
  drop illiquid`x'
}

foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  xtile income`x' = income if year == `x', nq(5)
	}
	  gen income_q5_10_90 =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace income_q5_10_90 = income`x' if year == `x'
	  drop income`x'
	}

foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  xtile l1_income`x' = l1_income if year == `x', nq(5)
	}
	  gen l1_income_q5_10_90 =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace l1_income_q5_10_90 = l1_income`x' if year == `x'
	  drop l1_income`x'
	}
	
foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  xtile income`x' = income if year == `x', nq(10)
	}
	  gen income_q10_10_90 =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace income_q10_10_90 = income`x' if year == `x'
	  drop income`x'	
	}
	
foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  xtile l1_income`x' = l1_income if year == `x', nq(10)
	}
	  gen l1_income_q10_10_90 =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace l1_income_q10_10_90 = l1_income`x' if year == `x'
	  drop l1_income`x'	
	}	
	
foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  xtile income`x' = income if year == `x', nq(50)
	}
	  gen income_q50 =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace income_q50 = income`x' if year == `x'
	  drop income`x'
	}
foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  xtile l1_income`x' = l1_income if year == `x', nq(50)
	}
	  gen l1_income_q50 =.
	foreach x of numlist 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017{
	  replace l1_income_q50 = l1_income`x' if year == `x'
	  drop l1_income`x'
	}
	
gen xinc =(income_q50==1)
replace xinc = 2 if income_q50==2
replace xinc = 3 if income_q50==3
replace xinc = 4 if income_q50==4
replace xinc = 5 if income_q50==5
replace xinc = 6 if income_q50==46
replace xinc = 7 if income_q50==47
replace xinc = 8 if income_q50==48
replace xinc = 9 if income_q50==49
replace xinc = 10 if income_q50==50

gen xl1inc =(l1_income_q50==1)
replace xl1inc = 2 if l1_income_q50==2
replace xl1inc = 3 if l1_income_q50==3
replace xl1inc = 4 if l1_income_q50==4
replace xl1inc = 5 if l1_income_q50==5
replace xl1inc = 6 if l1_income_q50==46
replace xl1inc = 7 if l1_income_q50==47
replace xl1inc = 8 if l1_income_q50==48
replace xl1inc = 9 if l1_income_q50==49
replace xl1inc = 10 if l1_income_q50==50


drop if income==. | income2==. | l1_income==. | l1_income2==. | liquid_wealth==. ///
 | liquid2==. | illiquid_wealth==. | illiquid2==.	
replace exp_personal_lagged_1 = exp_personal_lagged_1/100
replace exp_personal_nat_l3=exp_personal_nat_l3/100
replace exp_personal_nat_1g = exp_personal_nat_1g/100
replace exp_personal_nat_3g=exp_personal_nat_3g/100
egen cohort_year = group(cohort year)
egen ID_year = group(ID year)

save "../../data/PSID/psid_new_final_lag_LS.dta", replace

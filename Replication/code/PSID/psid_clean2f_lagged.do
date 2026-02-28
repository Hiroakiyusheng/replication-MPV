cap log close

/************************************************************************************************
  Input: 1. "../../data/PSID/psid_new"
         2. "../../data/PSID/individual_exp_state_nat_lagged_1.dta"
		 3. "../../data/PSID/individual_exp_personal_lagged_1.dta"
		 4. "../../data/PSID/individual_exp_state_nat_lagged_1_lambda3.dta"
         5. "../../data/PSID/individual_exp_personal_lagged_1_lambda3.dta"
		 6. "../../raw/state_UE_1976_2017.dta"
		 7. "../../raw/nat_UE_1890_2017.dta"
		 8. "../../raw/PCE_use2.xls"
		 
  Output: "../../data/PSID/psid_new_with_exp_fzero_lagged.dta"
  
  cd to the folder that stores this code: cd "./Replication/code/PSID"
************************************************************************************************/
clear
set more off

use "../../data/PSID/psid_new"

/* Step 1: clean the variables (adjust time units/brackets, etc.) */

  /* Clean head education levels -- replace bracket variable to mean */
  foreach x of numlist 1968/1974 1985/1990 {
    replace HEAD_EDU = 2.5 if HEAD_EDU == 1 & year == `x'
	replace HEAD_EDU = 7 if HEAD_EDU == 2 & year == `x'
	replace HEAD_EDU = 10 if HEAD_EDU == 3 & year == `x'
	replace HEAD_EDU = 12 if HEAD_EDU == 4 & year == `x'
	replace HEAD_EDU = 13 if HEAD_EDU == 5 & year == `x'
	replace HEAD_EDU = 14 if HEAD_EDU == 6 & year == `x'
	replace HEAD_EDU = 16 if HEAD_EDU == 7 & year == `x'
	replace HEAD_EDU = 17 if HEAD_EDU == 8 & year == `x'
	replace HEAD_EDU = . if HEAD_EDU == 9 & year == `x'
  }
  replace HEAD_EDU =. if HEAD_EDU >90
  
  /* Clean food consumption*/
  /* Generate whether using food stamps */
  gen WHETHER_FOOD_STAMPS = 1 if EXPENSE_FOODHOME_STAMP_WHETHER == 1 | EXPENSE_FOODHOME_STAMP_WHETHER == 5
  replace WHETHER_FOOD_STAMPS = 0 if EXPENSE_FOODHOME_STAMP_WHETHER == 0 /* Use this variable as an indicator
  for whether used food stamps. Though this is not a variable directly for answering whether used food stamps.
  But I treat observations answering this question as using food stamps. After checking, this variable is
  reasonable to use */
  
  /* Use time units to calculate annual amount */
  replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = 52 if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 1 & year == 1994
  replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = 26 if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 2 & year == 1994
  replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = 12 if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 3 & year == 1994
  replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = . if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 4 & year == 1994
  replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = . if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 8 & year == 1994
  replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = . if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 9 & year == 1994
  replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = . if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 0 & year == 1994
  
  foreach x of numlist 1995/1997 1999 {
    replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = 365 if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 2 & year == `x'
    replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = 52 if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 3 & year == `x'
    replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = 26 if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 4 & year == `x'
    replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = 12 if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 5 & year == `x'
	replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = 1 if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 6 & year == `x'
	replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = . if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 7 & year == `x'
    replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = . if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 8 & year == `x'
    replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = . if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 9 & year == `x'
    replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = . if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 0 & year == `x'
  }
  foreach x of numlist 2001 2003 2005 2007 2009 2011 2013 2015 2017 {
    replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = . if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 2 & year == `x'
    replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = 52 if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 3 & year == `x'
    replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = 26 if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 4 & year == `x'
    replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = 12 if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 5 & year == `x'
	replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = 1 if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 6 & year == `x'
	replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = . if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 7 & year == `x'
    replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = . if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 8 & year == `x'
    replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = . if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 9 & year == `x'
    replace EXPENSE_FOODHOME_NOSTAMPS_UNIT = . if EXPENSE_FOODHOME_NOSTAMPS_UNIT == 0 & year == `x'
  }
  replace EXPENSE_FOOD_HOME_NOSTAMPS =. if EXPENSE_FOOD_HOME_NOSTAMPS > 99997
  gen EXPENSE_FOODHOME_NOSTAMPS = EXPENSE_FOODHOME_NOSTAMPS_UNIT * EXPENSE_FOOD_HOME_NOSTAMPS
  
  replace EXPENSE_FOODHOME_AMOUNT_UNIT = 52 if EXPENSE_FOODHOME_AMOUNT_UNIT == 1 & year == 1994
  replace EXPENSE_FOODHOME_AMOUNT_UNIT = 26 if EXPENSE_FOODHOME_AMOUNT_UNIT == 2 & year == 1994
  replace EXPENSE_FOODHOME_AMOUNT_UNIT = 12 if EXPENSE_FOODHOME_AMOUNT_UNIT == 3 & year == 1994
  replace EXPENSE_FOODHOME_AMOUNT_UNIT = . if EXPENSE_FOODHOME_AMOUNT_UNIT == 4 & year == 1994
  replace EXPENSE_FOODHOME_AMOUNT_UNIT = . if EXPENSE_FOODHOME_AMOUNT_UNIT == 8 & year == 1994
  replace EXPENSE_FOODHOME_AMOUNT_UNIT = . if EXPENSE_FOODHOME_AMOUNT_UNIT == 9 & year == 1994
  replace EXPENSE_FOODHOME_AMOUNT_UNIT = . if EXPENSE_FOODHOME_AMOUNT_UNIT == 0 & year == 1994
  
  foreach x of numlist 1995/1997 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017 {
    replace EXPENSE_FOODHOME_AMOUNT_UNIT = 365 if EXPENSE_FOODHOME_AMOUNT_UNIT == 2 & year == `x'
    replace EXPENSE_FOODHOME_AMOUNT_UNIT = 52 if EXPENSE_FOODHOME_AMOUNT_UNIT == 3 & year == `x'
    replace EXPENSE_FOODHOME_AMOUNT_UNIT = 26 if EXPENSE_FOODHOME_AMOUNT_UNIT == 4 & year == `x'
    replace EXPENSE_FOODHOME_AMOUNT_UNIT = 12 if EXPENSE_FOODHOME_AMOUNT_UNIT == 5 & year == `x'
	replace EXPENSE_FOODHOME_AMOUNT_UNIT = 1 if EXPENSE_FOODHOME_AMOUNT_UNIT == 6 & year == `x'
	replace EXPENSE_FOODHOME_AMOUNT_UNIT = . if EXPENSE_FOODHOME_AMOUNT_UNIT == 7 & year == `x'
    replace EXPENSE_FOODHOME_AMOUNT_UNIT = . if EXPENSE_FOODHOME_AMOUNT_UNIT == 8 & year == `x'
    replace EXPENSE_FOODHOME_AMOUNT_UNIT = . if EXPENSE_FOODHOME_AMOUNT_UNIT == 9 & year == `x'
    replace EXPENSE_FOODHOME_AMOUNT_UNIT = . if EXPENSE_FOODHOME_AMOUNT_UNIT == 0 & year == `x'
  }
  replace EXPENSE_FOOD_HOME_AMOUNT =. if EXPENSE_FOOD_HOME_AMOUNT > 99997
  gen EXPENSE_FOODHOME_STAMPS = EXPENSE_FOOD_HOME_AMOUNT * EXPENSE_FOODHOME_AMOUNT_UNIT
  
  replace EXPENSE_FOOD_HOME = EXPENSE_FOODHOME_STAMPS if WHETHER_FOOD_STAMPS == 1
  replace EXPENSE_FOOD_HOME = EXPENSE_FOODHOME_NOSTAMPS if WHETHER_FOOD_STAMPS == 0
  ***********************************************************************************************
  replace EXPENSE_FOODOUT_STAMPS_UNIT = 52 if EXPENSE_FOODOUT_STAMPS_UNIT == 1 & year == 1994
  replace EXPENSE_FOODOUT_STAMPS_UNIT = 26 if EXPENSE_FOODOUT_STAMPS_UNIT == 2 & year == 1994
  replace EXPENSE_FOODOUT_STAMPS_UNIT = 12 if EXPENSE_FOODOUT_STAMPS_UNIT == 3 & year == 1994
  replace EXPENSE_FOODOUT_STAMPS_UNIT = . if EXPENSE_FOODOUT_STAMPS_UNIT == 4 & year == 1994
  replace EXPENSE_FOODOUT_STAMPS_UNIT = . if EXPENSE_FOODOUT_STAMPS_UNIT == 8 & year == 1994
  replace EXPENSE_FOODOUT_STAMPS_UNIT = . if EXPENSE_FOODOUT_STAMPS_UNIT == 9 & year == 1994
  replace EXPENSE_FOODOUT_STAMPS_UNIT = . if EXPENSE_FOODOUT_STAMPS_UNIT == 0 & year == 1994
  
  foreach x of numlist 1995/1997 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017 {
    replace EXPENSE_FOODOUT_STAMPS_UNIT = 365 if EXPENSE_FOODOUT_STAMPS_UNIT == 2 & year == `x'
    replace EXPENSE_FOODOUT_STAMPS_UNIT = 52 if EXPENSE_FOODOUT_STAMPS_UNIT == 3 & year == `x'
    replace EXPENSE_FOODOUT_STAMPS_UNIT = 26 if EXPENSE_FOODOUT_STAMPS_UNIT == 4 & year == `x'
    replace EXPENSE_FOODOUT_STAMPS_UNIT = 12 if EXPENSE_FOODOUT_STAMPS_UNIT == 5 & year == `x'
	replace EXPENSE_FOODOUT_STAMPS_UNIT = 1 if EXPENSE_FOODOUT_STAMPS_UNIT == 6 & year == `x'
	replace EXPENSE_FOODOUT_STAMPS_UNIT = . if EXPENSE_FOODOUT_STAMPS_UNIT == 7 & year == `x'
    replace EXPENSE_FOODOUT_STAMPS_UNIT = . if EXPENSE_FOODOUT_STAMPS_UNIT == 8 & year == `x'
    replace EXPENSE_FOODOUT_STAMPS_UNIT = . if EXPENSE_FOODOUT_STAMPS_UNIT == 9 & year == `x'
    replace EXPENSE_FOODOUT_STAMPS_UNIT = . if EXPENSE_FOODOUT_STAMPS_UNIT == 0 & year == `x'
  }
  replace EXPENSE_FOOD_OUT_STAMPS =. if EXPENSE_FOOD_OUT_STAMPS > 99997
  gen EXPENSE_FOODOUT_STAMPS = EXPENSE_FOOD_OUT_STAMPS * EXPENSE_FOODOUT_STAMPS_UNIT
  
  replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = 52 if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 1 & year == 1994
  replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = 26 if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 2 & year == 1994
  replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = 12 if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 3 & year == 1994
  replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = . if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 4 & year == 1994
  replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = . if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 8 & year == 1994
  replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = . if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 9 & year == 1994
  replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = . if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 0 & year == 1994
  
  foreach x of numlist 1995/1997 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017 {
    replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = 365 if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 2 & year == `x'
    replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = 52 if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 3 & year == `x'
    replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = 26 if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 4 & year == `x'
    replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = 12 if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 5 & year == `x'
	replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = 1 if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 6 & year == `x'
	replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = . if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 7 & year == `x'
    replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = . if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 8 & year == `x'
    replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = . if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 9 & year == `x'
    replace EXPENSE_FOODOUT_NOSTAMPS_UNIT = . if EXPENSE_FOODOUT_NOSTAMPS_UNIT == 0 & year == `x'
  }
  replace EXPENSE_FOOD_OUT_NOSTAMPS =. if EXPENSE_FOOD_OUT_NOSTAMPS > 99997
  gen EXPENSE_FOODOUT_NOSTAMPS = EXPENSE_FOOD_OUT_NOSTAMPS * EXPENSE_FOODOUT_NOSTAMPS_UNIT
  
  replace EXPENSE_FOOD_OUT = EXPENSE_FOODOUT_STAMPS if WHETHER_FOOD_STAMPS == 1
  replace EXPENSE_FOOD_OUT = EXPENSE_FOODOUT_NOSTAMPS if WHETHER_FOOD_STAMPS == 0
  ***********************************************************************************************
  replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = 52 if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 1 & year == 1994
  replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = 26 if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 2 & year == 1994
  replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = 12 if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 3 & year == 1994
  replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = . if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 4 & year == 1994
  replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = . if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 8 & year == 1994
  replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = . if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 9 & year == 1994
  replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = . if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 0 & year == 1994
  
  foreach x of numlist 1995/1997 1999 {
    replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = 365 if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 2 & year == `x'
    replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = 52 if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 3 & year == `x'
    replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = 26 if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 4 & year == `x'
    replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = 12 if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 5 & year == `x'
	replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = 1 if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 6 & year == `x'
	replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = . if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 7 & year == `x'
    replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = . if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 8 & year == `x'
    replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = . if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 9 & year == `x'
    replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = . if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 0 & year == `x'
  }
  foreach x of numlist 2001 2003 2005 2007 2009 2011 2013 2015 2017 {
    replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = . if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 2 & year == `x'
    replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = 52 if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 3 & year == `x'
    replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = 26 if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 4 & year == `x'
    replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = 12 if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 5 & year == `x'
	replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = 1 if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 6 & year == `x'
	replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = . if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 7 & year == `x'
    replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = . if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 8 & year == `x'
    replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = . if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 9 & year == `x'
    replace EXPENSE_DELIVERY_NOSTAMPS_UNIT = . if EXPENSE_DELIVERY_NOSTAMPS_UNIT == 0 & year == `x'
  }
  replace EXPENSE_FOOD_DELIVERY_NOSTAMPS =. if EXPENSE_FOOD_DELIVERY_NOSTAMPS > 99997
  gen EXPENSE_FOOD_DELIVERY_NS = EXPENSE_FOOD_DELIVERY_NOSTAMPS * EXPENSE_DELIVERY_NOSTAMPS_UNIT
  
  replace EXPENSE_DELIVERY_STAMPS_UNIT = 52 if EXPENSE_DELIVERY_STAMPS_UNIT == 1 & year == 1994
  replace EXPENSE_DELIVERY_STAMPS_UNIT = 26 if EXPENSE_DELIVERY_STAMPS_UNIT == 2 & year == 1994
  replace EXPENSE_DELIVERY_STAMPS_UNIT = 12 if EXPENSE_DELIVERY_STAMPS_UNIT == 3 & year == 1994
  replace EXPENSE_DELIVERY_STAMPS_UNIT = . if EXPENSE_DELIVERY_STAMPS_UNIT == 4 & year == 1994
  replace EXPENSE_DELIVERY_STAMPS_UNIT = . if EXPENSE_DELIVERY_STAMPS_UNIT == 8 & year == 1994
  replace EXPENSE_DELIVERY_STAMPS_UNIT = . if EXPENSE_DELIVERY_STAMPS_UNIT == 9 & year == 1994
  replace EXPENSE_DELIVERY_STAMPS_UNIT = . if EXPENSE_DELIVERY_STAMPS_UNIT == 0 & year == 1994
  
  foreach x of numlist 1995/1997 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017 {
    replace EXPENSE_DELIVERY_STAMPS_UNIT = . if EXPENSE_DELIVERY_STAMPS_UNIT == 1 & year == `x'
    replace EXPENSE_DELIVERY_STAMPS_UNIT = 365 if EXPENSE_DELIVERY_STAMPS_UNIT == 2 & year == `x'
    replace EXPENSE_DELIVERY_STAMPS_UNIT = 52 if EXPENSE_DELIVERY_STAMPS_UNIT == 3 & year == `x'
    replace EXPENSE_DELIVERY_STAMPS_UNIT = 26 if EXPENSE_DELIVERY_STAMPS_UNIT == 4 & year == `x'
    replace EXPENSE_DELIVERY_STAMPS_UNIT = 12 if EXPENSE_DELIVERY_STAMPS_UNIT == 5 & year == `x'
	replace EXPENSE_DELIVERY_STAMPS_UNIT = 1 if EXPENSE_DELIVERY_STAMPS_UNIT == 6 & year == `x'
	replace EXPENSE_DELIVERY_STAMPS_UNIT = . if EXPENSE_DELIVERY_STAMPS_UNIT == 7 & year == `x'
    replace EXPENSE_DELIVERY_STAMPS_UNIT = . if EXPENSE_DELIVERY_STAMPS_UNIT == 8 & year == `x'
    replace EXPENSE_DELIVERY_STAMPS_UNIT = . if EXPENSE_DELIVERY_STAMPS_UNIT == 9 & year == `x'
    replace EXPENSE_DELIVERY_STAMPS_UNIT = . if EXPENSE_DELIVERY_STAMPS_UNIT == 0 & year == `x'
  }
  replace EXPENSE_FOOD_DELIVERY_STAMPS =. if EXPENSE_FOOD_DELIVERY_STAMPS > 99997
  gen EXPENSE_FOOD_DELIVERY_S = EXPENSE_FOOD_DELIVERY_STAMPS * EXPENSE_DELIVERY_STAMPS_UNIT
  
  gen EXPENSE_FOOD_DELIVERY = EXPENSE_FOOD_DELIVERY_S if WHETHER_FOOD_STAMPS == 1
  replace EXPENSE_FOOD_DELIVERY = EXPENSE_FOOD_DELIVERY_NS if WHETHER_FOOD_STAMPS == 0
  
  /* Food Variables Checking
  sum EXPENSE_FOODHOME_NOSTAMPS if WHETHER_FOOD_STAMPS == 1
  sum EXPENSE_FOODOUT_NOSTAMPS if WHETHER_FOOD_STAMPS == 1
  sum EXPENSE_FOOD_DELIVERY_NS if WHETHER_FOOD_STAMPS == 1
  sum EXPENSE_FOODHOME_STAMPS if EXPENSE_FOODHOME_STAMP_WHETHER == 5
  sum EXPENSE_FOODOUT_STAMPS if WHETHER_FOOD_STAMPS == 0
  sum EXPENSE_FOODHOME_STAMPS if WHETHER_FOOD_STAMPS == 0
  sum EXPENSE_FOOD_DELIVERY_S if WHETHER_FOOD_STAMPS == 0   */
  

  /* Clean head employment status */
  foreach x of numlist 1976/1997 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017 {
    replace HEAD_EMPLOY_STATUS = 1 if HEAD_EMPLOY_STATUS == 2 & year == `x'
	replace HEAD_EMPLOY_STATUS = 2 if HEAD_EMPLOY_STATUS == 3 & year == `x'
	replace HEAD_EMPLOY_STATUS = 3 if HEAD_EMPLOY_STATUS == 4 & year == `x'
	replace HEAD_EMPLOY_STATUS = 3 if HEAD_EMPLOY_STATUS == 5 & year == `x'
	replace HEAD_EMPLOY_STATUS = 4 if HEAD_EMPLOY_STATUS == 6 & year == `x'
	replace HEAD_EMPLOY_STATUS = 5 if HEAD_EMPLOY_STATUS == 7 & year == `x'
	replace HEAD_EMPLOY_STATUS = 6 if HEAD_EMPLOY_STATUS == 8 & year == `x'
	replace HEAD_EMPLOY_STATUS = . if HEAD_EMPLOY_STATUS == 9 & year == `x'
	replace HEAD_EMPLOY_STATUS = . if HEAD_EMPLOY_STATUS == 98 & year == `x'
	replace HEAD_EMPLOY_STATUS = . if HEAD_EMPLOY_STATUS == 99 & year == `x'
	replace HEAD_EMPLOY_STATUS = . if HEAD_EMPLOY_STATUS == 0 & year == `x'
	replace HEAD_EMPLOY_STATUS = . if HEAD_EMPLOY_STATUS == 22 & year == `x'
  }
  
  gen HEAD_EMPLOYMENT = 1 if HEAD_EMPLOY_STATUS == 1 | HEAD_EMPLOY_STATUS == 4 | HEAD_EMPLOY_STATUS == 5
  replace HEAD_EMPLOYMENT = 2 if HEAD_EMPLOY_STATUS == 2 
  replace HEAD_EMPLOYMENT = 3 if HEAD_EMPLOY_STATUS == 3
  
  /* Clean head race variable */
  gen HD_RACE = 1 if HEAD_RACE == 1
  replace HD_RACE = 2 if HEAD_RACE == 2
  replace HD_RACE = 3 if HEAD_RACE == 3 | HEAD_RACE == 4 | HEAD_RACE == 5 | HEAD_RACE == 6 | ///
  HEAD_RACE == 7
  
  /* Clean family weight */
  gen FAM_WEIGHT_CLI = WEIGHT_LONG_CORE_FAM if year == 1968
  foreach x of numlist 1969/1989 1996 {
  replace FAM_WEIGHT_CLI = WEIGHT_LONG_CORE_FAM if year == `x'
  } 
  forvalues x = 1990/1995 {
  replace FAM_WEIGHT_CLI = WEIGHT_LONG_FAM_CL if year == `x'
  } 
  foreach x of numlist 1997 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017 {
  replace FAM_WEIGHT_CLI = WEIGHT_LONG_FAM_CI if year == `x'
  }  /* including Latino */
  
  gen FAM_WEIGHT_CI = WEIGHT_LONG_CORE_FAM if year == 1968
  forvalues x = 1969/1996 {
  replace FAM_WEIGHT_CI = WEIGHT_LONG_CORE_FAM if year == `x'
  } 
  foreach x of numlist 1997 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017 {
  replace FAM_WEIGHT_CI = WEIGHT_LONG_FAM_CI if year == `x'
  }  /* not including Latino */
  
  /* Clean head marital status variable */
  gen HEAD_MARITAL = 1 if HEAD_MARITAL_STATUS == 1 | HEAD_MARITAL_STATUS == 8
  replace HEAD_MARITAL = 0 if HEAD_MARITAL_STATUS == 2 | HEAD_MARITAL_STATUS == 3 | HEAD_MARITAL_STATUS == 4 ///
  | HEAD_MARITAL_STATUS == 5
  
  /* clean family region */
  replace FAM_REGION = . if FAM_REGION == 9 | FAM_REGION == 0

  
  
/* Step 2: subset the data -- drop Latinos, keep only heads */
  drop if Fam_ID > 7000 /* drop Latino */
  
  gen HEAD = 1 if RELATION_TO_HEAD == 1 & year == 1968
  replace HEAD = 1 if RELATION_TO_HEAD == 1 & SEQUENCE_NUM == 1 & year >1968
  replace HEAD = 1 if RELATION_TO_HEAD == 10 & SEQUENCE_NUM == 1
  keep if HEAD == 1
  
  
  
/* Step 3: merge in experiences and UE rates */ 
  merge 1:1 ID year using "../../data/PSID/individual_exp_state_nat_lagged_1.dta"
  drop if _merge == 2
  drop _merge
  merge 1:1 ID year using "../../data/PSID/individual_exp_personal_lagged_1.dta", keepusing (exp_personal_nat exp_personal_nat2)
  drop if _merge == 2
  drop _merge mark 
  merge 1:1 ID year using "../../data/PSID/individual_exp_state_nat_lagged_1_lambda3.dta", keepusing(exp_state_nat_lagged_l3)
  drop if _merge == 2
  drop _merge 
  merge 1:1 ID year using "../../data/PSID/individual_exp_personal_lagged_1_lambda3.dta", keepusing (exp_personal_nat_l3)
  drop if _merge == 2
  drop _merge 
  merge 1:1 ID year using "../../data/PSID/individual_exp_personal_lagged_1g.dta", keepusing (exp_personal_nat_1g)
  drop if _merge == 2
  drop _merge
  merge 1:1 ID year using "../../data/PSID/individual_exp_state_nat_lagged_1g.dta", keepusing (exp_state_nat_lagged_1g)
  drop if _merge == 2
  drop _merge 
  merge 1:1 ID year using "../../data/PSID/individual_exp_personal_lagged_3g.dta", keepusing(exp_personal_nat_3g)
  drop if _merge == 2
  drop _merge 
  merge 1:1 ID year using "../../data/PSID/individual_exp_state_nat_lagged_3g.dta", keepusing(exp_state_nat_lagged_3g)
  drop if _merge == 2
  drop _merge 
  
 
  preserve
  clear
  use "../../raw/state_UE_1976_2017.dta"
  reshape long unemp_state, i(GSA) j(year)
  sort GSA year
  tempfile temp
  save `temp'
  restore
  sort GSA year
  merge m:1 GSA year using `temp'
  drop if _merge == 2
  drop _merge
  merge m:1 year using "../../raw/nat_UE_1890_2017.dta"
  drop if _merge == 2
  drop _merge
  
  preserve
  clear
  import excel "../../raw/PCE_use2.xls", sheet("PCE") firstrow clear
  gen year = year(date)
  collapse PCE, by(year)
  sort year
  tempfile temp1
  save `temp1'
  restore
  sort year
  merge m:1 year using `temp1'
  keep if _merge == 3
  drop _merge
  save "../../data/PSID/psid_new_with_exp_fzero_lagged.dta", replace



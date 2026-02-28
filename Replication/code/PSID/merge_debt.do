/************************************************************************************************
  Input: 1. "../../data/PSID/psid_new_with_exp_fzero_lagged.dta"
		 2. Raw PSID data files on debt: "../../raw/PSID/wealth/debt_[year].dta"
		 3. Raw PSID data files on wealth: "../../raw/PSID/wealth/wealth_sub_[year].dta"
		 
  Output: "../../data/PSID/psid_new_with_exp_fzero_debt_lagged"

  cd to the folder that stores this code: cd "./Replication/code/PSID"
************************************************************************************************/
clear
set more off

/* Merge in debt variables */
  use "../../data/PSID/psid_new_with_exp_fzero_lagged.dta"
  sort INTERVIEW_ID year
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/debt_1984.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/debt_1989.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/debt_1994.dta"
    drop if _merge == 2 /* Latino Sample */
	drop _merge
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/debt_1999.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/debt_2001.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/debt_2003.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/debt_2005.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/debt_2007.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/debt_2009.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/debt_2011.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/debt_2013.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/debt_2015.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/debt_2017.dta", assert(1 3) nogen

  
/* Clean debt variables */
  gen DEBT = .
  gen TOTAL_DEBT = .
  /* 1984 */
  replace DEBT = OTHER_DEBT_84 if year == 1984
  replace TOTAL_DEBT = MORTGAGE_84 + OTHER_DEBT_84 if year == 1984
  /* 1989 */
  replace MORTGAGE_89 = . if MORTGAGE_89 == 999999
  replace DEBT = OTHER_DEBT_89 if year == 1989
  replace TOTAL_DEBT = MORTGAGE_89 + OTHER_DEBT_89 if year == 1989
  /* 1994 */
  replace MORTGAGE1_94 =. if MORTGAGE1_94 > 999996
  replace MORTGAGE2_94 =. if MORTGAGE2_94 > 999997
  replace DEBT = OTHER_DEBT_94 if year == 1994
  replace TOTAL_DEBT = MORTGAGE1_94 + MORTGAGE2_94 + OTHER_DEBT_94 if year == 1994
  /* 1999 */
  replace MORTGAGE1_99 =. if MORTGAGE1_99 > 9999997
  replace MORTGAGE2_99 =. if MORTGAGE2_99 > 9999997
  replace VEHICLE_LOAN1_99 =. if VEHICLE_LOAN1_99 > 999997
  replace VEHICLE_LOAN2_99 =. if VEHICLE_LOAN2_99 > 999997
  replace VEHICLE_LOAN3_99 =. if VEHICLE_LOAN3_99 > 999997
  replace DEBT = OTHER_DEBT_99 if year == 1999
  replace TOTAL_DEBT = MORTGAGE1_99 + MORTGAGE2_99 + VEHICLE_LOAN1_99 + VEHICLE_LOAN2_99 ///
    + VEHICLE_LOAN3_99 + OTHER_DEBT_99 if year == 1999
  /* 2001 */
  replace MORTGAGE1_01 =. if MORTGAGE1_01 > 9999997
  replace MORTGAGE2_01 =. if MORTGAGE2_01 > 9999997
  replace VEHICLE_LOAN1_01 =. if VEHICLE_LOAN1_01 > 999997
  replace VEHICLE_LOAN2_01 =. if VEHICLE_LOAN2_01 > 999997
  replace VEHICLE_LOAN3_01 =. if VEHICLE_LOAN3_01 > 999997
  replace DEBT = OTHER_DEBT_01 if year == 2001
  replace TOTAL_DEBT = MORTGAGE1_01 + MORTGAGE2_01 + VEHICLE_LOAN1_01 + VEHICLE_LOAN2_01 ///
    + VEHICLE_LOAN3_01 + OTHER_DEBT_01 if year == 2001
  /* 2003 */
  replace MORTGAGE1_03 =. if MORTGAGE1_03 > 9999997
  replace MORTGAGE2_03 =. if MORTGAGE2_03 > 9999997
  replace VEHICLE_LOAN1_03 =. if VEHICLE_LOAN1_03 > 999997
  replace VEHICLE_LOAN2_03 =. if VEHICLE_LOAN2_03 > 999997
  replace VEHICLE_LOAN3_03 =. if VEHICLE_LOAN3_03 > 999997
  replace DEBT = OTHER_DEBT_03 if year == 2003
  replace TOTAL_DEBT = MORTGAGE1_03 + MORTGAGE2_03 + VEHICLE_LOAN1_03 + VEHICLE_LOAN2_03 ///
    + VEHICLE_LOAN3_03 + OTHER_DEBT_03 if year == 2003
  /* 2005 */
  replace MORTGAGE1_05 =. if MORTGAGE1_05 > 9999997
  replace MORTGAGE2_05 =. if MORTGAGE2_05 > 9999997
  replace VEHICLE_LOAN1_05 =. if VEHICLE_LOAN1_05 > 999997
  replace VEHICLE_LOAN2_05 =. if VEHICLE_LOAN2_05 > 999997
  replace VEHICLE_LOAN3_05 =. if VEHICLE_LOAN3_05 > 999997
  replace DEBT = OTHER_DEBT_05 if year == 2005
  replace TOTAL_DEBT = MORTGAGE1_05 + MORTGAGE2_05 + VEHICLE_LOAN1_05 + VEHICLE_LOAN2_05 ///
    + VEHICLE_LOAN3_05 + OTHER_DEBT_05 if year == 2005
  /* 2007 */
  replace MORTGAGE1_07 =. if MORTGAGE1_07 > 9999997
  replace MORTGAGE2_07 =. if MORTGAGE2_07 > 9999997
  replace VEHICLE_LOAN1_07 =. if VEHICLE_LOAN1_07 > 999997
  replace VEHICLE_LOAN2_07 =. if VEHICLE_LOAN2_07 > 999997
  replace VEHICLE_LOAN3_07 =. if VEHICLE_LOAN3_07 > 999997
  replace DEBT = OTHER_DEBT_07 if year == 2007
  replace TOTAL_DEBT = MORTGAGE1_07 + MORTGAGE2_07 + VEHICLE_LOAN1_07 + VEHICLE_LOAN2_07 ///
    + VEHICLE_LOAN3_07 + OTHER_DEBT_07 if year == 2007
  /* 2009 */
  replace MORTGAGE1_09 =. if MORTGAGE1_09 > 9999997
  replace MORTGAGE2_09 =. if MORTGAGE2_09 > 9999997
  replace VEHICLE_LOAN1_09 =. if VEHICLE_LOAN1_09 > 999997
  replace VEHICLE_LOAN2_09 =. if VEHICLE_LOAN2_09 > 999997
  replace VEHICLE_LOAN3_09 =. if VEHICLE_LOAN3_09 > 999997
  replace DEBT = OTHER_DEBT3_09 if year == 2009
  replace TOTAL_DEBT = MORTGAGE1_09 + MORTGAGE2_09 + VEHICLE_LOAN1_09 + VEHICLE_LOAN2_09 ///
    + VEHICLE_LOAN3_09 + OTHER_DEBT3_09 if year == 2009
  /* 2011 */
  replace MORTGAGE1_11 =. if MORTGAGE1_11 > 9999997
  replace MORTGAGE2_11 =. if MORTGAGE2_11 > 9999997
  replace VEHICLE_LOAN1_11 =. if VEHICLE_LOAN1_11 > 999997
  replace VEHICLE_LOAN2_11 =. if VEHICLE_LOAN2_11 > 999997
  replace VEHICLE_LOAN3_11 =. if VEHICLE_LOAN3_11 > 999997
  replace DEBT = CREDITCARD_DEBT_11 + STUDENT_LOAN_11 + MEDICAL_DEBT_11 + LEGAL_DEBT_11 + ///
    FAMILY_LOAN_11 if year == 2011
  replace TOTAL_DEBT = MORTGAGE1_11 + MORTGAGE2_11 + VEHICLE_LOAN1_11 + VEHICLE_LOAN2_11 ///
    + VEHICLE_LOAN3_11 + CREDITCARD_DEBT_11 + STUDENT_LOAN_11 + MEDICAL_DEBT_11 + LEGAL_DEBT_11 + ///
    FAMILY_LOAN_11 if year == 2011
  /* 2013 */
  replace MORTGAGE1_13 =. if MORTGAGE1_13 > 9999997
  replace MORTGAGE2_13 =. if MORTGAGE2_13 > 9999997
  replace VEHICLE_LOAN1_13 =. if VEHICLE_LOAN1_13 > 999997
  replace VEHICLE_LOAN2_13 =. if VEHICLE_LOAN2_13 > 999997
  replace VEHICLE_LOAN3_13 =. if VEHICLE_LOAN3_13 > 999997
  replace DEBT = FARMBUS_DEBT_13 + REALESTATE_DEBT_13 + CREDITCARD_DEBT_13 + STUDENT_LOAN_13 + MEDICAL_DEBT_13 + ///
    FAMILY_LOAN_13 + LEGAL_DEBT_13 + OTHER_DEBTS_13 if year == 2013
  replace TOTAL_DEBT = MORTGAGE1_13 + MORTGAGE2_13 + VEHICLE_LOAN1_13 + VEHICLE_LOAN2_13 ///
    + VEHICLE_LOAN3_13 + FARMBUS_DEBT_13 + REALESTATE_DEBT_13 + CREDITCARD_DEBT_13 + STUDENT_LOAN_13 + MEDICAL_DEBT_13 + ///
    FAMILY_LOAN_13 + LEGAL_DEBT_13 + OTHER_DEBTS_13 if year == 2013
  /* 2015 */
  replace MORTGAGE1_15 =. if MORTGAGE1_15 > 9999997
  replace MORTGAGE2_15 =. if MORTGAGE2_15 > 9999997
  replace VEHICLE_LOAN1_15 =. if VEHICLE_LOAN1_15 > 999997
  replace VEHICLE_LOAN2_15 =. if VEHICLE_LOAN2_15 > 999997
  replace VEHICLE_LOAN3_15 =. if VEHICLE_LOAN3_15 > 999997
  replace DEBT = FARMBUS_DEBT_15 + REALESTATE_DEBT_15 + CREDITCARD_DEBT_15 + STUDENT_LOAN_15 + MEDICAL_DEBT_15 + ///
    FAMILY_LOAN_15 + LEGAL_DEBT_15 + OTHER_DEBTS_15 if year == 2015
  replace TOTAL_DEBT = MORTGAGE1_15 + MORTGAGE2_15 + VEHICLE_LOAN1_15 + VEHICLE_LOAN2_15 ///
    + VEHICLE_LOAN3_15 + FARMBUS_DEBT_15 + REALESTATE_DEBT_15 + CREDITCARD_DEBT_15 + STUDENT_LOAN_15 + MEDICAL_DEBT_15 + ///
    FAMILY_LOAN_15 + LEGAL_DEBT_15 + OTHER_DEBTS_15 if year == 2015
  /* 2017 */
  replace MORTGAGE1_17 =. if MORTGAGE1_17 > 9999997
  replace MORTGAGE2_17 =. if MORTGAGE2_17 > 9999997
  replace VEHICLE_LOAN1_17 =. if VEHICLE_LOAN1_17 > 999997
  replace VEHICLE_LOAN2_17 =. if VEHICLE_LOAN2_17 > 999997
  replace VEHICLE_LOAN3_17 =. if VEHICLE_LOAN3_17 > 999997
  replace DEBT = FARMBUS_DEBT_17 + REALESTATE_DEBT_17 + CREDITCARD_DEBT_17 + STUDENT_LOAN_17 + MEDICAL_DEBT_17 + ///
    FAMILY_LOAN_17 + LEGAL_DEBT_17 + OTHER_DEBTS_17 if year == 2017
  replace TOTAL_DEBT = MORTGAGE1_17 + MORTGAGE2_17 + VEHICLE_LOAN1_17 + VEHICLE_LOAN2_17 ///
    + VEHICLE_LOAN3_17 + FARMBUS_DEBT_17 + REALESTATE_DEBT_17 + CREDITCARD_DEBT_17 + STUDENT_LOAN_17 + MEDICAL_DEBT_17 + ///
    FAMILY_LOAN_17 + LEGAL_DEBT_17 + OTHER_DEBTS_17 if year == 2017

   
  /* Merge in wealth sub-categories */

  sort INTERVIEW_ID year
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/wealth_sub_1984.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/wealth_sub_1989.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/wealth_sub_1994.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/wealth_sub_1999.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/wealth_sub_2001.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/wealth_sub_2003.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/wealth_sub_2005.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/wealth_sub_2007.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/wealth_sub_2009.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/wealth_sub_2011.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/wealth_sub_2013.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/wealth_sub_2015.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/wealth/wealth_sub_2017.dta", assert(1 3) nogen


/* Combine the wealth sub-categories */
	gen FARM_BUS = .
	replace FARM_BUS = FARM_BUS_84 if year == 1984
	replace FARM_BUS = FARM_BUS_89 if year == 1989
	replace FARM_BUS = FARM_BUS_94 if year == 1994
	replace FARM_BUS = FARM_BUS_99 if year == 1999
	replace FARM_BUS = FARM_BUS_01 if year == 2001
	replace FARM_BUS = FARM_BUS_03 if year == 2003
	replace FARM_BUS = FARM_BUS_05 if year == 2005
	replace FARM_BUS = FARM_BUS_07 if year == 2007
	replace FARM_BUS = FARM_BUS_09 if year == 2009
	replace FARM_BUS = FARM_BUS_11 if year == 2011
	replace FARM_BUS = FARM_BUS_13 if year == 2013
	replace FARM_BUS = FARM_BUS_15 if year == 2015
	replace FARM_BUS = FARM_BUS_17 if year == 2017

	gen CHECK_SAVING = .
	replace CHECK_SAVING = CHECK_SAVING_84 if year == 1984
	replace CHECK_SAVING = CHECK_SAVING_89 if year == 1989
	replace CHECK_SAVING = CHECK_SAVING_94 if year == 1994
	replace CHECK_SAVING = CHECK_SAVING_99 if year == 1999
	replace CHECK_SAVING = CHECK_SAVING_01 if year == 2001
	replace CHECK_SAVING = CHECK_SAVING_03 if year == 2003
	replace CHECK_SAVING = CHECK_SAVING_05 if year == 2005
	replace CHECK_SAVING = CHECK_SAVING_07 if year == 2007
	replace CHECK_SAVING = CHECK_SAVING_09 if year == 2009
	replace CHECK_SAVING = CHECK_SAVING_11 if year == 2011
	replace CHECK_SAVING = CHECK_SAVING_13 if year == 2013
	replace CHECK_SAVING = CHECK_SAVING_15 if year == 2015
	replace CHECK_SAVING = CHECK_SAVING_17 if year == 2017
	
	gen OTHER_REAL_ESTATE = .
	replace OTHER_REAL_ESTATE = OTHER_REAL_ESTATE_84 if year == 1984
	replace OTHER_REAL_ESTATE = OTHER_REAL_ESTATE_89 if year == 1989
	replace OTHER_REAL_ESTATE = OTHER_REAL_ESTATE_94 if year == 1994
	replace OTHER_REAL_ESTATE = OTHER_REAL_ESTATE_99 if year == 1999
	replace OTHER_REAL_ESTATE = OTHER_REAL_ESTATE_01 if year == 2001
	replace OTHER_REAL_ESTATE = OTHER_REAL_ESTATE_03 if year == 2003
	replace OTHER_REAL_ESTATE = OTHER_REAL_ESTATE_05 if year == 2005
	replace OTHER_REAL_ESTATE = OTHER_REAL_ESTATE_07 if year == 2007
	replace OTHER_REAL_ESTATE = OTHER_REAL_ESTATE_09 if year == 2009
	replace OTHER_REAL_ESTATE = OTHER_REAL_ESTATE_11 if year == 2011
	replace OTHER_REAL_ESTATE = OTHER_REAL_ESTATE_13 if year == 2013
	replace OTHER_REAL_ESTATE = OTHER_REAL_ESTATE_15 if year == 2015
	replace OTHER_REAL_ESTATE = OTHER_REAL_ESTATE_17 if year == 2017
	
	gen STOCK = .
	replace STOCK = STOCK_84 if year == 1984
	replace STOCK = STOCK_89 if year == 1989
	replace STOCK = STOCK_94 if year == 1994
	replace STOCK = STOCK_99 if year == 1999
	replace STOCK = STOCK_01 if year == 2001
	replace STOCK = STOCK_03 if year == 2003
	replace STOCK = STOCK_05 if year == 2005
	replace STOCK = STOCK_07 if year == 2007
	replace STOCK = STOCK_09 if year == 2009
	replace STOCK = STOCK_11 if year == 2011
	replace STOCK = STOCK_13 if year == 2013
	replace STOCK = STOCK_15 if year == 2015
	replace STOCK = STOCK_17 if year == 2017
	
	gen VEHICLE_VALUE =.
	replace VEHICLE_VALUE = VEHICLE_VALUE_84 if year == 1984
	replace VEHICLE_VALUE = VEHICLE_VALUE_89 if year == 1989
	replace VEHICLE_VALUE = VEHICLE_VALUE_94 if year == 1994
	replace VEHICLE_VALUE = VEHICLE_VALUE_99 if year == 1999
	replace VEHICLE_VALUE = VEHICLE_VALUE_01 if year == 2001
	replace VEHICLE_VALUE = VEHICLE_VALUE_03 if year == 2003
	replace VEHICLE_VALUE = VEHICLE_VALUE_05 if year == 2005
	replace VEHICLE_VALUE = VEHICLE_VALUE_07 if year == 2007
	replace VEHICLE_VALUE = VEHICLE_VALUE_09 if year == 2009
	replace VEHICLE_VALUE = VEHICLE_VALUE_11 if year == 2011
	replace VEHICLE_VALUE = VEHICLE_VALUE_13 if year == 2013
	replace VEHICLE_VALUE = VEHICLE_VALUE_15 if year == 2015
	replace VEHICLE_VALUE = VEHICLE_VALUE_17 if year == 2017
	
	gen OTHER_ASSET_VALUE =.
	replace OTHER_ASSET_VALUE = OTHER_ASSET_VALUE_84 if year == 1984
	replace OTHER_ASSET_VALUE = OTHER_ASSET_VALUE_89 if year == 1989
	replace OTHER_ASSET_VALUE = OTHER_ASSET_VALUE_94 if year == 1994
	replace OTHER_ASSET_VALUE = OTHER_ASSET_VALUE_99 if year == 1999
	replace OTHER_ASSET_VALUE = OTHER_ASSET_VALUE_01 if year == 2001
	replace OTHER_ASSET_VALUE = OTHER_ASSET_VALUE_03 if year == 2003
	replace OTHER_ASSET_VALUE = OTHER_ASSET_VALUE_05 if year == 2005
	replace OTHER_ASSET_VALUE = OTHER_ASSET_VALUE_07 if year == 2007
	replace OTHER_ASSET_VALUE = OTHER_ASSET_VALUE_09 if year == 2009
	replace OTHER_ASSET_VALUE = OTHER_ASSET_VALUE_11 if year == 2011
	replace OTHER_ASSET_VALUE = OTHER_ASSET_VALUE_13 if year == 2013
	replace OTHER_ASSET_VALUE = OTHER_ASSET_VALUE_15 if year == 2015
	replace OTHER_ASSET_VALUE = OTHER_ASSET_VALUE_17 if year == 2017

	gen ANNUITY_IRA =.
	replace ANNUITY_IRA = ANNUITY_IRA_99 if year == 1999
	replace ANNUITY_IRA = ANNUITY_IRA_01 if year == 2001
	replace ANNUITY_IRA = ANNUITY_IRA_03 if year == 2003
	replace ANNUITY_IRA = ANNUITY_IRA_05 if year == 2005
	replace ANNUITY_IRA = ANNUITY_IRA_07 if year == 2007
	replace ANNUITY_IRA = ANNUITY_IRA_09 if year == 2009
	replace ANNUITY_IRA = ANNUITY_IRA_11 if year == 2011
	replace ANNUITY_IRA = ANNUITY_IRA_13 if year == 2013
	replace ANNUITY_IRA = ANNUITY_IRA_15 if year == 2015
	replace ANNUITY_IRA = ANNUITY_IRA_17 if year == 2017

  save "../../data/PSID/psid_new_with_exp_fzero_debt_lagged.dta", replace
  

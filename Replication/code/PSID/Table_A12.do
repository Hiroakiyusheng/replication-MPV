** Generate Table A.12: Wealth Accumulation
clear
est clear 
clear mata 
clear matrix 
set more off 
set matsize 11000 
set maxvar 24000 
clear mata 
cap log close


use "../../data/PSID/psid_new_with_exp_allf_lagged", clear

    drop if Fam_ID > 3000 & Fam_ID < 5000 /* drop Immigrant Sample */
    drop if age < 25 | age >75 /* 36648 obs. dropped */

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

	
	replace exp_personal_lagged_1 = exp_personal_lagged_1/100
	replace exp_personal_nat_l3=exp_personal_nat_l3/100
	
	
	sort ID year
	by ID:gen num = _N
	drop if num==1
	
	
	xtset ID seq
	gen L0_INCOME = INCOME_TOTAL_FAM
	** generate income lags **
	gen L2_INCOME = L1.INCOME_TOTAL_FAM
	
	gen L3_INCOME = L2.INCOME_TOTAL_FAM
	gen L4_INCOME = L2.INCOME_TOTAL_FAM if year >1999
	replace L4_INCOME = L3.INCOME_TOTAL_FAM if year ==1999
	
	gen L5_INCOME = L3.INCOME_TOTAL_FAM if year >1999
	replace L5_INCOME = L4.INCOME_TOTAL_FAM if year ==1999
	gen L6_INCOME = L3.INCOME_TOTAL_FAM if year >2001
	replace L6_INCOME = L4.INCOME_TOTAL_FAM if year ==2001
	replace L6_INCOME = L5.INCOME_TOTAL_FAM if year ==1999
	
	gen L7_INCOME = L4.INCOME_TOTAL_FAM if year >2001
	replace L7_INCOME = L5.INCOME_TOTAL_FAM if year ==2001
	replace L7_INCOME = L6.INCOME_TOTAL_FAM if year ==1999
	gen L8_INCOME = L4.INCOME_TOTAL_FAM if year >2003
	replace L8_INCOME = L5.INCOME_TOTAL_FAM if year ==2003
	replace L8_INCOME = L6.INCOME_TOTAL_FAM if year ==2001
	replace L8_INCOME = L7.INCOME_TOTAL_FAM if year ==1999
	
	gen L9_INCOME = L5.INCOME_TOTAL_FAM if year >2003
	replace L9_INCOME = L6.INCOME_TOTAL_FAM if year ==2003
	replace L9_INCOME = L7.INCOME_TOTAL_FAM if year ==2001
	replace L9_INCOME = L8.INCOME_TOTAL_FAM if year ==1999
	gen L10_INCOME = L5.INCOME_TOTAL_FAM if year >2005
	replace L10_INCOME = L6.INCOME_TOTAL_FAM if year ==2005
	replace L10_INCOME = L7.INCOME_TOTAL_FAM if year ==2003
	replace L10_INCOME = L8.INCOME_TOTAL_FAM if year ==2001
	replace L10_INCOME = L9.INCOME_TOTAL_FAM if year ==1999
	
	gen L11_INCOME = L6.INCOME_TOTAL_FAM if year >2005
	replace L11_INCOME = L7.INCOME_TOTAL_FAM if year ==2005
	replace L11_INCOME = L8.INCOME_TOTAL_FAM if year ==2003
	replace L11_INCOME = L9.INCOME_TOTAL_FAM if year ==2001
	replace L11_INCOME = L10.INCOME_TOTAL_FAM if year ==1999
	gen L12_INCOME = L6.INCOME_TOTAL_FAM if year >2007
	replace L12_INCOME = L7.INCOME_TOTAL_FAM if year ==2007
	replace L12_INCOME = L8.INCOME_TOTAL_FAM if year ==2005
	replace L12_INCOME = L9.INCOME_TOTAL_FAM if year ==2003
	replace L12_INCOME = L10.INCOME_TOTAL_FAM if year ==2001
	replace L12_INCOME = L11.INCOME_TOTAL_FAM if year ==1999
	
	gen L13_INCOME = L7.INCOME_TOTAL_FAM if year >2007
	replace L13_INCOME = L8.INCOME_TOTAL_FAM if year ==2007
	replace L13_INCOME = L9.INCOME_TOTAL_FAM if year ==2005
	replace L13_INCOME = L10.INCOME_TOTAL_FAM if year ==2003
	replace L13_INCOME = L11.INCOME_TOTAL_FAM if year ==2001
	replace L13_INCOME = L12.INCOME_TOTAL_FAM if year ==1999
	
	gen L14_INCOME = L7.INCOME_TOTAL_FAM if year >2009
	replace L14_INCOME = L8.INCOME_TOTAL_FAM if year ==2009
	replace L14_INCOME = L9.INCOME_TOTAL_FAM if year ==2007
	replace L14_INCOME = L10.INCOME_TOTAL_FAM if year ==2005
	replace L14_INCOME = L11.INCOME_TOTAL_FAM if year ==2003
	replace L14_INCOME = L12.INCOME_TOTAL_FAM if year ==2001
	replace L14_INCOME = L13.INCOME_TOTAL_FAM if year ==1999
		
	gen L4_INCOME_AVE = (L1_INCOME+L2_INCOME+L3_INCOME)/3
	gen L6_INCOME_AVE = (L1_INCOME+L2_INCOME+L3_INCOME+L4_INCOME+L5_INCOME)/5
	gen L8_INCOME_AVE = (L1_INCOME+L2_INCOME+L3_INCOME+L4_INCOME+L5_INCOME+L6_INCOME+L7_INCOME)/7
	gen L10_INCOME_AVE = (L1_INCOME+L2_INCOME+L3_INCOME+L4_INCOME+L5_INCOME+L6_INCOME+L7_INCOME+L8_INCOME+L9_INCOME)/9
	gen L12_INCOME_AVE = (L1_INCOME+L2_INCOME+L3_INCOME+L4_INCOME+L5_INCOME+L6_INCOME+L7_INCOME+L8_INCOME+L9_INCOME+L10_INCOME+L11_INCOME)/11
	gen L14_INCOME_AVE = (L1_INCOME+L2_INCOME+L3_INCOME+L4_INCOME+L5_INCOME+L6_INCOME+L7_INCOME+L8_INCOME+L9_INCOME+L10_INCOME+L11_INCOME+L12_INCOME+L13_INCOME)/13

	gen l4_income_ave = log(L4_INCOME_AVE) /* the lowest value is -45974 */
	gen l6_income_ave = log(L6_INCOME_AVE) /* the lowest value is -16464.4 */
	gen l8_income_ave = log(L8_INCOME_AVE) /* the lowest value is -6244.9 */
	gen l10_income_ave = log(L10_INCOME_AVE) /* the lowest value is 0 */
	gen l12_income_ave = log(L12_INCOME_AVE) /* the lowest value is 333 */
	gen l14_income_ave = log(L14_INCOME_AVE) /* the lowest value is 465 */
	
	
	* 14-year lag of experience variable
	gen L14_exp_state_nat = L7.exp_state_nat_lagged_1 if year > 2010
	replace L14_exp_state_nat = L8.exp_state_nat_lagged_1 if year ==2009
	replace L14_exp_state_nat = L9.exp_state_nat_lagged_1 if year ==2007
	replace L14_exp_state_nat = L10.exp_state_nat_lagged_1 if year ==2005
	replace L14_exp_state_nat = L11.exp_state_nat_lagged_1 if year ==2003
	replace L14_exp_state_nat = L12.exp_state_nat_lagged_1 if year ==2001
	replace L14_exp_state_nat = L13.exp_state_nat_lagged_1 if year ==1999
	
	gen L14_exp_personal = L7.exp_personal_lagged_1 if year > 2010
	replace L14_exp_personal = L8.exp_personal_lagged_1 if year ==2009
	replace L14_exp_personal = L9.exp_personal_lagged_1 if year ==2007
	replace L14_exp_personal = L10.exp_personal_lagged_1 if year ==2005
	replace L14_exp_personal = L11.exp_personal_lagged_1 if year ==2003
	replace L14_exp_personal = L12.exp_personal_lagged_1 if year ==2001
	replace L14_exp_personal = L13.exp_personal_lagged_1 if year ==1999
	
	* 12-year lag of experience variable
	gen L12_exp_state_nat = L6.exp_state_nat_lagged_1 if year > 2008
	replace L12_exp_state_nat = L7.exp_state_nat_lagged_1 if year ==2007
	replace L12_exp_state_nat = L8.exp_state_nat_lagged_1 if year ==2005
	replace L12_exp_state_nat = L9.exp_state_nat_lagged_1 if year ==2003
	replace L12_exp_state_nat = L10.exp_state_nat_lagged_1 if year ==2001
	replace L12_exp_state_nat = L11.exp_state_nat_lagged_1 if year ==1999
	
	gen L12_exp_personal = L6.exp_personal_lagged_1 if year > 2008
	replace L12_exp_personal = L7.exp_personal_lagged_1 if year ==2007
	replace L12_exp_personal = L8.exp_personal_lagged_1 if year ==2005
	replace L12_exp_personal = L9.exp_personal_lagged_1 if year ==2003
	replace L12_exp_personal = L10.exp_personal_lagged_1 if year ==2001
	replace L12_exp_personal = L11.exp_personal_lagged_1 if year ==1999
	
	* 10-year lag of experience variable
	gen L10_exp_state_nat = L5.exp_state_nat_lagged_1 if year > 2006
	replace L10_exp_state_nat = L6.exp_state_nat_lagged_1 if year ==2005
	replace L10_exp_state_nat = L7.exp_state_nat_lagged_1 if year ==2003
	replace L10_exp_state_nat = L8.exp_state_nat_lagged_1 if year ==2001
	replace L10_exp_state_nat = L9.exp_state_nat_lagged_1 if year ==1999
	
	gen L10_exp_personal = L5.exp_personal_lagged_1 if year > 2006
	replace L10_exp_personal = L6.exp_personal_lagged_1 if year ==2005
	replace L10_exp_personal = L7.exp_personal_lagged_1 if year ==2003
	replace L10_exp_personal = L8.exp_personal_lagged_1 if year ==2001
	replace L10_exp_personal = L9.exp_personal_lagged_1 if year ==1999

	* 8-year lag of experience variable
	gen L8_exp_state_nat = L4.exp_state_nat_lagged_1 if year > 2004
	replace L8_exp_state_nat = L5.exp_state_nat_lagged_1 if year ==2003
	replace L8_exp_state_nat = L6.exp_state_nat_lagged_1 if year ==2001
	replace L8_exp_state_nat = L7.exp_state_nat_lagged_1 if year ==1999
	
	gen L8_exp_personal = L4.exp_personal_lagged_1 if year > 2004
	replace L8_exp_personal = L5.exp_personal_lagged_1 if year ==2003
	replace L8_exp_personal = L6.exp_personal_lagged_1 if year ==2001
	replace L8_exp_personal = L7.exp_personal_lagged_1 if year ==1999
	
	* 6-year lag of experience variable
	gen L6_exp_state_nat = L3.exp_state_nat_lagged_1 if year > 2002
	replace L6_exp_state_nat = L4.exp_state_nat_lagged_1 if year ==2001
	replace L6_exp_state_nat = L5.exp_state_nat_lagged_1 if year ==1999
	
	gen L6_exp_personal = L3.exp_personal_lagged_1 if year > 2002
	replace L6_exp_personal = L4.exp_personal_lagged_1 if year ==2001
	replace L6_exp_personal = L5.exp_personal_lagged_1 if year ==1999
		
	* 4-year lag of experience variable
	gen L4_exp_state_nat = L2.exp_state_nat_lagged_1 if year >2000
	replace L4_exp_state_nat = L3.exp_state_nat_lagged_1 if year ==1999
	
	gen L4_exp_personal = L2.exp_personal_lagged_1 if year >2000
	replace L4_exp_personal = L3.exp_personal_lagged_1 if year ==1999
	
		* 14-year lag of experience variable
	gen L14_exp_personal_nat_l3  = L7.exp_personal_nat_l3  if year > 2010
	replace L14_exp_personal_nat_l3  = L8.exp_personal_nat_l3  if year ==2009
	replace L14_exp_personal_nat_l3  = L9.exp_personal_nat_l3  if year ==2007
	replace L14_exp_personal_nat_l3  = L10.exp_personal_nat_l3  if year ==2005
	replace L14_exp_personal_nat_l3  = L11.exp_personal_nat_l3  if year ==2003
	replace L14_exp_personal_nat_l3  = L12.exp_personal_nat_l3  if year ==2001
	replace L14_exp_personal_nat_l3  = L13.exp_personal_nat_l3  if year ==1999
	
	gen L14_exp_state_nat_lagged_l3 = L7.exp_state_nat_lagged_l3 if year > 2010
	replace L14_exp_state_nat_lagged_l3 = L8.exp_state_nat_lagged_l3 if year ==2009
	replace L14_exp_state_nat_lagged_l3 = L9.exp_state_nat_lagged_l3 if year ==2007
	replace L14_exp_state_nat_lagged_l3 = L10.exp_state_nat_lagged_l3 if year ==2005
	replace L14_exp_state_nat_lagged_l3 = L11.exp_state_nat_lagged_l3 if year ==2003
	replace L14_exp_state_nat_lagged_l3 = L12.exp_state_nat_lagged_l3 if year ==2001
	replace L14_exp_state_nat_lagged_l3 = L13.exp_state_nat_lagged_l3 if year ==1999
	
	* 12-year lag of experience variable
	gen L12_exp_personal_nat_l3  = L6.exp_personal_nat_l3  if year > 2008
	replace L12_exp_personal_nat_l3  = L7.exp_personal_nat_l3  if year ==2007
	replace L12_exp_personal_nat_l3  = L8.exp_personal_nat_l3  if year ==2005
	replace L12_exp_personal_nat_l3  = L9.exp_personal_nat_l3 if year ==2003
	replace L12_exp_personal_nat_l3  = L10.exp_personal_nat_l3  if year ==2001
	replace L12_exp_personal_nat_l3  = L11.exp_personal_nat_l3  if year ==1999
	
	gen L12_exp_state_nat_lagged_l3 = L6.exp_state_nat_lagged_l3 if year > 2008
	replace L12_exp_state_nat_lagged_l3 = L7.exp_state_nat_lagged_l3 if year ==2007
	replace L12_exp_state_nat_lagged_l3 = L8.exp_state_nat_lagged_l3 if year ==2005
	replace L12_exp_state_nat_lagged_l3 = L9.exp_state_nat_lagged_l3 if year ==2003
	replace L12_exp_state_nat_lagged_l3 = L10.exp_state_nat_lagged_l3 if year ==2001
	replace L12_exp_state_nat_lagged_l3 = L11.exp_state_nat_lagged_l3 if year ==1999
	
	* 10-year lag of experience variable
	gen L10_exp_state_nat_lagged_l3 = L5.exp_state_nat_lagged_l3 if year > 2006
	replace L10_exp_state_nat_lagged_l3 = L6.exp_state_nat_lagged_l3 if year ==2005
	replace L10_exp_state_nat_lagged_l3 = L7.exp_state_nat_lagged_l3 if year ==2003
	replace L10_exp_state_nat_lagged_l3 = L8.exp_state_nat_lagged_l3 if year ==2001
	replace L10_exp_state_nat_lagged_l3 = L9.exp_state_nat_lagged_l3 if year ==1999
	
	gen L10_exp_personal_nat_l3 = L5.exp_personal_nat_l3 if year > 2006
	replace L10_exp_personal_nat_l3 = L6.exp_personal_nat_l3 if year ==2005
	replace L10_exp_personal_nat_l3 = L7.exp_personal_nat_l3 if year ==2003
	replace L10_exp_personal_nat_l3 = L8.exp_personal_nat_l3 if year ==2001
	replace L10_exp_personal_nat_l3 = L9.exp_personal_nat_l3 if year ==1999

	* 8-year lag of experience variable
	gen L8_exp_state_nat_lagged_l3 = L4.exp_state_nat_lagged_l3 if year > 2004
	replace L8_exp_state_nat_lagged_l3 = L5.exp_state_nat_lagged_l3 if year ==2003
	replace L8_exp_state_nat_lagged_l3 = L6.exp_state_nat_lagged_l3 if year ==2001
	replace L8_exp_state_nat_lagged_l3 = L7.exp_state_nat_lagged_l3 if year ==1999
	
	gen L8_exp_personal_nat_l3 = L4.exp_personal_nat_l3 if year > 2004
	replace L8_exp_personal_nat_l3 = L5.exp_personal_nat_l3 if year ==2003
	replace L8_exp_personal_nat_l3 = L6.exp_personal_nat_l3 if year ==2001
	replace L8_exp_personal_nat_l3 = L7.exp_personal_nat_l3 if year ==1999
	
	* 6-year lag of experience variable
	gen L6_exp_state_nat_lagged_l3 = L3.exp_state_nat_lagged_l3 if year > 2002
	replace L6_exp_state_nat_lagged_l3 = L4.exp_state_nat_lagged_l3 if year ==2001
	replace L6_exp_state_nat_lagged_l3 = L5.exp_state_nat_lagged_l3 if year ==1999
	
	gen L6_exp_personal_nat_l3 = L3.exp_personal_nat_l3 if year > 2002
	replace L6_exp_personal_nat_l3 = L4.exp_personal_nat_l3 if year ==2001
	replace L6_exp_personal_nat_l3 = L5.exp_personal_nat_l3 if year ==1999
		
	* 4-year lag of experience variable
	gen L4_exp_state_nat_lagged_l3 = L2.exp_state_nat_lagged_l3 if year >2000
	replace L4_exp_state_nat_lagged_l3 = L3.exp_state_nat_lagged_l3 if year ==1999
	
	gen L4_exp_personal_nat_l3 = L2.exp_personal_nat_l3 if year >2000
	replace L4_exp_personal_nat_l3 = L3.exp_personal_nat_l3 if year ==1999
	
		* 14-year lag of experience variable
	gen L14_WEALTH_TOTAL = L7.WEALTH_TOTAL if year > 2010
	replace L14_WEALTH_TOTAL = L8.WEALTH_TOTAL if year ==2009
	replace L14_WEALTH_TOTAL = L9.exp_state_nat_lagged_1 if year ==2007
	replace L14_WEALTH_TOTAL = L10.exp_state_nat_lagged_1 if year ==2005
	replace L14_WEALTH_TOTAL = L11.exp_state_nat_lagged_1 if year ==2003
	replace L14_WEALTH_TOTAL = L12.exp_state_nat_lagged_1 if year ==2001
	replace L14_WEALTH_TOTAL = L13.exp_state_nat_lagged_1 if year ==1999
		
	* 12-year lag of experience variable
	gen L12_WEALTH_TOTAL = L6.WEALTH_TOTAL if year > 2008
	replace L12_WEALTH_TOTAL = L7.WEALTH_TOTAL if year ==2007
	replace L12_WEALTH_TOTAL = L8.WEALTH_TOTAL if year ==2005
	replace L12_WEALTH_TOTAL= L9.WEALTH_TOTAL if year ==2003
	replace L12_WEALTH_TOTAL= L10.WEALTH_TOTAL if year ==2001
	replace L12_WEALTH_TOTAL = L11.WEALTH_TOTAL if year ==1999
	
	
	* 10-year lag of experience variable
	gen L10_WEALTH_TOTAL = L5.WEALTH_TOTAL if year > 2006
	replace L10_WEALTH_TOTAL = L6.WEALTH_TOTAL if year ==2005
	replace L10_WEALTH_TOTAL = L7.WEALTH_TOTAL if year ==2003
	replace L10_WEALTH_TOTAL = L8.WEALTH_TOTAL if year ==2001
	replace L10_WEALTH_TOTAL = L9.WEALTH_TOTAL if year ==1999
	

	* 8-year lag of experience variable
	gen L8_WEALTH_TOTAL = L4.WEALTH_TOTAL if year > 2004
	replace L8_WEALTH_TOTAL = L5.WEALTH_TOTAL if year ==2003
	replace L8_WEALTH_TOTAL = L6.WEALTH_TOTAL if year ==2001
	replace L8_WEALTH_TOTAL = L7.WEALTH_TOTAL if year ==1999
		
	* 6-year lag of experience variable
	gen L6_WEALTH_TOTAL = L3.WEALTH_TOTAL if year > 2002
	replace L6_WEALTH_TOTAL = L4.WEALTH_TOTAL if year ==2001
	replace L6_WEALTH_TOTAL = L5.WEALTH_TOTAL if year ==1999
			
	* 4-year lag of experience variable
	gen L4_WEALTH_TOTAL = L2.WEALTH_TOTAL if year >2000
	replace L4_WEALTH_TOTAL = L3.WEALTH_TOTAL if year ==1999

	gen l4_total_wealth = log(L4_WEALTH_TOTAL) 
	gen l6_total_wealth = log(L6_WEALTH_TOTAL) 
	gen l8_total_wealth = log(L8_WEALTH_TOTAL)
	gen l10_total_wealth = log(L10_WEALTH_TOTAL) 
	gen l12_total_wealth = log(L12_WEALTH_TOTAL) 
	gen l14_total_wealth = log(L14_WEALTH_TOTAL) 

	

	foreach x in 6 8 10 12 {
	  preserve
	  drop if L`x'_exp_state_nat ==.
	  drop if L`x'_exp_personal ==.
	  drop if l`x'_income_ave ==.
	  	
	  duplicates tag ID, gen(tag)
	  drop if tag == 0 /* singletons */
	  drop tag
	  	
      reghdfe total_wealth L`x'_exp_personal GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state income l`x'_income_ave l`x'_total_wealth i.HD_RACE i.HEAD_EDU, absorb(age year GSA) cluster(cohort)
	  outreg2 using "../../Tables/table_a12/table_a12_lambda1_`x'.tex", excel title (Dependent: Log Consumption Value) ctitle (Total_wealth) keep(L`x'_exp_personal) dec(3) nonotes nocons replace
 	reghdfe total_wealth L`x'_exp_state_nat GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state income l`x'_income_ave l`x'_total_wealth i.HD_RACE i.HEAD_EDU, absorb(age year GSA) cluster(cohort)
	  outreg2 using "../../Tables/table_a12/table_a12_lambda1_`x'.tex", excel title (Dependent: Log Consumption Value) ctitle (Total_wealth) keep(L`x'_exp_state_nat) dec(3) nonotes nocons append
	reghdfe total_wealth L`x'_exp_personal L`x'_exp_state_nat GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state income l`x'_income_ave l`x'_total_wealth i.HD_RACE i.HEAD_EDU, absorb(age year GSA) cluster(cohort)
	  outreg2 using "../../Tables/table_a12/table_a12_lambda1_`x'.tex", excel title (Dependent: Log Consumption Value) ctitle (Total_wealth) keep(L`x'_exp_state_nat L`x'_exp_personal) dec(3) nonotes nocons append

     reghdfe total_wealth L`x'_exp_personal_nat_l3 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state income l`x'_income_ave l`x'_total_wealth i.HD_RACE i.HEAD_EDU, absorb(age year GSA) cluster(cohort)
	  outreg2 using "../../Tables/table_a12/table_a12_lambda3_`x'.tex", excel title (Dependent: Log Consumption Value) ctitle (Total_wealth) keep(L`x'_exp_personal_nat_l3) dec(3) nonotes nocons replace
  	  reghdfe total_wealth L`x'_exp_state_nat_lagged_l3 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state income l`x'_income_ave l`x'_total_wealth i.HD_RACE i.HEAD_EDU, absorb(age year GSA) cluster(cohort)
	  outreg2 using "../../Tables/table_a12/table_a12_lambda3_`x'.tex", excel title (Dependent: Log Consumption Value) ctitle (Total_wealth) keep(L`x'_exp_state_nat_lagged_l3) dec(3) nonotes nocons append
	reghdfe total_wealth  L`x'_exp_personal_nat_l3 L`x'_exp_state_nat_lagged_l3 GENDER FAM_NUM_TOTAL HEAD_MARITAL UNEMP unemp_state income l`x'_income_ave l`x'_total_wealth i.HD_RACE i.HEAD_EDU, absorb(age year GSA) cluster(cohort)
	  outreg2 using "../../Tables/table_a12/table_a12_lambda3_`x'.tex", excel title (Dependent: Log Consumption Value) ctitle (Total_wealth) keep(L`x'_exp_state_nat_lagged_l3 L`x'_exp_personal_nat_l3) dec(3) nonotes nocons append

	  restore
	}

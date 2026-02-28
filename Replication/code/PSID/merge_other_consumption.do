/************************************************************************************************
  Input: 1. "../../data/PSID/psid_new_with_exp_fzero_debt_lagged"
         2. Raw PSID data files on consumption: "../../raw/PSID/consumption/con_[year].dta"

		 
  Output: "../../data/PSID/psid_new_with_exp_allf_lagged.dta"
  
  cd to the folder that stores this code: cd "./Replication/code/PSID"
************************************************************************************************/
clear
set more off

 use "../../data/PSID/psid_new_with_exp_fzero_debt_lagged"
  sort INTERVIEW_ID year
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/consumption/con_1999.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/consumption/con_2001.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/consumption/con_2003.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/consumption/con_2005.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/consumption/con_2007.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/consumption/con_2009.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/consumption/con_2011.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/consumption/con_2013.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/consumption/con_2015.dta", assert(1 3) nogen
  merge 1:1 INTERVIEW_ID year using "../../raw/PSID/consumption/con_2017.dta", assert(1 3) nogen
  
/* Combine consumption variables */
  gen FOOD_C =.
    replace FOOD_C = FOOD99 if year == 1999
    replace FOOD_C = FOOD01 if year == 2001
	replace FOOD_C = FOOD03 if year == 2003
	replace FOOD_C = FOOD05 if year == 2005
	replace FOOD_C = FOOD07 if year == 2007
	replace FOOD_C = FOOD09 if year == 2009
	replace FOOD_C = FOOD11 if year == 2011
	replace FOOD_C = FOOD13 if year == 2013
	replace FOOD_C = FOOD15 if year == 2015
	replace FOOD_C = FOOD17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop FOOD`x'
	}
  gen FDHM =.
    replace FDHM = FDHM99 if year == 1999
    replace FDHM = FDHM01 if year == 2001
	replace FDHM = FDHM03 if year == 2003
	replace FDHM = FDHM05 if year == 2005
	replace FDHM = FDHM07 if year == 2007
	replace FDHM = FDHM09 if year == 2009
	replace FDHM = FDHM11 if year == 2011
	replace FDHM = FDHM13 if year == 2013
	replace FDHM = FDHM15 if year == 2015
	replace FDHM = FDHM17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop FDHM`x'
	}
  gen FDOUT =.
    replace FDOUT = FDOUT99 if year == 1999
    replace FDOUT = FDOUT01 if year == 2001
	replace FDOUT = FDOUT03 if year == 2003
	replace FDOUT = FDOUT05 if year == 2005
	replace FDOUT = FDOUT07 if year == 2007
	replace FDOUT = FDOUT09 if year == 2009
	replace FDOUT = FDOUT11 if year == 2011
	replace FDOUT = FDOUT13 if year == 2013
	replace FDOUT = FDOUT15 if year == 2015
	replace FDOUT = FDOUT17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop FDOUT`x'
	}
  gen FDDEL =.
    replace FDDEL = FDDEL99 if year == 1999
    replace FDDEL = FDDEL01 if year == 2001
	replace FDDEL = FDDEL03 if year == 2003
	replace FDDEL = FDDEL05 if year == 2005
	replace FDDEL = FDDEL07 if year == 2007
	replace FDDEL = FDDEL09 if year == 2009
	replace FDDEL = FDDEL11 if year == 2011
	replace FDDEL = FDDEL13 if year == 2013
	replace FDDEL = FDDEL15 if year == 2015
	replace FDDEL = FDDEL17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop FDDEL`x'
	}
  gen HOUS =.
    replace HOUS = HOUS99 if year == 1999
    replace HOUS = HOUS01 if year == 2001
	replace HOUS = HOUS03 if year == 2003
	replace HOUS = HOUS05 if year == 2005
	replace HOUS = HOUS07 if year == 2007
	replace HOUS = HOUS09 if year == 2009
	replace HOUS = HOUS11 if year == 2011
	replace HOUS = HOUS13 if year == 2013
	replace HOUS = HOUS15 if year == 2015
	replace HOUS = HOUS17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop HOUS`x'
	}
  gen MORT =.
    replace MORT = MORT99 if year == 1999
    replace MORT = MORT01 if year == 2001
	replace MORT = MORT03 if year == 2003
	replace MORT = MORT05 if year == 2005
	replace MORT = MORT07 if year == 2007
	replace MORT = MORT09 if year == 2009
	replace MORT = MORT11 if year == 2011
	replace MORT = MORT13 if year == 2013
	replace MORT = MORT15 if year == 2015
	replace MORT = MORT17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop MORT`x'
	}
  gen RENT_C =.
    replace RENT_C = RENT99 if year == 1999
    replace RENT_C = RENT01 if year == 2001
	replace RENT_C = RENT03 if year == 2003
	replace RENT_C = RENT05 if year == 2005
	replace RENT_C = RENT07 if year == 2007
	replace RENT_C = RENT09 if year == 2009
	replace RENT_C = RENT11 if year == 2011
	replace RENT_C = RENT13 if year == 2013
	replace RENT_C = RENT15 if year == 2015
	replace RENT_C = RENT17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop RENT`x'
	}
  gen PRPTAX =.
    replace PRPTAX = PRPTAX99 if year == 1999
    replace PRPTAX = PRPTAX01 if year == 2001
	replace PRPTAX = PRPTAX03 if year == 2003
	replace PRPTAX = PRPTAX05 if year == 2005
	replace PRPTAX = PRPTAX07 if year == 2007
	replace PRPTAX = PRPTAX09 if year == 2009
	replace PRPTAX = PRPTAX11 if year == 2011
	replace PRPTAX = PRPTAX13 if year == 2013
	replace PRPTAX = PRPTAX15 if year == 2015
	replace PRPTAX = PRPTAX17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop PRPTAX`x'
	}
  gen HMEINS =.
    replace HMEINS = HMEINS99 if year == 1999
    replace HMEINS = HMEINS01 if year == 2001
	replace HMEINS = HMEINS03 if year == 2003
	replace HMEINS = HMEINS05 if year == 2005
	replace HMEINS = HMEINS07 if year == 2007
	replace HMEINS = HMEINS09 if year == 2009
	replace HMEINS = HMEINS11 if year == 2011
	replace HMEINS = HMEINS13 if year == 2013
	replace HMEINS = HMEINS15 if year == 2015
	replace HMEINS = HMEINS17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop HMEINS`x'
	}
  gen UTIL =.
    replace UTIL = UTIL99 if year == 1999
    replace UTIL = UTIL01 if year == 2001
	replace UTIL = UTIL03 if year == 2003
	replace UTIL = UTIL05 if year == 2005
	replace UTIL = UTIL07 if year == 2007
	replace UTIL = UTIL09 if year == 2009
	replace UTIL = UTIL11 if year == 2011
	replace UTIL = UTIL13 if year == 2013
	replace UTIL = UTIL15 if year == 2015
	replace UTIL = UTIL17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop UTIL`x'
	}
  gen HEAT =.
    replace HEAT = HEAT99 if year == 1999
    replace HEAT = HEAT01 if year == 2001
	replace HEAT = HEAT03 if year == 2003
	replace HEAT = HEAT05 if year == 2005
	replace HEAT = HEAT07 if year == 2007
	replace HEAT = HEAT09 if year == 2009
	replace HEAT = HEAT11 if year == 2011
	replace HEAT = HEAT13 if year == 2013
	replace HEAT = HEAT15 if year == 2015
	replace HEAT = HEAT17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop HEAT`x'
	}
  gen ELECTR =.
    replace ELECTR = ELECTR99 if year == 1999
    replace ELECTR = ELECTR01 if year == 2001
	replace ELECTR = ELECTR03 if year == 2003
	replace ELECTR = ELECTR05 if year == 2005
	replace ELECTR = ELECTR07 if year == 2007
	replace ELECTR = ELECTR09 if year == 2009
	replace ELECTR = ELECTR11 if year == 2011
	replace ELECTR = ELECTR13 if year == 2013
	replace ELECTR = ELECTR15 if year == 2015
	replace ELECTR = ELECTR17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop ELECTR`x'
	}
  gen WATER =.
    replace WATER = WATER99 if year == 1999
    replace WATER = WATER01 if year == 2001
	replace WATER = WATER03 if year == 2003
	replace WATER = WATER05 if year == 2005
	replace WATER = WATER07 if year == 2007
	replace WATER = WATER09 if year == 2009
	replace WATER = WATER11 if year == 2011
	replace WATER = WATER13 if year == 2013
	replace WATER = WATER15 if year == 2015
	replace WATER = WATER17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17{
	  drop WATER`x'
	}
  gen OUTIL =.
    replace OUTIL = OUTIL99 if year == 1999
    replace OUTIL = OUTIL01 if year == 2001
	replace OUTIL = OUTIL03 if year == 2003
	replace OUTIL = OUTIL05 if year == 2005
	replace OUTIL = OUTIL07 if year == 2007
	replace OUTIL = OUTIL09 if year == 2009
	replace OUTIL = OUTIL11 if year == 2011
	replace OUTIL = OUTIL13 if year == 2013
	replace OUTIL = OUTIL15 if year == 2015
	replace OUTIL = OUTIL17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop OUTIL`x'
	}
  gen TRAN =.
    replace TRAN = TRAN99 if year == 1999
    replace TRAN = TRAN01 if year == 2001
	replace TRAN = TRAN03 if year == 2003
	replace TRAN = TRAN05 if year == 2005
	replace TRAN = TRAN07 if year == 2007
	replace TRAN = TRAN09 if year == 2009
	replace TRAN = TRAN11 if year == 2011
	replace TRAN = TRAN13 if year == 2013
	replace TRAN = TRAN15 if year == 2015
	replace TRAN = TRAN17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop TRAN`x'
	}
  gen VEHLN =.
    replace VEHLN = VEHLN99 if year == 1999
    replace VEHLN = VEHLN01 if year == 2001
	replace VEHLN = VEHLN03 if year == 2003
	replace VEHLN = VEHLN05 if year == 2005
	replace VEHLN = VEHLN07 if year == 2007
	replace VEHLN = VEHLN09 if year == 2009
	replace VEHLN = VEHLN11 if year == 2011
	replace VEHLN = VEHLN13 if year == 2013
	replace VEHLN = VEHLN15 if year == 2015
	replace VEHLN = VEHLN17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop VEHLN`x'
	}
  gen VEHPAY =.
    replace VEHPAY = VEHPAY99 if year == 1999
    replace VEHPAY = VEHPAY01 if year == 2001
	replace VEHPAY = VEHPAY03 if year == 2003
	replace VEHPAY = VEHPAY05 if year == 2005
	replace VEHPAY = VEHPAY07 if year == 2007
	replace VEHPAY = VEHPAY09 if year == 2009
	replace VEHPAY = VEHPAY11 if year == 2011
	replace VEHPAY = VEHPAY13 if year == 2013
	replace VEHPAY = VEHPAY15 if year == 2015
	replace VEHPAY = VEHPAY17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop VEHPAY`x'
	}
  gen VEHLS =.
    replace VEHLS = VEHLS99 if year == 1999
    replace VEHLS = VEHLS01 if year == 2001
	replace VEHLS = VEHLS03 if year == 2003
	replace VEHLS = VEHLS05 if year == 2005
	replace VEHLS = VEHLS07 if year == 2007
	replace VEHLS = VEHLS09 if year == 2009
	replace VEHLS = VEHLS11 if year == 2011
	replace VEHLS = VEHLS13 if year == 2013
	replace VEHLS = VEHLS15 if year == 2015
	replace VEHLS = VEHLS17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop VEHLS`x'
	}
  gen AUTOIN =.
    replace AUTOIN = AUTOIN99 if year == 1999
    replace AUTOIN = AUTOIN01 if year == 2001
	replace AUTOIN = AUTOIN03 if year == 2003
	replace AUTOIN = AUTOIN05 if year == 2005
	replace AUTOIN = AUTOIN07 if year == 2007
	replace AUTOIN = AUTOIN09 if year == 2009
	replace AUTOIN = AUTOIN11 if year == 2011
	replace AUTOIN = AUTOIN13 if year == 2013
	replace AUTOIN = AUTOIN15 if year == 2015
	replace AUTOIN = AUTOIN17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop AUTOIN`x'
	}
  gen VEHADD =.
    replace VEHADD = VEHADD99 if year == 1999
    replace VEHADD = VEHADD01 if year == 2001
	replace VEHADD = VEHADD03 if year == 2003
	replace VEHADD = VEHADD05 if year == 2005
	replace VEHADD = VEHADD07 if year == 2007
	replace VEHADD = VEHADD09 if year == 2009
	replace VEHADD = VEHADD11 if year == 2011
	replace VEHADD = VEHADD13 if year == 2013
	replace VEHADD = VEHADD15 if year == 2015
	replace VEHADD = VEHADD17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop VEHADD`x'
	}
  gen VEHREP =.
    replace VEHREP = VEHREP99 if year == 1999
    replace VEHREP = VEHREP01 if year == 2001
	replace VEHREP = VEHREP03 if year == 2003
	replace VEHREP = VEHREP05 if year == 2005
	replace VEHREP = VEHREP07 if year == 2007
	replace VEHREP = VEHREP09 if year == 2009
	replace VEHREP = VEHREP11 if year == 2011
	replace VEHREP = VEHREP13 if year == 2013
	replace VEHREP = VEHREP15 if year == 2015
	replace VEHREP = VEHREP17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop VEHREP`x'
	}
  gen GAS =.
    replace GAS = GAS99 if year == 1999
    replace GAS = GAS01 if year == 2001
	replace GAS = GAS03 if year == 2003
	replace GAS = GAS05 if year == 2005
	replace GAS = GAS07 if year == 2007
	replace GAS = GAS09 if year == 2009
	replace GAS = GAS11 if year == 2011
	replace GAS = GAS13 if year == 2013
	replace GAS = GAS15 if year == 2015
	replace GAS = GAS17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop GAS`x'
	}
  gen PARK =.
    replace PARK = PARK99 if year == 1999
    replace PARK = PARK01 if year == 2001
	replace PARK = PARK03 if year == 2003
	replace PARK = PARK05 if year == 2005
	replace PARK = PARK07 if year == 2007
	replace PARK = PARK09 if year == 2009
	replace PARK = PARK11 if year == 2011
	replace PARK = PARK13 if year == 2013
	replace PARK = PARK15 if year == 2015
	replace PARK = PARK17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop PARK`x'
	}
  gen BUS =.
    replace BUS = BUS99 if year == 1999
    replace BUS = BUS01 if year == 2001
	replace BUS = BUS03 if year == 2003
	replace BUS = BUS05 if year == 2005
	replace BUS = BUS07 if year == 2007
	replace BUS = BUS09 if year == 2009
	replace BUS = BUS11 if year == 2011
	replace BUS = BUS13 if year == 2013
	replace BUS = BUS15 if year == 2015
	replace BUS = BUS17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop BUS`x'
	}
  gen CAB =.
    replace CAB = CAB99 if year == 1999
    replace CAB = CAB01 if year == 2001
	replace CAB = CAB03 if year == 2003
	replace CAB = CAB05 if year == 2005
	replace CAB = CAB07 if year == 2007
	replace CAB = CAB09 if year == 2009
	replace CAB = CAB11 if year == 2011
	replace CAB = CAB13 if year == 2013
	replace CAB = CAB15 if year == 2015
	replace CAB = CAB17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop CAB`x'
	}
  gen OTRAN =.
    replace OTRAN = OTRAN99 if year == 1999
    replace OTRAN = OTRAN01 if year == 2001
	replace OTRAN = OTRAN03 if year == 2003
	replace OTRAN = OTRAN05 if year == 2005
	replace OTRAN = OTRAN07 if year == 2007
	replace OTRAN = OTRAN09 if year == 2009
	replace OTRAN = OTRAN11 if year == 2011
	replace OTRAN = OTRAN13 if year == 2013
	replace OTRAN = OTRAN15 if year == 2015
	replace OTRAN = OTRAN17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop OTRAN`x'
	}
  gen ED =.
    replace ED = ED99 if year == 1999
    replace ED = ED01 if year == 2001
	replace ED = ED03 if year == 2003
	replace ED = ED05 if year == 2005
	replace ED = ED07 if year == 2007
	replace ED = ED09 if year == 2009
	replace ED = ED11 if year == 2011
	replace ED = ED13 if year == 2013
	replace ED = ED15 if year == 2015
	replace ED = ED17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop ED`x'
	}
  gen CHILD =.
    replace CHILD = CHILD99 if year == 1999
    replace CHILD = CHILD01 if year == 2001
	replace CHILD = CHILD03 if year == 2003
	replace CHILD = CHILD05 if year == 2005
	replace CHILD = CHILD07 if year == 2007
	replace CHILD = CHILD09 if year == 2009
	replace CHILD = CHILD11 if year == 2011
	replace CHILD = CHILD13 if year == 2013
	replace CHILD = CHILD15 if year == 2015
	replace CHILD = CHILD17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop CHILD`x'
	}
  gen HEALTH =.
    replace HEALTH = HEALTH99 if year == 1999
    replace HEALTH = HEALTH01 if year == 2001
	replace HEALTH = HEALTH03 if year == 2003
	replace HEALTH = HEALTH05 if year == 2005
	replace HEALTH = HEALTH07 if year == 2007
	replace HEALTH = HEALTH09 if year == 2009
	replace HEALTH = HEALTH11 if year == 2011
	replace HEALTH = HEALTH13 if year == 2013
	replace HEALTH = HEALTH15 if year == 2015
	replace HEALTH = HEALTH17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop HEALTH`x'
	}
  gen HOS =.
    replace HOS = HOS99 if year == 1999
    replace HOS = HOS01 if year == 2001
	replace HOS = HOS03 if year == 2003
	replace HOS = HOS05 if year == 2005
	replace HOS = HOS07 if year == 2007
	replace HOS = HOS09 if year == 2009
	replace HOS = HOS11 if year == 2011
	replace HOS = HOS13 if year == 2013
	replace HOS = HOS15 if year == 2015
	replace HOS = HOS17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop HOS`x'
	}
  gen DOCTOR =.
    replace DOCTOR = DOCTOR99 if year == 1999
    replace DOCTOR = DOCTOR01 if year == 2001
	replace DOCTOR = DOCTOR03 if year == 2003
	replace DOCTOR = DOCTOR05 if year == 2005
	replace DOCTOR = DOCTOR07 if year == 2007
	replace DOCTOR = DOCTOR09 if year == 2009
	replace DOCTOR = DOCTOR11 if year == 2011
	replace DOCTOR = DOCTOR13 if year == 2013
	replace DOCTOR = DOCTOR15 if year == 2015
	replace DOCTOR = DOCTOR17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop DOCTOR`x'
	}
  gen PRESCR =.
    replace PRESCR = PRESCR99 if year == 1999
    replace PRESCR = PRESCR01 if year == 2001
	replace PRESCR = PRESCR03 if year == 2003
	replace PRESCR = PRESCR05 if year == 2005
	replace PRESCR = PRESCR07 if year == 2007
	replace PRESCR = PRESCR09 if year == 2009
	replace PRESCR = PRESCR11 if year == 2011
	replace PRESCR = PRESCR13 if year == 2013
	replace PRESCR = PRESCR15 if year == 2015
	replace PRESCR = PRESCR17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop PRESCR`x'
	}
  gen HINS =.
    replace HINS = HINS99 if year == 1999
    replace HINS = HINS01 if year == 2001
	replace HINS = HINS03 if year == 2003
	replace HINS = HINS05 if year == 2005
	replace HINS = HINS07 if year == 2007
	replace HINS = HINS09 if year == 2009
	replace HINS = HINS11 if year == 2011
	replace HINS = HINS13 if year == 2013
	replace HINS = HINS15 if year == 2015
	replace HINS = HINS17 if year == 2017
	foreach x in 99 01 03 05 07 09 11 13 15 17 {
	  drop HINS`x'
	}
  gen TELINT =.
    replace TELINT = TELINT05 if year == 2005
	replace TELINT = TELINT07 if year == 2007
	replace TELINT = TELINT09 if year == 2009
	replace TELINT = TELINT11 if year == 2011
	replace TELINT = TELINT13 if year == 2013
	replace TELINT = TELINT15 if year == 2015
	replace TELINT = TELINT17 if year == 2017
	foreach x in 05 07 09 11 13 15 17 {
	  drop TELINT`x'
	}
  gen HHREP =.
    replace HHREP = HHREP05 if year == 2005
	replace HHREP = HHREP07 if year == 2007
	replace HHREP = HHREP09 if year == 2009
	replace HHREP = HHREP11 if year == 2011
	replace HHREP = HHREP13 if year == 2013
	replace HHREP = HHREP15 if year == 2015
	replace HHREP = HHREP17 if year == 2017
	foreach x in 05 07 09 11 13 15 17 {
	  drop HHREP`x'
	}
  gen FURN =.
    replace FURN = FURN05 if year == 2005
	replace FURN = FURN07 if year == 2007
	replace FURN = FURN09 if year == 2009
	replace FURN = FURN11 if year == 2011
	replace FURN = FURN13 if year == 2013
	replace FURN = FURN15 if year == 2015
	replace FURN = FURN17 if year == 2017
	foreach x in 05 07 09 11 13 15 17 {
	  drop FURN`x'
	}
  gen CLOTH =.
    replace CLOTH = CLOTH05 if year == 2005
	replace CLOTH = CLOTH07 if year == 2007
	replace CLOTH = CLOTH09 if year == 2009
	replace CLOTH = CLOTH11 if year == 2011
	replace CLOTH = CLOTH13 if year == 2013
	replace CLOTH = CLOTH15 if year == 2015
	replace CLOTH = CLOTH17 if year == 2017
	foreach x in 05 07 09 11 13 15 17 {
	  drop CLOTH`x'
	}
  gen TRIPS =.
    replace TRIPS = TRIPS05 if year == 2005
	replace TRIPS = TRIPS07 if year == 2007
	replace TRIPS = TRIPS09 if year == 2009
	replace TRIPS = TRIPS11 if year == 2011
	replace TRIPS = TRIPS13 if year == 2013
	replace TRIPS = TRIPS15 if year == 2015
	replace TRIPS = TRIPS17 if year == 2017
	foreach x in 05 07 09 11 13 15 17 {
	  drop TRIPS`x'
	}
  gen OTHREC =.
    replace OTHREC = OTHREC05 if year == 2005
	replace OTHREC = OTHREC07 if year == 2007
	replace OTHREC = OTHREC09 if year == 2009
	replace OTHREC = OTHREC11 if year == 2011
	replace OTHREC = OTHREC13 if year == 2013
	replace OTHREC = OTHREC15 if year == 2015
	replace OTHREC = OTHREC17 if year == 2017
	foreach x in 05 07 09 11 13 15 17 {
	  drop OTHREC`x'
	}
	
	
  gen TOTAL_CONSUMP1 = FOOD_C + HOUS + TRAN + ED + CHILD + HEALTH
  gen TOTAL_CONSUMP2 = FOOD_C + HOUS + TRAN + ED + CHILD + HEALTH if year < 2005
  replace TOTAL_CONSUMP2 = FOOD_C + HOUS + TRAN + ED + CHILD + HEALTH + TELINT + ///
    HHREP + FURN + CLOTH + TRIPS + OTHREC if year >= 2005
	
  
  save "../../data/PSID/psid_new_with_exp_allf_lagged.dta", replace
  

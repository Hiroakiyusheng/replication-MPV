
/************************************************************************************************
  Input: 1. "../../data/PSID/psid_new.dta"
         2. "../../raw/nat_UE_1890_2017.dta"
		 3. "../../raw/state_UE_1976_2017.dta"
  Output: 1. "../../data/PSID/individual_for_exp_nat_lagged.dta"
          2. "../../data/PSID/individual_for_exp_state_lagged_1.dta"
		  3. "../../data/PSID/individual_for_exp_personal_lagged_1.dta"

cd to the folder that stores this code: cd "./Replication/code/PSID"
************************************************************************************************/

clear
set more off

*************************************************************************************************/
/* PART I: prepare dataset for calculating 1-year lagged state-level exp measures 
using t-6 to t-2 unemployment rate */ 
*************************************************************************************************/  
/* subset the main data set */
use "../../data/PSID/psid_new.dta", clear
drop if Fam_ID > 7000  /* drop Latino */

preserve
gen HEAD = 1 if RELATION_TO_HEAD == 1 & year == 1968
replace HEAD = 1 if RELATION_TO_HEAD == 1 & SEQUENCE_NUM == 1 & year >1968
replace HEAD = 1 if RELATION_TO_HEAD == 10 & SEQUENCE_NUM == 1
keep if HEAD == 1  /* keep only heads */
keep HEAD ID
duplicates drop  
sort ID
save "heads_id.dta", replace
restore

sort ID year
merge m:1 ID using "heads_id.dta", keep(3) nogen
erase heads_id.dta
  
/* impute the ages */
preserve
bysort ID: gen tag = 1 if AGE_INDIVIDUAL! = 0 & AGE_INDIVIDUAL!=999
keep if tag == 1
sort ID year
by ID: gen seq = _n
by ID: gen age_start = AGE_INDIVIDUAL if seq == 1
keep age_start ID year
drop if age_start ==.
rename year year_start
tempfile temp1
save `temp1'
restore
merge m:1 ID using `temp1'
gen AGE_IMPUTED = age_start + year - year_start
drop _merge age_start year_start
replace AGE_IMPUTED = 0  if AGE_IMPUTED <0
drop if AGE_IMPUTED ==. 
gen birth = year - AGE_IMPUTED
drop if birth < 1890 /* we don't have UE rates before 1890 */
order AGE_IMPUTED, after(year)
rename AGE_IMPUTED age

/* get data set for calculating nation-level exp */
preserve
keep ID year age 
keep if age != 0
sort ID year
saveold "../../data/PSID/individual_for_exp_nat_lagged.dta", replace version(12)
restore
  
/* Criterion -- 5 consecutive years presence after 1976, the earliest year for which we have state UE data */
drop if year < 1976
gen presence = (SEQUENCE_NUM<21 & SEQUENCE_NUM >0)
replace presence = 0 if FAM_STATE_GSA == 50 | FAM_STATE_GSA == 51 | FAM_STATE_GSA == 0 ///
| FAM_STATE_GSA == 99

preserve
keep ID year presence
sort ID year
reshape wide presence, i(ID) j(year)
/* need to tag using not only the five years that will be inputted for experience measure but also the omitted years right before the current one for the R code to function properly */
gen tag1982 = 1 if presence1976 == 1 & presence1977 == 1 & presence1978 == 1 & presence1979 == 1 & presence1980 == 1 & presence1981 == 1 & presence1982 == 1
gen tag1983 = 1 if presence1977 == 1 & presence1978 == 1 & presence1979 == 1 & presence1980 == 1 & presence1981 == 1 & presence1982 == 1 & presence1983 == 1
gen tag1984 = 1 if presence1978 == 1 & presence1979 == 1 & presence1980 == 1 & presence1981 == 1 & presence1982 == 1 & presence1983 == 1 & presence1984 == 1
gen tag1985 = 1 if presence1979 == 1 & presence1980 == 1 & presence1981 == 1 & presence1982 == 1 & presence1983 == 1 & presence1984 == 1 & presence1985 == 1
gen tag1986 = 1 if presence1980 == 1 & presence1981 == 1 & presence1982 == 1 & presence1983 == 1 & presence1984 == 1 & presence1985 == 1 & presence1986 == 1
gen tag1987 = 1 if presence1981 == 1 & presence1982 == 1 & presence1983 == 1 & presence1984 == 1 & presence1985 == 1 & presence1986 == 1 & presence1987 == 1
gen tag1988 = 1 if presence1982 == 1 & presence1983 == 1 & presence1984 == 1 & presence1985 == 1 & presence1986 == 1 & presence1987 == 1 & presence1988 == 1
gen tag1989 = 1 if presence1983 == 1 & presence1984 == 1 & presence1985 == 1 & presence1986 == 1 & presence1987 == 1 & presence1988 == 1 & presence1989 == 1
gen tag1990 = 1 if presence1984 == 1 & presence1985 == 1 & presence1986 == 1 & presence1987 == 1 & presence1988 == 1 & presence1989 == 1 & presence1990 == 1
gen tag1991 = 1 if presence1985 == 1 & presence1986 == 1 & presence1987 == 1 & presence1988 == 1 & presence1989 == 1 & presence1990 == 1 & presence1991 == 1
gen tag1992 = 1 if presence1986 == 1 & presence1987 == 1 & presence1988 == 1 & presence1989 == 1 & presence1990 == 1 & presence1991 == 1 & presence1992 == 1
gen tag1993 = 1 if presence1987 == 1 & presence1988 == 1 & presence1989 == 1 & presence1990 == 1 & presence1991 == 1 & presence1992 == 1 & presence1993 == 1
gen tag1994 = 1 if presence1988 == 1 & presence1989 == 1 & presence1990 == 1 & presence1991 == 1 & presence1992 == 1 & presence1993 == 1 & presence1994 == 1
gen tag1995 = 1 if presence1989 == 1 & presence1990 == 1 & presence1991 == 1 & presence1992 == 1 & presence1993 == 1 & presence1994 == 1 & presence1995 == 1
gen tag1996 = 1 if presence1990 == 1 & presence1991 == 1 & presence1992 == 1 & presence1993 == 1 & presence1994 == 1 & presence1995 == 1 & presence1996 == 1
gen tag1997 = 1 if presence1991 == 1 & presence1992 == 1 & presence1993 == 1 & presence1994 == 1 & presence1995 == 1 & presence1996 == 1 & presence1997 == 1
gen tag1999 = 1 if presence1993 == 1 & presence1994 == 1 & presence1995 == 1 & presence1996 == 1 & presence1997 == 1 & presence1999 == 1
gen tag2001 = 1 if presence1995 == 1 & presence1996 == 1 & presence1997 == 1 & presence1999 == 1 & presence2001 == 1
gen tag2003 = 1 if presence1997 == 1 & presence1999 == 1 & presence2001 == 1 & presence2003 == 1
gen tag2005 = 1 if presence1999 == 1 & presence2001 == 1 & presence2003 == 1 & presence2005 == 1
gen tag2007 = 1 if presence2001 == 1 & presence2003 == 1 & presence2005 == 1 & presence2007 == 1
gen tag2009 = 1 if presence2003 == 1 & presence2005 == 1 & presence2007 == 1 & presence2009 == 1
gen tag2011 = 1 if presence2005 == 1 & presence2007 == 1 & presence2009 == 1 & presence2011 == 1
gen tag2013 = 1 if presence2007 == 1 & presence2009 == 1 & presence2011 == 1 & presence2013 == 1
gen tag2015 = 1 if presence2009 == 1 & presence2011 == 1 & presence2013 == 1 & presence2015 == 1
gen tag2017 = 1 if presence2011 == 1 & presence2013 == 1 & presence2015 == 1 & presence2017 == 1
reshape long presence tag, i(ID) j(year)
gen mark = tag
/* need to tag the five input years as only the current years are tagged */
reshape wide presence tag mark, i(ID) j(year)
replace tag1976 = 1 if tag1982 == 1
replace tag1977 = 1 if tag1982 == 1
replace tag1978 = 1 if tag1982 == 1
replace tag1979 = 1 if tag1982 == 1
replace tag1980 = 1 if tag1982 == 1
replace tag1981 = 1 if tag1982 == 1

replace tag1977 = 1 if tag1983 == 1
replace tag1978 = 1 if tag1983 == 1
replace tag1979 = 1 if tag1983 == 1
replace tag1980 = 1 if tag1983 == 1
replace tag1981 = 1 if tag1983 == 1
replace tag1982 = 1 if tag1983 == 1

replace tag1978 = 1 if tag1984 == 1
replace tag1979 = 1 if tag1984 == 1
replace tag1980 = 1 if tag1984 == 1
replace tag1981 = 1 if tag1984 == 1
replace tag1982 = 1 if tag1984 == 1
replace tag1983 = 1 if tag1984 == 1

replace tag1979 = 1 if tag1985 == 1
replace tag1980 = 1 if tag1985 == 1
replace tag1981 = 1 if tag1985 == 1
replace tag1982 = 1 if tag1985 == 1
replace tag1983 = 1 if tag1985 == 1
replace tag1984 = 1 if tag1985 == 1

replace tag1980 = 1 if tag1986 == 1
replace tag1981 = 1 if tag1986 == 1
replace tag1982 = 1 if tag1986 == 1
replace tag1983 = 1 if tag1986 == 1
replace tag1984 = 1 if tag1986 == 1
replace tag1985 = 1 if tag1986 == 1

replace tag1981 = 1 if tag1987 == 1
replace tag1982 = 1 if tag1987 == 1
replace tag1983 = 1 if tag1987 == 1
replace tag1984 = 1 if tag1987 == 1
replace tag1985 = 1 if tag1987 == 1
replace tag1986 = 1 if tag1987 == 1

replace tag1982 = 1 if tag1988 == 1
replace tag1983 = 1 if tag1988 == 1
replace tag1984 = 1 if tag1988 == 1
replace tag1985 = 1 if tag1988 == 1
replace tag1986 = 1 if tag1988 == 1
replace tag1987 = 1 if tag1988 == 1

replace tag1983 = 1 if tag1989 == 1
replace tag1984 = 1 if tag1989 == 1
replace tag1985 = 1 if tag1989 == 1
replace tag1986 = 1 if tag1989 == 1
replace tag1987 = 1 if tag1989 == 1
replace tag1988 = 1 if tag1989 == 1

replace tag1984 = 1 if tag1990 == 1
replace tag1985 = 1 if tag1990 == 1
replace tag1986 = 1 if tag1990 == 1
replace tag1987 = 1 if tag1990 == 1
replace tag1988 = 1 if tag1990 == 1
replace tag1989 = 1 if tag1990 == 1

replace tag1985 = 1 if tag1991 == 1
replace tag1986 = 1 if tag1991 == 1
replace tag1987 = 1 if tag1991 == 1
replace tag1988 = 1 if tag1991 == 1
replace tag1989 = 1 if tag1991 == 1
replace tag1990 = 1 if tag1991 == 1

replace tag1986 = 1 if tag1992 == 1
replace tag1987 = 1 if tag1992 == 1
replace tag1988 = 1 if tag1992 == 1
replace tag1989 = 1 if tag1992 == 1
replace tag1990 = 1 if tag1992 == 1
replace tag1991 = 1 if tag1992 == 1

replace tag1987 = 1 if tag1993 == 1
replace tag1988 = 1 if tag1993 == 1
replace tag1989 = 1 if tag1993 == 1
replace tag1990 = 1 if tag1993 == 1
replace tag1991 = 1 if tag1993 == 1
replace tag1992 = 1 if tag1993 == 1

replace tag1988 = 1 if tag1994 == 1
replace tag1989 = 1 if tag1994 == 1
replace tag1990 = 1 if tag1994 == 1
replace tag1991 = 1 if tag1994 == 1
replace tag1992 = 1 if tag1994 == 1
replace tag1993 = 1 if tag1994 == 1

replace tag1989 = 1 if tag1995 == 1
replace tag1990 = 1 if tag1995 == 1
replace tag1991 = 1 if tag1995 == 1
replace tag1992 = 1 if tag1995 == 1
replace tag1993 = 1 if tag1995 == 1
replace tag1994 = 1 if tag1995 == 1

replace tag1990 = 1 if tag1996 == 1
replace tag1991 = 1 if tag1996 == 1
replace tag1992 = 1 if tag1996 == 1
replace tag1993 = 1 if tag1996 == 1
replace tag1994 = 1 if tag1996 == 1
replace tag1995 = 1 if tag1996 == 1

replace tag1991 = 1 if tag1997 == 1
replace tag1992 = 1 if tag1997 == 1
replace tag1993 = 1 if tag1997 == 1
replace tag1994 = 1 if tag1997 == 1
replace tag1995 = 1 if tag1997 == 1
replace tag1996 = 1 if tag1997 == 1

replace tag1993 = 1 if tag1999 == 1
replace tag1994 = 1 if tag1999 == 1
replace tag1995 = 1 if tag1999 == 1
replace tag1996 = 1 if tag1999 == 1
replace tag1997 = 1 if tag1999 == 1

replace tag1995 = 1 if tag2001 == 1
replace tag1996 = 1 if tag2001 == 1
replace tag1997 = 1 if tag2001 == 1
replace tag1999 = 1 if tag2001 == 1

replace tag1997 = 1 if tag2003 == 1
replace tag1999 = 1 if tag2003 == 1
replace tag2001 = 1 if tag2003 == 1

replace tag1999 = 1 if tag2005 == 1
replace tag2001 = 1 if tag2005 == 1
replace tag2003 = 1 if tag2005 == 1

replace tag2001 = 1 if tag2007 == 1
replace tag2003 = 1 if tag2007 == 1
replace tag2005 = 1 if tag2007 == 1

replace tag2003 = 1 if tag2009 == 1
replace tag2005 = 1 if tag2009 == 1
replace tag2007 = 1 if tag2009 == 1

replace tag2005 = 1 if tag2011 == 1
replace tag2007 = 1 if tag2011 == 1
replace tag2009 = 1 if tag2011 == 1

replace tag2007 = 1 if tag2013 == 1
replace tag2009 = 1 if tag2013 == 1
replace tag2011 = 1 if tag2013 == 1

replace tag2009 = 1 if tag2015 == 1
replace tag2011 = 1 if tag2015 == 1
replace tag2013 = 1 if tag2015 == 1

replace tag2011 = 1 if tag2017 == 1
replace tag2013 = 1 if tag2017 == 1
replace tag2015 = 1 if tag2017 == 1

reshape long presence tag mark, i(ID) j(year)
keep ID year tag mark
sort ID year
tempfile temp
save `temp'	
restore
sort ID year
merge 1:1 ID year using `temp'
drop _merge
keep if tag == 1
gen GSA = FAM_STATE_GSA
keep ID year age GSA mark
replace mark = 0 if mark == .
saveold "../../data/PSID/individual_for_exp_state_lagged_1.dta", replace version(12)

*************************************************************************************************/
/* PART II: prepare dataset for calculating 1-year lagged personal experience measures 
using t-6 to t-2 unemployment status */ 
*************************************************************************************************/  
/* subset the main data set */
use "../../data/PSID/psid_new.dta", clear
drop if Fam_ID > 7000  /* drop Latino */

preserve
gen HEAD = 1 if RELATION_TO_HEAD == 1 & year == 1968
replace HEAD = 1 if RELATION_TO_HEAD == 1 & SEQUENCE_NUM == 1 & year >1968
replace HEAD = 1 if RELATION_TO_HEAD == 10 & SEQUENCE_NUM == 1
keep if HEAD == 1  /* keep only heads */
keep HEAD ID
duplicates drop  /* 25918 left */
sort ID
save "heads_id.dta", replace
restore

sort ID year
merge m:1 ID using "heads_id.dta", keep(3) nogen
erase "heads_id.dta"

/* impute the ages */
preserve
bysort ID: gen tag = 1 if AGE_INDIVIDUAL! = 0 & AGE_INDIVIDUAL!=999
keep if tag == 1
sort ID year
by ID: gen seq = _n
by ID: gen age_start = AGE_INDIVIDUAL if seq == 1
keep age_start ID year
drop if age_start ==.
rename year year_start
tempfile temp1
save `temp1'
restore
merge m:1 ID using `temp1'
gen AGE_IMPUTED = age_start + year - year_start
drop _merge age_start year_start
replace AGE_IMPUTED = 0  if AGE_IMPUTED <0
drop if AGE_IMPUTED ==. /* drop 4 heads */
gen birth = year - AGE_IMPUTED
drop if birth < 1890 /* drop 110 heads -- we don't have UE rates before 1890 */
order AGE_IMPUTED, after(year)
rename AGE_IMPUTED age

/* generate personal employment status */
gen EMP1 = 0 if EMPLOY_STATUS == 1 | EMPLOY_STATUS == 4 | EMPLOY_STATUS == 5 | EMPLOY_STATUS == 6 ///
| EMPLOY_STATUS == 7 | EMPLOY_STATUS == 2
replace EMP1 = 1 if EMPLOY_STATUS == 3
gen EMP2 = 0 if EMPLOY_STATUS == 1 | EMPLOY_STATUS == 4 | EMPLOY_STATUS == 5 | EMPLOY_STATUS == 6 ///
| EMPLOY_STATUS == 7 
replace EMP2 = 1 if EMPLOY_STATUS == 3 | EMPLOY_STATUS == 2

/* create personal experience measures using t-6 to t-2 years (1 year lag) */
keep ID year age EMP1 EMP2
drop if year < 1978
keep if age != 0
sort ID year

gen presence = 1 if EMP1!=.
preserve
keep ID year presence
/* need to tag using not only the five years that will be inputted for experience measure but also the omitted years right before the current one for the R code to function properly */
reshape wide presence, i(ID) j(year)
gen tag1984 = 1 if presence1978 == 1 & presence1979 == 1 & presence1980 == 1 & presence1981 == 1 & presence1982 == 1 & presence1983 == 1 & presence1984 == 1
gen tag1985 = 1 if presence1979 == 1 & presence1980 == 1 & presence1981 == 1 & presence1982 == 1 & presence1983 == 1 & presence1984 == 1 & presence1985 == 1
gen tag1986 = 1 if presence1980 == 1 & presence1981 == 1 & presence1982 == 1 & presence1983 == 1 & presence1984 == 1 & presence1985 == 1 & presence1986 == 1
gen tag1987 = 1 if presence1981 == 1 & presence1982 == 1 & presence1983 == 1 & presence1984 == 1 & presence1985 == 1 & presence1986 == 1 & presence1987 == 1
gen tag1988 = 1 if presence1982 == 1 & presence1983 == 1 & presence1984 == 1 & presence1985 == 1 & presence1986 == 1 & presence1987 == 1 & presence1988 == 1
gen tag1989 = 1 if presence1983 == 1 & presence1984 == 1 & presence1985 == 1 & presence1986 == 1 & presence1987 == 1 & presence1988 == 1 & presence1989 == 1
gen tag1990 = 1 if presence1984 == 1 & presence1985 == 1 & presence1986 == 1 & presence1987 == 1 & presence1988 == 1 & presence1989 == 1 & presence1990 == 1
gen tag1991 = 1 if presence1985 == 1 & presence1986 == 1 & presence1987 == 1 & presence1988 == 1 & presence1989 == 1 & presence1990 == 1 & presence1991 == 1
gen tag1992 = 1 if presence1986 == 1 & presence1987 == 1 & presence1988 == 1 & presence1989 == 1 & presence1990 == 1 & presence1991 == 1 & presence1992 == 1
gen tag1993 = 1 if presence1987 == 1 & presence1988 == 1 & presence1989 == 1 & presence1990 == 1 & presence1991 == 1 & presence1992 == 1 & presence1993 == 1
gen tag1994 = 1 if presence1988 == 1 & presence1989 == 1 & presence1990 == 1 & presence1991 == 1 & presence1992 == 1 & presence1993 == 1 & presence1994 == 1
gen tag1995 = 1 if presence1989 == 1 & presence1990 == 1 & presence1991 == 1 & presence1992 == 1 & presence1993 == 1 & presence1994 == 1 & presence1995 == 1
gen tag1996 = 1 if presence1990 == 1 & presence1991 == 1 & presence1992 == 1 & presence1993 == 1 & presence1994 == 1 & presence1995 == 1 & presence1996 == 1
gen tag1997 = 1 if presence1991 == 1 & presence1992 == 1 & presence1993 == 1 & presence1994 == 1 & presence1995 == 1 & presence1996 == 1 & presence1997 == 1
gen tag1999 = 1 if presence1993 == 1 & presence1994 == 1 & presence1995 == 1 & presence1996 == 1 & presence1997 == 1 & presence1999 == 1
gen tag2001 = 1 if presence1995 == 1 & presence1996 == 1 & presence1997 == 1 & presence1999 == 1 & presence2001 == 1
gen tag2003 = 1 if presence1997 == 1 & presence1999 == 1 & presence2001 == 1 & presence2003 == 1
gen tag2005 = 1 if presence1999 == 1 & presence2001 == 1 & presence2003 == 1 & presence2005 == 1
gen tag2007 = 1 if presence2001 == 1 & presence2003 == 1 & presence2005 == 1 & presence2007 == 1
gen tag2009 = 1 if presence2003 == 1 & presence2005 == 1 & presence2007 == 1 & presence2009 == 1
gen tag2011 = 1 if presence2005 == 1 & presence2007 == 1 & presence2009 == 1 & presence2011 == 1
gen tag2013 = 1 if presence2007 == 1 & presence2009 == 1 & presence2011 == 1 & presence2013 == 1
gen tag2015 = 1 if presence2009 == 1 & presence2011 == 1 & presence2013 == 1 & presence2015 == 1
gen tag2017 = 1 if presence2011 == 1 & presence2013 == 1 & presence2015 == 1 & presence2017 == 1
/* need to tag the five input years as only the current years are tagged */
reshape long presence tag, i(ID) j(year)
gen mark = tag
reshape wide presence tag mark, i(ID) j(year)
replace tag1978 = 1 if tag1984 == 1
replace tag1979 = 1 if tag1984 == 1
replace tag1980 = 1 if tag1984 == 1
replace tag1981 = 1 if tag1984 == 1
replace tag1982 = 1 if tag1984 == 1
replace tag1983 = 1 if tag1984 == 1

replace tag1979 = 1 if tag1985 == 1
replace tag1980 = 1 if tag1985 == 1
replace tag1981 = 1 if tag1985 == 1
replace tag1982 = 1 if tag1985 == 1
replace tag1983 = 1 if tag1985 == 1
replace tag1984 = 1 if tag1985 == 1

replace tag1980 = 1 if tag1986 == 1
replace tag1981 = 1 if tag1986 == 1
replace tag1982 = 1 if tag1986 == 1
replace tag1983 = 1 if tag1986 == 1
replace tag1984 = 1 if tag1986 == 1
replace tag1985 = 1 if tag1986 == 1

replace tag1981 = 1 if tag1987 == 1
replace tag1982 = 1 if tag1987 == 1
replace tag1983 = 1 if tag1987 == 1
replace tag1984 = 1 if tag1987 == 1
replace tag1985 = 1 if tag1987 == 1
replace tag1986 = 1 if tag1987 == 1

replace tag1982 = 1 if tag1988 == 1
replace tag1983 = 1 if tag1988 == 1
replace tag1984 = 1 if tag1988 == 1
replace tag1985 = 1 if tag1988 == 1
replace tag1986 = 1 if tag1988 == 1
replace tag1987 = 1 if tag1988 == 1

replace tag1983 = 1 if tag1989 == 1
replace tag1984 = 1 if tag1989 == 1
replace tag1985 = 1 if tag1989 == 1
replace tag1986 = 1 if tag1989 == 1
replace tag1987 = 1 if tag1989 == 1
replace tag1988 = 1 if tag1989 == 1

replace tag1984 = 1 if tag1990 == 1
replace tag1985 = 1 if tag1990 == 1
replace tag1986 = 1 if tag1990 == 1
replace tag1987 = 1 if tag1990 == 1
replace tag1988 = 1 if tag1990 == 1
replace tag1989 = 1 if tag1990 == 1

replace tag1985 = 1 if tag1991 == 1
replace tag1986 = 1 if tag1991 == 1
replace tag1987 = 1 if tag1991 == 1
replace tag1988 = 1 if tag1991 == 1
replace tag1989 = 1 if tag1991 == 1
replace tag1990 = 1 if tag1991 == 1

replace tag1986 = 1 if tag1992 == 1
replace tag1987 = 1 if tag1992 == 1
replace tag1988 = 1 if tag1992 == 1
replace tag1989 = 1 if tag1992 == 1
replace tag1990 = 1 if tag1992 == 1
replace tag1991 = 1 if tag1992 == 1

replace tag1987 = 1 if tag1993 == 1
replace tag1988 = 1 if tag1993 == 1
replace tag1989 = 1 if tag1993 == 1
replace tag1990 = 1 if tag1993 == 1
replace tag1991 = 1 if tag1993 == 1
replace tag1992 = 1 if tag1993 == 1

replace tag1988 = 1 if tag1994 == 1
replace tag1989 = 1 if tag1994 == 1
replace tag1990 = 1 if tag1994 == 1
replace tag1991 = 1 if tag1994 == 1
replace tag1992 = 1 if tag1994 == 1
replace tag1993 = 1 if tag1994 == 1

replace tag1989 = 1 if tag1995 == 1
replace tag1990 = 1 if tag1995 == 1
replace tag1991 = 1 if tag1995 == 1
replace tag1992 = 1 if tag1995 == 1
replace tag1993 = 1 if tag1995 == 1
replace tag1994 = 1 if tag1995 == 1

replace tag1990 = 1 if tag1996 == 1
replace tag1991 = 1 if tag1996 == 1
replace tag1992 = 1 if tag1996 == 1
replace tag1993 = 1 if tag1996 == 1
replace tag1994 = 1 if tag1996 == 1
replace tag1995 = 1 if tag1996 == 1

replace tag1991 = 1 if tag1997 == 1
replace tag1992 = 1 if tag1997 == 1
replace tag1993 = 1 if tag1997 == 1
replace tag1994 = 1 if tag1997 == 1
replace tag1995 = 1 if tag1997 == 1
replace tag1996 = 1 if tag1997 == 1

replace tag1993 = 1 if tag1999 == 1
replace tag1994 = 1 if tag1999 == 1
replace tag1995 = 1 if tag1999 == 1
replace tag1996 = 1 if tag1999 == 1
replace tag1997 = 1 if tag1999 == 1

replace tag1995 = 1 if tag2001 == 1
replace tag1996 = 1 if tag2001 == 1
replace tag1997 = 1 if tag2001 == 1
replace tag1999 = 1 if tag2001 == 1

replace tag1997 = 1 if tag2003 == 1
replace tag1999 = 1 if tag2003 == 1
replace tag2001 = 1 if tag2003 == 1

replace tag1999 = 1 if tag2005 == 1
replace tag2001 = 1 if tag2005 == 1
replace tag2003 = 1 if tag2005 == 1

replace tag2001 = 1 if tag2007 == 1
replace tag2003 = 1 if tag2007 == 1
replace tag2005 = 1 if tag2007 == 1

replace tag2003 = 1 if tag2009 == 1
replace tag2005 = 1 if tag2009 == 1
replace tag2007 = 1 if tag2009 == 1

replace tag2005 = 1 if tag2011 == 1
replace tag2007 = 1 if tag2011 == 1
replace tag2009 = 1 if tag2011 == 1

replace tag2007 = 1 if tag2013 == 1
replace tag2009 = 1 if tag2013 == 1
replace tag2011 = 1 if tag2013 == 1

replace tag2009 = 1 if tag2015 == 1
replace tag2011 = 1 if tag2015 == 1
replace tag2013 = 1 if tag2015 == 1

replace tag2011 = 1 if tag2017 == 1
replace tag2013 = 1 if tag2017 == 1
replace tag2015 = 1 if tag2017 == 1

reshape long presence tag mark, i(ID) j(year)
keep ID year tag mark
sort ID year
tempfile temp
save `temp'	
restore
sort ID year
merge 1:1 ID year using `temp', assert(2 3) nogen
keep if tag == 1
drop presence tag
replace mark = 0 if mark == .
saveold "../../data/PSID/individual_for_exp_personal_lagged_1.dta", replace version(12)

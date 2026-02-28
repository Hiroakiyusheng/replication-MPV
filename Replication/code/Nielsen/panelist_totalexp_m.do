clear
set more off
* cd "path/to/Replication/code/Nielsen"

forval i=2004/2013 {
	use "../../data/Nielsen/panelist_base", clear
	sort panel_year household_code
	keep if panel_year== `i'
	merge 1:m household_code using "../../raw/trips_`i'"
	drop if _merge==2
	drop _merge
	gen month = substr(purchase_date, 6, 2)
	destring month, replace
	gen qrt =1 if month<4
	replace qrt =2 if month>3 & month<7
	replace qrt =3 if month>6 & month<10
	replace qrt =4 if month>9
	bysort household_code month: gen tripcount=_N
	bysort household_code month: egen totalexp_trip=total(total_spent)
	merge 1:m trip_code_uc using "../../raw/purchases_`i'"
	drop if _merge==2
	drop _merge
	merge m:1 upc upc_ver_uc using "../../raw/products", keepusing( department_code)
	drop if _merge==2
	drop _merge
	gen spent = total_price_paid-coupon_value
	bysort household_code month: egen totalexp = total(spent)
	bysort household_code month: egen totalexp_food = total(spent) if department_code==1|department_code==2|department_code==3|department_code==4|department_code==5|department_code==6
	bysort household_code month: egen totalexp_nonfood = total(spent) if department_code==7
	bysort household_code month: egen totalexp_other = total(spent) if department_code==0 |department_code==9|department_code==8
	bysort household_code month: gen dup = _n
	keep if dup==1
	drop dup
	tempfile temp_`i'
	save "`temp_`i''" 
}
append using "`temp_2012'", force
append using "`temp_2011'", force
append using "`temp_2010'", force
append using "`temp_2009'", force
append using "`temp_2008'", force
append using "`temp_2007'", force
append using "`temp_2006'", force
append using "`temp_2005'", force
append using "`temp_2004'", force
sort household_code panel_year month
drop trip_code_uc purchase_date retailer_code store_code_uc store_zip3 total_spent
replace fips_county_descr=proper(fips_county_descr)
rename fips_state_descr state
rename fips_county_descr countyname
merge m:1 state countyname panel_year month using "../../data/Nielsen/County_Zhvi_AllHomes_m"
drop if _merge==2
drop _merge
merge m:1 panel_year month fips_state_code fips_county_code using "../../raw/Unemployment_county",  keepusing (value)
drop if _merge==2
drop _merge
gen yrmon = ym(panel_year, month)
format yrmon %tm
gen yrqrt = yq(panel_year, qrt)
format yrqrt %tq
compress
save "../../data/Nielsen/panelist_totalexp_m", replace

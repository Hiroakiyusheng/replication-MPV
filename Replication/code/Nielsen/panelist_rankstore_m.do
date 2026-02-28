clear
set more off
cd "./Replication/code/Nielsen"

forval i=2004/2013 {
	use "../../raw/panelist_base", clear
	sort panel_year household_code
	keep if panel_year== `i'
	merge 1:m household_code using "../../raw/trips_`i'"
	drop if _merge==2
	drop _merge
	gen month = substr(purchase_date, 6, 2)
	destring month, replace
	merge 1:m trip_code_uc using "../../raw/purchases_`i'"
	drop if _merge==2
	drop _merge
	drop kitchen_* tv_* household_internet_* member_* dup*
	gen disc = 0
	replace disc = 1 if deal_flag_uc!=0|coupon_value!=0
	drop upc upc_ver_uc quantity
	bysort household_code month: egen coupon = total(coupon_value) /*toal value of coupon used per household month*/
	bysort household_code month: egen totalprice = total(total_price_paid) /*total expenditure used per household month*/
	gen coupon_use = coupon/totalprice  /*amount of coupon use/total expenditure per household per month*/       /****************/
	bysort household_code month: gen upc = _N 
	bysort household_code month: egen sale = total(deal_flag_uc)
	gen onsale = sale/upc /*amount of sale items bought/total number of items bought per household per month*/  /****************/
	bysort household_code month: egen discount = total(disc)
	gen discounted = discount/upc /*amount of discount items bought/total number of items bought per household per month*/  /****************/
	bysort household_code month: gen dup = _n
	keep if dup==1
	drop dup deal total_price_paid coupon_value deal_flag_uc disc
	compress
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
merge m:m state countyname panel_year month using "../../data/Nielsen/County_Zhvi_AllHomes_m"
drop if _merge==2
drop _merge
merge m:1 panel_year month fips_state_code fips_county_code using "../../raw/Unemployment_county",  keepusing (value)
drop if _merge==2
drop _merge
gen date = ym(panel_year, month)
format date %tm
sort panel_year month
merge m:1 panel_year month using "../../raw/unemployment_raw_m"
drop if _merge ==2
drop _merge
gen yrmon = ym(panel_year, month)
format yrmon %tm
gen yrqrt = yq(panel_year, qrt)
format yrqrt %tq
sort household_code yrmon
compress
save "../../data/Nielsen/panelist_storerank_m",replace

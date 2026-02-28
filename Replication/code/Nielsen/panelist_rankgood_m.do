clear
set more off
cd "./Replication/code/Nielsen"

forval i=2004/2013 {
	use panelist_base, clear
	drop kitchen_* tv_* household_internet_* member_* dup*
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
	gen price = (total_price_paid-coupon_value)/quantity
	merge m:1 upc upc_ver_uc using "../../raw/products", keep (match)
	drop _merge
	gen unit_price = price/(multi*size1_amount)
	bysort dma_code product_module_code size1_units month upc upc_ver_uc: egen mean_unit_price = mean(unit_price)
	bysort dma_code product_module_code size1_units month: egen unitprice_rank=rank(mean_unit_price), track
	bysort dma_code product_module_code size1_units month: egen Rp_max= max(unitprice_rank)
	bysort dma_code product_module_code size1_units month: replace unitprice_rank=unitprice_rank/(Rp_max+1)
	drop upc upc_ver_uc quantity 
	gen storeb  = (brand_code_uc==536746)
	bysort household_code month: gen upc_tot = _N /*total number of items bought*/
	bysort household_code month: egen coupon = total(coupon_value) /*toal value of coupon used per household month*/
	bysort household_code month: egen totalprice = total(total_price_paid) /*total expenditure used per household month*/
	gen expend = totalprice-coupon  
	bysort household_code month: egen coupon_brand = total(coupon_value) if brand_code_uc==536746 /*toal value of coupon used per household month*/
	bysort household_code month: egen totalprice_brand = total(total_price_paid) if brand_code_uc==536746/*total expenditure used per household month*/
	gen expend_brand = totalprice_brand-coupon_brand
	replace expend_brand=0 if expend_brand==.
	gen storebrand_tr = expend_brand/expend /*value of store brand items bought/value of items bought per household per month*/  /****************/
	bysort household_code month: egen storebrand = total(storeb)
	gen storebrand_q = storebrand/upc_tot /*amount of store brand items bought/total number of items bought per household per month*/  /****************/
	replace storebrand_q = 0 if storebrand_q==.
	bysort household_code month: egen R_unitprice = mean(unitprice_rank)   /****************/
	bysort household_code month: gen dup = _n
	keep if dup==1
	drop dup total_price_paid coupon_value deal_flag_uc storeb storebrand unitprice_rank Rp_max coupon totalprice coupon_brand totalprice_brand
	sum R_unitprice,d
	sum storebrand_q,d
	sum storebrand_tr,d
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
save "../../data/Nielsen/panelist_goodrank_m",replace

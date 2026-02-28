clear
set more off
cd "./Replication/code/Nielsen"

insheet using "../../raw/County_Zhvi_AllHomes.csv", comma names clear
rename regionname countyname
reshape long homepr_all, i(countyname state metro statecodefips municipalcodefips) j(yr_mon)
bysort yr_mon state: egen homepr_state = mean(homepr_all) /* average housing price by state*/
bysort yr_mon: egen homepr_nation = mean(homepr_all) /*average national housing price*/
tostring yr_mon, replace
gen panel_year = substr(yr_mon,1,4)
gen month = substr(yr_mon, 5,2)
destring panel_year, replace
destring month, replace 
gen qrt =1 if month<4
replace qrt =2 if month>3 & month<7
replace qrt =3 if month>6 & month<10
replace qrt =4 if month>9
drop yr_mon
save "../../data/Nielsen/County_Zhvi_AllHomes_m", replace






** Generate Figure A.1: Earnings Around Displacement

use "../../data/PSID/psid_new_final_lag_LS.dta", clear  
xtset ID year
gen event_date=(EMPLOY_STATUS==3)

by ID: egen unemployed = total(event_date) if year >=1993

*unemployed F years ago
forval F = 7(-1)1 {
			by ID: gen F`F' = (event_date[_n-`F'] == 1)
		}

forval L = 0(1)5 {
			by ID: gen L`L' = (event_date[_n+`L'] == 1)
		}
		

order L5 L4 L3 L2 L1 L0 F1 F2 F3 F4 F5 F6 F7 
reghdfe income L5-F7 GENDER HEAD_MARITAL HD_RACE HEAD_EDU age, absorb(ID year) cluster(ID)

			capture drop coeffs
			capture drop lb
			capture drop ub
			qui gen coeffs = .
			qui gen lb = .
			qui gen ub = .
			cap drop displacement

			gen displacement = .
			forval L = 0(1)5 {
			replace displacement =-`L' if L`L'==1
			qui replace coeffs = _b[L`L']                    if displacement == -`L'
			qui replace lb     = _b[L`L'] -1.96*_se[L`L'] if displacement == -`L'
			qui replace ub     = _b[L`L'] +1.96*_se[L`L'] if displacement == -`L'	
			}
			
			forval F = 1(1)7 {
			replace displacement =`F' if F`F'==1
			qui replace coeffs = _b[F`F']                    if displacement == `F'
			qui replace lb     = _b[F`F'] -1.96*_se[F`F'] if displacement == `F'
			qui replace ub     = _b[F`F'] +1.96*_se[F`F'] if displacement == `F'
			}
			
			preserve 
			duplicates drop displacement, force
			sort displacement
			twoway rcap lb ub displacement if displacement>=-5, || ///
			scatter coeffs displacement if displacement>=-5, c(l) ///*title("Earning response to displacement", size(med)) ///
			xtitle("Years since displacement") ytitle("Estimation Coefficent") ///
			graphregion(color(white)) bgcolor(white) ///
			xlabel(-5(1)7,  angle(30)) xline(0) ///
			yline(0) name("Earning",replace) ///
			legend(off) 
			*note("No income control")
			graph export "../../Figures/figure_A1.pdf", replace
			restore

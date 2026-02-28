clear
set more off

cd "../../raw/CEX"

local i=80
local year = 1980 
	   
while `i' < 100 {		   
	   
	local YY 	= `year'-2000
   	local YY_p1 = `year'-1999
   
   	cd ./`year'
   
   	local j=1	
   	while `j' < 5 {

		u memb`i'`j'.dta,clear
		
		foreach v of varlist * { 
			capture qui rename `v' `= upper("`v'")'
		}
		
		gen intno=round(((NEWID/10)-int(NEWID/10))*10)
		replace NEWID=(NEWID-intno)/10
		keep NEWID intno CU_CODE SALARYX
		gen salary1=SALARYX if CU_CODE=="1"			// Ref pers
		gen salary2=SALARYX if CU_CODE=="2"			// Spouse
		collapse salary1 salary2,by(NEWID intno)
		compress
		sort NEWID intno
		save "../../../data/CEX/mq`i'`j'",replace
        local j=`j'+1
	}
    
    local i=`i'+1
    local year = `year'+1
	display `i'
	display `year'
	cd ..
}

clear

local i=100
local year = 2000 
	   
	   while `i' < 113 {		   
		   
 		   local YY 	= `year'-2000
		   local YY_p1 = `year'-1999
		   
		   cd ./`year'
		   
		   local j=1	
		   while `j' < 5 {
		   		   
				capture u memb0`YY'`j'.dta,clear
				capture u memb`YY'`j'.dta,clear
				capture u memb0`YY'0`j'.dta,clear
				capture u memb`YY'0`j'.dta,clear	
								
				foreach v of varlist * { 
					qui rename `v' `= upper("`v'")'
				}
					
				gen intno=round(((NEWID/10)-int(NEWID/10))*10)
				replace NEWID=(NEWID-intno)/10
				keep NEWID intno CU_CODE SALARYX*
				capture gen salary1=SALARYX if CU_CODE=="1"			// Ref pers
				capture gen salary2=SALARYX if CU_CODE=="2"			// Spouse
				capture gen salary1=SALARYX0 if CU_CODE=="1"			// Ref pers
				capture gen salary2=SALARYX0 if CU_CODE=="2"			// Spouse
				capture gen salary1=SALARYXM if CU_CODE=="1"			// Ref pers
				capture gen salary2=SALARYXM if CU_CODE=="2"			// Spouse
	
	
				collapse salary1 salary2,by(NEWID intno)
				compress
				sort NEWID intno
				save  "../../../data/CEX/mq`i'`j'",replace
	              
	     		local j=`j'+1
         }
         
	local i=`i'+1
	local year = `year'+1
	display `i'
	display `year'
	cd ..
}



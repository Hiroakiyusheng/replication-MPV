clear
set more off
cd "../../data/CEX"

local i=80
while `i' < 86 {
   local j=1	
   while `j' < 5 {
		u expq`i'`j'.dta,clear
		cap gen family=NEWID
		sort family intno
		save,replace
        local j=`j'+1
	}
	local i=`i'+1
}


local i=86
while `i' < 113 {
   local j=1	
   while `j' < 5 {
   		u expq`i'`j'.dta,clear
		cap gen family=NEWID+70000
		sort family intno
		save,replace
		local j=`j'+1
	}	
		local i=`i'+1
}

clear

local i=80
while `i' < 113 {
	local j=1	
	while `j' < 5 {
		append using expq`i'`j'.dta
		local j=`j'+1
	}
	local i=`i'+1
}

compress
saveold mtabdata,replace


local i=100
	while `i' < 113 {
		local j=1	
		while `j' < 5 {
			erase expq`i'`j'.dta
		local j=`j'+1
	}
	local i=`i'+1
}


clear



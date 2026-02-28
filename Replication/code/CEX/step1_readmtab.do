clear
set more off
* Starting from "./Replication/code/CEX"
cd "../../raw/CEX"

local i=80
local year = 1980

while `i' < 113 {
	
	display `year'
	
	if `i'<100 {	  
		local YY 	= `year'-1900
	}	
	if `i'>=100 {	  
		local YY 	= `year'-2000
	}
		   
	cd ./`year'
		   
	local j=1	 
	while `j' < 5 {
	
		display `j'

		capture u mtabq`YY'`j'.dta,clear		
		capture u mtabq0`YY'`j'.dta,clear
			
		foreach v of varlist * { 
			qui rename `v' `= upper("`v'")'
		}	
		
		capture destring ucc, replace
		capture destring NEWID, replace
		capture destring COST, replace
		capture gen intno=round(((NEWID/10)-int(NEWID/10))*10)
		capture replace NEWID=(NEWID-intno)/10
		capture gen ucc=real(UCC)
		
		#delimit;
			gen foodin   =COST if ucc==190904|ucc==790220|ucc==790230|ucc==790240;
			gen foodout  =COST if ucc>=190901 & ucc<=190903|ucc==790410|ucc==790430|ucc==800700;
			gen cons     =COST if ucc>=190901 & ucc<=190903|ucc==190904|
							ucc==200900|ucc>=210110 & ucc<=210902|ucc>=220111 & ucc<=220122|ucc>=220901 & ucc<=220902|
							ucc>=230111 & ucc<=230902|ucc>=250111 & ucc<=250904|
							ucc>=260111 & ucc<=260114|ucc>=260211 & ucc<=260214|ucc>=270000 & ucc<=270104|ucc>=270211 & ucc<=270214|
							ucc==270310|ucc>=270411 & ucc<=270414|ucc>=270901 & ucc<=270904|
							ucc==330511|ucc>=340210 & ucc<=340212|ucc>=340310 & ucc<=340420|ucc>=340510 & ucc<=340530|
							ucc>=340610 & ucc<=340905|ucc==340906|
							ucc>=340907 & ucc<=340908|ucc>=340911 & ucc<=340912|ucc==340914|ucc==340915|ucc==350110|
							ucc>=360110 & ucc<=420120|
							ucc>=440110 & ucc<=440140|ucc==440150|ucc==440210|ucc==440900|ucc>=470111 & ucc<=470212|
							ucc>=470220 & ucc<=490900|
							ucc>=520110 & ucc<=520907|ucc>=530110 & ucc<=530902|ucc>=590110 & ucc<=590212|
							ucc>=590220 & ucc<=590230|
							ucc==610900|ucc>=620110 & ucc<=620115|ucc>=620121 & ucc<=620320|ucc>=620330 & ucc<=620926|ucc==630110|
							ucc==630210|ucc>=650110 & ucc<=650900|
							ucc==790220|ucc==790230|ucc==790310|ucc==790320|ucc==790410|ucc==790420|ucc==790430|ucc==790600|
							ucc==800700|ucc==800710;
			gen homevalue=COST if 	ucc==800721;
			gen educ     =COST if	ucc>=660110 & ucc<=670902;
			gen health   =COST if	ucc==340910|ucc>=540000 & ucc<=580906;
			gen othexp   =COST if	ucc==002120|ucc>=220211 & ucc<=220322|ucc>=240111 & ucc<=240323|ucc>=280110 & ucc<=320904|ucc==340910|
							ucc>=430110 & ucc<=430130|ucc==450110|ucc==450210|ucc==450220|ucc==450310|ucc>=450313 & ucc<=450410|
							ucc>=450413 & ucc<=460110|ucc>=460901 & ucc<=460902|ucc==500110|ucc>=510110 & ucc<=510902|
							ucc>=540000 & ucc<=580906|ucc>=600110 & ucc<=600122|ucc==600132|ucc>=600141 & ucc<=600142|
							ucc>=600210 & ucc<=610320|ucc>=640130 & ucc<=640420|ucc>=660110 & ucc<=710110|
							ucc==790690|ucc==800111|ucc==800121|ucc>=800800 & ucc<=800861|
							ucc==880110|ucc==880210|ucc==880310|ucc==900002|ucc>=990920 & ucc<=990940;
			gen reasexp   =COST if	ucc>=240111 & ucc<=240323|ucc>=280110 & ucc<=320904|ucc==340910|
							ucc>=430110 & ucc<=430130|ucc==450310|ucc>=450313 & ucc<=450410|
							ucc==500110|ucc>=540000 & ucc<=580906|
							ucc>=600210 & ucc<=610320|ucc>=640130 & ucc<=640420|ucc>=660110 & ucc<=710110|
							ucc==790690|ucc>=800800 & ucc<=800861|
							ucc==900002|ucc>=990920 & ucc<=990940;
			gen nd_extra =COST if	ucc==500110|ucc==320903|ucc==610210|ucc>=680110 & ucc<=680902|ucc>=690113 & ucc<=690114; 
			gen durables =COST if   ucc>=280110 & ucc<=290440|ucc>=320110 & ucc<=320904|	/*home furniture*/
							ucc>=300111 & ucc<=300412|					/*white goods*/
							ucc>=310110 & ucc<=310342|					/*electronic goods*/
							ucc>=430110 & ucc<=430130|					/*jewelry*/
							ucc==450110|ucc==450210|ucc==450220|ucc==450310|
							ucc>=450313 & ucc<=450410|ucc>=450413 & ucc<=460110|
							ucc>=460901 & ucc<=460902|					/*vehicles*/
							ucc>=600110 & ucc<=600122|ucc==600132|
							ucc>=600141 & ucc<=600142|ucc>=600210 & ucc<=610320;	/*durable leisure goods*/	
			gen vehicle =COST if ucc==450110|ucc==450210|ucc==450220|ucc==450310| ucc>=450313 & ucc<=450410|ucc>=450413 & ucc<=460110|ucc>=460901 & ucc<=460902;	/*vehicles*/		
		#delimit cr
		collapse (sum) foodin foodout cons homevalue educ health othexp nd_extra reasexp durables vehicle,by(NEWID intno REF_MO REF_YR)
		keep NEWID intno REF_YR REF_MO cons foodin foodout homevalue educ health othexp nd_extra reasexp durables vehicle
		
		save "../../../data/CEX/expq`i'`j'",replace
		local j=`j'+1
	}
    local i=`i'+1
    local year = `year'+1
	cd ..
}

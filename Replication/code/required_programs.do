* required_programs.do 
* PURPOSE: installs required SSC Stata programs for Malmendier and Shen (2023)

* *****************************************************************************


foreach package in ftools reghdfe estout outreg2 xtabond2 _gwtmean {
	capture which `package'
	if _rc==111 ssc install `package'
}

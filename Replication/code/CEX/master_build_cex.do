* Master .do file that builds the CEX working dataset

clear
set more off
clear mata 
clear matrix 
set matsize 11000 
set maxvar 24000 
clear mata 

*cd to the following folder
*cd "./Replication/code/"

***************************************************
global cex_dofiles "./CEX"
cd $cex_dofiles
do step1_readmtab.do
do "../../code/$cex_dofiles/step2_readmemb.do"
do "../../code/$cex_dofiles/step3_readfmly.do"
do "../../code/$cex_dofiles/step4_create_bigmtab.do"
do "../../code/$cex_dofiles/step5_create_bigfmly.do"
do "../../code/$cex_dofiles/step6_create_CEX_1980_2012.do"


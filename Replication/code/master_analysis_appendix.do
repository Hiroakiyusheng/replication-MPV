* Master .do file that generates all the appendix tables and figures 

clear
set more off
clear mata 
clear matrix 
set matsize 11000 
set maxvar 24000 
clear mata 

* cd to the folder in which this code lives
*cd "./Replication/code/"

***************************************************
global psid_dofiles "./PSID"
cd $psid_dofiles

do Table_A1.do
do Table_A2.do
do Table_A3.do
do Table_A4.do
do Table_A5.do
do Table_A6.do
do Table_A7.do
do Table_A8.do
do Table_A9.do
do Table_A10.do
do Table_A11.do
do Table_A12.do
do Figure_A1.do

***************************************************
global cex_dofiles "../CEX"
cd "$cex_dofiles

do Table_A15_A16.do

***************************************************
global model_dofiles "../Model"
cd "$model_dofiles

do full_reg3_income.do

cd ..



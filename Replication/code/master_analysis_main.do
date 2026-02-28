* Master .do file that generates all the main tables and figures

clear
set more off
clear mata 
clear matrix 
set matsize 11000 
set maxvar 24000 
clear mata 

* cd to the folder in which this code lives
* cd "./Replication/code/"

***************************************************
global psid_dofiles "./PSID"
cd $psid_dofiles

do Table_1.do
do Table_2.do
do Table_4.do
do Table_5.do
do Figure_1_input.do

***************************************************
global msc_dofiles "../MSC"
cd "$msc_dofiles

do Table_3.do

***************************************************
global model_dofiles "../Model"
cd "$model_dofiles

do full_reg3.do

cd ..



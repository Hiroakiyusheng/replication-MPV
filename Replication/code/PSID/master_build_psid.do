* Master .do file that builds the raw PSID files and creates the working datasets

clear
set more off
clear mata 
clear matrix 
set matsize 11000 
set maxvar 24000 
clear mata 

cd "/Users/lsshen/Library/CloudStorage/Dropbox/Shared/Research/Working Projects/Ulrike Malmendier/Consumption Experience/Replication/code/"

***************************************************
global psid_dofiles "./PSID"
cd $psid_dofiles

do psid_clean.do
do prepare_exp_lagged.do
** Run gen_exp_lagged.R before proceeding **
do psid_clean2f_lagged.do
do merge_debt.do
do merge_other_consumption.do
do DATA_FINALIZING_LAG.do

***************************************************
cd "./Table_A4"
do prepare_exp_spouse_lagged.do
** Run gen_exp_lagged_spouse.R before proceeding **
do psid_clean2_spouse_lagged.do
do merge_debt_spouse.do
do merge_other_consumption_spouse.do
do DATA_FINALIZING_SPOUSES.do

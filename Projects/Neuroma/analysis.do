cls
clear all
set more off

cd "/Volumes/Encrypted/NSQIP/Projects"
pwd
do code_standard_variables "/Volumes/Encrypted/NSQIP/Data/Neuroma" "neuroma.dta"

// Excel file for results
local excel_file = "/Volumes/Encrypted/NSQIP/Projects/Neuroma/results.xlsx"
do initiate_excel "`excel_file'" "baseline" "Variable Observations Overall p"

egen tmr = anymatch(cpt othercpt1 othercpt2 othercpt3 othercpt4 othercpt5 othercpt6 othercpt7 othercpt8 othercpt9 othercpt10 concpt1 concpt2 concpt3 concpt4 concpt5 concpt6 concpt7 concpt8 concpt9 concpt10 reoporcpt1 reopor2cpt1), values(64787)
keep if tmr==1

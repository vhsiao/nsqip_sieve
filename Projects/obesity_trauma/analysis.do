clear all
set more off
import excel "/Volumes/Encrypted/NSQIP/Data/obesity_trauma/de_identified_ptx_selected.xlsx", sheet("stata") firstrow
 
local excel_file = "/Volumes/Encrypted/NSQIP/Projects/obesity_trauma/results.xlsx"
do initiate_excel "`excel_file'" "demographics" "Variable Obs. Overall <30 ≥30 p"
do initiate_excel "`excel_file'" "complications" "Variable Obs. Overall <30 ≥30 p"
do initiate_excel "`excel_file'" "outcomes" "Variable Obs. Overall <30 ≥30 p"
do initiate_excel "`excel_file'" "univariate_logit_regression" "Outcome OR p"
do initiate_excel "`excel_file'" "univariate_linear_regression" "Outcome Coeff. p"

do "./obesity_trauma/encode_variables"
do "./obesity_trauma/label_variables"

/* Analysis */
local baseline_i=2
local complication_i=2
local prediction_i=2

/* Variable Sets */
local n_demographics Agey BMI
local c_demographics sex_num race_num

local n_complications RBC1st24hrs HospLOS
local c_complications died SSI need_for_reoperation

local n_outcomes EDSBP ISS number_intraop_transfusion number_OR_visits
local c_outcomes gi_injury gu_injury vascular_injury diaphragm_injury spleen_injury liver_injury kidney_injury solid_organ_injury ///
	traumaticherniarepair cholecystectomy mesentericomentalappendagere dpl dpl_positive ex_lap died gi_resection gi_repair ///
	gi_repair_resection
local exlap_or_reasons reason_or_hi reason_or_peritonitis reason_or_evisceration reason_or_imaging_dpl reason_or_concerning_exam ex_lap_therapeutic
local cat_outcome_vars SSI gi_injury gu_injury vascular_injury diaphragm_injury spleen_injury ///
	liver_injury kidney_injury solid_organ_injury traumaticherniarepair cholecystectomy ///
	mesentericomentalappendagere dpl dpl_positive ex_lap died gi_resection gi_repair ///
	gi_repair_resection need_for_reoperation
local num_outcome_vars ISS EDSBP HospLOS number_intraop_transfusions number_OR_visits RBC1st24hrs

local len_n_demographics : word count `n_demographics'
local len_n_complications : word count `n_complications'
local len_n_outcomes : word count `n_outcomes'
local len_c_outcomes : word count `c_outcomes'

// T tests for continuous variables
// Linear regression on BMI
do put_all_in_excel "`excel_file'" "demographics" 2 1 "ttest" obese "`n_demographics'"
do put_all_in_excel "`excel_file'" "demographics" (2+`len_n_demographics') 1 "chi2" obese "`c_demographics'"
do put_all_in_excel "`excel_file'" "complications" 2 1 "ttest" obese "`n_complications'"
do put_all_in_excel "`excel_file'" "complications" (2+`len_n_complications') 1 "chi2" obese "`c_complications'"
do put_all_in_excel "`excel_file'" "outcomes" 2 1 "ttest" obese "`n_outcomes'"
do put_all_in_excel "`excel_file'" "outcomes" (2+`len_n_outcomes') 1 "chi2" obese "`c_outcomes'"
do put_all_in_excel "`excel_file'" "outcomes" (2+`len_n_outcomes'+`len_c_outcomes') 1 "chi2" obese "`exlap_or_reasons'" "dependent" "ex_lap"
do put_all_in_excel "`excel_file'" "univariate_linear_regression" 2 1 "linear" BMI "`num_outcome_vars'" "dependent"
do put_all_in_excel "`excel_file'" "univariate_logit_regression" 2 1 "logistic" BMI "`cat_outcome_vars'" "dependent

logistic gi_resection BMI Agey sex_num race_num

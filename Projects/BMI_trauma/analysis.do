clear all
set more off
import excel "/Volumes/Encrypted/NSQIP/Data/BMI_trauma/de_identified_ptx_selected.xlsx", sheet("stata") firstrow
 
local excel_file = "/Volumes/Encrypted/NSQIP/Projects/BMI_trauma/results.xlsx"
do initiate_excel "`excel_file'" "demographics" "Variable <30 ≥30 p"
do initiate_excel "`excel_file'" "complications" "Variable <30 ≥30 p"
do initiate_excel "`excel_file'" "outcomes" "Variable <30 ≥30 p" 

do encode_variables
do label_variables

/* Analysis */
local baseline_i=2
local complication_i=2
local prediction_i=2

/* Variable Sets */
local n_demographics Agey BMI
local c_demographics sex_num race_num

local n_complications RBC1st24hrs HospLOS
local c_complications died SSI need_for_reoperation

local c_outcomes ISS number_intraop_transfusion number_OR_visits reason_or_peritonitis reason_or_evisceration ///
	gi_injury gu_injury vascular_injury diaphragm_injury spleen_injury liver_injury kidney_injury solid_organ_injury ///
	traumaticherniarepair cholecystectomy mesentericomentalappendagere dpl dpl_positive ex_lap died gi_resection gi_repair ///
	gi_repair_resection reason_or_hi reason_or_imaging_dpl reason_or_concerning_exam ex_lap_therapeutic

local n_outcomes EDSBP 

// T tests for continuous variables
// Linear regression on BMI
//foreach var of varlist ISS EDSBP HospLOS number_intraop_transfusions number_OR_visits RBC1st24hrs {
foreach var of varlist n_demographics {
	disp "`var'"
	//ttest `var', by(obese)
	//regress `var' BMI
	do put_in_excel "`excel_file'" "baseline" `baseline_i' 1 "ttest" obese `var'
}

// Out of total patients who received ex lap
disp "Analysis of ex lap patients"
foreach var of varlist reason_or_peritonitis reason_or_evisceration reason_or_hi reason_or_imaging_dpl reason_or_concerning_exam ex_lap_therapeutic {
	//tab `var' obese if ex_lap==1, chi2 exact row column
	do put_in_excel "`excel_file'" "surgical_subspecialty" `subspecialty_i' 2 "tab" surgspec_e operation
}

foreach var of varlist sex_num race_num {
	disp "`var'"
	tab `var' obese, chi2 exact row column
}

foreach var of varlist SSI gi_injury gu_injury vascular_injury diaphragm_injury spleen_injury liver_injury kidney_injury solid_organ_injury traumaticherniarepair cholecystectomy mesentericomentalappendagere dpl dpl_positive ex_lap died gi_resection gi_repair gi_repair_resection need_for_reoperation {
	disp "`var'"
	tab `var' obese, chi2 exact row column
	logit `var' BMI, or
}

// T tests for continuous variables
// Linear regression on BMI
foreach var of varlist ISS EDSBP HospLOS number_intraop_transfusions number_OR_visits RBC1st24hrs {
	disp "`var'"
	ttest `var', by(obese)
	regress `var' BMI
}

// Check for univariate things that predict rate of GI resection
foreach var of varlist Agey sex_num race_num BMI {
	disp "`var'"
	logistic gi_resection `var'
}


/*
foreach var of varlist `nbaseline_characteristics' {
	disp "Variable: `var'"
	do put_in_excel "`excel_file'" "baseline" `baseline_i' 1 "ttest" transgender_type `var' 
	local baseline_i = `baseline_i' + 1
}

foreach var of varlist `cbaseline_characteristics' {
	disp "Variable: `var'"
	do put_in_excel "`excel_file'" "baseline" `baseline_i' 1 "chi2" transgender_type `var' 
	local summary_i = `summary_i' + 1
	local baseline_i = `baseline_i' + 1
}

foreach var of varlist `predictors' {
	do put_in_excel "`excel_file'" "prediction" `prediction_i' 1 "logistic" any_complication_nonlifethreaten `var'
	local prediction_i = `prediction_i' + 1
}
/*

// do put_in_excel "`excel_file'" "surgical_subspecialty" `subspecialty_i' 2 "tab" surgspec_e operation

logistic gi_resection BMI Agey sex_num race_num

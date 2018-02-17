cls
clear all
set more off

cd "/Volumes/Encrypted/NSQIP/Projects"
pwd
do code_standard_variables "/Volumes/Encrypted/NSQIP/Data/TendonRepair" "tendonrepair.dta"

// Excel file for results
local excel_file = "/Volumes/Encrypted/NSQIP/Projects/TendonRepair/results.xlsx"
do initiate_excel "`excel_file'" "baseline" "Variable Observations Overall Extensor Flexor p"
do initiate_excel "`excel_file'" "complication" "Variable Observations Overall Extensor Flexor p"
do initiate_excel "`excel_file'" "prediction" "Variable OR_Any_Complication p"

/*
1.	Flexor tendon repair or advancement, single, not in no mans land; primary or secondary without free graft, each tendon (26350)
2.	Flexor tendon repair or advancement, single, not in no mans land; secondary with free graft (includes obtaining graft), each (26352)
3.	Flexor tendon repair or advancement, single, in no mans land; primary, each tendon (26356)
4.	Flexor tendon repair or advancement, single, in no mans land; secondary, each tendon (26357)
5.	Flexor tendon repair or advancement, single, in no mans land secondary with free graft (includes obtaining graft), each (26358)
6.	Profundus tendon repair or advancement, with intact sublimis; primary (26370)
7.	Profundus tendon repair or advancement, with intact sublimis; secondary with free graft (includes obtaining graft) (26372)
8.	Profundus tendon repair or advancement, with intact sublimis; secondary without free graft (26373)
9.	Flexor tendon excision, implantation of plastic tube or rod for delayed tendon graft, hand or finger (26390)
10.	Removal of tube or rod and insertion of flexor tendon graft (includes obtaining graft), hand or finger (26392)

26350 26352 26356 26357 26358 26370 26372 26373 26390 26392
*/

egen flexor_cpt = anymatch(cpt othercpt1 othercpt2 othercpt3 othercpt4 othercpt5 othercpt6 othercpt7 othercpt8 othercpt9 othercpt10 concpt1 concpt2 concpt3 concpt4 concpt5 concpt6 concpt7 concpt8 concpt9 concpt10 reoporcpt1 reopor2cpt1), values(26350 26352 26356 26357 26358 26370 26372 26373 26390 26392)
generate flexor = 0
replace flexor = 1 if flexor_cpt > 0

local nbaseline_characteristics age BMI optime
local cbaseline_characteristics sex_e race_american_indian_e race_asian_e race_black_e race_nh_pi_e race_white_e ///
	 smoke_e fnstatus2_e diabetes2_e prsepsis2_e ///
	 hxchf_e hxcopd_e discancr_e dialysis_e hypermed_e ///
	 hx_tia_cva hx_cardiac_ischemia hx_pvd_rest_pain ///
	 plastics_e ortho_e gensurg_e gyn_e urology_e ent_e resident_involvement_e ///
	 
local complications new_sssi_e new_dssi_e new_ossi_e dehis_e ///
	oupneumo_e othdvt_e urninfec_e renafail_e cnscva_e neurodef_e pulembol_e othbleed_e ///
	neurodef_e rbc_need_e sepsis_septic_shock mi_cardiac_arrest_cva failwean_reintub death_e reoperation1_e unplannedreadmission1_e

local comorbidities smoke_e diabetes2_e hxchf_e hxcopd_e discancr_e dialysis_e hypermed_e hx_tia_cva hx_cardiac_ischemia hx_pvd_rest_pain

local summary_i=2
local baseline_i=2
local complication_i=2
local prediction_i=2

foreach var of varlist `nbaseline_characteristics' {
	disp "Variable: `var'"
	do put_in_excel "`excel_file'" "baseline" `baseline_i' "ttest" flexor `var' 
	local baseline_i = `baseline_i' + 1
}

foreach var of varlist `cbaseline_characteristics' {
	disp "Variable: `var'"
	do put_in_excel "`excel_file'" "baseline" `baseline_i' "chi2" flexor `var' 
	local summary_i = `summary_i' + 1
	local baseline_i = `baseline_i' + 1
}

foreach var of varlist `complications' {
	disp "Variable: `independent_var'"
	do put_in_excel "`excel_file'" "complication" `complication_i' "chi2" flexor `var'
	local complication_i = `complication_i' + 1
}

local predictors age BMI optime race2_e ///
	smoke_e fnstatus2_e highasa diabetes2_e hxchf_e hxcopd_e discancr_e dialysis_e hxpvd_e hypermed_e any_comorbidities ///
	race_american_indian_e race_asian_e race_black_e race_nh_pi_e race_white_e ///
	plastics_e ortho_e gensurg_e gyn_e urology_e ent_e resident_involvement_e any_comorbidities ///
	prsodm prbun prcreat pralbum prbili prsgot pralkph prwbc prhct prplate prptt prinr prpt ///
	
local i=2
foreach var of varlist `predictors' {
	do put_in_excel "`excel_file'" "prediction" `prediction_i' "logistic" any_complication `var'
	local prediction_i = `prediction_i' + 1
}

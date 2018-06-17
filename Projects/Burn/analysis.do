cls
clear all
set more off

cd "/Volumes/Encrypted/NSQIP/Projects"
pwd
do code_standard_variables "/Volumes/Encrypted/NSQIP/Data/Burn" "burn.dta"

// Excel file for results
local excel_file = "/Volumes/Encrypted/NSQIP/Projects/Burn/results.xlsx"
do initiate_excel "`excel_file'" "baseline" "Variable Observations Overall autograft_stsg_ftsg_only skin_substitute_only p"
do initiate_excel "`excel_file'" "complication" "Variable Observations Overall autograft_stsg_ftsg_only skin_substitute_only p"
do initiate_excel "`excel_file'" "prediction" "Variable OR_Any_Complication p"

/*
Skin Substitutes
Total surface area <100 sq cm:

Surface Area         |Trunk, arms, legs    | Face, scalp, mouth, neck, | All non-integumentary anatomic
                     |(incl. wrist, ankle) | genitalia, hands/feet     | sites
----------------------------------------------------------------------------------
First 25 sq cm       | 15271               | 15275                     | +15777 
Each addt'l 25 sq cm | +15272              | +15276                    | +15777

Total surface area ≥100 sq cm:

Surface Area         |Trunk, arms, legs    | Face, scalp, mouth, neck, | All non-integumentary anatomic
                     |(incl. wrist, ankle) | genitalia, hands/feet     | sites
----------------------------------------------------------------------------------
First 25 sq cm       | 15273               | 15277                     | +15777 
Each addt'l 25 sq cm | +15274              | +152787                   | +15777

(15100 15120 15101 15121)
15100: Split-thickness autograft, trunk, arms, legs; first 100 sq cm or less, or 1% of body area of infants and children
15120: Split-thickness autograft, face, scalp, eyelids, mouth, neck, ears, orbits, genitalia, hands, feet, and/or multiple digits; first 100 sq cm or less, or 1% of body area of infants and children
15101: Split-thickness autograft, trunk, arms, legs; each additional 100 sq cm, or each 1% of body area of infants and children; first 100 sq cm or less, or 1% of body area of infants and children
15121: Split-thickness autograft, face, scalp, eyelids, mouth, neck, ears, orbits, genitalia, hands, feet, and/or multiple digits; first 100 sq cm or less, or 1% of body area of infants and children

(15200 15201 15220 15221 15240 15241 15260 15261)
15200:  skin full graft trunk
15201:  skin full graft trunk add-on 
15220: Full thickness graft, free, including direct closure of donor site, scalp, arms, and/or legs; 20 sq cm or less
15221: Full thickness graft, free, including direct closure of donor site, scalp, arms, and/or legs; each additional 20 sq cm
15240: Full thickness graft, free, including direct closure of donor site, forehead, cheeks, chin, mouth, neck, axillae, genitalia, hands, and/or feet; 20 sq cm or less
15241: Full thickness graft, free, including direct closure of donor site, forehead, cheeks, chin, mouth, neck, axillae, genitalia, hands, and/or feet; each additional 20 sq cm
15260: Full thickness graft, free, including direct closure of donor site, nose, ears, eyelids, and /or lips; 20 sq cm or less
15261: Full thickness graft, free, including direct closure of donor site, nose, ears, eyelids, and /or lips; each additional 20 sq cm (List separately in addition to code for primary procedure)

Related:
15151: cltr skin agrft t/a/l addl 1 cm-75 cm 
11042: debridement subcutaneous tissue 20 sq cm/< 
*/
generate skin_substitute = 0
generate autograft = 0

egen skin_substitute_cpt = anymatch(cpt othercpt1 othercpt2 othercpt3 othercpt4 othercpt5 othercpt6 othercpt7 othercpt8 othercpt9 othercpt10 concpt1 concpt2 concpt3 concpt4 concpt5 concpt6 concpt7 concpt8 concpt9 concpt10 reoporcpt1 reopor2cpt1), values(15271 15272 15273 15274 15275 15276 15277 15278 15777)
egen autograft_cpt = anymatch(cpt othercpt1 othercpt2 othercpt3 othercpt4 othercpt5 othercpt6 othercpt7 othercpt8 othercpt9 othercpt10 concpt1 concpt2 concpt3 concpt4 concpt5 concpt6 concpt7 concpt8 concpt9 concpt10 reoporcpt1 reopor2cpt1), values(15100 15120 15101 15121 15200 15201 15200 15201 15220 15221 15240 15241 15260 15261)

replace skin_substitute = 1 if skin_substitute_cpt > 0
replace autograft = 1 if autograft_cpt > 0

drop if autograft==0 & skin_substitute==0
count if autograft==1 & skin_substitute==1
drop if autograft==1 & skin_substitute==1

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
local complications `complications' any_complication

/* FTM vs. MTF */
local summary_i=2
local baseline_i=2
local complication_i=2
local prediction_i=2

foreach var of varlist `nbaseline_characteristics' {
	disp "Variable: `var'"
	do put_in_excel "`excel_file'" "baseline" `baseline_i' "ttest" skin_substitute `var' 
	local baseline_i = `baseline_i' + 1
}

foreach var of varlist `cbaseline_characteristics' {
	disp "Variable: `var'"
	do put_in_excel "`excel_file'" "baseline" `baseline_i' "chi2" skin_substitute `var' 
	local summary_i = `summary_i' + 1
	local baseline_i = `baseline_i' + 1
}

foreach var of varlist `complications' {
	disp "Variable: `independent_var'"
	do put_in_excel "`excel_file'" "complication" `complication_i' "chi2" skin_substitute `var'
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

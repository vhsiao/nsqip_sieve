cls
clear all
set more off

cd "/Volumes/Encrypted/NSQIP/Projects"
pwd
do code_standard_variables "/Volumes/Encrypted/NSQIP/Data/Transgender" "transgender.dta"

// Excel file for results
local excel_file = "/Volumes/Encrypted/NSQIP/Projects/Transgender/results.xlsx"
do initiate_excel "`excel_file'" "baseline" "Variable Observations Overall FTM MTF p"
do initiate_excel "`excel_file'" "complication" "Variable Observations Overall FTM MTF p"
do initiate_excel "`excel_file'" "prediction" "Variable OR_Any_Complication p"
do initiate_excel "`excel_file'" "operation class" "Complication FTM_top FTM_hysterectomy FTM_bottom MTF_top MTF_bottom Head_Neck"
do initiate_excel "`excel_file'" "surgical_subspecialty" " Subspecialty_vs_operation"
do initiate_excel "`excel_file'" "surgical_subspecialty_2" "Subspecialty_vs_operation_Class"

/* Create Variable for MTF vs FTM top surgery patients and encode */
/* Infer FTM vs. MTF */

local ftm_keywords `" "mastectomy" "reduction mammaplasty" "intersex surg female male" "hysterect" "vag hyst" "vaginectomy" "testicular prosth" "scrotoplasty" "tah" "unlisted laparoscopy procedure uterus" "vulvectomy" "breast reconstruction""'
local mtf_keywords `" "mammaplasty augmentation" "intersex surg male female" "orchiectomy" "vaginoplasty" "urethroplasty rcnstj female" "brst prosth" "tiss expander" "artificial vagina" "tracheoplasty" "clitoroplasty" "amputation penis" "unlisted procedure larynx" "unlisted procedure trachea bronchi" "setback ant frontal" "reconstruction orbit" "reduction forehead contouring" "unlisted craniofacial""'
local top_surgery_keywords `" "mastectomy" "mammaplasty" "brst prosth" "brst rcnstj" "breast reconstruction" "tiss expander" "brst prsth" "tiss expander""'

/* Intersex surg CPT codes 
55970 intersex surg male female
55980 intersex surg female male
*/
generate operation = 0
generate transgender_type = 0
generate top_surgery = 0
label define transgender_type 0 "unknown", modify
label define transgender_type 1 "ftm", modify
label define transgender_type 2 "mtf", modify

local operations "ftm_top hysterectomy vaginectomy_vulvectomy scrotoplasty ftm_genital mtf_top orchiectomy vaginoplasty clitoroplasty urethroplasty penectomy mtf_genital throat facial"
local cptx_fields prncptx otherproc1 otherproc2 otherproc3 otherproc4 otherproc5 otherproc6 otherproc7 otherproc8 otherproc9 otherproc10 concurr1 concurr2 concurr3 concurr4 concurr5 concurr6 concurr7 concurr8 concurr9 concurr10
local cpt_fields cpt othercpt1 othercpt2 othercpt3 othercpt4 othercpt5 othercpt6 othercpt7 othercpt8 othercpt9 othercpt10 concpt1 concpt2 concpt3 concpt4 concpt5 concpt6 concpt7 concpt8 concpt9 concpt10

foreach operation of local operations {
	generate `operation'_e = 0
}

foreach cptx of varlist `cptx_fields' {	
	di "`cptx'"
	quietly {
		foreach kwd of local ftm_keywords {
			replace transgender_type = 1 if strpos(`cptx', "`kwd'") & transgender_type==0
		}
		foreach kwd of local mtf_keywords {
			replace transgender_type = 2 if strpos(`cptx', "`kwd'") & transgender_type==0
		}
		foreach kwd of local top_surgery_keywords {
			replace top_surgery = 1 if strpos(`cptx', "`kwd'") & top_surgery==0
		}
		
		replace hysterectomy_e = 1 if strpos(`cptx', "hysterect") | strpos(`cptx', "vag hyst") | strpos(`cptx', "tah") | strpos(`cptx', "uterus")
		replace vaginectomy_vulvectomy_e = 1 if strpos(`cptx', "vaginectomy") | strpos(`cptx', "vulvectomy")
		replace scrotoplasty_e = 1 if strpos(`cptx', "scrotoplasty") | strpos(`cptx', "testicular prosth")
		replace orchiectomy_e = 1 if strpos(`cptx', "orchiectomy")
		replace vaginoplasty_e = 1 if strpos(`cptx', "vaginoplasty") | strpos(`cptx', "artificial vagina")
		replace clitoroplasty_e = 1 if strpos(`cptx', "clitoroplasty")
		replace penectomy_e = 1 if strpos(`cptx', "amputation penis")
		replace throat_e = 1 if strpos(`cptx', "tracheoplasty") | strpos(`cptx', "larynx")
		replace facial_e = 1 if strpos(`cptx', "setback ant frontal") | strpos(`cptx', "reconstruction orbit") | strpos(`cptx', "forehead") | strpos(`cptx', "craniofacial") | strpos(`cptx', "trachea")
	}
}

replace ftm_top_e = 1 if top_surgery==1 & transgender_type==1
replace mtf_top_e = 1 if top_surgery==1 & transgender_type==2

foreach cpt_field of varlist `cpt_fields' {
	quietly {
		replace ftm_genital_e = 1 if `cpt_field'==55980
		replace mtf_genital_e = 1 if `cpt_field'==55970
		replace urethroplasty_e = 1 if `cpt_field'==53430 | `cpt_field'==53410
	}
}

replace operation = 1 if ftm_top_e==1
replace operation = 2 if hysterectomy_e==1
replace operation = 3 if vaginectomy_vulvectomy_e==1
replace operation = 4 if scrotoplasty_e==1
replace operation = 5 if ftm_genital_e==1
replace operation = 6 if mtf_top_e==1
replace operation = 7 if orchiectomy_e==1
replace operation = 8 if vaginoplasty_e==1
replace operation = 9 if clitoroplasty_e==1
replace operation = 10 if urethroplasty_e==1
replace operation = 11 if penectomy_e==1
replace operation = 12 if mtf_genital_e==1
replace operation = 13 if throat_e==1
replace operation = 14 if facial_e==1

label define operation 0 "Unknown" 1 "FTM Top Surgery" 2 "Hysterectomy" 3 "Vaginectomy/Vulvectomy" 4 "Scrotoplasty/Testicular Prostheses" 5 "Genital Intersex Surg Female Male" 6 "MTF Top Surgery" 7 "Orchiectomy" 8 "Vaginoplasty" 9 "Clitoroplasty" 10 "Urethroplasty" 11 "Penectomy" 12 "Genital Intersex Surg Male Female" 13 "Laryngeal/Tracheoplasty" 14 "Facial"

/* Exclusion Criteria */
// Revision surgery, secondary procedrue, complication not included: ""revision" "excision tracheal stenosis" "closure ureterocutaneous fistula" "exc breast les preop plmt rad marker" "clsr urethrostomy""
// Unknown CPT: "nipple/areola reconstruction", "musc myocutaneous/faciocutaneous" "unlisted procedure breast" "adjnt tis trnsfr" "tissue grafts other"
/*
local exclusion_criteria `""revision" "excision tracheal stenosis" "closure ureterocutaneous fistula" "exc breast les preop plmt rad marker" "nipple/areola reconstruction" "musc myocutaneous" "unlisted procedure breast" "mastopexy" "clsr urethrostomy" "adjnt tis trnsfr" "panniculectomy" "cystourethroscopy" "perineoplasty" "torsion tstis" "rmvl prosthetic vaginal" "urethromeatoplasty w/mucosal advancement" "tissue grafts other""'
foreach exclusion of local exclusion_criteria {
	drop if strpos(prncptx, "`exclusion'")
}
*/
drop if strpos(prncptx, "revision") | operation==0 | transgender_type==0

generate operation_class = 0
replace operation_class = 1 if operation==1
replace operation_class = 2 if operation==2
replace operation_class = 3 if operation>=3 & operation<=5
replace operation_class = 4 if operation==6
replace operation_class = 5 if operation>=7 & operation <=12
replace operation_class = 6 if operation>12

label define operation_class 0 "Unknown" 1 "FTM Top" 2 "FTM Internal" 3 "FTM Bottom" 4 "MTF Top" 5 "MTF Bottom" 6 "Head & Neck" 7 "Multi-Operation" 8 "Multi-Site"

generate ftm_internal_e = (operation_class==2)
generate ftm_bottom_e = (operation_class==3)
generate mtf_bottom_e = (operation_class==5)
generate head_neck_e = (operation_class==6)
generate mtf_surgery = 0
replace mtf_surgery=1 if transgender_type==2

egen multioperation = anycount(ftm_top_e hysterectomy_e vaginectomy_vulvectomy_e scrotoplasty_e ftm_genital_e mtf_top_e orchiectomy_e vaginoplasty_e clitoroplasty_e urethroplasty_e penectomy_e mtf_genital_e throat_e facial_e), values(1)
egen multisite = anycount(ftm_top_e ftm_internal_e ftm_bottom_e mtf_top_e mtf_bottom_e head_neck_e), values(1)
replace operation_class = 7 if multioperation>1
generate multisite_e = (multisite>1)
generate multioperation_e = (operation_class==7)

/* Now let's look at the subgroup of patients who had surgery at two different sites at once */

local nbaseline_characteristics age BMI optime ///
	 prsodm prbun prcreat pralbum prbili prsgot pralkph prwbc prhct prplate prptt prinr
local cbaseline_characteristics sex_e race_american_indian_e race_asian_e race_black_e race_nh_pi_e race_white_e ///
	 smoke_e fnstatus2_e diabetes2_e prsepsis2_e ///
	 hxchf_e hxcopd_e discancr_e dialysis_e hypermed_e  any_comorbidities ///
	 hx_tia_cva hx_cardiac_ischemia hx_pvd_rest_pain ///
	 plastics_e ortho_e gensurg_e gyn_e urology_e ent_e resident_involvement_e ///
	 top_surgery mtf_surgery top_surgery ftm_top_e ftm_internal_e ftm_bottom_e mtf_top_e mtf_bottom_e head_neck_e multioperation_e ///
	 
local complications new_sssi_e new_dssi_e new_ossi_e dehis_e ///
	oupneumo_e othdvt_e urninfec_e renafail_e cnscva_e neurodef_e pulembol_e othbleed_e ///
	neurodef_e rbc_need_e sepsis_septic_shock mi_cardiac_arrest_cva failwean_reintub death_e reoperation1_e
	
local predictors age BMI optime race2_e ///
	smoke_e fnstatus2_e highasa diabetes2_e hxchf_e hxcopd_e discancr_e dialysis_e hxpvd_e hypermed_e any_comorbidities ///
	race_american_indian_e race_asian_e race_black_e race_nh_pi_e race_white_e ///
	plastics_e ortho_e gensurg_e gyn_e urology_e ent_e resident_involvement_e ///
	top_surgery mtf_surgery ftm_top_e ftm_internal_e ftm_bottom_e mtf_top_e mtf_bottom_e head_neck_e multioperation_e ///
	prsodm prbun prcreat pralbum prbili prsgot pralkph prwbc prhct prplate prptt prinr ///

local comorbidities smoke_e diabetes2_e hxchf_e hxcopd_e discancr_e dialysis_e hypermed_e hx_tia_cva hx_cardiac_ischemia hx_pvd_rest_pain

local complications `complications' any_complication

/* Variable Labels */
label variable transgender_type "MTF/FTM"
label variable top_surgery "Top Surgery"
label variable operation "Operation"
label variable operation_class "Operation Class"
label variable ftm_top_e "FTM Top Surgery"
label variable ftm_internal_e "Hysterectomy/Oophorectomy"
label variable ftm_bottom_e "Vaginectomy/Vulvectomy"
label variable mtf_top_e "MTF Top Surgery"
label variable mtf_bottom_e "MTF Bottom Surgery"
label variable multioperation_e "Multi-Operation"
label variable head_neck_e "Head/Neck Surgery"
label variable mtf_surgery "MTF"

/* FTM vs. MTF */
local summary_i=2
local baseline_i=2
local complication_i=2
local prediction_i=2
local subspecialty_i=2
local subspecialty_i_2=2

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

foreach var of varlist `complications' {
	disp "Variable: `independent_var'"
	do put_in_excel "`excel_file'" "complication" `complication_i' 1 "chi2" transgender_type `var'
	local complication_i = `complication_i' + 1
}

putexcel set "`excel_file'", sheet("operation class") modify
local operation_class_row = 2
/* Complications (row) by operation Class (column) */
foreach dependent_var of varlist `complications' {
	putexcel A`operation_class_row'=("`:var label `dependent_var''")
	local operation_class_row = `operation_class_row' + 1
}
forvalues i=1/6 {
	disp "Variable: `independent_var'"
	
	local operation_class_col = 65 + `i'
	local col = "`=char(`operation_class_col')'"
	local overall_freq_val = 0
	
	local operation_class_row = 2
	local j = 1
	foreach dependent_var of varlist `complications' {
		di "Complication: `dependent_var'"
		tab operation_class `dependent_var' if operation_class<., row column matcell(freq)
		matlist(freq)
		return list
		local freq_val_`j' = freq[`i', 2]
		local percent_val_`j' = `freq_val_`j'' / (`freq_val_`j'' + freq[`i', 1]) * 100
		local percent_val_`j' : display %03.2f `percent_val_`j''
		putexcel `col'`operation_class_row'=("`freq_val_`j'' (`percent_val_`j''%)")
		local j = `j' + 1
		local operation_class_row = `operation_class_row' + 1
	}
}

do put_in_excel "`excel_file'" "surgical_subspecialty" `subspecialty_i' 2 "tab" surgspec_e operation
do put_in_excel "`excel_file'" "surgical_subspecialty_2" `subspecialty_i_2' 2 "tab" surgspec_e operation_class 
	
local i=2
foreach var of varlist `predictors' {
	do put_in_excel "`excel_file'" "prediction" `prediction_i' 1 "logistic" any_complication `var'
	local prediction_i = `prediction_i' + 1
}

/* Does the difference in complication rates persist when possible cofounders are 
included all in the same model?*/

/* To limit variables in model, only adding if these were predictors in the univariate regression */
//logistic any_complication optime top_surgery ftm_top_e mtf_bottom_e multioperation prhct prptt
/* To increase power, preop labs were omitted because of relatively fewer observations; put in a  different analysis*/
//logistic any_complication age BMI race_black_e race_white_e hypermed_e any_comorbidities gensurg_e gyn_e ent_e optime top_surgery ftm_top_e mtf_top_e mtf_bottom multioperation_e
//logistic any_complication age BMI optime race_black_e race_white_e diabetes2_e hypermed_e any_comorbidities mtf_surgery top_surgery multioperation_e
logistic any_complication optime mtf_top_e ftm_top_e mtf_bottom_e multioperation

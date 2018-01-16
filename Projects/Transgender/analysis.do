cls
clear all
set more off

cd "/Volumes/Encrypted/NSQIP/Projects"
pwd
do code_standard_variables "/Volumes/Encrypted/NSQIP/Data/Transgender" "transgender.dta"

// Revision surgery, secondary procedrue, complication not included: ""revision" "excision tracheal stenosis" "closure ureterocutaneous fistula" "exc breast les preop plmt rad marker" "clsr urethrostomy""
// Unknown CPT: "nipple/areola reconstruction", "musc myocutaneous/faciocutaneous" "unlisted procedure breast" "adjnt tis trnsfr" "tissue grafts other"
local exclusion_criteria `""revision" "excision tracheal stenosis" "closure ureterocutaneous fistula" "exc breast les preop plmt rad marker" "nipple/areola reconstruction" "musc myocutaneous" "unlisted procedure breast" "mastopexy" "clsr urethrostomy" "adjnt tis trnsfr" "panniculectomy" "cystourethroscopy" "perineoplasty" "torsion tstis" "rmvl prosthetic vaginal" "urethromeatoplasty w/mucosal advancement" "tissue grafts other""'
foreach exclusion of local exclusion_criteria {
	drop if strpos(prncptx, "`exclusion'")
}

/* Create Variable for MTF vs FTM top surgery patients and encode */
/* Infer FTM vs. MTF */


generate transgender_type = .
generate top_surgery = 0
local ftm_keywords `" "mastectomy" "reduction mammaplasty" "intersex surg female male" "hysterect" "vag hyst" "vaginectomy" "testicular prosth" "scrotoplasty" "tah" "unlisted laparoscopy procedure uterus" "vulvectomy" "breast reconstruction""'
local mtf_keywords `" "mammaplasty augmentation" "intersex surg male female" "orchiectomy" "vaginoplasty" "urethroplasty rcnstj female" "brst prosth" "tiss expander" "artificial vagina" "tracheoplasty" "clitoroplasty" "amputation penis" "unlisted procedure larynx" "unlisted procedure trachea bronchi" "setback ant frontal" "reconstruction orbit" "reduction forehead contouring" "unlisted craniofacial""'
local top_surgery_keywords `" "mastectomy" "mammaplasty" "brst prosth" "brst rcnstj" "breast reconstruction" "tiss expander" "brst prsth" "tiss expander""'
foreach kwd of local ftm_keywords {
	replace transgender_type = 1 if strpos(prncptx, "`kwd'")
}
foreach kwd of local mtf_keywords {
	replace transgender_type = 2 if strpos(prncptx, "`kwd'")
}
foreach kwd of local top_surgery_keywords {
	replace top_surgery = 1 if strpos(prncptx, "`kwd'")
}

label define transgender_type 1 "ftm", modify
label define transgender_type 2 "mtf", modify
label define top_surgery 1 yes, modify

tab transgender_type
tab top_surgery
tab admyr

/* Intersex surg CPT codes 
55970 intersex surg male female
55980 intersex surg female male
*/
generate operation = 0
replace operation = 1 if top_surgery==1 & transgender_type==1
replace operation = 2 if strpos(prncptx, "hysterect") | strpos(prncptx, "vag hyst") | strpos(prncptx, "tah") | strpos(prncptx, "uterus")
replace operation = 3 if strpos(prncptx, "vaginectomy") | strpos(prncptx, "vulvectomy") 
replace operation = 4 if strpos(prncptx, "scrotoplasty") | strpos(prncptx, "testicular prosth")
replace operation = 5 if cpt==55980
replace operation = 6 if top_surgery==1 & transgender_type==2
replace operation = 7 if strpos(prncptx, "orchiectomy")
replace operation = 8 if strpos(prncptx, "vaginoplasty") | strpos(prncptx, "artificial vagina")
replace operation = 9 if strpos(prncptx, "clitoroplasty")
replace operation = 10 if strpos(prncptx, "rcnstj female urethra")
replace operation = 11 if strpos(prncptx, "amputation penis")
replace operation = 12 if cpt==55970
replace operation = 13 if strpos(prncptx, "tracheoplasty") | strpos(prncptx, "larynx")
replace operation = 14 if strpos(prncptx, "setback ant frontal") | strpos(prncptx, "reconstruction orbit") | strpos(prncptx, "forehead") | strpos(prncptx, "craniofacial") | strpos(prncptx, "trachea")

label define operation 1 "FTM Top Surgery" 2 "Hysterectomy" 3 "Vaginectomy/Vulvectomy" 4 "Scrotoplasty/Testicular Prostheses" 5 "Genital Intersex Surg Female Male" 6 "MTF Top Surgery" 7 "Orchiectomy" 8 "Vaginoplasty" 9 "Clitoroplasty" 10 "Female Urethral Reconstruction" 11 "penectomy" 12 "Genital Intersex Surg Male Female" 13 "Laryngeal/Tracheoplasty" 14 "Facial"

generate operation_class = 0
replace operation_class = 1 if operation==1
replace operation_class = 2 if operation==2
replace operation_class = 3 if operation>=3 & operation<=5
replace operation_class = 4 if operation==6
replace operation_class = 5 if operation>=7 & operation <=12
replace operation_class = 6 if operation>12

label define operation_class 1 "FTM Top" 2 "FTM Internal" 3 "FTM Bottom" 4 "MTF Top" 5 "MTF Bottom" 6 "Head & Neck"

/*
foreach var of varlist "ftm_top_e ftm_internal_e ftm_bottom_e mtf_top_e mtf_bottom_e head_neck_e" {
	generate `var' = 0
}
*/
generate ftm_top_e = (operation_class==1)
generate ftm_internal_e = (operation_class==2)
generate ftm_bottom_e = (operation_class==3)
generate mtf_top_e = (operation_class==4)
generate mtf_bottom_e = (operation_class==5)
generate head_neck_e = (operation_class==6)

// Compound MI/Stroke outcome
//TODO fix
// generate mi_stroke_e = 1 if cdmi_e==1 | cva2_e==1

/* Summary statistics */
local nbaseline_characteristics age BMI
local cbaseline_characteristics sex_e race2_e smoke_e fnstatus2_e diabetes2_e ///
	 hxchf_e hxcopd_e discancr_e dialysis_e hxpvd_e hypermed_e ///
	 surgspec_e resident_involvement_e top_surgery
local complications new_sssi_e dehis_e oupneumo_e othdvt_e urninfec_e renafail_e ///
	neurodef_e rbc_need_e
	
// mi/stroke
	
egen any_complication = rowtotal(new_sssi_e dehis_e oupneumo_e othdvt_e urninfec_e renafail_e neurodef_e rbc_need_e)
replace any_complication = 1 if any_complication > 0 

egen any_comorbidities = rowtotal(diabetes2_e hxchf_e hxcopd_e discancr_e dialysis_e hxpvd_e hypermed_e)
replace any_comorbidities = 1 if any_comorbidities > 0 

local complications `complications' any_complication

/* FTM vs. MTF */
foreach var of varlist `cbaseline_characteristics' {
	disp "Variable: `var'"
	summarize `var'
	tab `var' if `var' < ., sort
	tab `var' transgender_type if `var'<., chi2 exact row column
}

foreach var of varlist `nbaseline_characteristics' {
	disp "Variable: `var'"
	summarize `var'
	ttest `var', by(transgender_type)
}

foreach var of varlist `complications' {
	disp "Variable: `var'"
	tab `var' if `var' < ., sort
	tab `var' transgender_type if `var'<., chi2 exact row column
}

tab operation_class surgspec, row column
tab operation surgspec, row column

foreach var_complic of varlist `complications' {
	tab `var_complic' operation_class, chi2 exact row column
}

generate mtf = 0
replace mtf=1 if transgender_type==2

local predictors age BMI sex_e race2_e smoke_e fnstatus2_e diabetes2_e ///
	hxchf_e hxcopd_e discancr_e dialysis_e hxpvd_e hypermed_e any_comorbidities ///
	plastics_e ortho_e gensurg_e gyn_e urology_e ent_e resident_involvement_e mtf top_surgery

foreach var of varlist `predictors' {
	logistic any_complication `var'
}

/* Does the difference in complication rates persist when possible cofounders are 
included all in the same model?*/
logistic any_complication age BMI any_comorbidities mtf top_surgery


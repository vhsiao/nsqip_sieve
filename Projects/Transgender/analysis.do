cls
clear all
set more off

cd "/Volumes/Encrypted/NSQIP/Projects"
pwd
use "/Volumes/Encrypted/NSQIP/Data/Transgender/transgender.dta"
drop if strpos(surgspec, "Ortho") //Weird outlier

// do code_standard_variables "/Volumes/Encrypted/NSQIP/Data/Transgender" "transgender.dta"
do code_standard_variables

// Excel file for results
local excel_file = "/Volumes/Encrypted/NSQIP/Projects/Transgender/results.xlsx"
do initiate_excel "`excel_file'" "baseline" "Variable Observations Overall FTM MTF p"
do initiate_excel "`excel_file'" "complication" "Variable Observations Overall FTM MTF p"
do initiate_excel "`excel_file'" "prediction" "Variable OR_any_complication_nonlifethreaten p"
do initiate_excel "`excel_file'" "operation site" "Complication FTM_top FTM_hysterectomy FTM_bottom MTF_top MTF_bottom Head_Neck Multi-Site"
do initiate_excel "`excel_file'" "surgical_subspecialty" " Subspecialty_vs_operation"
do initiate_excel "`excel_file'" "surgical_subspecialty_2" "Subspecialty_vs_operation_site"

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

local operations "ftm_top hysterectomy vaginectomy_vulvectomy scrotoplasty ftm_genital mtf_top orchiectomy vaginoplasty clitoroplasty urethroplasty penectomy mtf_genital throat facial revision"
local cptx_fields prncptx otherproc1 otherproc2 otherproc3 otherproc4 otherproc5 otherproc6 otherproc7 otherproc8 otherproc9 otherproc10 concurr1 concurr2 concurr3 concurr4 concurr5 concurr6 concurr7 concurr8 concurr9 concurr10
local cpt_fields cpt othercpt1 othercpt2 othercpt3 othercpt4 othercpt5 othercpt6 othercpt7 othercpt8 othercpt9 othercpt10 concpt1 concpt2 concpt3 concpt4 concpt5 concpt6 concpt7 concpt8 concpt9 concpt10

foreach operation of local operations {
	generate `operation'_e = 0
}
local operations ftm_top_e hysterectomy_e vaginectomy_vulvectomy_e scrotoplasty_e ftm_genital_e mtf_top_e orchiectomy_e vaginoplasty_e clitoroplasty_e urethroplasty_e penectomy_e mtf_genital_e throat_e facial_e

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
		
		replace ftm_top_e = 1 if top_surgery==1 & transgender_type==1
		replace mtf_top_e = 1 if top_surgery==1 & transgender_type==2
		
		replace hysterectomy_e = 1 if strpos(`cptx', "hysterect") | strpos(`cptx', "vag hyst") | strpos(`cptx', "tah") | strpos(`cptx', "uterus")
		replace vaginectomy_vulvectomy_e = 1 if strpos(`cptx', "vaginectomy") | strpos(`cptx', "vulvectomy")
		replace scrotoplasty_e = 1 if strpos(`cptx', "scrotoplasty") | strpos(`cptx', "testicular prosth")
		replace orchiectomy_e = 1 if strpos(`cptx', "orchiectomy")
		replace vaginoplasty_e = 1 if strpos(`cptx', "vaginoplasty") | strpos(`cptx', "artificial vagina")
		replace clitoroplasty_e = 1 if strpos(`cptx', "clitoroplasty")
		replace penectomy_e = 1 if strpos(`cptx', "amputation penis")
		replace throat_e = 1 if strpos(`cptx', "tracheoplasty") | strpos(`cptx', "larynx")
		replace facial_e = 1 if strpos(`cptx', "setback ant frontal") | strpos(`cptx', "reconstruction orbit") | strpos(`cptx', "forehead") | strpos(`cptx', "craniofacial") | strpos(`cptx', "trachea")

		/* The primary operation for the patient is classified based on the prncptx/cpt */
		if strpos("`cptx'", "prncptx") {
			replace operation = 1 if ftm_top_e==1 & operation==0
			replace operation = 2 if hysterectomy_e==1 & operation==0
			replace operation = 3 if vaginectomy_vulvectomy_e==1 & operation==0
			replace operation = 4 if scrotoplasty_e==1 & operation==0
			
			replace operation = 6 if mtf_top_e==1 & operation==0
			replace operation = 7 if orchiectomy_e==1 & operation==0
			replace operation = 8 if vaginoplasty_e==1 & operation==0
			replace operation = 9 if clitoroplasty_e==1 & operation==0
			
			replace operation = 11 if penectomy_e==1 & operation==0
			
			replace operation = 13 if throat_e==1 & operation==0
			replace operation = 14 if facial_e==1 & operation==0
			}
		}
}
/* 
55970 intersex surg male female
55980 intersex surg female male
*/
foreach cpt of varlist `cpt_fields' {
	quietly {
		replace ftm_genital_e = 1 if `cpt' == 55980
		replace mtf_genital_e = 1 if `cpt' == 55970
		replace urethroplasty_e = 1 if `cpt' == 53430 | `cpt' == 53410
	}
	/* The primary operation for the patient is classified based on the prncptx/cpt */
	if strpos("`cpt'", "cpt") {
		replace operation = 5 if ftm_genital_e==1 & operation==0
		replace operation = 12 if mtf_genital_e==1 & operation==0
		replace operation = 10 if urethroplasty_e==1 & operation==0 // Urethroplasty takes last priority in determining what the sex reassignment operation was. 	
	}
	replace transgender_type = 1 if ftm_genital_e==1 & transgender_type==0
	replace transgender_type = 2 if mtf_genital_e==1 & transgender_type==0
}

/* Exclusion Criteria */
// Revision surgery, secondary procedrue, complication not included: ""revision" "excision tracheal stenosis" "closure ureterocutaneous fistula" "exc breast les preop plmt rad marker" "clsr urethrostomy""
// Unknown CPT: "nipple/areola reconstruction", "musc myocutaneous/faciocutaneous" "unlisted procedure breast" "adjnt tis trnsfr" "tissue grafts other"
/*
local exclusion_criteria `""revision" "excision tracheal stenosis" "closure ureterocutaneous fistula" "exc breast les preop plmt rad marker" "nipple/areola reconstruction" "musc myocutaneous" "unlisted procedure breast" "mastopexy" "clsr urethrostomy" "adjnt tis trnsfr" "panniculectomy" "cystourethroscopy" "perineoplasty" "torsion tstis" "rmvl prosthetic vaginal" "urethromeatoplasty w/mucosal advancement" "tissue grafts other""'
foreach exclusion of local exclusion_criteria {
	drop if strpos(prncptx, "`exclusion'")
}
*/

/* Identify revision procedures among operations that have not yet been classified */
foreach cptx of varlist `cptx_fields' {
	quietly {
		replace revision_e=1 if (strpos(`cptx', "revision") | strpos(`cptx', "revj")) & operation==0
	}
}

tab prncptx if revision_e==1, sort
tab cpt if revision_e==1, sort
drop if revision_e==1

tab prncptx if operation==0 | transgender_type==0, sort
tab cpt if operation==0 | transgender_type==0, sort
drop if operation==0 | transgender_type==0

generate mtf_surgery = 0
replace mtf_surgery=1 if transgender_type==2

generate operation_site = 0
replace operation_site = 1 if operation==1
replace operation_site = 2 if operation==2
replace operation_site = 3 if operation>=3 & operation<=5
replace operation_site = 4 if operation==6
replace operation_site = 5 if operation>=7 & operation <=12
replace operation_site = 6 if operation>12

label define operation 0 "Unknown" 1 "FTM Top Surgery" 2 "Hysterectomy/Oophorectomy" 3 "Vaginectomy/Vulvectomy" 4 "Scrotoplasty/Testicular Prostheses" 5 "Genital Intersex Surg Female Male" 6 "MTF Top Surgery" 7 "Orchiectomy" 8 "Vaginoplasty" 9 "Clitoroplasty" 10 "Urethroplasty" 11 "Penectomy" 12 "Genital Intersex Surg Male Female" 13 "Laryngeal/Tracheoplasty" 14 "Facial Remodeling" 15 "Multi-Site"
label define operation_site 0 "Unknown" 1 "FTM Top" 2 "FTM Internal" 3 "FTM Bottom" 4 "MTF Top" 5 "MTF Bottom" 6 "Head & Neck" 7 "Multi-Site"

generate ftm_internal_e = hysterectomy_e==1
generate ftm_bottom_e = ftm_genital_e==1 | vaginectomy_vulvectomy_e==1 | scrotoplasty==1
generate mtf_bottom_e = mtf_genital_e==1 | orchiectomy_e==1 | vaginoplasty_e==1 | clitoroplasty_e==1 | penectomy_e==1
generate head_neck_e = throat_e==1 | facial_e==1

egen multioperation = anycount(`operations'), values(1)
egen multisite = anycount(ftm_top_e ftm_internal_e ftm_bottom_e mtf_top_e mtf_bottom_e head_neck_e), values(1)

generate multioperation_e = (multioperation>1)
generate multisite_e = (multisite>1)
replace operation = 15 if multisite_e
replace operation_site = 7 if multisite_e

generate hyperbili_e = prbili > 1.9 & prbili < .
generate highalp_e = pralkph > 147 & pralkph < .
generate high_hct_e = prhct > 52 & prhct < .
generate low_hct_e = prhct < 38

local nbaseline_characteristics age BMI optime ///
	 prsodm prbun prcreat pralbum prbili prsgot pralkph prwbc prhct prplate prptt prinr
local cbaseline_characteristics race_american_indian_e race_asian_e race_black_e race_nh_pi_e race_white_e ///
	 smoke_e fnstatus2_e diabetes2_e prsepsis2_e ///
	 hxchf_e hxcopd_e discancr_e dialysis_e hypermed_e  any_comorbidities ///
	 hx_tia_cva hx_cardiac_ischemia hx_pvd_rest_pain ///
	 plastics_e ortho_e gensurg_e gyn_e urology_e ent_e resident_involvement_e ///
	 top_surgery mtf_surgery ftm_top_e ftm_internal_e ftm_bottom_e mtf_top_e mtf_bottom_e head_neck_e multisite_e ///
	 hyperbili_e highalp_e high_hct_e low_hct_e
	
// Removed: UTI, peripheral nerve injury, readmission, dehiscence
local complications new_sssi_e new_dssi_e new_ossi_e ///
	oupneumo_e othdvt_e renafail_e cnscva_e pulembol_e othbleed_e ///
	rbc_need_e sepsis_septic_shock mi_cardiac_arrest_cva failwean_reintub death_e reoperation1_e
	
local predictors age BMI optime ///
	prsodm prbun prcreat pralbum prbili prsgot pralkph prwbc prhct prplate prptt prinr ///
	smoke_e fnstatus2_e diabetes2_e prsepsis2_e ///
	hxchf_e hxcopd_e discancr_e dialysis_e hypermed_e  any_comorbidities ///
	hx_tia_cva hx_cardiac_ischemia hx_pvd_rest_pain ///
	plastics_e ortho_e gensurg_e gyn_e urology_e ent_e resident_involvement_e ///
	top_surgery mtf_surgery ftm_top_e ftm_internal_e ftm_bottom_e mtf_top_e mtf_bottom_e head_neck_e multioperation_e multisite_e ///

do compound_variable "any_complication_nonlifethreaten" "`complications'"
	
local comorbidities smoke_e diabetes2_e hxchf_e hxcopd_e discancr_e dialysis_e hypermed_e hx_tia_cva hx_cardiac_ischemia hx_pvd_rest_pain
local complications `complications' any_complication_nonlifethreaten

/* Variable Labels */
quietly {
	label variable transgender_type "MTF/FTM"
	label variable top_surgery "Top Surgery"
	label variable operation "Operation"
	label variable operation_site "Operation Site"
	label variable ftm_top_e "FTM Top Surgery"
	label variable ftm_internal_e "Hysterectomy/Oophorectomy"
	label variable ftm_bottom_e "Vaginectomy/Vulvectomy"
	label variable mtf_top_e "MTF Top Surgery"
	label variable mtf_bottom_e "MTF Bottom Surgery"
	label variable multioperation_e "Multi-Operation"
	label variable multisite_e "Multiple Sites"
	label variable head_neck_e "Head/Neck Surgery"
	label variable mtf_surgery "MTF"
	label variable hyperbili_e "Hyperbilirubinemia"
	label variable highalp_e "High Alk Phos"
	label variable high_hct_e "Elevated Hematocrit"
	label variable low_hct_e "Low Hematocrit"
}

/* FTM vs. MTF */
local subspecialty_i=2
local subspecialty_i_2=2

local len_n_baseline_characteristics : word count `nbaseline_characteristics'

do put_all_in_excel "`excel_file'" "baseline" 2 1 "ttest" transgender_type "`nbaseline_characteristics'"
do put_all_in_excel "`excel_file'" "baseline" (2+`len_n_baseline_characteristics') 1 "chi2" transgender_type "`cbaseline_characteristics'"
do put_all_in_excel "`excel_file'" "complication" 2 1 "chi2" transgender_type "`complications'"
do put_all_in_excel "`excel_file'" "prediction" 2 1 "logistic" "`predictors'" any_complication_nonlifethreaten "independent"

putexcel set "`excel_file'", sheet("operation site") modify
local operation_site_row = 2

/* Complications (row) by operation site (column) */
quietly {
	foreach dependent_var of varlist `complications' {
		putexcel A`operation_site_row'=("`:var label `dependent_var''")
		local operation_site_row = `operation_site_row' + 1
	}
	forvalues i=1/7 {
		disp "Variable: `independent_var'"
		
		local operation_site_col = 65 + `i'
		local col = "`=char(`operation_site_col')'"
		local overall_freq_val = 0
		
		local operation_site_row = 2
		local j = 1
		foreach dependent_var of varlist `complications' {
			di "Complication: `dependent_var'"
			tab operation_site `dependent_var' if operation_site<., row column matcell(freq)
			matlist(freq)
			return list
			local freq_val_`j' = freq[`i', 2]
			local percent_val_`j' = `freq_val_`j'' / (`freq_val_`j'' + freq[`i', 1]) * 100
			local percent_val_`j' : display %03.2f `percent_val_`j''
			putexcel `col'`operation_site_row'=("`freq_val_`j'' (`percent_val_`j''%)")
			local j = `j' + 1
			local operation_site_row = `operation_site_row' + 1
		}
	}
}

	do put_in_excel "`excel_file'" "surgical_subspecialty" `subspecialty_i' 2 "tab" surgspec_e operation
	do put_in_excel "`excel_file'" "surgical_subspecialty_2" `subspecialty_i_2' 2 "tab" surgspec_e operation_site
/* 
Regression run with all predictors significant in univariate analysis

Dropped if <80% of observations present.

 */

 /*
logistic any_complication_nonlifethreaten age BMI optime ///
		smoke_e diabetes2_e ///
		hypermed_e  any_comorbidities ///
		plastics_e gensurg_e gyn_e urology_e ///
		mtf_surgery ftm_top_e ftm_internal_e ftm_bottom_e mtf_top_e mtf_bottom_e multioperation_e
*/
logistic any_complication_nonlifethreaten optime ftm_top_e mtf_top_e mtf_bottom_e multioperation_e
logistic any_complication_nonlifethreaten optime multioperation_e

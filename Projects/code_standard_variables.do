cls
set more off

replace prncptx = lower(prncptx)
tab prncptx

generate BMI = (weight/height^2) * 703 // Generate BMI variable

// modify diabetes
generate diabetes2 = diabetes
replace diabetes2 = "yes" if strpos(diabetes, "INSULIN") | strpos(diabetes, "ORAL")

// Generate sepsis variable
generate prsepsis2 = prsepis
replace prsepsis2 = "" if prsepis=="."

// Modify functional status variable
replace fnstatus2 = "" if fnstatus2 == "Unknown"

// Modify race variable
generate race2 = race_new
replace race2 = "" if strpos(race_new, "Unknown")

local races "race_american_indian_e race_asian_e race_black_e race_nh_pi_e race_white_e"
foreach var of local races {
	generate `var' = 0 if ~missing(race2)
}
replace race_american_indian_e = 1 if strpos(race2, "American Indian")
replace race_asian_e = 1 if strpos(race2, "Asian")
replace race_black_e = 1 if strpos(race2, "Black")
replace race_nh_pi_e = 1 if strpos(race2, "Native Hawaiian")
replace race_white_e = 1 if strpos(race2, "White")

/* Encoding variables for resident involvement */
generate resident_involvement_e = .
replace resident_involvement_e = 0 if strpos(attend, "Attending Alone")
replace resident_involvement_e = 1 if strpos(attend, "Resident") | (pgy>0 & pgy<.)

/* Encode all categorical variables */
local numeric_vars age BMI rbc
local categorical_vars sex race2 fnstatus1 fnstatus2 anesthes anesthes_other asaclas ///
	dyspnea prsepsis2 surgspec wndclas admqtr
	 
foreach var of varlist `numeric_vars' {
	replace `var' = . if `var'==-99
}
	 
foreach var of varlist `categorical_vars' {
	disp "`var'"
	capture replace `var' = "" if `var'=="."
	capture encode `var', gen(`var'_e)
	if _rc !=0 {
		generate `var'_e = `var'
	}
	label variable `var'_e "`: var label `var''"
}

local binary1 = "dehis oupneumo othdvt oprenafl renainsf urninfec cnscva supinfec wndinfd orgspcssi neurodef reintub pulembol failwean cnscoma cdarrest cdmi othbleed othgrafl othsysep othseshock"
local binary2 = "renafail cva cvano discancr hxmi hxchf hxcopd hxtia hxpvd hxangina dialysis hypermed diabetes2 returnor readmission1 reoperation1 steroid smoke ascites wtloss electsurg dnr etoh ventilat ventpatos restpain prvpci prvpcs cpneumon esovar para quad bleeddis transfus chemo radio pregnancy proper30 emergncy tumorcns unplannedreadmission1 unplannedreadmission2 unplannedreadmission3 unplannedreadmission4 unplanreadmission5"
foreach var of local binary1 {
	do encode_and_label_binary `var' "no complication" "`: var label `var''"
}
foreach var of local binary2 {
	do encode_and_label_binary `var' "no" "`: var label `var''"
}

// Modify ASA class variable
replace asaclas_e = . if lower(asaclas)=="none assigned"
generate highasa = asaclas_e
replace highasa = 0 if asaclas_e==1
replace highasa = 1 if asaclas_e>1 & asaclas_e<.

// Generate Death Variable
generate death_e = 0
replace death_e = 1 if yrdeath!=.

generate rbc_need_e = 1 if rbc > 0 & rbc < .

generate new_sssi_e = 1 if supinfec=="Superficial Incisional SSI" & sssipatos~="Yes"
generate new_dssi_e = 1 if wndinfd=="Deep Incisional SSI" & dssipatos~="Yes"
generate new_ossi_e = 1 if orgspcssi=="Organ/Space SSI" & ossipatos~="Yes"

generate gensurg_e = 1 if surgspec=="General Surgery"
generate gyn_e = 1 if surgspec=="Gynecology"
generate ortho_e = 1 if surgspec=="Orthopedics"
generate ent_e = 1 if strpos(surgspec, "Otolaryngology")
generate plastics_e = 1 if surgspec=="Plastics"
generate urology_e = 1 if surgspec=="Urology"

foreach var of varlist new_sssi_e new_dssi_e new_ossi_e rbc_need_e gensurg_e gyn_e ortho_e ent_e plastics_e urology_e {
	replace `var' = 0 if missing(`var')
}

// Partially or Totally Dependent
generate fnstatus_dependent = .
replace fnstatus_dependent = 0 if fnstatus_dependent==1
replace fnstatus_dependent = 1 if fnstatus_dependent > 1 & fnstatus_dependent < . //Partially/Totally Dependent
label define fnstatus_dependent 1 "Partially/Totally Dependent", modify

do compound_variable "sepsis_septic_shock" "othsysep_e othseshock_e"
do compound_variable "mi_cardiac_arrest_cva" "cdmi_e cdarrest_e cnscva_e"
do compound_variable "hx_tia_cva" "hxtia_e cva_e cvano_e"
do compound_variable "hx_cardiac_ischemia" "hxmi_e hxangina_e prvpci_e prvpcs_e"
do compound_variable "hx_pvd_rest_pain" "hxpvd_e restpain_e"
do compound_variable "failwean_reintub" "failwean_e reintub_e"

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

do compound_variable "any_complication" "`complications'"
do compound_variable "any_comorbidities" "`comorbidities'"	


local complications `complications' any_complication

/* Variable Labels */
label variable diabetes2_e "Diabetes"
label variable BMI "BMI"
label variable race_american_indian_e "Race: American Indian or Alaska Native"
label variable race_asian_e "Race: Asian"
label variable race_black_e "Race: Black of African American"
label variable race_nh_pi_e "Race: Native Hawaiian or Pacific Islander"
label variable race_white_e "Race: White"
label variable resident_involvement_e "Resident Involved"
label variable race2_e "Race"
label variable prsepsis2_e "Previous Sepsis"
label variable fnstatus_dependent "Functional Status Partially/Totally Dependent"
label variable highasa "ASA Class >1"
label variable death_e "Death"
label variable rbc_need_e "Need for RBC intraoperatively"
label variable new_sssi_e "New Superficial Surgical Site Infection"
label variable new_dssi_e "New Deep Surgical Site Infection"
label variable new_ossi_e "New Organ Space Infection"
label variable gensurg_e "General Surgery"
label variable gyn_e "Gynecology"
label variable ortho_e "Orthopedics"
label variable ent_e "Otolaryngology (ENT)"
label variable plastics_e "Plastics"
label variable urology_e "Urology"
label variable any_complication "Any Complication"
label variable any_comorbidities "Any Comorbidities"
label variable sepsis_septic_shock "Systemic Sepsis or Septic Schock"
label variable mi_cardiac_arrest_cva "MI, Cardiac Arrest or CVA"
label variable hx_tia_cva "History of TIA/CVA"
label variable hx_cardiac_ischemia "History of Cardiac Ischemia"
label variable hx_pvd_rest_pain "History of PVD, rest pain or gangrene"
label variable failwean_reintub "Reintubation or Failure to Wean Vent"

cd "/Volumes/Encrypted/NSQIP/Projects"

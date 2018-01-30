cls
clear all
set more off

local project_file `1'
local dta_file `2'

cd "`project_file'"
use "`dta_file'"

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

/* */

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
}

local binary1 = "dehis oupneumo othdvt oprenafl urninfec cnscva supinfec wndinfd orgspcssi neurodef reintub pulembol failwean cnscoma cdarrest cdmi othbleed othgrafl othsysep othseshock"
local binary2= "renafail cva cvano discancr hxmi hxchf hxcopd hxtia hxpvd hxangina dialysis hypermed diabetes2 returnor reoperation steroid smoke ascites wtloss electsurg dnr etoh ventilat ventpatos restpain prvpci prvpcs cpneumon esovar para quad bleeddis transfus chemo radio pregnancy proper30 emergncy tumorcns"
foreach var of local binary1 {
	capture replace `var' = "" if `var'=="."
	generate `var'_e = 0
	replace `var'_e = 1 if `var'!="" & ~strpos(lower(`var'), "no complication")
}
foreach var of local binary2 {
	capture replace `var' = "" if `var'=="."
	generate `var'_e = 0
	replace `var'_e = 1 if `var'!="" & lower(`var')!="no"
}

generate death_e = 0
replace death_e = 1 if yrdeath!=.

generate rbc_need_e = 1 if rbc > 0 & rbc < .

generate new_sssi_e = 1 if supinfec=="Superficial Incisional SSI" & sssipatos~="Yes"
generate new_dssi_e = 1 if wndinfd=="Deep Incisional SSI" & dssipatos~="Yes"
generate new_ossi_e = 1 if orgspcssi=="Organ/Space SSI" & ossipatos~="Yes"

generate gensurg_e = 1 if surgspec=="General Gurgery"
generate gyn_e = 1 if surgspec=="Gynecology"
generate ortho_e = 1 if surgspec=="Orthopedics"
generate ent_e = 1 if strpos(surgspec, "Otolaryngology")
generate plastics_e = 1 if surgspec=="Plastics"
generate urology_e = 1 if surgspec=="Urology"

foreach var of varlist new_sssi_e new_dssi_e new_ossi_e rbc_need_e gensurg_e gyn_e ortho_e ent_e plastics_e urology_e {
	replace `var' = 0 if missing(`var')
}

// Partially or Totally Dependent
replace fnstatus2_e = 0 if fnstatus2_e==1
replace fnstatus2_e = 1 if fnstatus2_e > 1 & fnstatus2_e < . //Partially/Totally Dependent
label define fnstatus2_e 1 "Partially/Totally Dependent", modify

cd "/Volumes/Encrypted/NSQIP/Projects"

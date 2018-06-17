cls
clear all
set more off

cd "/Volumes/Encrypted/NSQIP/Projects"
pwd
do code_standard_variables "/Volumes/Encrypted/NSQIP/Data/TendonRepair" "tendonrepair.dta"

/* Summary statistics */
local nbaseline_characteristics age BMI
local cbaseline_characteristics sex_e race2_e diabetes2_e smoke_e fnstatus2_e steroid_e ///
	 ascites_e hxcopd_e hxchf_e hxpvd_e hypermed_e dialysis_e resident_involvement_e wtloss_e ///
	 prsepis2_e surgspec_e

/*
CPT Codes

1.	Flexor tendon repair or advancement, single, not in no mans land; primary or secondary without free graft, each tendon (26350)
2.	Flexor tendon repair or advancement, single, not in no mans land; secondary with free graft (includes obtaining graft), each (26352)
3.	Flexor tendon repair or advancement, single, in no mans land; primary, each tendon (26356)
4.	Flexor tendon repair or advancement, single, in no mans land; secondary, each tendon (26357)
5.	Flexor tendon repair or advancement, single, in no mans land secondary with free graft (includes obtaining graft), each (26358)
6.	Profundus tendon repair or advancement, with intact sublimis; primary (26370)
7.	Profundus tendon repair or advancement, with intact sublimis; secondary with free graft (includes obtaining graft) (26372)
8.	Profundus tendon repair or advancement, with intact sublimis; secondary without free graft (26373)
9.	XXX Flexor tendon excision, implantation of plastic tube or rod for delayed tendon graft, hand or finger (26390)
10.	XXX Removal of tube or rod and insertion of flexor tendon graft (includes obtaining graft), hand or finger (26392)
11.	Extensor tendon repair, dorsum of hand, single, primary or secondary; without free graft, each tendon (26410)
12.	Extensor tendon repair, dorsum of hand, single, primary or secondary; with free graft, (includes obtaining graft), each tendon (26412)
13.	Extensor tendon excision, implantation of plastic tube or rod for delayed extensor tendon graft, hand or finger (26415)
14.	XXX Removal of tube or rod and insertion of extensor tendon graft (includes obtaining graft), hand or finger (26416)
15.	Extensor tendon repair, dorsum of finger, single, primary or secondary, without free graft, each tendon (26418)
16.	Extensor tendon repair, dorsum of finger, single, primary or secondary, with free graft, (includes obtaining graft) each tendon (26420)
17.	XXX Extensor tendon repair, central slip repair, secondary (boutonniere deformity); using local tissues (26426)
18.	XXX Extensor tendon repair, central slip repair, secondary (boutonniere deformity); with free graft (includes obtaining graft) (26428)
19.	XXX Extensor tendon repair, distal insertion (mallet finger), closed, splinting with or without percutaneous pinning (26432)
*/

// Exclude delayed repair, distal insertion (mallet finger)/central slip repairs.
local flexor_codes 26350 26352 26356 26357 26358 26370 26372 26373
local extensor_codes 26410 26412 26416 26418 26420

quietly {
generate flexor = 0
generate extensor = 0
generate flexor_extensor = 0
foreach var of varlist cpt othercpt1 othercpt2 othercpt3 othercpt4 othercpt5 othercpt6 othercpt7 othercpt8 othercpt9 othercpt10 {
	foreach code of local flexor_codes {
		replace flexor = 1 if `var'==`code'
	}
	foreach code of local extensor_codes {
		replace extensor = 1 if `var'==`code'
	}
}
replace flexor_extensor = 3 if flexor & extensor
replace flexor_extensor = 1 if flexor & ~extensor
replace flexor_extensor = 2 if ~flexor & extensor

label define flexor_extensor 1 "flexor only", modify
label define flexor_extensor 2 "extensor only", modify
label define flexor_extensor 3 "flexor and extensor", modify

drop flexor
drop extensor
}

di "`count(flexor_extensor==3)' patients had both flexor and extensor repair"
drop if flexor_extensor==3 | flexor_extensor==0

/* Baseline Characteristics */
foreach var of varlist `nbaseline_characteristics' {
	disp "Variable: `var'"
	summarize `var'
	ttest `var', by(flexor_extensor)
}
foreach var of varlist `cbaseline_characteristics' {
	disp "`var'"
	tab `var' if `var' < ., sort
	tab `var' flexor_extensor if `var'<., chi2 exact row column
}

/* Complications (failure, wound complication) */

// Major outcome is return to or in 30 days

// Define wound complication as SSSI, DSSI, peripheral nerve injury, #rbc units given */
// supinfec/sssipatos wndinfd/dssipatos neurodef rbc
egen any_wound_complication = rowtotal(sssi_e dssi_e neurodef_e rbc_need_e dehis_e)
replace any_wound_complication = 2 if any_wound_complication > 0 

di "=== Wound Complications ==="

foreach var of varlist returnor_e sssi_e dssi_e neurodef_e rbc_need_e any_wound_complication {
	tab `var', sort
	tab `var' flexor_extensor, chi2 exact row column
}

di "=== Predictors of Complications ==="
/* Predictors of Complications */

local baseline_characteristics `cbaseline_characteristics' plastics ortho gensurg
local baseline_characteristics `nbaseline_characteristics' `cbaseline_characteristics' plastics ortho gensurg
local preop_labs "prsodm prbun prcreat pralbum prbili prsgot pralkph prwbc prhct prplate prptt prinr prpt"
local lln "136 8 0.7 3.5 0.3 0 36 4.5 36 150 25 2 0.8 11"
local luln "145 20 1.3 5.5 1.2 35 92 11 51 350 35 3 1.2 13"
forvalues i=1/14 {
	
}


foreach var_independent of varlist `baseline_characteristics' {
	
	// logit regression (num/cat or cat/cat)
	foreach var_independent of varlist returnor_e any_wound_complication {
		disp "Independent Variable: `var_independent'"
		disp "Outcome Variable: `var_outcome'"
		capture noisily logit `var_outcome' `var_independent', or
	}
}

logistic returnor_e age sex_e hxcopd_e hypermed_e
logistic any_wound_complication age sex_e hxcopd_e hypermed_e

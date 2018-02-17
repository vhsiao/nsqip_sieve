/* 
Cleans NSQIP data.
*/
clear all
set more off

// This is a 5000 observations (500 from each year)
cd "/Volumes/Encrypted/NSQIP/Data/"
use "./merged/nsqip.dta"

// This is a 5000 observations (500 from each year)
/*
cd "/Volumes/Encrypted/NSQIP/Data/"
use "./Samples/merged/nsqip.dta"
*/

// First renaming all variables to lowercase to avoid case confusion
rename *, lower

// Manually renaming a couple variables with confusing names

/*
	Recoding variables mean you change values of numeric variables according to 
	a set of rules.
	
	Encoding means you convert a string into a numeric value- useful for categorical
	variables. You can then label each of the different values for ease.
	
	Do not use encode if varname
	contains numbers that merely happen to be stored as strings; instead, use
	generate newvar = real(varname) or destring
*/

// Replacing "NULL" strings with proper missing value for Stata
quietly: {
	ds, has(type string)
	foreach var of varlist `r(varlist)' {
		replace `var' = "." if `var'=="NULL"
	}
}

// Converting strings to numeric values
quietly: {
	foreach var of varlist age cpt pufyear {
		destring `var', replace force
	}
	foreach var of varlist othercpt* {
		destring `var', replace force
	}
	foreach var of varlist *cpt1 concpt* {
		destring `var', replace force
	}
}
	
// Converting strings to categorical variables
quietly: {
	// Build the list of categorical variables
	local categorical_variable_list
	
	foreach var of varlist sex race_new race ethnicity_hispanic inout transt dischdest anesthes surgspec electsurg diabetes smoke dyspnea fnstatus2 ventilat ascites hypermed renafail dialysis discancr wndinf steroid wtloss bleeddis transfus prsepis emergncy wndclas asaclas supinfec wndinfd orgspcssi dehis {
		local categorical_variable_list `categorical_variable_list' `var'
	}
	foreach var of varlist oupneumo reintub pulembol failwean renainsf cnscva cdarrest cdmi {
		local categorical_variable_list `categorical_variable_list' `var'
	}
	foreach var of varlist othbleed othdvt othsysep othseshock othcdiff {
		local categorical_variable_list `categorical_variable_list' `var'
	}
	foreach var of varlist oprenafl urninfec {
		local categorical_variable_list `categorical_variable_list' `var'
	}
	foreach var of varlist returnor stillinhosp {
		local categorical_variable_list `categorical_variable_list' `var'
	}
	foreach var of varlist wound_closure anesthes_other attend {
		local categorical_variable_list `categorical_variable_list' `var'
	}
	foreach var of varlist etoh dnr fnstatus1 opnote {
		local categorical_variable_list `categorical_variable_list' `var'
	}
	foreach var of varlist esovar cpneumon restpain impsens coma cnscoma hemi para quad cva cvano tumorcns chemo radio pregnancy proper30 airtra typeintoc neurodef othgrafl {
		local categorical_variable_list `categorical_variable_list' `var'
	}
	
	// Some variables are named similarly so we can set wildcard rules instead of manually typing their names as above.
	foreach var of varlist *patos reoperation* *readmission* *susp* *icd10* *icd9* *related* *tx hx* prv* otherproc* concurr* {
		foreach var2 of varlist `var' {
			local categorical_variable_list `categorical_variable_list' `var2'
		}
	}
	
	// Now convert to categoricals and rename them all at once
	foreach var of varlist `categorical_variable_list' {
		//encode `var', generate(cat_`var')
		capture noisily encode `var', generate(`var'_2)
		drop `var'
		capture noisily rename `var'_2 `var'
	}
}

// Replacing missing number values with proper missing value for Stata
quietly: {
	local numeric_variable_list
	
	foreach var of varlist height weight packs {
		local numeric_variable_list `numeric_variable_list' `var'
	}
	foreach var of varlist prsodm prbun prcreat pralbum prbili prsgot pralkph prwbc prhct prplate prptt prinr prpt {
		local numeric_variable_list `numeric_variable_list' `var'
	}
	foreach var of varlist yrdeath tothlos dsupinfec dwndinfd dorgspcssi ddehis {
		local numeric_variable_list `numeric_variable_list' `var'
	}
	foreach var of varlist doupneumo dreintub dpulembol dfailwean drenainsf doprenafl durninfec dcnscva dcdarrest dcdmi dothbleed dothdvt dothsysep {
		local numeric_variable_list `numeric_variable_list' `var'
	}
	foreach var of varlist dopertod doptodis dothcdiff {
		local numeric_variable_list `numeric_variable_list' `var'
	}
	foreach var of varlist pgy mallamp yrdeath sdisdt hdisdt dsupinfec dwndinfd dcnscoma dneurodef dothgrafl dothseshock {
		local numeric_variable_list `numeric_variable_list' `var'
	}
	
	// Some variables are named similarly so we can set wildcard rules instead of manually typing their names as above.
	foreach var of varlist *days* dpr* otherwrvu* conwrvu* {
		foreach var2 of varlist `var' {
			local numeric_variable_list `numeric_variable_list' `var2'
		}
	}
	foreach var of varlist `numeric_variable_list' {
		replace `var' = . if `var'==-99
	}
}

save "./Samples/merged/nsqip_cleaned.dta", replace

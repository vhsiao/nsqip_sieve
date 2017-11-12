/* 
Cleans NSQIP data in all files of this directory.
*/

// This is the full 2016 dataset
// use "/Users/vivianhsiao/Google Drive/MS4/NSQIP Data/Data/acs_nsqip_puf_05_to_16.dta"

// This is a random sample of 500 records from 2016 data
clear all

local data_files : dir . files "*.dta"
disp `data_files'

foreach data_file of local data_files {
	use `data_file'
	
	// First renaming all variables to lowercase to avoid case confusion
	rename *, lower

	// Manually renaming a couple variables with confusing names
	// rename podiag_other podiag_othericd9
	// rename podiag_other10 podiag_othericd10

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
	destring cpt, replace force
	destring pufyear, replace force
	// Do the same thing for other variables, using a foreach loop
	quietly {
		foreach var of varlist age {
			destring `var', replace force
		}
		foreach var of varlist othercpt* {
			destring `var', replace force
		}
		foreach var of varlist *cpt1 {
			destring `var', replace force
		}
	}
		
	// Converting strings to categorical variables
	encode sex, generate(cat_sex)
	encode race_new, generate(cat_race)

	// Do the same thing for other variables, using a foreach loop
	quietly: {
		// Build the list of categorical variables
		local categorical_variable_list
		
		foreach var of varlist ethnicity_hispanic inout transt dischdest anesthes surgspec electsurg diabetes smoke dyspnea fnstatus2 ventilat hxcopd ascites hxchf hypermed renafail dialysis discancr wndinf steroid wtloss bleeddis transfus prsepis emergncy wndclas asaclas supinfec wndinfd orgspcssi dehis {
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
		foreach var of varlist wound_closure anesthes_other {
			local categorical_variable_list `categorical_variable_list' `var'
		}
		
		// Some variables are named similarly so we can set wildcard rules instead of manually typing their names as above.
		foreach var of varlist *patos reoperation* *readmission* *susp* *icd10* *icd9* *related* {
			foreach var2 of varlist `var' {
				local categorical_variable_list `categorical_variable_list' `var2'
			}
		}
		
		// Now convert to categoricals and rename them all at once
		foreach var of varlist `categorical_variable_list' {
			encode `var', generate(cat_`var')
		}
	}

	// Replacing missing number values with proper missing value for Stata
	quietly: {
		local numeric_variable_list
		foreach var of varlist prsodm prbun prcreat pralbum prbili prsgot pralkph prwbc prhct prplate prptt prinr prpt {
			local numeric_variable_list `numeric_variable_list' `var'
		}
		foreach var of varlist yrdeath tothlos dsupinfec dwndinfd dorgspcssi ddehis {
			local numeric_variable_list `numeric_variable_list' `var'
		}
		foreach var of varlist doupneumo dreintub dpulembol dfailwean drenainsf {
			local numeric_variable_list `numeric_variable_list' `var'
		}
		foreach var of varlist doupneumo dreintub dpulembol dfailwean drenainsf doprenafl durninfec dcnscva dcdarrest dcdmi dothbleed dothdvt dothsysep {
			local numeric_variable_list `numeric_variable_list' `var'
		}
		foreach var of varlist dopertod doptodis dothcdiff {
			local numeric_variable_list `numeric_variable_list' `var'
		}
		
		// Some variables are named similarly so we can set wildcard rules instead of manually typing their names as above.
		foreach var of varlist *days* dpr* otherwrvu* {
			foreach var2 of varlist `var' {
				local numeric_variable_list `numeric_variable_list' `var2'
			}
		}
		foreach var of varlist `numeric_variable_list' {
			replace `var' = . if `var'==-99
		}
	}
	
}

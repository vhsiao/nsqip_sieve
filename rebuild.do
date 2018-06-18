/* 
	Merge data across all years into 1 dataset
*/

set more off
clear all

// Full data
cd "/Volumes/Encrypted/NSQIP/Data/"

// Sample data
//cd "/Volumes/Encrypted/NSQIP/Data/Samples"

// Summarizes data. Comment out to save time.
local files : dir . files "*.dta"
di `files'

foreach data_file of local files {
	clear all
	use `data_file'
	
	// Rename all variables to lowercase
	rename *, lower
	
	// Rename variables named differently across years
	capture rename new_race race_new
	capture rename podiag podiag_icd9 //TODO: confirm correct
	
	capture rename podiagtx podiagtx_icd9 //TODO: confirm correct
	capture rename podiag_other podiag_othericd9 //TODO: confirm correct
	
	capture rename podiag10 podiag_icd10 //TODO: confirm correct
	capture rename podiagtx10 podiagtx_icd10 //TODO: confirm correct
	capture rename podiag_other10 podiag_othericd10
	
	capture rename admyear pufyear //TODO:confirm correct
	
	
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
		local numstr age cpt pufyear inout
		foreach var of local numstr {
			capture confirm var `var'
			if _rc == 0 {
				destring `var', replace force
			} 
			else {
				di "`var' does not exist in `data_file'"
			}
		}
		foreach var of varlist othercpt* *cpt1 concpt* {
			destring `var', replace force
		}
	}

	// Replacing missing number values with proper missing value for Stata
	local numeric_variable_list height weight packs ///
		prsodm prbun prcreat pralbum prbili prsgot pralkph prwbc prhct prplate prptt prinr prpt ///
		yrdeath tothlos dsupinfec dwndinfd dorgspcssi ddehis ///
		doupneumo dreintub dpulembol dfailwean drenainsf doprenafl durninfec ///
		dcnscva dcdarrest dcdmi dothbleed dothdvt dothsysep ///
		dopertod doptodis dothcdiff ///
		pgy mallamp sdisdt hdisdt dsupinfec dwndinfd dcnscoma dneurodef ///
		dothgrafl dothseshock
			
	// Some variables are named similarly so we can set wildcard rules instead of manually typing their names as above.
	foreach var in *days* dpr* otherwrvu* conwrvu* {
		capture noisily {
			foreach var2 of varlist `var' {
				local numeric_variable_list `numeric_variable_list' `var2'
			}
		}
		if _rc != 0 {
			di "`var' does not exist in `data_file'"
		}
	}
	
	foreach var of local numeric_variable_list {
		capture confirm var `var'
		if _rc == 0 {
			capture {
				replace `var' = . if `var'==-99
			}
			if _rc != 0 {
				di "Variable: `var'"
			}
		} 
		else {
			di "`var' does not exist in `data_file'"
		}
	}
	capture mkdir cleaned
	save "./cleaned/cleaned_`data_file'", replace
}

clear all
local cleaned_files : dir "./cleaned" files "*.dta"
foreach cfile of local cleaned_files {
	di "`cfile'"
	quietly : {
		append using "./cleaned/`cfile'"
	}
}


capture mkdir merged
save "./merged/nsqip", replace

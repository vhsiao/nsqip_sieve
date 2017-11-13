/* 
	Merge data across all years into 1 dataset
*/

set more off
clear all

// Full data
// cd "/Volumes/Encrypted/NSQIP/Data/"

// Sample data
cd "/Volumes/Encrypted/NSQIP/Data/Samples"

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
	
	save, replace
}

clear all
foreach data_file of local files {
	di "`data_file'"
	quietly : {
		append using `data_file'
	}
	//describe, short
}

capture mkdir merged
save "./merged/nsqip", replace

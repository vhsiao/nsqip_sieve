clear all

// Full data
// cd "/Volumes/Encrypted/NSQIP/Data/Samples"

// Sample data
cd "/Volumes/Encrypted/NSQIP/Data/Samples"

// Summarizes data. Comment out to save time.
local files : dir . files "*.dta"
di `files'
foreach data_file of local files {
	use `data_file'
	describe, short
}

// Meeting these conditions
// Plastic Surgery cases only

// Pull data from years
// TODO

// Use these variables
// TODO

// Output to new data file
// TODO

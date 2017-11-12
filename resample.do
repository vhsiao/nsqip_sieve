clear all

local sample_num = 500 //Pull this many records from each file randomly
cd "/Volumes/Encrypted/NSQIP/Data"
local files : dir . files "*.dta"
di `files'
foreach data_file of local files {
	use `data_file'
	describe, short
	sample `sample_num', count
	save "./Samples/`sample_num'_`data_file'"
	clear all
}

cls
clear all
set more off

local excel_file `1'
local table_type `2'
local independent_var `3'
local dependent_var `4'

use "`excel_file'"

if table_type == "ttest" {
	// ttest `var', by(transgender_type)
	ttest `independent_var', by(`dependent_var')
}
else if table_type = "summarize" {
	// summarize `var'
	summarize `independent_var'
}
else if table_type = "chi2" {
	// tab `var' transgender_type if `var'<., chi2 exact row column
	tab `independent_var' `dependent_var' if `independent_var'<., chi2 exact row column
}
else {
	disp "Unrecognized table type"
}

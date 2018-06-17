/*
foreach var of varlist `complications' {
	disp "Variable: `independent_var'"
	do put_in_excel "`excel_file'" "complication" `complication_i' 1 "chi2" transgender_type `var'
	local complication_i = `complication_i' + 1
}
*/

quietly {
	local excel_file `1'
	local excel_sheet `2'
	local rownum `3'
	local colnum `4'
	local table_type `5'
	local dependent_var_list `6'
	local independent_var `7'
	local subgroup_var `8'
}

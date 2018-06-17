/*
foreach var of varlist `dependent_var_list' {
	disp "Variable: `independent_var'"
	do put_in_excel "`excel_file'" "complication" `i' 1 "chi2" transgender_type `var'
	local i = `i' + 1
}
*/

quietly {
	local excel_file `1'
	local excel_sheet `2'
	local rownum `3'
	local colnum `4'
	local table_type `5'
	local independent_var `6'
	local dependent_var_list `7'
	local subgroup_var `8'
	
	local i = `rownum'
	
	foreach var of varlist `dependent_var_list' {
		disp "Variable: `var'"
		do put_in_excel "`excel_file'" "`excel_sheet'" `i' 1 "`table_type'" `independent_var' `var'
		local i = `i' + 1
	}
}

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
	local independent_var_list `6'
	local dependent_var_list `7'
	local subgroup_var `8'
		
	local len_indep_var_list : word count `independent_var_list'
	local len_dep_var_list : word count `dependent_var_list'
	
	if `len_indep_var_list'==1 & `len_dep_var_list'==1 {
		local independent_var `independent_var_list'
		local dependent_var `dependent_var_list'
		do put_in_excel "`excel_file'" "`excel_sheet'" `rownum' 1 "`table_type'" `independent_var' `dependent_var' `subgroup_var'
	}
	else if `len_indep_var_list' == 1 {
		local independent_var `independent_var_list'
		local i = `rownum'
		foreach var of varlist `dependent_var_list' {
			disp "Variable: `var'"
			do put_in_excel "`excel_file'" "`excel_sheet'" `i' 1 "`table_type'" `independent_var' `var' `subgroup_var'
			local i = `i' + 1
		}
	}
	else if `len_dep_var_list' == 1 {
		local dependent_var `dependent_var_list'
		local i = `rownum'
		foreach var of varlist `independent_var_list' {
			disp "Variable: `var'"
			do put_in_excel "`excel_file'" "`excel_sheet'" `i' 1 "`table_type'" `var' `dependent_var' `subgroup_var'
			local i = `i' + 1
		}
	}
	else {
		display as error "Currently no support for lists of both dependent variables and independent variables. At least one must not be a list."
		exit
	}
}

set more off

noisily {

/* 
Runs statistical tests and writes results to excel file. 
excel_file: path to excel file to write to
excel_sheet: name of excel sheet within excel_file
rownum, colnum: entry at which result will be written. Both integers.
table_type: ttest, chi2, tab, logistic
independent_var: independent variable for analysis
dependent_var: dependent variable for analysis
row_label_spec: whether to label each entry by the independent or dependent variable.
subgroup_var: if specified, will run analysis only for those subjects where `subgroup_var' == 1

row_label_spec and subgroup_var are optional, but subgroup_var cannot be specified
 unless a value is given for row_label_spec. 

*/


	local excel_file `1'
	local excel_sheet `2'
	local rownum `3'
	local colnum `4'
	local table_type `5'
	local independent_var `6'
	local dependent_var `7'
	local row_label_spec `8'
	local subgroup_var `9'
	
	if ~missing("`row_label_spec'") & "`row_label_spec'"=="independent" {
		local row_label = "`: var label `independent_var''"
	} 
	else {
		local row_label = "`: var label `dependent_var''"
	}
	
	if ~missing("`subgroup_var'") & "`subgroup_var'"~="" {
		local subgroup_only = 1
	} 
	else {
		local subgroup_only = 0
	}

	putexcel set "`excel_file'", sheet("`excel_sheet'") modify
	
	if "`table_type'" == "ttest" {
		quietly {
			summarize `dependent_var'
			return list
			local overall_mean = r(mean)
			local overall_sd = r(sd)

			if `subgroup_only' {
				ttest `dependent_var' if `subgroup_var'==1, by(`independent_var')
			}
			else {
				ttest `dependent_var', by(`independent_var')
			}
			
			return list
			local observations = r(N_1) + r(N_2)
			
			local overall_mean : display %04.3f `overall_mean'
			local overall_sd : display %04.3f `overall_sd'
			local mu_1 : display %04.3f `r(mu_1)'
			local mu_2 : display %04.3f `r(mu_2)'
			local sd_1 : display %04.3f `r(sd_1)'
			local sd_2 : display %04.3f `r(sd_2)'
			local p : display %04.3f `r(p)'
			// Format: Depdendent variable	#obs Mean_all (SD_all) Mean1 (SD1) Mean2 (SD2) pval
			putexcel A`rownum'=("`row_label'") B`rownum'=("`observations'") C`rownum'=("`overall_mean' (`overall_sd')") D`rownum'=("`mu_1' (`sd_1')") E`rownum'=("`mu_2' (`sd_2')") F`rownum'=("`p'")
		
		}
	}
	else if "`table_type'" == "summarize" {
		quietly {
			if `subgroup_only' {
				summarize `independent_var' if `subgroup_var'==1
			}
			else {
				summarize `independent_var'
			}
			
			return list
			
			local mu : display %04.3f `r(mean)'
			local sd : display %04.3f `r(sd)'
			
			putexcel A`rownum'=("`row_label'") B`rownum'=("`r(N)'") C`rownum'=("`mu'") D`rownum'=("`sd'")
		}
	}
	else if "`table_type'" == "chi2" {
		// tab `var' transgender_type if `var'<., chi2 exact row column
		quietly {
			if `subgroup_only' {
				tab `dependent_var' `independent_var' if `dependent_var'<. & `subgroup_var'==1, chi2 exact row column matcell(freq)
			}
			else {
				tab `dependent_var' `independent_var' if `dependent_var'<., chi2 exact row column matcell(freq)
			}
			return list
			forvalues i=1/2 {
				local freq_val_`i' = freq[2,`i']
				local total_val_`i'= freq[1,`i'] + `freq_val_`i''
				local percent_val_`i' = `freq_val_`i''/`total_val_`i''  * 100 
				
				local total_val_`i' : display %04.3f `total_val_`i''
				local percent_val_`i' : display %04.3f `percent_val_`i''
			}
			local overall_freq_val = `freq_val_1' + `freq_val_2'
			local overall_percent_val = `overall_freq_val' / `r(N)' * 100
			
			local overall_percent_val : display %04.3f `overall_percent_val'
			
			local p : display %04.3f `r(p)'
			putexcel A`rownum'=("`row_label'") B`rownum'=(r(N)) C`rownum'=("`overall_freq_val' (`overall_percent_val'%)") D`rownum'=("`freq_val_1' (`percent_val_1'%)") E`rownum'=("`freq_val_2' (`percent_val_2'%)") F`rownum'=("`p'")
		}
	}
	else if "`table_type'" == "tab" {
		quietly {
			disp "dependent variable: `dependent_var'"
			disp "independent variable: `independent_var'"
			//tab `dependent_var' `independent_var' if `dependent_var'<., row column matcell(freq)
			
			if `subgroup_only' {
				tab `dependent_var' `independent_var' if `dependent_var'<. & `subgroup_var'==1, row column matcell(freq)
			}
			else {
				tab `dependent_var' `independent_var' if `dependent_var'<., row column matcell(freq)
			}
			return list
			matlist(freq)
			//matlist(names)
			// Get number of independent & dependent classes.
			putexcel A`rownum'=("`:var label `dependent_var''")
			putexcel B`rownum'=("`:var label `independent_var''")
			matrix V = J(`r(c)', 1, 1)
			matrix rowtotals = freq * V
			local col_last = 65 + `r(c)' + 1
			local col_last = "`=char(`col_last')'"
			putexcel `col_last'`rownum'=("Total")
			local row = `rownum' + 1
			forvalues j=1/`r(c)' {
				local col = 65 + `j' 
				local col = "`=char(`col')'"
				putexcel `col'`row'=("`: label `independent_var' `j''")
			}
			forvalues i=1/`r(r)' {
				local row = `rownum' + `i' + 1
				local row_sum = rowtotals[`i', 1]
				putexcel A`row'=("`: label `dependent_var' `i''")
				putexcel `col_last'`row'=("`row_sum' (100.00%)")
				forvalues j=1/`r(c)' {
					local col = 65 + `j'
					local col = "`=char(`col')'"
					local freq = freq[`i', `j']
					local perc = (`freq'/`row_sum') * 100
					local perc : display %04.3f `perc'
					putexcel `col'`row'=("`freq' (`perc'%)")
				}
			}
		}
	}
	else if "`table_type'" == "logistic" {
		noisily {
			if `subgroup_only' {
				logistic `dependent_var' `independent_var' if `subgroup_var'==1
			}
			else {
				logistic `dependent_var' `independent_var' 
			}
			else {
				return list
				matrix results = r(table)
				matlist(results)
				local or = results[1,1]
				local ll = results[5,1]
				local ul = results[6,1]
				local p = results[4,1]
				
				local or: display %04.3f `or'
				local ll: display %04.3f `ll'
				local ul: display %04.3f `ul'
				local p: display %04.3f `p'
				putexcel A`rownum'=("`row_label'") B`rownum'=("`or' (`ll'-`ul')") C`rownum'=("`p'")
			}
		}
	}
	else {
		disp "Unrecognized table type `table_type'"
	}
}

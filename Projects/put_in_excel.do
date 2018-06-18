set more off

quietly {
	local excel_file `1'
	local excel_sheet `2'
	local rownum `3'
	local colnum `4'
	local table_type `5'
	local independent_var `6'
	local dependent_var `7'
	local subgroup_var `8'
	local row_label `9'

	//use "`excel_file'"
	putexcel set "`excel_file'", sheet("`excel_sheet'") modify
	if missing(`row_label') {
	}
	
	if "`table_type'" == "ttest" {
		quietly {
			summarize `dependent_var'
			return list
			local overall_mean = r(mean)
			local overall_sd = r(sd)

			if ~missing("`subgroup_var'") {
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
			putexcel A`rownum'=("`: var label `dependent_var''") B`rownum'=("`observations'") C`rownum'=("`overall_mean' (`overall_sd')") D`rownum'=("`mu_1' (`sd_1')") E`rownum'=("`mu_2' (`sd_2')") F`rownum'=("`p'")
		
		}
	}
	else if "`table_type'" == "summarize" {
		quietly {
			if ~missing("`subgroup_var'") {
				summarize `independent_var' if `subgroup_var'==1
			}
			else {
				summarize `independent_var'
			}
			
			return list
			
			local mu : display %04.3f `r(mean)'
			local sd : display %04.3f `r(sd)'
			
			putexcel A`rownum'=("`: var label `independent_var''") B`rownum'=("`r(N)'") C`rownum'=("`mu'") D`rownum'=("`sd'")
		}
	}
	else if "`table_type'" == "chi2" {
		// tab `var' transgender_type if `var'<., chi2 exact row column
		quietly {
			//tab `dependent_var' `independent_var' if `dependent_var'<., chi2 exact row column matcell(freq)
			
			if ~missing("`subgroup_var'") {
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
			putexcel A`rownum'=("`: var label `dependent_var''") B`rownum'=(r(N)) C`rownum'=("`overall_freq_val' (`overall_percent_val'%)") D`rownum'=("`freq_val_1' (`percent_val_1'%)") E`rownum'=("`freq_val_2' (`percent_val_2'%)") F`rownum'=("`p'")
		}
	}
	else if "`table_type'" == "tab" {
		quietly {
			disp "dependent variable: `dependent_var'"
			disp "independent variable: `independent_var'"
			//tab `dependent_var' `independent_var' if `dependent_var'<., row column matcell(freq)
			
			if ~missing("`subgroup_var'") {
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
		// logistic any_complication `var'
		quietly {
			//capture logistic `independent_var' `dependent_var' 
			if ~missing("`subgroup_var'") {
				capture logistic `independent_var' `dependent_var' if `subgroup_var'==1
			}
			else {
				capture logistic `independent_var' `dependent_var' 
			}
			
			if _rc!=0 {
				putexcel A`rownum'=("`: var label `dependent_var''") B`rownum'=("Outcome does not vary") C`rownum'=("N/A")
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
				putexcel A`rownum'=("`: var label `dependent_var''") B`rownum'=("`or' (`ll'-`ul')") C`rownum'=("`p'")
			}
		}
	}
	else {
		disp "Unrecognized table type `table_type'"
	}
}

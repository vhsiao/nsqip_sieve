set more off

quietly {
	local excel_file `1'
	local excel_sheet `2'
	local rownum `3'
	local colnum `4'
	local table_type `5'
	local dependent_var `6'
	local independent_var `7'

	//use "`excel_file'"
	putexcel set "`excel_file'", sheet("`excel_sheet'") modify
	
	if "`table_type'" == "ttest" {
		// ttest `var', by(transgender_type)
		noisily {
			summarize `independent_var'
			return list
			local overall_mean = r(mean)
			local overall_sd = r(sd)

			ttest `independent_var', by(`dependent_var')
			return list
			local observations = r(N_1) + r(N_2)
			
			local overall_mean : display %03.2f `overall_mean'
			local overall_sd : display %03.2f `overall_sd'
			local mu_1 : display %03.2f `r(mu_1)'
			local mu_2 : display %03.2f `r(mu_2)'
			local sd_1 : display %03.2f `r(sd_1)'
			local sd_2 : display %03.2f `r(sd_2)'
			local p : display %03.2f `r(p)'
			putexcel A`rownum'=("`: var label `independent_var''") B`rownum'=("`observations'") C`rownum'=("Mean `overall_mean' (SD=`overall_sd')") D`rownum'=("Mean `mu_1' (SD=`sd_1')") E`rownum'=("Mean `mu_2' (SD=`sd_2')") F`rownum'=("`p'")
		
		}
	}
	else if "`table_type'" == "summarize" {
		noisily {
			summarize `dependent_var'
			return list
			
			local mu : display %03.2f `r(mean)'
			local sd : display %03.2f `r(sd)'
			
			putexcel A`rownum'=("`: var label `dependent_var''") B`rownum'=("`r(N)'") C`rownum'=("`mu'") D`rownum'=("`sd'")
		}
	}
	else if "`table_type'" == "chi2" {
		// tab `var' transgender_type if `var'<., chi2 exact row column
		noisily {
			tab `independent_var' `dependent_var' if `independent_var'<., chi2 exact row column matcell(freq)
			return list
			forvalues i=1/2 {
				local freq_val_`i' = freq[2,`i']
				local total_val_`i'= freq[1,`i'] + `freq_val_`i''
				//matlist(freq)
				//matlist(names)
				local percent_val_`i' = `freq_val_`i''/`total_val_`i''  * 100 
				
				local total_val_`i' : display %03.2f `total_val_`i''
				local percent_val_`i' : display %03.2f `percent_val_`i''
			}
			local overall_freq_val = `freq_val_1' + `freq_val_2'
			local overall_percent_val = `overall_freq_val' / `r(N)' * 100
			
			local overall_percent_val : display %03.2f `overall_percent_val'
			
			local p : display %03.2f `r(p)'
			putexcel A`rownum'=("`: var label `independent_var''") B`rownum'=(r(N)) C`rownum'=("`overall_freq_val' (`overall_percent_val'%)") D`rownum'=("`freq_val_1' (`percent_val_1'%)") E`rownum'=("`freq_val_2' (`percent_val_2'%)") F`rownum'=("`p'")
		}
	}
	else if "`table_type'" == "tab" {
		noisily {
			disp "Independent variable: `independent_var'"
			disp "Dependent variable: `dependent_var'"
			tab `independent_var' `dependent_var' if `independent_var'<., row column matcell(freq)
			return list
			matlist(freq)
			//matlist(names)
			// Get number of dependent and independent classes.
			putexcel A`rownum'=("`:var label `independent_var''")
			putexcel B`rownum'=("`:var label `dependent_var''")
			tab `independent_var' `dependent_var' if `independent_var'<., row column matcell(freq)
			matlist(freq)
			return list
			matrix V = J(`r(c)', 1, 1)
			matrix rowtotals = freq * V
			local col_last = 65 + `r(c)' + 1
			local col_last = "`=char(`col_last')'"
			putexcel `col_last'`rownum'=("Total")
			local row = `rownum' + 1
			forvalues j=1/`r(c)' {
				local col = 65 + `j' 
				local col = "`=char(`col')'"
				putexcel `col'`row'=("`: label `dependent_var' `j''")
			}
			forvalues i=1/`r(r)' {
				local row = `rownum' + `i' + 1
				local row_sum = rowtotals[`i', 1]
				putexcel A`row'=("`: label `independent_var' `i''")
				putexcel `col_last'`row'=("`row_sum' (100.00%)")
				forvalues j=1/`r(c)' {
					local col = 65 + `j'
					local col = "`=char(`col')'"
					local freq = freq[`i', `j']
					local perc = (`freq'/`row_sum') * 100
					local perc : display %03.2f `perc'
					putexcel `col'`row'=("`freq' (`perc'%)")
				}
			}
		}
	}
	else if "`table_type'" == "logistic" {
		// logistic any_complication `var'
		noisily {
			capture logistic `dependent_var' `independent_var' 
			if _rc!=0 {
				putexcel A`rownum'=("`: var label `independent_var''") B`rownum'=("Outcome does not vary") C`rownum'=("N/A")
			} 
			else {
				return list
				matrix results = r(table)
				matlist(results)
				local or = results[1,1]
				local ll = results[5,1]
				local ul = results[6,1]
				local p = results[4,1]
				
				local or: display %03.2f `or'
				local ll: display %03.2f `ll'
				local ul: display %03.2f `ul'
				local p: display %03.2f `p'
				putexcel A`rownum'=("`: var label `independent_var''") B`rownum'=("`or' (`ll'-`ul')") C`rownum'=("`p'")
			}
		}
	}
	else {
		disp "Unrecognized table type `table_type'"
	}
}

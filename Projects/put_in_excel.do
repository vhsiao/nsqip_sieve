set more off

quietly {
	local excel_file `1'
	local excel_sheet `2'
	local rownum `3'
	local table_type `4'
	local dependent_var `5'
	local independent_var `6'

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
			local p : display %03.2f `p'
			putexcel A`rownum'=("`independent_var'") B`rownum'=("`observations'") C`rownum'=("`overall_mean' (`overall_sd')") D`rownum'=("`mu_1' (`sd_1')") E`rownum'=("`mu_2' (`sd_2')") F`rownum'=("`p'")
		}
	}
	else if "`table_type'" == "summarize" {
		noisily {
			summarize `dependent_var'
			return list
			
			local mu : display %03.2f `r(mean)'
			local sd : display %03.2f `r(sd)'
			
			putexcel A`rownum'=("`dependent_var'") B`rownum'=("`r(N)'") C`rownum'=("`mu'") D`rownum'=("`sd'")
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
			putexcel A`rownum'=("`independent_var'") B`rownum'=(r(N)) C`rownum'=("`overall_freq_val' (`overall_percent_val'%)") D`rownum'=("`freq_val_1' (`percent_val_1'%)") E`rownum'=("`freq_val_2' (`percent_val_2'%)") F`rownum'=("`p'")
		}
	}
	else if "`table_type'" == "tab" {
		//tab `var' if `var' < ., sort
		noisily {
			tab `dependent_var' if `dependent_var'<., sort
			return list
			
		}
	}
	else if "`table_type'" == "logistic" {
		// logistic any_complication `var'
		noisily {
			capture noisily logistic `dependent_var' `independent_var'
			if _rc!=0 {
				putexcel A`rownum'=("`independent_var'") B`rownum'=("Outcome does not vary") C`rownum'=("N/A")
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
				putexcel A`rownum'=("`independent_var'") B`rownum'=("`or' (`ll'-`ul')") C`rownum'=("`p'")
			}
		}
	}
	else {
		noisily disp "Unrecognized table type" `table_type'
	}
}

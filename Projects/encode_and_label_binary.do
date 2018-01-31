local var `1'
local negative_value `2'
local var_label `3'

capture replace `var' = "" if `var'=="."
generate `var'_e = .
label variable `var'_e "`var_label'"
capture {
	replace `var'_e = 1 if `var'!="" & ~strpos(lower(`var'), "`negative_value'")
	replace `var'_e = 0 if `var'!="" & strpos(lower(`var'), "`negative_value'")
}

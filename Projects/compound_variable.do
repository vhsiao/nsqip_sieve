local compound_variable_name `1'
local component_variables `2'

egen `compound_variable_name' = rowtotal(`component_variables')
replace `compound_variable_name' = 1 if `compound_variable_name' > 0 & `compound_variable_name' < .

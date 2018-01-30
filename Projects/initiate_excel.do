set more off

local excel_file `1'
local excel_sheet `2'
local excel_sheet_headings `3'

putexcel set "`excel_file'", sheet("`excel_sheet'", replace) modify

local n_headings: word count "`excel_sheet_headings'"
di "`n_headings'"

local i = 1
foreach heading in `excel_sheet_headings' {
	di "`heading'"
	local j = 64 + `i'
	local col = "`=char(`j')'"
	putexcel `col'1=("`heading'")
	local i = `i' + 1
}

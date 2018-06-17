quietly: {
	ds, has(type string)
	foreach var of varlist `r(varlist)' {
		replace `var' = "." if `var'=="*ND"
		replace `var' = "." if `var'=="*NA"
		replace `var' = "." if `var'=="NA"
		replace `var' = "." if `var'=="DOA"
	}
}

encode Race, gen(race_num)
encode Sex, gen(sex_num)
encode InjMech, gen(injmech_num)

// Converting string data to numeric
foreach var of varlist BMI Heightin Weight ISS EDSBP ORVisits reason_for_or dpl_positive RBC1st24hrs {
	destring `var', replace float
}
replace EDSBP = . if EDSBP==0

// Generating new vars for reason for OR
generate reason_or_peritonitis = reason_for_or==1
generate reason_or_evisceration = reason_for_or==2
generate reason_or_hi = reason_for_or==3
generate reason_or_imaging_dpl = reason_for_or==4
generate reason_or_concerning_exam = reason_for_or==5


// Generate composite outcomes
generate gi_repair_resection = gi_repair==1 | gi_resection==1
generate solid_organ_injury = spleen_injury==1 | liver_injury==1 | kidney_injury==1
 
// Encoding obesity data
generate obese = BMI > 30 if BMI < .
label define obese 1 "obese", modify
label define obese 0 "nonobese", modify

// Recoding to White and Non-white
recode race_num (1/4=0)
recode race_num (5=1)
label define race_num 0 "Non-White", modify
label define race_num 1 "White", modify

// Recoding sex for logistic regression
recode sex_num (1=0)
recode sex_num (2=1)
label define sex_num 0 "Female", modify
label define sex_num 1 "Male", modify

// Recoding missing values for location_abdomen as non abdominal
foreach var of varlist location_abdomen sex_num race_num reason_or_peritonitis reason_or_evisceration reason_or_hi reason_or_imaging_dpl reason_or_concerning_exam SSI gi_injury gu_injury vascular_injury diaphragm_injury spleen_injury liver_injury kidney_injury need_for_reoperation traumaticherniarepair cholecystectomy mesentericomentalappendagere dpl dpl_positive ex_lap ex_lap_therapeutic died gi_resection gi_repair RBC1st24hrs number_OR_visits laparoscopy {
	recode `var' (.=0)
}

// Removing non-stab wounds, people without recorded BMI
drop if injmech_num != 1
drop if BMI == .

// Abdominal only from now on
drop if location_abdomen != 1

// Chi squared tests for categorical variables
// Logit regression on BMI
foreach var of varlist sex_num race_num location_abdomen {
	disp "`var'"
	//tab `var' obese, chi2 exact row column
	
}
foreach var of varlist Agey {
	disp "`var'"
	ttest `var', by(obese)
}

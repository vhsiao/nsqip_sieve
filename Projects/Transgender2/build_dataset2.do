use "/Volumes/Encrypted/NSQIP/Data/merged/nsqip.dta"
set more off
// Get just the trans data
/*
ICD-9
Non-specific code 302.5 Trans-sexualism
Specific code 302.50 Trans-sexualism with unspecified sexual history convert 302.50 to ICD-10-CM
Specific code 302.51 Trans-sexualism with asexual history convert 302.51 to ICD-10-CM
Specific code 302.52 Trans-sexualism with homosexual history convert 302.52 to ICD-10-CM
Specific code 302.53 Trans-sexualism with heterosexual history convert 302.53 to ICD-10-CM
Specific code 302.6 Gender identity disorder in children convert 302.6 to ICD-10-CM

302.85 Gender identity disorder in adolescents or adults convert 302.85 to ICD-10-CM

ICD-10
 F64 Gender identity disorders
 F64.0 Transsexualism
 xxxxx DO NOT INCLUDE F64.1 Dual role transvestism
 F64.2 Gender identity disorder of childhood
 F64.8 Other gender identity disorders
 F64.9 Gender identity disorder, unspecified
*/
keep if strpos(podiag_icd9, "302.5") | podiag_icd9=="302.85" | (podiag_icd9=="302.6") | (podiag_icd10=="F64.0") | (podiag_icd10=="F64.2") | (podiag_icd10=="F64.8") | (podiag_icd10=="F64.9")
count

// Get just the variables of interest
//keep caseid age sex race race_new prncptx cpt inout admyr pufyear surgspec attend pgy weight diabetes smoke packs etoh rbc asaclas steroid bleeddis optime totslos supinfec wndinfd orgspcssi dehis oupneumo pulembol podiag* returnor othdvt reoperation wound_closure

cd "/Volumes/Encrypted/NSQIP/Data/"
capture mkdir "Transgender2"
save "Transgender/transgender2.dta", replace

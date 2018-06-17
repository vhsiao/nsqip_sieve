use "/Volumes/Encrypted/NSQIP/Data/merged/nsqip.dta"
set more off
// Get just the burns data
/*
ICD-9
1st 2 digits: 94
3rd digit:
1 Head and neck
2 Trunk
3 Upper extremity excluding hand
4 Hand and digits
5 Lower extremity
6 Multiple sites

ICD-10
T20 Head, face and neck
T21 Trunk
T22 Shoulder, upper limb
T23 Wrist and Hand
T24 Lower limb except ankle and foot
T25 Ankle and foot
T26-28 Eye and adnexa

*/
keep if substr(podiag_icd9, 1, 2) == "94" | substr(podiag_icd10, 1, 2) == "T2"
count

// Get just the variables of interest
cd "/Volumes/Encrypted/NSQIP/Data/"
capture mkdir "Burn"
save "Burn/burn.dta", replace

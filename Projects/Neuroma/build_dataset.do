cls
clear all
set more off
use "/Volumes/Encrypted/NSQIP/Data/merged/nsqip.dta"

/*
CPT Codes
Implantation of nerve end into bone or muscle (list separately in addition to neuroma excision) (64787)
Excision of neuroma; cutaneous nerve, surgically identifiable (64774)
Excision of neuroma; digital nerve, one or both, same digit (64776)
Excision of neuroma; digital nerve, each additional digit (list separately by this number) (64778)
Excision of neuroma; hand or foot, except digital nerve (64782)
Excision of neuroma; hand or foot, each additional nerve, except same digit (list separately by this number) (64783)
Excision of neuroma; major peripheral nerve, except sciatic (64784)
*/

egen tmr_cpt = anymatch(cpt othercpt1 othercpt2 othercpt3 othercpt4 othercpt5 othercpt6 othercpt7 othercpt8 othercpt9 othercpt10 concpt1 concpt2 concpt3 concpt4 concpt5 concpt6 concpt7 concpt8 concpt9 concpt10 reoporcpt1 reopor2cpt1), values(64787 64774 64776 64778 64782 64783 64784)
drop if tmr_cpt==0

count

cd "/Volumes/Encrypted/NSQIP/Data/"
capture mkdir "Neuroma"
save "Neuroma/neuroma.dta", replace

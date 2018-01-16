cls
clear all
set more off
use "/Volumes/Encrypted/NSQIP/Data/merged/nsqip.dta"

// Get just the tendon repair data
/*
CPT Codes

1.	Flexor tendon repair or advancement, single, not in no mans land; primary or secondary without free graft, each tendon (26350)
2.	Flexor tendon repair or advancement, single, not in no mans land; secondary with free graft (includes obtaining graft), each (26352)
3.	Flexor tendon repair or advancement, single, in no mans land; primary, each tendon (26356)
4.	Flexor tendon repair or advancement, single, in no mans land; secondary, each tendon (26357)
5.	Flexor tendon repair or advancement, single, in no mans land secondary with free graft (includes obtaining graft), each (26358)
6.	Profundus tendon repair or advancement, with intact sublimis; primary (26370)
7.	Profundus tendon repair or advancement, with intact sublimis; secondary with free graft (includes obtaining graft) (26372)
8.	Profundus tendon repair or advancement, with intact sublimis; secondary without free graft (26373)
9.	Flexor tendon excision, implantation of plastic tube or rod for delayed tendon graft, hand or finger (26390)
10.	Removal of tube or rod and insertion of flexor tendon graft (includes obtaining graft), hand or finger (26392)
11.	Extensor tendon repair, dorsum of hand, single, primary or secondary; without free graft, each tendon (26410)
12.	Extensor tendon repair, dorsum of hand, single, primary or secondary; with free graft, (includes obtaining graft), each tendon (26412)
13.	Extensor tendon excision, implantation of plastic tube or rod for delayed extensor tendon graft, hand or finger (26415)
14.	Removal of tube or rod and insertion of extensor tendon graft (includes obtaining graft), hand or finger (26416)
15.	Extensor tendon repair, dorsum of finger, single, primary or secondary, without free graft, each tendon (26418)
16.	Extensor tendon repair, dorsum of finger, single, primary or secondary, with free graft, (includes obtaining graft) each tendon (26420)
17.	Extensor tendon repair, central slip repair, secondary (boutonniere deformity); using local tissues (26426)
18.	Extensor tendon repair, central slip repair, secondary (boutonniere deformity); with free graft (includes obtaining graft) (26428)
19.	Extensor tendon repair, distal insertion (mallet finger), closed, splinting with or without percutaneous pinning (26432)
*/

egen tendon_cpt = anyvalue(cpt), value(26350 26352 26356 26357 26358 26370 26372 26373 26390 26392 26410 26412 26415 26410 26412 26415 26416 26418 26420 26426 26428 26432)
drop if missing(tendon_cpt)

// keep if strpos(podiag_icd9, "302.5") | podiag_icd9=="302.85" | (podiag_icd9=="302.6") | strpos(podiag_icd10, "F64.")
count

// Get just the variables of interest
//keep caseid age sex race race_new prncptx cpt inout admyr pufyear surgspec attend pgy weight diabetes smoke packs etoh rbc asaclas steroid bleeddis optime totslos supinfec wndinfd orgspcssi dehis oupneumo pulembol podiag* returnor othdvt reoperation wound_closure

cd "/Volumes/Encrypted/NSQIP/Data/"
capture mkdir "TendonRepair"
save "TendonRepair/tendonrepair.dta", replace

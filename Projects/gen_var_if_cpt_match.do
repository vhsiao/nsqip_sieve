local match_name `1'
local cpt_list `2'
egen `match_name'_cpt = anymatch(cpt othercpt1 othercpt2 othercpt3 othercpt4 othercpt5 othercpt6 othercpt7 othercpt8 othercpt9 othercpt10 concpt1 concpt2 concpt3 concpt4 concpt5 concpt6 concpt7 concpt8 concpt9 concpt10 reoporcpt1 reopor2cpt1), values(cpt_list)
generate `match_name' = 0
replace `match_name' = 1 if skin_substitute_cpt > 0

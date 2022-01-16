**FILE 1: SCHOOL TESTING DATA, NO SUBJECTS

use "/Users/lacm/Documents/Stanford/EDS Seminar/EDS Group Project/Data/SEDA/School Level/School - Pooled - Cohort.dta"
rename tot_asmts total_math_reading_tests
rename sedasch school_id
rename sedaschname school_name

//learning rates, all subjects
rename cs_mn_grd_ol lr_all_ols
rename  cs_mn_grd_ol_se lr_se_all_ols
rename  cs_mn_grd_eb lr_all_bayes
rename  cs_mn_grd_eb_se lr_se_all_bayes

//achievement scores, all subjects
rename cs_mn_avg_ol achievement_all_ols
rename cs_mn_avg_ol_se achievement_se_all_ols

rename cs_mn_avg_eb achievement_all_bayes
rename cs_mn_avg_eb_se achievement_se_all_bayes


drop subcat subgroup cs_mn_coh_ol cs_mn_coh_ol_se cs_mn_coh_eb cs_mn_coh_eb_se cs_mn_mth_ol_se cs_mn_mth_ol cs_mn_mth_eb_se cs_mn_mth_eb fips stateabb gradecenter gap cellcount mn_asmts

tempfile schools
save `schools'
clear

**FILE 2: COVARIATES
use "/Users/lacm/Documents/Stanford/EDS Seminar/EDS Group Project/Data/SEDA/School Level/(COVARIATES) School - Pooled - Cohort.dta"

rename sedasch school_id
rename sedalea lea_id
rename schnam school_name
rename schcity city
rename stateabb state
rename mingrd min_grade
rename maxgrd max_grade
rename lep percent_ell
rename gifted_tot percent_gifted
rename disab_tot percent_disability
rename disab_tot_idea percent_disability_idea
rename avgrdall avg_grade_enrollment
rename totenrl total_enrollment
rename perasn percent_asian
rename perblk percent_black
rename perecd percent_ecd
rename perfl percent_fl
rename perfrl percent_frl
rename perhsp percent_hispanic
rename pernam percent_native_american
rename perrl percent_rl
rename perwht percent_white


**MERGING FILES
merge 1:1 school_id using `schools'
drop if _merge == 1
drop _merge

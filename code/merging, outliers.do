**PER PUPIL SPENDING DATA
import delimited "/Users/lacm/Documents/Stanford/EDS Seminar/EDS Group Project/Data/per_pupil_spending.csv", delimiter(comma) bindquote(strict) varnames(1) stringcols(1) 
replace per_pupil_exp = "" if per_pupil_exp =="NA"
destring per_pupil_exp , force replace
tempfile perpupil
save `perpupil'
clear

**STUDENT/TEACHER RATIO
import delimited "/Users/lacm/Documents/Stanford/EDS Seminar/EDS Group Project/Data/student_teacher_ratio.csv", delimiter(comma) bindquote(strict) varnames(1) stringcols(1) 
tempfile teacherratio
save `teacherratio'
clear

**SEDA DATA
import delimited "/Users/lacm/Documents/Stanford/EDS Seminar/EDS Group Project/Data/SEDA/District Level/(CLEANED) Wide District - Cohort - All Subjects - Covariates.csv", delimiter(comma) bindquote(strict) varnames(1) stringcols(1) 
tempfile seda
save `seda'

**MERGING ALL 3 DATASETS
merge 1:1 leaid using `teacherratio'
keep if _merge == 3
drop _merge
merge 1:1 leaid using `perpupil'
keep if _merge == 3
drop _merge

tempfile merged
save `merged'
clear

**DISCIPLINE DATA CLEANING 
import delimited "/Users/lacm/Documents/Stanford/EDS Seminar/EDS Group Project/Data/disc_data_by_percent (1).csv", delimiter(comma) bindquote(strict) varnames(1) 
drop v1
replace students_susp_in_sch = "" if students_susp_in_sch == "NA"
replace students_susp_out_sch_single = "" if students_susp_out_sch_single == "NA"
replace students_susp_out_sch_multiple = "" if students_susp_out_sch_multiple == "NA"
replace expulsions_no_ed_serv = "" if expulsions_no_ed_serv == "NA"
replace expulsions_with_ed_serv = "" if expulsions_with_ed_serv == "NA"
replace expulsions_zero_tolerance = "" if expulsions_zero_tolerance == "NA"
replace students_arrested = "" if students_arrested == "NA"
replace total_enrollment_by_race = "" if total_enrollment_by_race == "NA"
replace percentage_students_susp_in_sch = "" if percentage_students_susp_in_sch == "NA"
destring students_susp_in_sch, force replace
destring students_susp_out_sch_single, force replace
destring students_susp_out_sch_multiple, force replace
destring expulsions_no_ed_serv, force replace
destring expulsions_with_ed_serv, force replace
destring expulsions_zero_tolerance, force replace
destring students_arrested, force replace
destring total_enrollment_by_race, force replace
destring percentage_students_susp_in_sch, force replace
tostring race, force replace
replace race = "_white" if race == "1"
replace race = "_black" if race == "2"
replace race = "_hispanic" if race == "3"
drop percentage_students_susp_in_sch 
collapse (sum) students_susp_in_sch students_susp_out_sch_single students_susp_out_sch_multiple expulsions_no_ed_serv expulsions_with_ed_serv expulsions_zero_tolerance students_arrested total_enrollment_by_race, by(leaid race )
rename students_susp_out_sch_single students_ooss_single
rename students_susp_out_sch_multiple students_ooss_multiple
rename expulsions_zero_tolerance expulsions_no_tol
rename total_enrollment_by_race enrollment
reshape wide students_susp_in_sch students_ooss_single students_ooss_multiple expulsions_no_ed_serv expulsions_with_ed_serv expulsions_no_tol students_arrested enrollment, i(leaid ) j(race)s
gen pct_stu_iss_black = students_susp_in_sch_black/enrollment_black *100
gen pct_students_ooss_single_black = students_ooss_single_black/enrollment_black *100
gen pct_students_ooss_multiple_black= students_ooss_multiple_black/enrollment_black *100
gen pct_expulsions_no_ed_serv_black= expulsions_no_ed_serv_black/enrollment_black *100
gen pct_expulsions_with_ed_black= expulsions_with_ed_serv_black/enrollment_black *100
gen pct_expulsions_no_tol_black= expulsions_no_tol_black/enrollment_black *100
gen pct_students_arrested_black= students_arrested_black/enrollment_black *100
gen pct_students_ooss_single_hsp = students_ooss_single_hispanic/enrollment_hispanic *100
gen pct_students_ooss_multiple_hsp= students_ooss_multiple_hispanic/enrollment_hispanic *100
gen pct_expulsions_no_ed_serv_hsp= expulsions_no_ed_serv_hispanic/enrollment_hispanic *100
gen pct_expulsions_with_ed_hsp= expulsions_with_ed_serv_hispanic/enrollment_hispanic *100
gen pct_expulsions_no_tol_hsp= expulsions_no_tol_hispanic/enrollment_hispanic *100
gen pct_students_arrested_hsp= students_arrested_hispanic/enrollment_hispanic *100
gen pct_students_ooss_single_white = students_ooss_single_white/enrollment_white *100
gen pct_students_ooss_multiple_white= students_ooss_multiple_white/enrollment_white *100
gen pct_expulsions_with_ed_white= expulsions_with_ed_serv_white/enrollment_white *100
gen pct_expulsions_no_tol_white= expulsions_no_tol_white/enrollment_white *100
gen pct_students_arrested_white= students_arrested_white/enrollment_white *100
drop students_susp_in_sch_black students_ooss_single_black students_ooss_multiple_black expulsions_no_ed_serv_black expulsions_with_ed_serv_black expulsions_no_tol_black students_arrested_black enrollment_black students_susp_in_sch_hispanic students_ooss_single_hispanic students_ooss_multiple_hispanic expulsions_no_ed_serv_hispanic expulsions_with_ed_serv_hispanic expulsions_no_tol_hispanic students_arrested_hispanic enrollment_hispanic students_susp_in_sch_white students_ooss_single_white students_ooss_multiple_white expulsions_no_ed_serv_white expulsions_with_ed_serv_white expulsions_no_tol_white students_arrested_white enrollment_white

tempfile discipline
save `discipline'
clear



**MERGING MERGED DOC WITH DISCIPLINE
use `merged'
merge 1:1 leaid using `discipline'
keep if _merge == 3
drop _merge

**OUTLIERS
summarize per_pupil_exp student_teacher_ratio,d 
extremes per_pupil_exp 
extremes student_teacher_ratio 

qui regress lr_math_ols_wbg per_pupil_exp 
predict residual_studentized, rstudent
gen residual_studentized_abs = abs(residual_studentized)
gsort -residual_studentized_abs 
count if residual_studentized_abs > 2 & !mi(residual_studentized) & !mi(lr_all_ols_whg) & !mi(per_pupil_exp )
list leaid lea_name per_pupil_exp residual_studentized_abs if residual_studentized_abs > 2 & !mi(residual_studentized) & !mi(lr_all_ols_whg) & !mi(per_pupil_exp )

gsort -per_pupil_exp 
browse leaid lea_name per_pupil_exp 
//values above the 99th percentile
gen outlier = 1 if per_pupil_exp > 42398.02

gsort -student_teacher_ratio 
browse leaid lea_name student_teacher_ratio 
//values above the 99th percentile
replace outlier = 1 if student_teacher_ratio > 21.37301 
replace outlier = 0 if mi(outlier)

gsort -outlier -per_pupil_exp -student_teacher_ratio
tab outlier
browse leaid lea_name state outlier per_pupil_exp student_teacher_ratio  



save "/Users/lacm/Documents/Stanford/EDS Seminar/EDS Group Project/Data/merged data.dta", replace
export delimited using "/Users/lacm/Documents/Stanford/EDS Seminar/EDS Group Project/Data/merged data.csv", replace

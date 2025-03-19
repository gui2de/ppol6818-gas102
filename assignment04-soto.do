if c(username)=="jacob" {
	
	global wd "C:\Users\jacob\OneDrive\Desktop\PPOL_6818"
}

if c(username)=="gabos" { //this would be your username on your computer
	
	global wd "C:\Users\gabos\OneDrive - Georgetown University\Spring 2025\exp\" //this would your ppol_6818 folder address
}
********************************************************************************
* PPOL 6818: Assignment 04 
* asdf
* Gabriel Soto 
* March 15th, 2025
********************************************************************************

/*******************************************************************************
Question 1.
*******************************************************************************/
/*
As part of a larger examination of how various factors contribute to student achievement, you have been asked to find a couple of pieces of information about a school district. Unfortunately, the relevant data is

*/ 

*setting up the directories

global student "$wd\week_05\03_assignment\01_data\q1_psle_student_raw.dta"
clear
use "$student", clear

*splitting raw HTML data into student entries based on the closing table cell/row tags

split s, parse("</TD></TR>") gen(temp_var)

*removing original HTML column and first empty split result
drop s temp_var1

*creating unique id 
gen id = _n

//as I was having issues with the Temp file folder because of the large dataset being processed, it was better to sleep the process to give time stata
set more off
quietly {
    reshape long temp_var, i(id) j(var_num)
    sleep 500  // 500 millisecond pause
}

*cleanup temp reshap vars
drop id var_num
*removing empty entries
drop if temp_var == ""

*split entries into individual columns col
split temp_var, parse("</TD>") gen(col)

*extract school code with regex
gen school_code = ""
replace school_code = regexs(1) if regexm(col1, "([A-Z0-9]+)-[0-9]+")

drop if school_code == ""

*extract candidate id, number, gender, name through regex
gen candidate_id = regexs(2) if regexm(col1, "([A-Z0-9]+)-([0-9]+)")
replace candidate_id = regexs(2) if regexm(col1, "([A-Z0-9]+)-([0-9]+)")
gen student_number = regexs(0) if regexm(col2, "[0-9]{10,12}")
gen gender = regexs(0) if regexm(col3, "(?<=>)(M|F|Male|Female)(?=<)")
gen full_name = regexs(0) if regexm(col4, "(?<=<P>)([^<]+)(?=</FONT>)")

*extract subject scores from 5th column
gen subject_scores = regexs(0) if regexm(col5, "(?<=>K)(.*?)(?=</FONT>)")

*cleaning up whitespace
replace subject_scores = trim(subject_scores)

*splitting subjekcj scores into individual subjects
split subject_scores, parse(", ") gen(subj)

*create id per observation for reshaping
gen obs_id = _n

*reshaping to long formate for subject-grade processing
reshape long subj, i(obs_id) j(subject_count)

*split subject-grade pairs into components
split subj, parse("- ") gen(subj_clean)

*create subjet name and grade variables
gen subject_name = trim(subj_clean1)
gen subject_grade = trim(subj_clean2)

*cleanup
drop subj subj_clean1 subj_clean2 subject_count
drop if subject_name == "" | subject_name == "."

*convert subject name to numeric codes
encode subject_name, gen(subject_code)
drop subject_name

*reshape to wide formate for final structure
reshape wide subject_grade, i(obs_id) j(subject_code)

*renaming
rename subject_grade1 total_avg
rename subject_grade2 eng_score
rename subject_grade3 math_score
rename subject_grade4 kiswahili_score
rename subject_grade5 knowledge_score
rename subject_grade6 science_score
rename subject_grade7 civics_score

*cleanup and ordering
drop obs_id
drop school_code
order schoolcode candidate_id gender student_number full_name kiswahili_score eng_score knowledge_score math_score science_score civics_score total_avg

drop temp_var col1 col2 col3 col4 col5 subject_scores






/*******************************************************************************
Question 2.
*******************************************************************************/
/*
As part of a larger examination of how various factors contribute to student achievement, you have been asked to find a couple of pieces of information about a school district. Unfortunately, the relevant data is

*/ 

*setting up the directories

global civ "$wd\week_05\03_assignment\01_data\q2_CIV_Section_0.dta"
global excel "$wd\week_05\03_assignment\01_data\q2_CIV_populationdensity.xlsx"
clear
use "$civ", clear
import excel using "$excel", sheet("Population density") firstrow clear

*kepping only department-level entries (exclude districts/regions)
keep if !regexm(NOMCIRCONSCRIPTION, "DISTRICT|REGION|DEPARTEMENT") 
drop SUPERFICIEKM2 POPULATION
collapse (mean) pop_density = DENSITEAUKM, by(NOMCIRCONSCRIPTION)
rename NOMCIRCONSCRIPTION department

replace department = ustrnormalize(department, "nfd")  // Remove accents
replace department = ustrregexra(department, "\p{Mark}", "")  // Strip diacritics
replace department = lower(strtrim(stritrim(department)))  // Lowercase + trim
replace department = subinstr(department, "'", "", .)  // Remove apostrophes
//replace department = subinstr(department, " ", "", .)  // Remove all spaces

save "$wd/CIV_pop_density_clean.dta", replace

use "$wd/CIV_pop_density_clean.dta", clear


use "$civ", clear
* Decode numeric department variable to string
decode b07_souspref, gen(department)

replace department = lower(strtrim(stritrim(department)))  // Ensure consistency
replace department = ustrnormalize(department, "nfd")  // Remove accents
replace department = ustrregexra(department, "\p{Mark}", "")  // Strip diacritics
replace department = lower(strtrim(stritrim(department)))  // Lowercase + trim
replace department = subinstr(department, "'", "", .)  // Remove apostrophes
//replace department = subinstr(department, " ", "", .)  // Remove all spaces

merge m:1 department using "$wd/CIV_pop_density_clean.dta"


* Check results
tab _merge
keep if _merge == 3
drop _merge





/*******************************************************************************
Question 3.
*******************************************************************************/
/*
As part of a larger examination of how various factors contribute to student achievement, you have been asked to find a couple of pieces of information about a school district. Unfortunately, the relevant data is

*/ 

*setting up the directories
clear
global gps "$wd\week_05\03_assignment\01_data\q3_GPS Data.dta"
use "$gps", clear

*households are now ordered geographically
sort latitude longitude  


local n_enum = 19
local n_hh = _N          
local base = floor(`n_hh'/`n_enum') 
local remainder = `n_hh' - `base' * `n_enum' 

gen enum_id = .
local counter = 1

forvalues i = 1/`n_enum' {
    local this_size = `base' + (`i' <= `remainder')  
    forvalues j = 1/`this_size' {
        if `counter' > `n_hh' continue, break  
        replace enum_id = `i' in `counter'
        local counter = `counter' + 1
    }
}

//other way I was thinking was using kmeans clusters
/*
*standardize coordinates for clustering
egen std_lat = std(latitude)
egen std_lon = std(longitude)

*performing k-means clustering into 19 groups
cluster kmeans std_lat std_lon, k(19) gen(enum_id)


*assigning enumerator IDs (1-19)
replace enum_id = enum_id + 1
*/

/*******************************************************************************
Question 4.
*******************************************************************************/
/*
As part of a larger examination of how various factors contribute to student achievement, you have been asked to find a couple of pieces of information about a school district. Unfortunately, the relevant data is

*/ 
global election "$wd\week_05\03_assignment\01_data\q4_Tz_election_2010_raw.xls"
global template "$wd\week_05\03_assignment\01_data\q4_Tz_election_template.dta"
//use "$template", clear
clear
import excel using "$election", clear
//import excel using "$election", sheet("Sheet1") firstrow clear
rename A REGION
rename B district
rename C costituency
rename D Ward 
rename E CandidateName
rename F Sex
rename H party
rename I votes
rename J Elected
drop K G
drop if CandidateName ==""
drop if CandidateName == "CANDIDATE NAME"
replace Sex = "F" if Sex ==""
replace Elected = "NOT ELECTED" if Elected ==""

//populating each empty region/ward until hits differently one
replace REGION = REGION[_n-1] if REGION == ""
replace district = district[_n-1] if district == ""
replace costituency = costituency[_n-1] if costituency == ""
replace Ward = Ward[_n-1] if Ward == ""

egen ward_id = group(REGION district Ward)
bysort ward_id: gen candidate_num = _n
bysort ward_id: egen total_candidates = max(candidate_num)
fillin party ward_id
gsort ward_id -REGION

replace REGION = REGION[_n-1] if REGION == ""
replace district = district[_n-1] if district == ""
replace costituency = costituency[_n-1] if costituency == ""
replace Ward = Ward[_n-1] if Ward == ""

replace votes = "0" if votes == "UN OPPOSSED"
destring votes, gen(Votes)
drop votes
rename Votes votes  

bysort ward_id: gen rank = _n
drop _fillin CandidateName Sex Elected candidate_num
sort ward_i party

reshape wide party total_candidates votes, i(ward_id) j(rank)
egen totalvotes = rowtotal(votes*)


local parties AFP APPT_MAENDELEO CCM CHADEMA CHAUSTA CUF DP JAHAZIASILIA MAKIN NCCRMAGEUZI NLD NRA SAU TADEA TLP UDP UMD UPDP

foreach p of local parties {
    gen votes`p' = .
}

forvalues i=1/18 {
	replace votesAFP = votes`i' if party`i' == "AFP"
	replace votesAPPT_MAENDELEO = votes`i' if party`i' == "APPT - MAENDELEO"
	replace votesCCM = votes`i' if party`i' == "CCM"
	replace votesCHADEMA = votes`i' if party`i' == "CHADEMA"
	replace votesCHAUSTA = votes`i' if party`i' == "CHAUSTA"
	replace votesCUF = votes`i' if party`i' == "CUF"
	replace votesDP = votes`i' if party`i' == "DP"
	replace votesJAHAZIASILIA = votes`i' if party`i' == "JAHAZI ASILIA"
	replace votesMAKIN = votes`i' if party`i' == "MAKIN"
	replace votesNCCRMAGEUZI = votes`i' if party`i' == "NCCR-MAGEUZI"
	replace votesNLD = votes`i' if party`i' == "NLD"
	replace votesNRA = votes`i' if party`i' == "NRA"
	replace votesSAU = votes`i' if party`i' == "SAU"
	replace votesTADEA = votes`i' if party`i' == "TADEA"
	replace votesTLP = votes`i' if party`i' == "TLP"
	replace votesUDP = votes`i' if party`i' ==  "UDP"
	replace votesUMD = votes`i' if party`i' == "UMD"
	replace votesUPDP = votes`i' if party`i' == "UPDP"	
}

drop total_candidates* 
drop party* votes*

/*******************************************************************************
Question 5.
*******************************************************************************/
/*
As part of a larger examination of how various factors contribute to student achievement, you have been asked to find a couple of pieces of information about a school district. Unfortunately, the relevant data is

*/
clear
global psle "$wd\week_05\03_assignment\01_data\q5_psle_2020_data.dta"
global location "$wd\week_05\03_assignment\01_data\q5_school_location.dta"

* Process first dataset

tempfile data_location
use "$location", clear 
rename NECTACentreNo school_center
drop if school_center == "n/a" 
duplicates drop school_center, force
save `data_location'
 
use "$psle", clear 
//parsing school code address
split school_code_address, parse(_)
split school_code_address2, parse(.) 
replace school_code_address21 = strupper(school_code_address21)
rename school_code_address21 school_center 
drop school_code_address22 school_code_address2 school_code_address1
merge 1:1 school_center using `data_location'
drop if _merge==2

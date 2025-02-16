if c(username)=="jacob" {
	
	global wd "C:\Users\jacob\OneDrive\Desktop\PPOL_6818"
}

if c(username)=="gabriel" { //this would be your username on your computer
	
	global wd "C:\Users\gabos\OneDrive - Georgetown University\Spring 2025\exp\canvas-export/" //this would your ppol_6818 folder address
}
********************************************************************************
* PPOL 6818: Assignment 03 
* asdf
* Gabriel Soto 
* Feb 10th, 2025
********************************************************************************

/*******************************************************************************
Question 1.
*******************************************************************************/
/*
As part of a larger examination of how various factors contribute to student achievement, you have been asked to find a couple of pieces of information about a school district. Unfortunately, the relevant data is spread across four different files (student.dta, teacher.dta, school.dta, and subject.dta all in the following subfolder: q1_data. See the readme file for more details regarding each dataset

	(a) What is the mean attendance of students at southern schools?
	(b) Of all students in high school, what proportion of them have a primary teacher who teaches a tested subject?
	(c) What is the mean gpa of all students in the district?
	(d) What is the mean attendance of each middle school? 

*/ 

*setting up the directories

global q1_school "$wd\week_03\04_assignment\01_data\q1_data\school.dta"

global q2_village "$wd\week_03\04_assignment\01_data\q2_village_pixel.dta"

global q3_proposal "$wd\week_03\04_assignment\01_data\q3_proposal_review.dta"

global student "$wd/week_03/04_assignment/01_data/q1_data/student"
global subject "$wd/week_03/04_assignment/01_data/q1_data/subject"
global teacher "$wd/week_03/04_assignment/01_data/q1_data/teacher"
clear
*a.
use "$student", clear
rename primary_teacher teacher
merge m:1 teacher using "$teacher", generate(merge_teacher)
merge m:1 school using "$q1_school", generate(merge_school)
codebook attendance if loc == "South"

*b.
merge m:1 subject using "$subject", generate(merge_subject) 
tab tested

*c.
codebook gpa

*d.
tabstat attendance if level == "Middle", by(school) stat(mean)			  


/*******************************************************************************
Question 2.
*******************************************************************************/

/* 
You are working on a crop insurance project in Kenya. For each household, we have the following information: village name, pixel and payout status.
	a)	Payout variable should be consistent within a pixel, confirm if that is the case. Create a new dummy variable (pixel_consistent), this variable =0 if payout variable isn't consistent within that pixel (i.e. =1 when all the payouts are exactly the same, =0 if there is even a single different payout in the pixel) 
	b)	Usually the households in a particular village are within the same pixel but it is possible that some villages are in multiple pixels (boundary cases). Create a new dummy variable (pixel_village), =0 for the entire village when all the households from the village are within a particular pixel, =1 if households from a particular village are in more than 1 pixel. Hint: This variable is at village level.
	c)	For this experiment, it is only an issue if villages are in different pixels AND have different payout status. For this purpose, divide the households in the following three categories:
		i.	Villages that are entirely in a particular pixel. (==1)
		ii.	Villages that are in different pixels AND have same payout status (Create a list of all hhids in such villages) (==2)
		iii.	Villages that are in different pixels AND have different payout status (==3)

Hint: These 3 categories are mutually exclusive AND exhaustive i.e. every single observation should fall in one of the 3 categories. Note also that the categories may or may not line up with what you created in (a) and (b) so read the instructions closely.

*/

*a.
use "$q2_village", clear
browse

*check if payout 1 or 0 is consistent within pixels, visual examination
tab2 pixel payout

*getting the minimum value of payout for each group and doing this for each pixel and sorting
bysort pixel: egen min_payout = min(payout)

*getting the maximum value of payout for each pixel group and sorting it
bysort pixel: egen max_payout = max(payout)

*creating dummy variable which evaluates if min and max are the same. If same, then 1, if not 0.
gen pixel_consistent = (min_payout == max_payout)
*dropping variables max and min
drop min_payout max_payout

*counting the amount of records and tabulating to confirm all are consistent
count
tabulate pixel_consistent

*b.
*first validating that an specific village, can be seen in several pixels. Visual examination
bysort village: tab pixel

*we create the tag variable, using the tag function which takes village and pixel. What it will do is that it will tag with 1, a new combination of village and pixel
egen tag = tag(village pixel)

*then by village, we count the number of pixels they appear on (counting tag).
bysort village: egen num_pixels = total(tag)

*then we create the pixel_village variable, where if the number of pixels is creater than 1(meaning village is in more that 1 pixel), pixel_village is 1.
gen pixel_village = (num_pixels > 1)

*dropping the variable num_pixels
drop tag num_pixels

*showing results
tab pixel_village 
list village pixel  if pixel_village == 1

*c.

*by village, we create with egen, min and max payouth flag variable. If values of the variables are the same, they have the same payout within the village.
bysort village: egen min_vil_payout = min(payout)
bysort village: egen max_vil_payout = max(payout)

*creating variable category with empty.
*we replace the values depending on the conditions
gen category = .
replace category = 1 if pixel_village == 0
replace category = 2 if pixel_village == 1 & min_vil_payout == max_vil_payout
replace category = 3 if pixel_village == 1 & min_vil_payout != max_vil_payout

*dropping max,min variables
drop max_vil_payout min_vil_payout
tabulate category


/*******************************************************************************
Question 3.
*******************************************************************************/

/*
Faculty members submitted 128 proposals for funding opportunities. Unfortunately, we only have enough funding for 50 grants. Each proposal was assigned randomly to three selected reviewers who each gave a score between 1 (lowest) and 5 (highest). Each person reviewed 24 proposals and assigned a score. We think it will be better if we normalize the score wrt each reviewer (using unique ids) before calculating the average score. Add the following columns 1) stand_r1_score 2) stand_r2_score 3) stand_r3_score 4) average_stand_score 5) rank (Note: highest score =>1, lowest => 128)

Hint: We can normalize scores using the following formula: (score – mean)/sd, where mean = mean score of that particular reviewer (based on the netid), sd = standard deviation of scores of that particular reviewer (based on that netid). (Hint: we are not standardizing the score wrt reviewer 1, 2 or 3. But by the netID.)

*/


use "$q3_proposal", clear
browse

*renaming the column, so it is similar format as the other columns
rename Rewiewer1 Reviewer1
rename Review1Score ReviewerScore1
rename Reviewer2Score ReviewerScore2
rename Reviewer3Score ReviewerScore3 


*reshaping the dataset from wide to long format, where each row will now be a separation for each reviewer per proposal.
reshape long Reviewer ReviewerScore, i(proposal_id) j(reviewer_num)

*by Reviewer create each reviwere level mean and sd
bysort Reviewer: egen reviewer_mean = mean(ReviewerScore)
bysort Reviewer: egen reviewer_sd = sd(ReviewerScore)

*Per proposal-reviwere, generateign a standard score, 
gen stand_score = (ReviewerScore - reviewer_mean) / reviewer_sd

*reshaping to wide formatting so we can have now the proposal level data with each reviewer normalized
reshape wide Reviewer ReviewerScore reviewer_mean reviewer_sd stand_score, i(proposal_id) j(reviewer_num)

*using normalized reviewers values, generating avg normalized score 
egen average_stand_score = rowmean(stand_score1 stand_score2 stand_score3)

*sorting descending using avg normalized score and creating rank variable
gsort -average_stand_score
gen rank = _n

*listing first 50 proposals with its avg score, avg normalized score 
list proposal_id AverageScore average_stand_score rank in 1/50


/*******************************************************************************
Question 4.
*******************************************************************************/

/*
We have the information of adults that have computerized national ID card in the following pdf: Pakistan_district_table21.pdf. This pdf has 135 tables (one for each district). We extracted data through an OCR software but unfortunately it wasn't very accurate. We need to extract column 2-13 from the first row ("18 and above") from each table. Create a dataset where each row contains information for a particular district. The hint do file contains the code to loop through each sheet, you need to find a way to align the columns correctly.

Hint: While the formatting is mostly regular, there are a couple of (pretty minor) anomalies so be sure to look at what your code produces.
*/

global excel_t21 "$wd//week_03/04_assignment/01_data/q4_Pakistan_district_table21.xlsx"

clear
tempfile table21
save `table21', replace emptyok

*extract 135 tables from excel sheet
forvalues i=1/135 {
	import excel "$excel_t21", sheet("Table `i'") firstrow clear allstring //import
	display as error `i' //display the loop number

	keep if regexm(TABLE21PAKISTANICITIZEN1, "18 AND" )==1 //keep only those rows that have "18 AND"
	*I'm using regex because the following code won't work if there are any trailing/leading blanks
	*keep if TABLE21PAKISTANICITIZEN1== "18 AND" 
	keep in 1 //there are 3 of them, but we want the first one
	rename TABLE21PAKISTANICITIZEN1 table21
	
*now we drop columns with empty values
	foreach x of varlist * {
		count if `x' == ""
		 if `r(N)' !=0 { 
				drop `x'
		 }
	}
	
*now we standardize the column names with a local var across all sheets
	local col = 1
	foreach x of varlist * { 
		rename `x' column_`col'
		local col = `col' + 1
	}
	
	gen table=`i' //to keep track of the sheet we imported the data from
	append using `table21' 
	save `table21', replace //saving the tempfile so that we don't lose any data
}

*cleaning variables with - on them, mostly strngs. 
foreach x of varlist column_* {
    // Replace dashes and blanks with "0"
    replace `x' = "0" if `x' == "" | strpos(`x', "-") > 0  
    // Extract the part before the dash (if needed)
    replace `x' = substr(`x', 1, strpos(`x', "-") - 1) if strpos(`x', "-") > 0
}

*formatting column* like columns
format %40s column_* 

*renaming and sorting 
replace column_1 = table
drop table
rename column_1 Table_Number
destring Table_Number, replace
gsort Table_Number                 


exit
/*******************************************************************************
Question 5.
*******************************************************************************/

/*
This task involves string cleaning and data wrangling. We scraped data for a school from a Tanzanian government website. Unfortunately, the formatting of the data is a mess. Your task is to extract the following school level variables: 

1) number of students that took the test, 
2) school average 
3) student group (binary, either under 40 or >=40  
4) school ranking in council (22 out of 46) 
5) school ranking in the region (74 out of 290)
6) school ranking at the national level (545 out of 5664) level dataset with the following variables. 

In addition to these variables, also capture the school name and school code in two different columns. Note: This is a school level dataset, and should only contain one row with all the variables. All the school level information is given at the top of this webpage. The page is in Swahili but it should be fairly straightforward to find the relevant information. You can use google translate if you have trouble finding the relevant parts of the webpage. 
*/

global q5_tanzania "$wd/week_03/04_assignment/01_data/q5_Tz_student_roster_html"
use "$q5_tanzania", clear

split s, parse(:)

*extracting number of students
rename s2 number_students
split number_students, parse(<)
replace number_students = number_students1
destring number_students, replace


*extracting school size
rename s3 school_average
split school_average, parse(<)
replace school_average = school_average1
destring school_average, replace

*getting the group size
split s4
split s44, parse(<)
destring s441, replace
rename s441 size
gen groupsize = 0
replace groupsize = 1 if size >= 40

*getting the council rnak
rename s5 councilrank_string
split councilrank_string
split councilrank_string4, parse(<)
destring councilrank_string41, replace
local rank = councilrank_string1
local outof = councilrank_string41
gen councilrank = "`rank' out of `outof'"
split councilrank, parse(<)
replace councilrank = councilrank1

*getting regional rank 
rename s6 regionrank_string
split regionrank_string
split regionrank_string4, parse(<)
destring regionrank_string41, replace
local rank = regionrank_string1
local outof = regionrank_string41
gen regionrank = "`rank' out of `outof'"

*creating national rank
rename s7 natrank_string
split natrank_string, limit (5)
split natrank_string4, parse(<)
destring natrank_string41, replace
local rank = natrank_string1
local outof = natrank_string41 
gen national_rank = "`rank' out of `outof'"

*extracting school name 
rename s r
 split r, parse(>) limit(16)
 rename r15 school
 split school, parse (-) generate (schoolname)
 
 foreach x of varlist schoolname* {
	if strpos(`x', "PS") > 0 {
		rename `x' theschoolname
 }
 }
 split theschoolname, parse (<) generate (theschoolnum)
 split theschoolnum1, parse(PS)
 destring theschoolnum12, replace
 tostring theschoolnum12, replace
 local schoolnum = theschoolnum12
 replace theschoolnum1 = "PS`schoolnum'"
 rename schoolname1 schoolname
 rename theschoolnum1 schoolcode
 
keep r number_students school_average groupsize councilrank regionrank national_rank schoolname schoolcode


rename r s

/*******************************************************************************
Bonus question
*******************************************************************************/

/*
This task involves string cleaning and data wrangling. We scrapped student data for a school from a Tanzanian government website. Unfortunately, the formatting of the data is a mess. Your task is to create a student level dataset with the following variables: schoolcode, cand_id, gender, prem_number, name, grade variables for: Kiswahili, English, maarifa, hisabati, science, uraia, average. Note: This is a school level dataset, and should have 16 rows (same as the number of students in that school).
Hint: you can get a better view of the string if you go to the website and view its source (which can be done by right clicking or hitting ctrl/command+U).
*/
//code





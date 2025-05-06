if c(username)=="jacob" {
	
	global wd "C:\Users\jacob\OneDrive\Desktop\PPOL_6818"
}

if c(username)=="gabos" { //this would be your username on your computer
	
	global wd "C:\Users\gabos\OneDrive - Georgetown University\Spring 2025\exp\" //this would your ppol_6818 folder address
}
********************************************************************************
* PPOL 6818: Assignment 05 
* asdf
* Gabriel Soto 
* March 27th, 2025
********************************************************************************

/*******************************************************************************
Question 1.
*******************************************************************************/
/*
As part of a larger examination of how various factors contribute to student achievement, you have been asked to find a couple of pieces of information about a school district. Unfortunately, the relevant data is

*/ 

*creating population
clear
set seed 4040  
set obs 10000   


gen rand = runiform()
gen treatment = (rand < 0.5)


local mean1 = 100   
local mean2 = 110   
local stand_dev = 10    


gen dep_var = rnormal(`mean1', `stand_dev') if treatment == 0
replace dep_var = rnormal(`mean2', `stand_dev') if treatment == 1

save "population_fx.dta", replace

*capturing/creating a program of regression
capture program drop smpl_regression
program define smpl_regression, rclass
    args N  

    use "population_fx.dta", clear  
    sample `N', count  

    regress dep_var treatment
	
    mat a = r(table)

    
    return scalar N = `N'
	*coefficient beta
    return scalar beta = a[1,1]
	*std error
    return scalar sem = a[2,1]   
    return scalar p_value = a[4,1]  
    return scalar confidence_low= a[5,1]
    return scalar confidence_up = a[6,1]
end

*test
smpl_regression 100
return list

*simulating for different n values
clear
set seed 4040

local reps 500
local number_list 10 100 1000 10000

foreach N in `number_list' {
    display "Simulating for sample of size -> `N'"

    simulate N=r(N) beta=r(beta) sem=r(sem) p_value=r(p_value) /// 
        confidence_low=r(confidence_low) confidence_up=r(confidence_up), reps(`reps'): ///
        smpl_regression `N'

    save "sample_`N'_simulation.dta", replace  
}

*sumarrizing graph results
clear
set more off

use "sample_10_simulation.dta", clear
append using "sample_100_simulation.dta"
append using "sample_1000_simulation.dta"
append using "sample_10000_simulation.dta"

save "complete_results.dta", replace

use "complete_results.dta", clear 

collapse (mean) beta sem confidence_low confidence_up, by(N)
list  

rename beta beta_part1
rename sem sem_part1
rename confidence_low confidence_low_p1
rename confidence_up confidence_up_p1

*saving summary
save summary_p1.dta, replace
	
*for sample of size N = 10
use "sample_10_simulation.dta", clear
histogram beta, bin(30) normal ///
    title("N = 10") xtitle("Beta") name(h10, replace)

*for sample of size N = 100
use "sample_100_simulation.dta", clear
histogram beta, bin(30) normal ///
    title("N = 100") xtitle("Beta") name(h100, replace)

*for sample of size N = 1000
use "sample_1000_simulation.dta", clear
histogram beta, bin(30) normal ///
    title("N = 1000") xtitle("Beta") name(h1000, replace)

*for sample of size N = 10000
use "sample_10000_simulation.dta", clear
histogram beta, bin(30) normal ///
    title("N = 10000") xtitle("Beta") name(h10000, replace)
	
graph combine h10 h100 h1000 h10000, ///
    title("Estimates for Beta for Different Sample Sizes") ///
    cols(2)

save "results_final.dta", replace

/*******************************************************************************
Question 2.
*******************************************************************************/
/*
As part of a larger examination of how various factors contribute to student achievement, you have been asked to find a couple of pieces of information about a school district. Unfortunately, the relevant data is

*/ 

clear
capture program drop population_infinite
program define population_infinite, rclass
    args N

    clear
    set obs `N'

    gen rand = runiform()
    gen treatment = (rand < 0.5)

    local mean1 = 100
    local mean2 = 110
    local stand_dev = 10

    gen dep_var = rnormal(`mean1', `stand_dev') if treatment == 0
    replace dep_var = rnormal(`mean2', `stand_dev') if treatment == 1

    regress dep_var treatment

    mat a = r(table)

    return scalar N = `N'
    return scalar beta = a[1,1]
    return scalar sem = a[2,1]
    return scalar p_value = a[4,1]
    return scalar confidence_low = a[5,1]
    return scalar confidence_up = a[6,1]
end

*rnning simulations
clear
set more off
set seed 4041

local reps 500
local powers2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152
local powers10 10 100 1000 10000 100000 1000000
local all_N `powers2' `powers10'

foreach N of local all_N {
    simulate N=r(N) beta=r(beta) sem=r(sem) p_value=r(p_value) ///
        confidence_low=r(confidence_low) confidence_up=r(confidence_up), reps(`reps') nodots: ///
        population_infinite `N'

    save "simulation_results_for_`N'2.dta", replace
}

*combining sumarizing
clear
use "simulation_results_for_42.dta", clear
foreach N in 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 10 100 1000 10000 100000 1000000 {
    append using "simulation_results_for_`N'2.dta"
}
save "complete_results2.dta", replace

collapse (mean) beta sem confidence_low confidence_up, by(N)
rename beta beta_part2
rename sem sem_part2
rename confidence_low confidence_low_p2
rename confidence_up confidence_up_p2

save summary_p2.dta, replace
export excel using "summary_p2.xlsx", firstrow(variables) replace

*create graph
label define Nlbl ///
    1 "4" 2 "8" 3 "16" 4 "32" 5 "64" 6 "128" 7 "256" 8 "512" 9 "1024" ///
    10 "2048" 11 "4096" 12 "8192" 13 "16384" 14 "32768" 15 "65536" ///
    16 "131072" 17 "262144" 18 "524288" 19 "1048576" 20 "2097152" ///
    21 "10" 22 "100" 23 "1000" 24 "10000" 25 "100000" 26 "1000000"

gen x = _n
label values x Nlbl

twoway ///
    (rcap confidence_up confidence_low x, color(gs8)) ///
    (bar beta x, barwidth(0.5) color(blue)), ///
    title("Estimates of Beta with Confidence of 95%, Size (N)") ///
    xtitle("Sample N") ytitle("Beta Estimate") ///
    xlabel(1(1)26, valuelabel angle(45)) ///
    legend(off)

*both parts analysis

use "summary_p1.dta", clear
collapse (mean) beta sem confidence_low confidence_up, by(N)
gen source = "Part1"
save "summary_part1.dta", replace

use "summary_p2.dta", clear
collapse (mean) beta sem confidence_low confidence_up, by(N)
gen source = "Part2"
save "summary_part2.dta", replace

use "summary_part1.dta", clear
append using "summary_part2.dta"
sort N source
save "comparison_summary.dta", replace

rename beta_part1 beta
rename beta_part2 beta

gen beta_all = beta
replace beta_all = beta_part2 if missing(beta_all)

gen sem_all = sem_part1
replace sem_all = sem_part2 if missing(sem_all)

gen confidence_low_all = confidence_low_p1
replace confidence_low_all = confidence_low_p2 if missing(confidence_low_all)

gen confidence_up_all = confidence_up_p1 
replace confidence_up_all = confidence_up_p2 if missing(confidence_up_all)

drop beta sem_part1 confidence_low_p1 confidence_up_p1 beta_part2 sem_part2 confidence_low_p2 confidence_up_p2 

graph bar beta_all if inlist(N, 10, 100, 1000, 10000, 100000, 1000000), ///
    over(source) over(N, label(angle(0))) ///
    bar(1, color(blue)) bar(2, color(gs12)) ///
    legend(label(1 "Part 1") label(2 "Part 2")) ///
    title("Mean Estimates of Beta for Key Sample Sizes") ///
    ytitle("Mean for Estimate Beta")
	
twoway (line sem_all N if source == "Part1", lcolor(blue) lpattern(solid)) ///
       (line sem_all N if source == "Part2", lcolor(red) lpattern(dash)), ///
       legend(label(1 "Part 1") label(2 "Part 2")) ///
       title("Standard Error by Sample Size") ///
       xlabel(10 100 1000 10000 100000 1000000, angle(0)) ///
       ytitle("Standard Error Mean") xtitle("Sample Size") xscale(log)

graph bar sem_all if inlist(N, 10, 100, 1000, 10000, 100000, 1000000), ///
    over(source) over(N, label(angle(0))) ///
    bar(1, color(navy)) bar(2, color(maroon)) ///
    legend(label(1 "Part 1") label(2 "Part 2")) ///
    title("Standard Error Mean for Sample Sizes") ///
    ytitle("Standard Error Mean")
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
**generating the data
clear
set seed 4040
set obs 1000 

*treatment assignment, half 50%
gen treatment = runiform() < 0.5

*create individual treatment effects (uniform 0-0.2 SD)
gen te = treatment * runiform(0, 0.2)

*create Y (normal with SD=1 + treatment effect)
gen y = rnormal(0, 1) + te


*now calculating sample size to get 80% Power
power twomeans 0 0.1, sd(1) power(0.8)
local n_initial = r(N)
display "Required sample size: `n_initial'"


*now assuming attrition of 15%
local n_attrition = ceil(`n_initial' / (1 - 0.15))
display "Adjusted sample size (15% attrition): `n_attrition'"


*now assuming only 30% of sample can be treated

power twomeans 0 0.1, sd(1) power(0.8) nratio(0.3/0.7)
local n_unequal = r(N)
display "Required sample size (30% treated): `n_unequal'"

**graphing the above
matrix results = J(3, 2, .) 
matrix colnames results = "Scenario" "Sample_Size"
matrix rownames results = "Original" "15%_Attrition" "30%_Treated"

matrix results[1,1] = 1
matrix results[1,2] = `n_initial'   
matrix results[2,1] = 2
matrix results[2,2] = `n_attrition' 
matrix results[3,1] = 3
matrix results[3,2] = `n_unequal'   

*create stata matrix dataset
clear
svmat results, names(col)
label define scenario 1 "Original" 2 "15% Attrition" 3 "30% Treated"
label values Scenario scenario

*bar graph
#delimit ;
graph bar (asis) Sample_Size,
  over(Scenario, label(angle(45)))
  ytitle("Required Sample Size")
  title("Sample Size for 80% Power Under Different Scenarios")
  blabel(bar, format(%5.0f))
  scheme(s1color)
  name(bar_graph, replace);
#delimit cr

*create powercurve
local effect_size 0.1
local alpha 0.05
local power_target 0.8

range n 1000 5000 50 
gen power = .

quietly {
  forval i = 1/`=_N' {
    local ni = n[`i']
    power twomeans 0 `effect_size', sd(1) n(`ni')
    replace power = r(power) in `i'
  }
}

#delimit ;
line power n,
  xline(`n_initial', lpattern(dash) lcolor(red))
  yline(`power_target', lpattern(dash) lcolor(blue))
  xtitle("Sample Size")
  ytitle("Power")
  title("Power vs. Sample Size (ATE = 0.1 SD)")
  legend(off)
  scheme(s1color)
  name(power_curve, replace);
#delimit cr

*show table
list Scenario Sample_Size, separator(0) noobs

/*******************************************************************************
Question 2.
*******************************************************************************/
/*
As part of a larger examination of how various factors contribute to student achievement, you have been asked to find a couple of pieces of information about a school district. Unfortunately, the relevant data is

*/ 
* 1. Data Generating Process 
version 17
clear all
set more off
set seed 4040

program define school_intervention, rclass
    syntax, schools(integer) students_per_school(integer)
    
    *initialize dataset
    clear
    set obs `= `schools' * `students_per_school''
    
    *school identification system
    gen school_code = ceil(_n / `students_per_school')
    
    *intervention assignment process
    preserve
        bysort school_code: keep if _n == 1
        gen random_sort = runiform()
        tempfile school_assignments
        save `school_assignments'
    restore
    
    merge m:1 school_code using `school_assignments', nogen
    
    *balanced group assignment
    gen intervention_group = 0
    qui {
        gsort random_sort
        replace intervention_group = 1 in 1/`= floor(_N/2)'
    }
    
    *variance components setup (ICC = 0.25)
    scalar school_variance = sqrt(0.25)
    scalar student_variance = sqrt(0.75)
    
    *school-level characteristics
    gen school_impact = .
    qui forvalues s = 1/`schools' {
        local school_effect = rnormal(0, school_variance)
        replace school_impact = `school_effect' if school_code == `s'
    }
    
    *student-level components
    gen individual_variation = rnormal(0, student_variance)
    
    *treatment effect implementation
    gen intervention_effect = intervention_group * runiform(0.15, 0.25)
    
    *academic performance outcome
    gen academic_performance = 50 + 0.2 * intervention_group + school_impact + individual_variation + rnormal(0, 0.1)
    
    *intervention impact analysis
    reg academic_performance intervention_group
    return scalar p_value = 2 * (1 - normal(abs(_b[intervention_group]/_se[intervention_group])))
end

*power analysis by insitution
tempfile power_analysis
save `power_analysis', replace emptyok

local institution_sizes 1 2 4 8 16 32 64 128 256 512

foreach size of local institution_sizes {
    display "Analyzing institution size: `size'..."
    
    clear
    simulate analysis_p=r(p_value), reps(100): ///
        school_intervention, schools(200) students_per_school(`size')
    
    *calculate power metrics
    sum analysis_p
    local mean_p = r(mean)
    
    clear
    set obs 1
    gen institution_size = `size'
    gen power_metric = `mean_p'
    
    append using `power_analysis'
    save `power_analysis', replace
}

*projections
*initialize results matrix
matrix resource_matrix = J(2, 3, .)
matrix colnames resource_matrix = "Case" "Total_Institutions" "Institutions_Per_Condition"
matrix rownames resource_matrix = "Full_Implementation" "Partial_Implementation"

* 6. Complete Adoption Scenario
power twomeans 0 0.2, cluster m1(15) m2(15) rho(0.25) power(0.8)
matrix resource_matrix[1,1] = 1
matrix resource_matrix[1,2] = r(N)
matrix resource_matrix[1,3] = ceil(r(N)/2)

* 7. Partial Adoption Scenario (70% Compliance)
power twomeans 0 0.14, cluster m1(15) m2(15) rho(0.25) power(0.8)
matrix resource_matrix[2,1] = 2
matrix resource_matrix[2,2] = r(N)
matrix resource_matrix[2,3] = ceil(r(N)/2)

clear
svmat resource_matrix, names(col)
label define case_labels 1 "Full Implementation" 2 "Partial Implementation (70%)"
label values Case case_labels

list Case Total_Institutions Institutions_Per_Condition, noobs sep(0)

/*******************************************************************************
Question 3.
*******************************************************************************/

clear all
set seed 4040

*data generation process
clear
set obs 10000

*create strata groups
gen strata = ceil(5*runiform())

*generate covariates
gen confounder = rnormal()   
gen outcome_only = rnormal() 
gen treatment_only = rnormal() 

*treatment assignment model
gen treatment_prob = 0.4*confounder + 0.7*treatment_only
gen treatment = runiform() < treatment_prob

*outcome model with true TE = 0.5
gen outcome = 0.5*treatment + 0.8*confounder + 0.3*outcome_only + strata + rnormal(0,1)

save "analysis_data.dta", replace

*regression models 
capture program drop run_models
program define run_models, rclass
    syntax, n(integer)
    
    use "analysis_data.dta", clear
    sample `n', count
    
    * Model 1: Naive
    reg outcome treatment
    return scalar b1 = _b[treatment]
    return scalar ci_low1 = _b[treatment] - 1.96*_se[treatment]
    return scalar ci_high1 = _b[treatment] + 1.96*_se[treatment]
    
    * Model 2: + Confounder
    reg outcome treatment confounder
    return scalar b2 = _b[treatment]
    return scalar ci_low2 = _b[treatment] - 1.96*_se[treatment]
    return scalar ci_high2 = _b[treatment] + 1.96*_se[treatment]
    
    * Model 3: + Outcome-only
    reg outcome treatment confounder outcome_only
    return scalar b3 = _b[treatment]
    return scalar ci_low3 = _b[treatment] - 1.96*_se[treatment]
    return scalar ci_high3 = _b[treatment] + 1.96*_se[treatment]
    
    * Model 4: Fixed Effects
    areg outcome treatment confounder outcome_only, absorb(strata)
    return scalar b4 = _b[treatment]
    return scalar ci_low4 = _b[treatment] - 1.96*_se[treatment]
    return scalar ci_high4 = _b[treatment] + 1.96*_se[treatment]
    
    * Model 5: Full Model
    areg outcome treatment confounder outcome_only treatment_only, absorb(strata)
    return scalar b5 = _b[treatment]
    return scalar ci_low5 = _b[treatment] - 1.96*_se[treatment]
    return scalar ci_high5 = _b[treatment] + 1.96*_se[treatment]
end

*simulations
tempfile results
local sizes 100 250 500 1000 5000 10000

clear
save `results', replace emptyok

foreach N of local sizes {
    di "Processing N = `N'"
    
    simulate b1=r(b1) ci_low1=r(ci_low1) ci_high1=r(ci_high1) ///
             b2=r(b2) ci_low2=r(ci_low2) ci_high2=r(ci_high2) ///
             b3=r(b3) ci_low3=r(ci_low3) ci_high3=r(ci_high3) ///
             b4=r(b4) ci_low4=r(ci_low4) ci_high4=r(ci_high4) ///
             b5=r(b5) ci_low5=r(ci_low5) ci_high5=r(ci_high5), ///
             reps(100): run_models, n(`N')
    
    gen N = `N'
    append using `results'
    save `results', replace
}

*visualizing
use `results', clear

collapse (mean) b* ci_*, by(N)
reshape long b ci_low ci_high, i(N) j(model)
label define models 1 "Naive" 2 "+Confounder" 3 "+Outcome Control" 4 "+FE" 5 "Full Model"
label values model models
twoway (connected b N if model==1, lcolor(red)) ///
       (connected b N if model==2, lcolor(blue)) ///
       (connected b N if model==3, lcolor(green)) ///
       (connected b N if model==4, lcolor(purple)) ///
       (connected b N if model==5, lcolor(orange)) ///
       (function y=0.5, range(100 10000) lcolor(black) lpattern(dash)), ///
       legend(order(1 "Naive" 2 "+Confounder" 3 "+Outcome Control" ///
       4 "+FE" 5 "Full Model" 6 "True Effect")) ///
       xtitle("Sample Size") ytitle("Treatment Effect") ///
       title("Estimate Convergence Across Models") ///
       name(convergence, replace)

preserve
collapse (mean) b ci_low ci_high, by(model)

twoway (rcap ci_low ci_high model, lcolor(gs10)) ///
       (scatter b model, mcolor(navy)), ///
       xlabel(1(1)5, valuelabel angle(45)) ///
       ytitle("Treatment Effect") ///
       title("Model Comparison: Point Estimates and CIs") ///
       legend(off) name(model_compare, replace)
restore

graph export "convergence_plot.png", replace
graph export "model_comparison.png", replace
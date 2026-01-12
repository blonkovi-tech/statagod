/*==============================================================================
  Visualization Script for Hypothesis Testing Results
  
  This script creates publication-quality visualizations comparing effects
  of nwspol and pstplonl on vote and ac_index across different ages.
==============================================================================*/

clear all
set more off

* Ensure coefplot is installed
* ssc install coefplot, replace

/*==============================================================================
  PART 1: Marginal Effects Plots by Age
  
  These plots show how effects vary with age for H3c
==============================================================================*/

* Load your dataset and run the models
* do "hypothesis_testing.do"

* Set graph scheme for consistent appearance
set scheme s2color

*------------------------------------------------------------------------------
* Combined plot: nwspol effects on both outcomes by age
*------------------------------------------------------------------------------

* For vote
quietly logit vote c.nwspol##c.age c.pstplonl##c.age
margins, dydx(nwspol) at(age=(20(5)70)) atmeans
matrix vote_nwspol = r(table)

* For ac_index (using P(ac_index=4))
quietly ologit ac_index c.nwspol##c.age c.pstplonl##c.age
margins, dydx(nwspol) at(age=(20(5)70)) predict(outcome(4)) atmeans
matrix ac_nwspol = r(table)

* Create combined plot
marginsplot, ///
    title("Effect of News Consumption by Age and Outcome") ///
    ytitle("Marginal Effect") ///
    xtitle("Age") ///
    note("Vote: Binary outcome; AC_Index: P(highest activism level)")
graph export "nwspol_comparison_by_age.png", replace

*------------------------------------------------------------------------------
* Combined plot: pstplonl effects on both outcomes by age
*------------------------------------------------------------------------------

* For vote
quietly logit vote c.nwspol##c.age c.pstplonl##c.age
margins, dydx(pstplonl) at(age=(20(5)70)) atmeans
matrix vote_pstplonl = r(table)

* For ac_index
quietly ologit ac_index c.nwspol##c.age c.pstplonl##c.age
margins, dydx(pstplonl) at(age=(20(5)70)) predict(outcome(4)) atmeans
matrix ac_pstplonl = r(table)

marginsplot, ///
    title("Effect of Online Posting by Age and Outcome") ///
    ytitle("Marginal Effect") ///
    xtitle("Age") ///
    note("Vote: Binary outcome; AC_Index: P(highest activism level)")
graph export "pstplonl_comparison_by_age.png", replace

/*==============================================================================
  PART 2: Coefficient Plots
  
  Compare standardized coefficients across models
==============================================================================*/

*------------------------------------------------------------------------------
* Coefficient plot comparing models
*------------------------------------------------------------------------------

* Standardize variables
foreach var of varlist nwspol pstplonl age {
    quietly egen z_`var' = std(`var')
}

* Estimate models
quietly reg vote c.z_nwspol c.z_pstplonl c.z_age
estimates store vote_std

quietly reg ac_index c.z_nwspol c.z_pstplonl c.z_age
estimates store ac_std

* Create coefficient plot
coefplot vote_std ac_std, ///
    keep(z_nwspol z_pstplonl z_age) ///
    xline(0) ///
    legend(order(1 "Vote" 2 "AC_Index")) ///
    title("Standardized Coefficients Comparison") ///
    subtitle("Effects on Vote vs. Activism Index") ///
    note("All variables standardized for comparison")
graph export "coefficients_comparison.png", replace

*------------------------------------------------------------------------------
* Coefficient plot with interactions
*------------------------------------------------------------------------------

quietly reg vote c.z_nwspol##c.z_age c.z_pstplonl##c.z_age
estimates store vote_int

quietly reg ac_index c.z_nwspol##c.z_age c.z_pstplonl##c.z_age
estimates store ac_int

coefplot vote_int ac_int, ///
    keep(z_nwspol z_pstplonl c.z_nwspol#c.z_age c.z_pstplonl#c.z_age) ///
    xline(0) ///
    legend(order(1 "Vote" 2 "AC_Index")) ///
    title("Model Comparison with Age Interactions") ///
    subtitle("Main Effects and Moderation by Age") ///
    coeflabels(z_nwspol = "News Consumption" ///
               z_pstplonl = "Online Posting" ///
               c.z_nwspol#c.z_age = "News × Age" ///
               c.z_pstplonl#c.z_age = "Posting × Age")
graph export "coefficients_interactions.png", replace

/*==============================================================================
  PART 3: Predicted Probabilities
  
  Show predicted outcomes at different levels of predictors
==============================================================================*/

*------------------------------------------------------------------------------
* Predicted probability plots for vote
*------------------------------------------------------------------------------

* Using original (non-standardized) models
quietly logit vote c.nwspol##c.age c.pstplonl##c.age

* Predict vote probability by nwspol at different ages
margins, at(nwspol=(0(1)10) age=(25 45 65)) atmeans
marginsplot, ///
    title("Predicted Probability of Voting by News Consumption") ///
    ytitle("Pr(Vote = 1)") ///
    xtitle("News Consumption") ///
    legend(order(1 "Age 25" 2 "Age 45" 3 "Age 65"))
graph export "vote_prob_nwspol.png", replace

* Predict vote probability by pstplonl at different ages
margins, at(pstplonl=(0(1)10) age=(25 45 65)) atmeans
marginsplot, ///
    title("Predicted Probability of Voting by Online Posting") ///
    ytitle("Pr(Vote = 1)") ///
    xtitle("Online Posting Frequency") ///
    legend(order(1 "Age 25" 2 "Age 45" 3 "Age 65"))
graph export "vote_prob_pstplonl.png", replace

*------------------------------------------------------------------------------
* Predicted probability plots for ac_index
*------------------------------------------------------------------------------

quietly ologit ac_index c.nwspol##c.age c.pstplonl##c.age

* Predict P(ac_index=4) by nwspol at different ages
margins, at(nwspol=(0(1)10) age=(25 45 65)) predict(outcome(4)) atmeans
marginsplot, ///
    title("Predicted Probability of High Activism by News Consumption") ///
    ytitle("Pr(AC_Index = 4)") ///
    xtitle("News Consumption") ///
    legend(order(1 "Age 25" 2 "Age 45" 3 "Age 65"))
graph export "ac_prob_nwspol.png", replace

* Predict P(ac_index=4) by pstplonl at different ages
margins, at(pstplonl=(0(1)10) age=(25 45 65)) predict(outcome(4)) atmeans
marginsplot, ///
    title("Predicted Probability of High Activism by Online Posting") ///
    ytitle("Pr(AC_Index = 4)") ///
    xtitle("Online Posting Frequency") ///
    legend(order(1 "Age 25" 2 "Age 45" 3 "Age 65"))
graph export "ac_prob_pstplonl.png", replace

/*==============================================================================
  PART 4: Distribution Visualizations
==============================================================================*/

*------------------------------------------------------------------------------
* Bar chart of ac_index distribution
*------------------------------------------------------------------------------

graph bar (count), over(ac_index) ///
    title("Distribution of Activism Index") ///
    ytitle("Frequency") ///
    blabel(bar, format(%9.0f))
graph export "ac_index_distribution.png", replace

*------------------------------------------------------------------------------
* Stacked bar chart: ac_index by vote
*------------------------------------------------------------------------------

graph bar (count), over(ac_index) over(vote) ///
    title("Activism Index by Voting Status") ///
    ytitle("Frequency") ///
    legend(order(1 "Non-voters" 2 "Voters"))
graph export "ac_index_by_vote.png", replace

/*==============================================================================
  PART 5: Effect Size Comparison Visualization
  
  Direct visual comparison for H3a and H3b
==============================================================================*/

*------------------------------------------------------------------------------
* Create a summary plot showing key comparisons
*------------------------------------------------------------------------------

* Extract standardized coefficients
quietly reg vote c.z_nwspol c.z_pstplonl c.z_age
matrix vote_coef = e(b)

quietly reg ac_index c.z_nwspol c.z_pstplonl c.z_age  
matrix ac_coef = e(b)

* Create custom comparison plot
preserve
clear
set obs 4

gen outcome = ""
gen predictor = ""
gen coefficient = .
gen se = .

* Fill in values (adjust based on actual results)
* Row 1: nwspol on vote
replace outcome = "Vote" in 1
replace predictor = "News Consumption" in 1
replace coefficient = vote_coef[1,1] in 1

* Row 2: nwspol on ac_index
replace outcome = "Activism" in 2
replace predictor = "News Consumption" in 2
replace coefficient = ac_coef[1,1] in 2

* Row 3: pstplonl on vote
replace outcome = "Vote" in 3
replace predictor = "Online Posting" in 3
replace coefficient = vote_coef[1,2] in 3

* Row 4: pstplonl on ac_index
replace outcome = "Activism" in 4
replace predictor = "Online Posting" in 4
replace coefficient = ac_coef[1,2] in 4

* Generate effect labels for H3a and H3b
gen h3a = (predictor == "News Consumption")
gen h3b = (predictor == "Online Posting")

* Create comparison chart
graph bar coefficient, over(outcome) over(predictor) ///
    asyvars ///
    title("Effect Size Comparison") ///
    subtitle("Standardized Coefficients") ///
    ytitle("Coefficient") ///
    note("H3a: News stronger on Vote than Activism" ///
         "H3b: Posting stronger on Activism than Vote") ///
    legend(order(1 "Vote" 2 "Activism"))
graph export "hypothesis_comparison.png", replace

restore

/*==============================================================================
  PART 6: Summary Statistics Table Visualization
==============================================================================*/

* Create a visual summary of descriptive statistics
graph hbox vote ac_index nwspol pstplonl age, ///
    title("Distribution of Key Variables") ///
    note("Box plots showing median, quartiles, and outliers")
graph export "descriptives_boxplot.png", replace

di "=========================================="
di "All visualizations have been created:"
di "  - nwspol_comparison_by_age.png"
di "  - pstplonl_comparison_by_age.png"
di "  - coefficients_comparison.png"
di "  - coefficients_interactions.png"
di "  - vote_prob_nwspol.png"
di "  - vote_prob_pstplonl.png"
di "  - ac_prob_nwspol.png"
di "  - ac_prob_pstplonl.png"
di "  - ac_index_distribution.png"
di "  - ac_index_by_vote.png"
di "  - hypothesis_comparison.png"
di "  - descriptives_boxplot.png"
di "=========================================="

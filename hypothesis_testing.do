/*==============================================================================
  Hypothesis Testing Script for H3a, H3b, and H3c
  
  This script tests the following hypotheses:
  - H3a: Effect of nwspol on vote is stronger than on ac_index
  - H3b: Effect of pstplonl on ac_index is stronger than on vote
  - H3c: These differences vary with age (moderation effect)
  
  Note: vote is binary (0/1), ac_index is ordinal/count (0-4)
==============================================================================*/

clear all
set more off

* Set working directory (adjust as needed)
* cd "your/data/directory"

* Load your dataset
* use "your_data.dta", clear

/*==============================================================================
  PART 1: Data Preparation and Descriptive Statistics
==============================================================================*/

* Check that ac_index is properly constructed (0-4 range)
* If not already created, uncomment and use the construction script:
* do "construct_ac_index.do"

* Descriptive statistics
summarize vote ac_index nwspol pstplonl age

* Check for missing values
misstable summarize vote ac_index nwspol pstplonl age

* Correlation matrix
correlate vote ac_index nwspol pstplonl age

/*==============================================================================
  PART 2: Main Models
  
  Since vote is binary and ac_index is ordinal (0-4), we need different models:
  - Logistic regression for vote (binary outcome)
  - Ordered logistic or Poisson/negative binomial for ac_index (count/ordinal)
  
  For comparability, we'll use standardized coefficients and calculate
  marginal effects at the mean.
==============================================================================*/

*------------------------------------------------------------------------------
* Model 1: Vote as outcome (Logistic Regression)
*------------------------------------------------------------------------------

* Basic model without interaction
logit vote c.nwspol c.pstplonl c.age
estimates store vote_base

* Model with age interactions (H3c)
logit vote c.nwspol##c.age c.pstplonl##c.age
estimates store vote_interact

* Calculate marginal effects at mean
margins, dydx(nwspol pstplonl) atmeans
matrix vote_me = r(table)

* Calculate marginal effects at different ages (for H3c)
margins, dydx(nwspol) at(age=(20(10)70)) atmeans
marginsplot, title("Effect of News Consumption on Vote by Age")
graph export "nwspol_vote_by_age.png", replace

margins, dydx(pstplonl) at(age=(20(10)70)) atmeans
marginsplot, title("Effect of Online Posting on Vote by Age")
graph export "pstplonl_vote_by_age.png", replace

*------------------------------------------------------------------------------
* Model 2: AC_Index as outcome (Ordered Logistic Regression)
*------------------------------------------------------------------------------

* Check distribution of ac_index
tab ac_index

* Basic model without interaction
ologit ac_index c.nwspol c.pstplonl c.age
estimates store ac_base

* Model with age interactions (H3c)
ologit ac_index c.nwspol##c.age c.pstplonl##c.age
estimates store ac_interact

* Calculate marginal effects at mean (for highest category)
* For ordered logit, we'll look at P(ac_index=4)
margins, dydx(nwspol pstplonl) predict(outcome(4)) atmeans
matrix ac_me = r(table)

* Calculate marginal effects at different ages (for H3c)
margins, dydx(nwspol) at(age=(20(10)70)) predict(outcome(4)) atmeans
marginsplot, title("Effect of News Consumption on Activism (High) by Age")
graph export "nwspol_ac_by_age.png", replace

margins, dydx(pstplonl) at(age=(20(10)70)) predict(outcome(4)) atmeans
marginsplot, title("Effect of Online Posting on Activism (High) by Age")
graph export "pstplonl_ac_by_age.png", replace

/*==============================================================================
  PART 3: Alternative Approach - Poisson/Negative Binomial for AC_Index
  
  Since ac_index is a count (0-4), we can also use count models which may
  be more directly comparable to logistic regression
==============================================================================*/

*------------------------------------------------------------------------------
* Model 3: AC_Index with Poisson
*------------------------------------------------------------------------------

* Basic model
poisson ac_index c.nwspol c.pstplonl c.age
estimates store ac_poisson_base

* Model with interactions
poisson ac_index c.nwspol##c.age c.pstplonl##c.age
estimates store ac_poisson_interact

* Marginal effects
margins, dydx(nwspol pstplonl) atmeans
matrix ac_poisson_me = r(table)

*------------------------------------------------------------------------------
* Model 4: AC_Index with Negative Binomial (if overdispersion is present)
*------------------------------------------------------------------------------

* Check for overdispersion
poisson ac_index c.nwspol c.pstplonl c.age
estat gof

* If overdispersion exists, use negative binomial
nbreg ac_index c.nwspol c.pstplonl c.age
estimates store ac_nb_base

nbreg ac_index c.nwspol##c.age c.pstplonl##c.age
estimates store ac_nb_interact

margins, dydx(nwspol pstplonl) atmeans
matrix ac_nb_me = r(table)

/*==============================================================================
  PART 4: Hypothesis Testing
==============================================================================*/

*------------------------------------------------------------------------------
* H3a: Effect of nwspol on vote is stronger than on ac_index
*------------------------------------------------------------------------------

di "==================================================================="
di "H3a: Testing if nwspol effect is stronger on vote than on ac_index"
di "==================================================================="

* Use seemingly unrelated regression (suest) to compare coefficients
* across models with different outcomes
* Note: This requires converting to linear probability models or using
* standardized effects for comparison

* Alternative: Compare standardized marginal effects
* Extract marginal effects from matrices
scalar vote_nwspol_me = vote_me[1,1]
scalar ac_nwspol_me = ac_me[1,1]

di "Marginal effect of nwspol on vote: " vote_nwspol_me
di "Marginal effect of nwspol on ac_index (P(ac=4)): " ac_nwspol_me

* For formal test, we can use bootstrap or simulation
* A simple comparison shows which effect is larger in magnitude

*------------------------------------------------------------------------------
* H3b: Effect of pstplonl on ac_index is stronger than on vote
*------------------------------------------------------------------------------

di "==================================================================="
di "H3b: Testing if pstplonl effect is stronger on ac_index than on vote"
di "==================================================================="

scalar vote_pstplonl_me = vote_me[1,2]
scalar ac_pstplonl_me = ac_me[1,2]

di "Marginal effect of pstplonl on vote: " vote_pstplonl_me
di "Marginal effect of pstplonl on ac_index (P(ac=4)): " ac_pstplonl_me

*------------------------------------------------------------------------------
* H3c: Test if differences vary with age (moderation)
*------------------------------------------------------------------------------

di "==================================================================="
di "H3c: Testing moderation effects of age"
di "==================================================================="

* Test significance of interaction terms in both models
di "Testing age interactions in vote model:"
estimates restore vote_interact
test c.nwspol#c.age
test c.pstplonl#c.age

di "Testing age interactions in ac_index model:"
estimates restore ac_interact
test c.nwspol#c.age
test c.pstplonl#c.age

* Compare the strength of moderation across outcomes
* This requires examining the interaction coefficients and their relative sizes

/*==============================================================================
  PART 5: Standardized Comparison Approach
  
  For a more formal comparison across different outcome types, we can:
  1. Standardize all variables (z-scores)
  2. Use linear probability models for comparability
  3. Compare standardized coefficients
==============================================================================*/

* Standardize continuous variables
foreach var of varlist nwspol pstplonl age {
    egen z_`var' = std(`var')
}

* Linear probability model for vote
reg vote c.z_nwspol c.z_pstplonl c.z_age
estimates store vote_lpm_base
matrix vote_std = e(b)

reg vote c.z_nwspol##c.z_age c.z_pstplonl##c.z_age
estimates store vote_lpm_interact

* Linear model for ac_index (treating as continuous)
reg ac_index c.z_nwspol c.z_pstplonl c.z_age
estimates store ac_lpm_base
matrix ac_std = e(b)

reg ac_index c.z_nwspol##c.z_age c.z_pstplonl##c.z_age
estimates store ac_lpm_interact

* Display standardized coefficients for comparison
di "==================================================================="
di "Standardized Coefficients for Direct Comparison"
di "==================================================================="

di "Vote model - nwspol coefficient: " vote_std[1,1]
di "AC_index model - nwspol coefficient: " ac_std[1,1]
di "Vote model - pstplonl coefficient: " vote_std[1,2]
di "AC_index model - pstplonl coefficient: " ac_std[1,2]

* Formal test using seemingly unrelated regression
suest vote_lpm_base ac_lpm_base

* H3a test: nwspol effect on vote vs ac_index
di "H3a: Testing if nwspol has stronger effect on vote than ac_index"
test [vote_lpm_base_mean]z_nwspol = [ac_lpm_base_mean]z_nwspol

* H3b test: pstplonl effect on ac_index vs vote  
di "H3b: Testing if pstplonl has stronger effect on ac_index than vote"
test [ac_lpm_base_mean]z_pstplonl = [vote_lpm_base_mean]z_pstplonl

* For H3c, compare interaction terms
suest vote_lpm_interact ac_lpm_interact

di "H3c: Testing if age moderation differs between outcomes for nwspol"
test [vote_lpm_interact_mean]c.z_nwspol#c.z_age = [ac_lpm_interact_mean]c.z_nwspol#c.z_age

di "H3c: Testing if age moderation differs between outcomes for pstplonl"
test [ac_lpm_interact_mean]c.z_pstplonl#c.z_age = [vote_lpm_interact_mean]c.z_pstplonl#c.z_age

/*==============================================================================
  PART 6: Results Summary Table
==============================================================================*/

* Create comprehensive results table
estimates table vote_base vote_interact ac_base ac_interact, ///
    star stats(N r2_p ll aic bic) b(%9.3f) se

* Export results
estimates table vote_lpm_base vote_lpm_interact ac_lpm_base ac_lpm_interact, ///
    star stats(N r2 F) b(%9.3f) se

/*==============================================================================
  PART 7: Additional Robustness Checks
==============================================================================*/

* Include control variables if available in your dataset
* For example:
* logit vote c.nwspol##c.age c.pstplonl##c.age i.gender i.education c.income
* ologit ac_index c.nwspol##c.age c.pstplonl##c.age i.gender i.education c.income

* Check for multicollinearity
reg vote nwspol pstplonl age
estat vif

* Sensitivity analysis with different model specifications
* (e.g., probit vs logit, ologit vs gologit)

di "==================================================================="
di "Analysis complete. Review the results above and graphics generated."
di "==================================================================="

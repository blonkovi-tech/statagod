/*==============================================================================
  Example Data Generation Script
  
  This script creates simulated data for testing the hypothesis testing code.
  Use this to understand the expected data structure and test the analysis.
==============================================================================*/

clear all
set more off
set seed 12345

* Set number of observations
set obs 1000

/*==============================================================================
  Generate predictor variables
==============================================================================*/

* Age: Normal distribution, mean 45, sd 15, range 18-80
gen age = rnormal(45, 15)
replace age = 18 if age < 18
replace age = 80 if age > 80

* News consumption (nwspol): Ordinal scale 0-10
* Higher scores for older people
gen nwspol = floor(runiform(0, 11)) + floor((age-45)/10)
replace nwspol = 0 if nwspol < 0
replace nwspol = 10 if nwspol > 10

* Online posting (pstplonl): Ordinal scale 0-10  
* Higher scores for younger people, correlation with nwspol
gen pstplonl = floor(runiform(0, 11)) - floor((age-45)/10) + floor(nwspol/3)
replace pstplonl = 0 if pstplonl < 0
replace pstplonl = 10 if pstplonl > 10

/*==============================================================================
  Generate activism components (4 binary variables)
==============================================================================*/

* Simulate latent propensity for activism
* Influenced by pstplonl (primary), nwspol (secondary), and age (negative)
gen activism_propensity = -1.5 + 0.15*nwspol + 0.25*pstplonl - 0.02*age + rnormal(0, 1)

* Component 1: Signed petition online (easiest, most common)
gen prob_ac1 = invlogit(activism_propensity + 0.5)
gen ac_var1 = runiform() < prob_ac1
label variable ac_var1 "Signed online petition"

* Component 2: Shared political content
gen prob_ac2 = invlogit(activism_propensity + 0.2)
gen ac_var2 = runiform() < prob_ac2
label variable ac_var2 "Shared political content"

* Component 3: Contacted official
gen prob_ac3 = invlogit(activism_propensity - 0.1)
gen ac_var3 = runiform() < prob_ac3
label variable ac_var3 "Contacted elected official"

* Component 4: Attended protest/rally (hardest, least common)
gen prob_ac4 = invlogit(activism_propensity - 0.8)
gen ac_var4 = runiform() < prob_ac4
label variable ac_var4 "Attended protest or rally"

* Create activism index
egen ac_index = rowtotal(ac_var1 ac_var2 ac_var3 ac_var4)
label variable ac_index "Activism Index (0-4)"

/*==============================================================================
  Generate vote variable (binary)
==============================================================================*/

* Voting is influenced more by nwspol than pstplonl, and positively by age
* Age interaction: news consumption matters more for older voters
gen vote_propensity = -1.0 + 0.30*nwspol + 0.10*pstplonl + 0.03*age ///
                      + 0.005*nwspol*age - 0.002*pstplonl*age + rnormal(0, 1)

gen prob_vote = invlogit(vote_propensity)
gen vote = runiform() < prob_vote
label variable vote "Voted in last election"

/*==============================================================================
  Add some missing values (realistic)
==============================================================================*/

* Random missingness (5%)
foreach var in vote ac_var1 ac_var2 ac_var3 ac_var4 nwspol pstplonl age {
    replace `var' = . if runiform() < 0.05
}

* Recalculate ac_index with missingness handled
drop ac_index
egen ac_index = rowtotal(ac_var1 ac_var2 ac_var3 ac_var4), missing
label variable ac_index "Activism Index (0-4)"

/*==============================================================================
  Add demographic controls (optional, for robustness checks)
==============================================================================*/

* Gender (binary)
gen female = runiform() < 0.52
label variable female "Female (1=yes)"

* Education (ordinal 1-5)
gen education = ceil(runiform() * 5)
replace education = education + floor((age-45)/15)
replace education = 1 if education < 1
replace education = 5 if education > 5
label variable education "Education level (1-5)"

* Income (ordinal 1-10)
gen income = ceil(runiform() * 10)
replace income = income + floor(education/2)
replace income = 1 if income < 1
replace income = 10 if income > 10
label variable income "Household income decile"

* Political interest (ordinal 0-4)
gen polint = floor((nwspol + pstplonl)/5)
replace polint = 4 if polint > 4
label variable polint "Political interest (0-4)"

/*==============================================================================
  Label values
==============================================================================*/

label define yesno 0 "No" 1 "Yes"
label values vote female ac_var1 ac_var2 ac_var3 ac_var4 yesno

label define educ 1 "Primary" 2 "Some secondary" 3 "Secondary" ///
                  4 "Some university" 5 "University degree"
label values education educ

/*==============================================================================
  Descriptive statistics
==============================================================================*/

di "=========================================="
di "Example Dataset Generated"
di "=========================================="

di ""
di "Sample size: " _N
di ""

di "Outcome variables:"
tab vote, missing
tab ac_index, missing

di ""
di "Predictor variables:"
summarize nwspol pstplonl age

di ""
di "Activism components:"
tab1 ac_var1 ac_var2 ac_var3 ac_var4

di ""
di "Correlations:"
correlate vote ac_index nwspol pstplonl age

/*==============================================================================
  Save example dataset
==============================================================================*/

* Order variables nicely
order vote ac_index ac_var1 ac_var2 ac_var3 ac_var4 nwspol pstplonl age ///
      female education income polint

* Add dataset label
label data "Example data for hypothesis testing (H3a, H3b, H3c)"

* Save
save "example_data.dta", replace

di ""
di "=========================================="
di "Dataset saved as: example_data.dta"
di "=========================================="
di ""
di "Key features of this simulated data:"
di "  - Vote is MORE influenced by nwspol (H3a)"
di "  - AC_index is MORE influenced by pstplonl (H3b)"
di "  - Age moderates these effects (H3c)"
di ""
di "You can now run:"
di "  do hypothesis_testing.do"
di "  do visualization.do"
di "=========================================="

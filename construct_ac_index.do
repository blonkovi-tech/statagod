/*==============================================================================
  AC_Index Construction Script
  
  This script constructs the ac_index (activism index) from four binary 
  variables. The index ranges from 0 to 4.
  
  Adjust the variable names below to match your actual binary variables.
==============================================================================*/

clear all
set more off

* Load your dataset
* use "your_data.dta", clear

/*==============================================================================
  Construct AC_Index from four binary variables
==============================================================================*/

* Replace these variable names with your actual binary activism variables
* Examples might be: attended_protest, signed_petition, contacted_official, donated

* Example construction (adjust variable names):
* Assuming you have variables: ac_var1, ac_var2, ac_var3, ac_var4
* Each coded as 0/1

* Check that variables are binary
foreach var in ac_var1 ac_var2 ac_var3 ac_var4 {
    tab `var'
    assert inlist(`var', 0, 1, .)
}

* Create the index by summing the four binary variables
egen ac_index = rowtotal(ac_var1 ac_var2 ac_var3 ac_var4), missing

* Label the index
label variable ac_index "Activism Index (0-4)"

* Check the distribution
tab ac_index
summarize ac_index

* Verify range
assert inrange(ac_index, 0, 4) | missing(ac_index)

* Display distribution
di "Distribution of AC_Index:"
tab ac_index, missing

* Calculate internal consistency (Cronbach's alpha)
alpha ac_var1 ac_var2 ac_var3 ac_var4

* Save dataset with new index
* save "your_data_with_index.dta", replace

/*==============================================================================
  Alternative: If you need to create the index from different variable types
==============================================================================*/

* If variables are not binary, you may need to recode them first
* Example:
* recode original_var (1/2=0) (3/5=1), gen(ac_var1)

* Or if using a different coding scheme:
* gen ac_var1 = (original_var >= threshold)

/*==============================================================================
  Descriptive Statistics
==============================================================================*/

* Crosstabs to understand the index composition
tab ac_index ac_var1, row
tab ac_index ac_var2, row
tab ac_index ac_var3, row
tab ac_index ac_var4, row

* Correlation among components
correlate ac_var1 ac_var2 ac_var3 ac_var4

di "AC_Index constructed successfully."
di "Range: 0-4, where higher values indicate more activism."

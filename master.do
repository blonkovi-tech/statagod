/*==============================================================================
  MASTER SCRIPT: Complete Hypothesis Testing Analysis
  
  This master script runs the complete analysis pipeline for testing
  hypotheses H3a, H3b, and H3c.
  
  Usage:
  1. If using example data: do "master.do"
  2. If using your own data: 
     - Comment out the example data generation section
     - Load your own data
     - Run construct_ac_index.do (after editing variable names)
==============================================================================*/

clear all
set more off
capture log close
set linesize 120

* Set seed for reproducibility (if generating example data)
set seed 12345

di ""
di "=========================================================================="
di "  HYPOTHESIS TESTING ANALYSIS: H3a, H3b, H3c"
di "=========================================================================="
di ""
di "This script will:"
di "  1. Generate example data (or you can load your own)"
di "  2. Run descriptive statistics"
di "  3. Test hypotheses H3a, H3b, and H3c"
di "  4. Create visualizations"
di ""

* Start log file
log using "analysis_log.log", replace text

/*==============================================================================
  STEP 1: DATA PREPARATION
==============================================================================*/

di ""
di "=========================================================================="
di "STEP 1: Data Preparation"
di "=========================================================================="
di ""

* Option A: Generate example data (comment this out if using your own data)
di "Generating example data..."
do "generate_example_data.do"

* Option B: Load your own data (uncomment and edit if using your own data)
* use "your_data.dta", clear
* do "construct_ac_index.do"

di ""
di "Data loaded successfully."
di "Sample size: " _N

/*==============================================================================
  STEP 2: DESCRIPTIVE STATISTICS
==============================================================================*/

di ""
di "=========================================================================="
di "STEP 2: Descriptive Statistics"
di "=========================================================================="
di ""

di "Outcome variables:"
tab vote
tab ac_index

di ""
di "Predictor variables:"
summarize nwspol pstplonl age, detail

di ""
di "Cross-tabulation:"
tab vote ac_index, row col

di ""
di "Correlations:"
correlate vote ac_index nwspol pstplonl age

di ""
di "Missing data:"
misstable summarize vote ac_index nwspol pstplonl age

/*==============================================================================
  STEP 3: HYPOTHESIS TESTING
==============================================================================*/

di ""
di "=========================================================================="
di "STEP 3: Hypothesis Testing"
di "=========================================================================="
di ""

do "hypothesis_testing.do"

/*==============================================================================
  STEP 4: VISUALIZATIONS
==============================================================================*/

di ""
di "=========================================================================="
di "STEP 4: Creating Visualizations"
di "=========================================================================="
di ""

do "visualization.do"

/*==============================================================================
  STEP 5: SUMMARY OF RESULTS
==============================================================================*/

di ""
di "=========================================================================="
di "STEP 5: Summary of Results"
di "=========================================================================="
di ""

di "The analysis is complete. Key files have been generated:"
di ""
di "Log file:"
di "  - analysis_log.log (contains all statistical output)"
di ""
di "Data file:"
di "  - example_data.dta (simulated data used)"
di ""
di "Visualizations:"
di "  - nwspol_comparison_by_age.png"
di "  - pstplonl_comparison_by_age.png"
di "  - coefficients_comparison.png"
di "  - coefficients_interactions.png"
di "  - vote_prob_nwspol.png"
di "  - vote_prob_pstplonl.png"
di "  - ac_prob_nwspol.png"
di "  - ac_prob_pstplonl.png"
di "  - hypothesis_comparison.png"
di "  - And more..."
di ""
di "Next steps:"
di "  1. Review the analysis_log.log file for detailed results"
di "  2. Check the visualizations (PNG files)"
di "  3. Interpret the hypothesis tests (see QUICK_REFERENCE.md)"
di "  4. Report results in your paper/thesis"
di ""
di "=========================================================================="
di "For help interpreting results, see:"
di "  - QUICK_REFERENCE.md (quick guide)"
di "  - README_ANALYSIS.md (detailed methodology)"
di "=========================================================================="
di ""

log close

di ""
di "Analysis complete! Check analysis_log.log for full output."
di ""

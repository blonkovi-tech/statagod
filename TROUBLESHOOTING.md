# Troubleshooting Guide

## Common Issues and Solutions

### 1. Variable Not Found

**Error:** `variable nwspol not found` or similar

**Cause:** The variable names in the scripts don't match your data

**Solution:**
1. Check your variable names: `describe` or `codebook`
2. Edit the .do files to use your actual variable names
3. Common variables to check:
   - `vote` → your voting variable
   - `ac_index` → your activism index (or components)
   - `nwspol` → your news consumption variable
   - `pstplonl` → your online posting variable
   - `age` → your age variable

### 2. AC_Index Not Found

**Error:** `variable ac_index not found`

**Cause:** The activism index hasn't been created yet

**Solution:**
1. Open `construct_ac_index.do`
2. Replace `ac_var1`, `ac_var2`, `ac_var3`, `ac_var4` with your actual binary activism variables
3. Run: `do "construct_ac_index.do"`
4. Then proceed with the main analysis

### 3. Model Won't Converge

**Error:** `convergence not achieved` or `could not calculate numerical derivatives`

**Possible causes and solutions:**

**A. Perfect prediction (separation)**
- Check: `tab vote nwspol` (or other predictors)
- If one predictor perfectly predicts outcome, you'll see separation
- Solution: Use Firth logistic regression or drop problematic predictor

**B. Too many missing values**
- Check: `misstable summarize`
- Solution: Use `listwise` deletion or multiple imputation

**C. Scale issues**
- If variables are on very different scales
- Solution: Already handled by standardization in script

**D. Multicollinearity**
- Check: `estat vif` after running regression
- If VIF > 10, you have multicollinearity
- Solution: Remove one of the correlated predictors

### 4. Proportional Odds Assumption Violated

**Error/Warning:** Proportional odds assumption not met for ordered logistic regression

**Check:**
```stata
ologit ac_index nwspol pstplonl age
brant  // or approximate Brant test
```

**Solution:**
Use generalized ordered logit instead:
```stata
ssc install gologit2
gologit2 ac_index c.nwspol##c.age c.pstplonl##c.age
```

### 5. Overdispersion in Count Models

**Error/Warning:** Overdispersion detected in Poisson model

**Check:**
```stata
poisson ac_index nwspol pstplonl age
estat gof
```

**Solution:**
Use negative binomial instead (already included in script):
```stata
nbreg ac_index c.nwspol##c.age c.pstplonl##c.age
```

### 6. Insufficient Variation in AC_Index

**Issue:** AC_Index has limited variation (e.g., mostly 0s)

**Check:**
```stata
tab ac_index
```

**Solution:**
- If AC_Index is heavily zero-inflated, consider:
  1. Zero-inflated Poisson (ZIP) or zero-inflated negative binomial (ZINB)
  2. Dichotomize AC_Index (0 vs. 1+) and use logistic regression
  3. Treat as binary: high activism (3-4) vs. low (0-2)

### 7. File Not Found

**Error:** `file "filename.do" not found`

**Solution:**
1. Check you're in the correct directory: `pwd`
2. List files: `dir` or `ls`
3. Set correct working directory: `cd "path/to/your/directory"`
4. Or use full file paths

### 8. Margins Command Fails

**Error:** Error running `margins` after model

**Possible causes:**

**A. Complex model specification**
- Solution: Simplify interaction terms or use fewer `at()` values

**B. Missing data**
- Solution: Use `atmeans` option or specify all variable values

**C. Model convergence issues**
- Solution: Re-fit model with fewer interactions first

### 9. SUEST Fails

**Error:** `suest` command fails or gives unexpected results

**Cause:** SUEST requires models with same sample (listwise deletion)

**Solution:**
```stata
* Mark observations used in both models
mark touse
markout touse vote ac_index nwspol pstplonl age

* Run models on same sample
reg vote c.z_nwspol c.z_pstplonl c.z_age if touse
estimates store vote_model

reg ac_index c.z_nwspol c.z_pstplonl c.z_age if touse
estimates store ac_model

* Now SUEST should work
suest vote_model ac_model
```

### 10. Graphics Don't Look Right

**Issue:** Plots are hard to read or poorly formatted

**Solutions:**

**Change color scheme:**
```stata
set scheme s2color  // or s1color, s2mono, economist, etc.
```

**Customize plot:**
```stata
marginsplot, ///
    ytitle("Your Y Label") ///
    xtitle("Your X Label") ///
    title("Your Title") ///
    legend(order(1 "Label 1" 2 "Label 2"))
```

**Export at higher resolution:**
```stata
graph export "filename.png", replace width(1200) height(800)
```

### 11. Interpretation Questions

**Q: How do I know if H3a is supported?**

A: Look at the SUEST test output. You want to see:
1. Standardized coefficient for `nwspol` is larger in the vote model
2. The test comparing these coefficients has p < 0.05
3. The sign is in the expected direction (both positive, or both negative)

**Q: What if the effects go in opposite directions?**

A: This is actually meaningful! It means the predictor has opposite effects on the two outcomes. Report this finding - it's interesting and may require theoretical explanation.

**Q: My interaction terms are not significant. Does this mean H3c is not supported?**

A: Not necessarily. Check:
1. Are the interaction patterns different across models? (Look at plots)
2. Does the SUEST test comparing interactions show differences?
3. Consider power - you may need a larger sample to detect interactions

### 12. Memory Issues

**Error:** `no room to add more observations`

**Solution:**
```stata
clear all
set maxvar 10000  // increase max variables
set matsize 800   // increase matrix size
set memory 500m   // increase memory (Stata 12 or earlier)
```

For Stata 13+, memory is dynamic, but you can still set maxvar and matsize.

### 13. Package Not Found

**Error:** `coefplot not found` or similar

**Solution:**
```stata
ssc install coefplot
ssc install estout
ssc install gologit2
```

If SSC is unreachable:
```stata
net search coefplot
```

## Getting Additional Help

### Check Stata Resources:
1. Stata manual: `help command_name`
2. Stata website: https://www.stata.com
3. Statalist forum: https://www.statalist.org

### Check Your Data:
```stata
* Examine variables
codebook vote ac_index nwspol pstplonl age

* Check for outliers
summarize, detail

* Look at distributions
histogram age
graph box nwspol pstplonl
```

### Verify Model Assumptions:
```stata
* After logistic regression
estat classification  // classification table
estat gof            // goodness of fit
lroc                 // ROC curve

* After linear regression
predict residuals, residuals
histogram residuals   // check normality
rvfplot              // check homoscedasticity
```

## Still Having Issues?

1. Check that you're using Stata 14 or later: `about`
2. Update Stata: `update all`
3. Try running with the example data first to ensure scripts work
4. Check the README_ANALYSIS.md for methodological questions
5. Review your variable coding and data structure

## Common Misunderstandings

### "Why use linear models for final comparison?"
- Coefficients from logit/ologit aren't directly comparable across models
- Standardized linear models provide coefficients on the same scale
- SUEST allows formal testing across these linear models

### "Why not just compare odds ratios?"
- Odds ratios from logit for vote and ologit for ac_index aren't comparable
- They represent different quantities (odds of vote=1 vs. cumulative odds)
- Standardized effects solve this problem

### "Can I just look at the p-values?"
- No! Effect sizes matter, not just significance
- Use SUEST to formally test if effects differ
- Consider confidence intervals, not just p-values

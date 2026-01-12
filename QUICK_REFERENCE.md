# Quick Reference Guide: Hypothesis Testing

## Quick Start

### 1. If you have your own data:
```stata
* Load your data
use "your_data.dta", clear

* Construct ac_index (edit variable names first)
do "construct_ac_index.do"

* Run analysis
do "hypothesis_testing.do"

* Create visualizations
do "visualization.do"
```

### 2. To test with example data:
```stata
* Generate example dataset
do "generate_example_data.do"

* Run analysis on example data
do "hypothesis_testing.do"

* Create visualizations
do "visualization.do"
```

## Understanding Your Results

### H3a: nwspol effect on vote > nwspol effect on ac_index

**What to look for:**
1. Standardized coefficient for nwspol in vote model
2. Standardized coefficient for nwspol in ac_index model
3. SUEST test p-value

**Interpretation:**
- If the coefficient is LARGER for vote AND p < 0.05: **H3a is SUPPORTED**
- News consumption primarily drives voting behavior

### H3b: pstplonl effect on ac_index > pstplonl effect on vote

**What to look for:**
1. Standardized coefficient for pstplonl in ac_index model
2. Standardized coefficient for pstplonl in vote model
3. SUEST test p-value

**Interpretation:**
- If the coefficient is LARGER for ac_index AND p < 0.05: **H3b is SUPPORTED**
- Online posting drives broader activism more than just voting

### H3c: Effects vary with age (moderation)

**What to look for:**
1. Significance of interaction terms: `predictor#age`
2. SUEST test comparing interactions across models
3. Marginal effects plots showing different slopes by age
4. Whether interaction patterns differ between vote and ac_index models

**Interpretation:**
- If interactions are significant AND differ between models: **H3c is SUPPORTED**
- The relationship between predictors and outcomes changes with age, and this change differs for voting vs. activism

## Key Output Files

### Statistical Results (in Stata output window):
- Model coefficients and standard errors
- Hypothesis test results (p-values)
- Marginal effects tables

### Visualizations (PNG files):
- `nwspol_comparison_by_age.png` - How news effects vary by age
- `pstplonl_comparison_by_age.png` - How posting effects vary by age
- `coefficients_comparison.png` - Direct comparison of standardized effects
- `hypothesis_comparison.png` - Summary visualization for H3a and H3b

## Common Issues and Solutions

### Issue: "ac_index not found"
**Solution:** Run `do "construct_ac_index.do"` first (after editing variable names)

### Issue: "Variable names don't match"
**Solution:** Edit the .do files to replace example variable names with your actual variable names:
- `ac_var1`, `ac_var2`, `ac_var3`, `ac_var4` → your activism variables
- `nwspol` → your news consumption variable
- `pstplonl` → your online posting variable
- `vote` → your voting variable
- `age` → your age variable

### Issue: "Proportional odds assumption violated"
**Solution:** Use generalized ordered logit:
```stata
gologit2 ac_index c.nwspol##c.age c.pstplonl##c.age
```

### Issue: "Overdispersion in count model"
**Solution:** Use negative binomial instead of Poisson (already included in script)

## Reporting Results

### In your paper/thesis:

**For H3a:**
> "To test H3a, we compared the standardized effect of news consumption on voting versus activism using seemingly unrelated estimation. The effect on voting (β = X.XX, SE = X.XX) was significantly larger than the effect on activism (β = X.XX, SE = X.XX), χ²(1) = X.XX, p = X.XX. This supports H3a."

**For H3b:**
> "H3b predicted that online posting would have a stronger effect on activism than on voting. Consistent with this hypothesis, the standardized effect on activism (β = X.XX, SE = X.XX) was significantly larger than on voting (β = X.XX, SE = X.XX), χ²(1) = X.XX, p = X.XX."

**For H3c:**
> "To test whether age moderated these effects differently across outcomes (H3c), we examined interaction terms in both models. The news consumption × age interaction was significant for voting (β = X.XX, p = X.XX) but not for activism (β = X.XX, p = X.XX). The difference between these interactions was significant (χ²(1) = X.XX, p = X.XX), supporting H3c."

## Advanced Options

### Add control variables:
```stata
logit vote c.nwspol##c.age c.pstplonl##c.age i.female i.education c.income
ologit ac_index c.nwspol##c.age c.pstplonl##c.age i.female i.education c.income
```

### Test alternative specifications:
```stata
* Probit instead of logit
probit vote c.nwspol##c.age c.pstplonl##c.age

* Treat ac_index as continuous
reg ac_index c.nwspol##c.age c.pstplonl##c.age

* Use negative binomial for ac_index
nbreg ac_index c.nwspol##c.age c.pstplonl##c.age
```

### Calculate predicted probabilities:
```stata
* For a 30-year-old with nwspol=7, pstplonl=5
margins, at(age=30 nwspol=7 pstplonl=5)

* For multiple scenarios
margins, at(age=(25 45 65) nwspol=(3 7) pstplonl=(2 8))
```

## Getting Help

1. Check that your variables are coded correctly: `codebook vote ac_index nwspol pstplonl age`
2. Verify no multicollinearity: `estat vif` after regression
3. Check model assumptions: `estat classification` (logit), `estat gof` (ordered logit)
4. Review the full README_ANALYSIS.md for methodological details

## Packages Required

Install if needed:
```stata
ssc install estout
ssc install coefplot
ssc install gologit2
```

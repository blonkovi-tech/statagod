# Hypothesis Testing Model for H3a, H3b, and H3c

This repository contains Stata scripts for testing hypotheses about the differential effects of news consumption and online political posting on voting behavior and political activism, moderated by age.

## Research Questions

The analysis tests three related hypotheses:

- **H3a**: The effect of news consumption (nwspol) on voting (vote) is stronger than its effect on activism index (ac_index)
- **H3b**: The effect of online posting (pstplonl) on activism index (ac_index) is stronger than its effect on voting (vote)
- **H3c**: These differential effects vary with age (moderation effect)

## Variables

- **vote**: Binary outcome variable (0/1) indicating whether respondent voted
- **ac_index**: Ordinal/count variable (0-4) representing level of political activism, constructed from four binary activism indicators
- **nwspol**: Predictor variable measuring news consumption about politics
- **pstplonl**: Predictor variable measuring frequency of online political posting
- **age**: Continuous moderator variable

## Files

### 1. `construct_ac_index.do`
Script for constructing the activism index from four binary variables. 

**Usage:**
```stata
do "construct_ac_index.do"
```

**Important:** Edit this file to replace `ac_var1`, `ac_var2`, `ac_var3`, `ac_var4` with your actual binary activism variable names.

### 2. `hypothesis_testing.do`
Main analysis script that:
- Runs appropriate models for both outcome types (logistic for vote, ordered logistic for ac_index)
- Tests moderation effects with age interactions
- Compares effects across outcomes using standardized coefficients
- Provides formal statistical tests using seemingly unrelated estimation (SUEST)
- Generates marginal effects plots

**Usage:**
```stata
do "hypothesis_testing.do"
```

### 3. `visualization.do`
Creates publication-quality visualizations of the results.

**Usage:**
```stata
do "visualization.do"
```

## Methodological Approach

### Challenge: Comparing Effects Across Different Outcome Types

The key methodological challenge is comparing effects between:
- A binary outcome (vote) - analyzed with logistic regression
- A count/ordinal outcome (ac_index) - analyzed with ordered logistic or count models

### Solutions Implemented

1. **Marginal Effects Approach**
   - Calculate marginal effects at the mean for both models
   - Compare the magnitude of effects on the probability scale
   - For vote: Change in P(vote=1)
   - For ac_index: Change in P(ac_index=4)

2. **Standardized Linear Model Approach** (Primary recommendation)
   - Standardize all variables (z-scores)
   - Use linear probability models for both outcomes
   - Compare standardized coefficients directly
   - Use SUEST (Seemingly Unrelated Estimation) for formal statistical tests
   - This allows direct hypothesis testing across models

3. **Visual Comparison**
   - Plot marginal effects at different ages for both outcomes
   - Visual inspection of interaction patterns

## Running the Analysis

### Step 1: Prepare Data
```stata
* Load your dataset
use "your_data.dta", clear

* Construct ac_index if not already done
do "construct_ac_index.do"
```

### Step 2: Run Main Analysis
```stata
do "hypothesis_testing.do"
```

### Step 3: Generate Visualizations
```stata
do "visualization.do"
```

## Interpreting Results

### H3a: nwspol effect stronger on vote than ac_index

Look for:
- Comparison of standardized coefficients (should be larger for vote)
- SUEST test result (p-value < 0.05 indicates significant difference)
- Marginal effects comparison

**Interpretation:** If H3a is supported, news consumption primarily drives voting behavior rather than broader activism.

### H3b: pstplonl effect stronger on ac_index than vote

Look for:
- Comparison of standardized coefficients (should be larger for ac_index)
- SUEST test result (p-value < 0.05 indicates significant difference)
- Marginal effects comparison

**Interpretation:** If H3b is supported, online posting is more strongly associated with activism than with voting specifically.

### H3c: Age moderation varies across outcomes

Look for:
- Significance of interaction terms in both models
- SUEST test comparing interaction coefficients
- Marginal effects plots showing different patterns by age
- Test of whether age interactions differ between models

**Interpretation:** If H3c is supported, the relationship between predictors and outcomes changes differently with age depending on whether we're examining voting or activism.

## Model Specifications

### For Vote (Binary Outcome)
```stata
logit vote c.nwspol##c.age c.pstplonl##c.age
```

### For AC_Index (Ordinal Outcome)
```stata
ologit ac_index c.nwspol##c.age c.pstplonl##c.age
```

### For Standardized Comparison
```stata
* Standardize variables
egen z_nwspol = std(nwspol)
egen z_pstplonl = std(pstplonl)
egen z_age = std(age)

* Linear models for comparison
reg vote c.z_nwspol##c.z_age c.z_pstplonl##c.z_age
reg ac_index c.z_nwspol##c.z_age c.z_pstplonl##c.z_age

* Test hypotheses
suest vote_model ac_model
test [vote_model]z_nwspol = [ac_model]z_nwspol
```

## Extensions and Robustness

Consider adding:
1. **Control variables**: gender, education, income, etc.
2. **Alternative model specifications**: 
   - Probit instead of logit
   - Negative binomial for ac_index if overdispersion exists
   - Generalized ordered logit if proportional odds assumption violated
3. **Sensitivity analyses**:
   - Different age categorizations
   - Subgroup analyses
   - Bootstrap confidence intervals

## Output Files

The analysis generates:
- `nwspol_vote_by_age.png` - Effect of news on voting across ages
- `pstplonl_vote_by_age.png` - Effect of online posting on voting across ages
- `nwspol_ac_by_age.png` - Effect of news on activism across ages
- `pstplonl_ac_by_age.png` - Effect of online posting on activism across ages
- `comparison_plot.png` - Side-by-side comparison of effects

## Requirements

- Stata 14 or later
- Required Stata packages (install if needed):
  - `estout` for table formatting
  - `coefplot` for coefficient plots

## Citation

If you use this code, please cite appropriately and note the methodological approach taken to compare effects across different outcome types.

## Notes

- Always check model assumptions (proportional odds for ologit, overdispersion for count models)
- Consider adding control variables relevant to your research context
- The standardized approach using linear models provides the most straightforward hypothesis tests
- Marginal effects provide intuitive interpretations but require careful thought about which probability to focus on for ac_index

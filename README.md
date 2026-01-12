# statagod

Stata scripts for testing hypotheses about differential effects of news consumption and online political posting on voting behavior and political activism, with age moderation.

## Overview

This repository provides a complete analysis framework for testing complex hypotheses involving:
- Binary outcomes (voting)
- Ordinal/count outcomes (activism index 0-4)
- Moderation effects (age)
- Cross-outcome comparisons

## Quick Start

```stata
* Option 1: Use example data to learn
do "generate_example_data.do"
do "hypothesis_testing.do"
do "visualization.do"

* Option 2: Use your own data
use "your_data.dta", clear
do "construct_ac_index.do"  // Edit variable names first!
do "hypothesis_testing.do"
do "visualization.do"
```

## Files

- **hypothesis_testing.do** - Main analysis script with all hypothesis tests
- **construct_ac_index.do** - Constructs activism index from binary variables
- **visualization.do** - Creates publication-quality visualizations
- **generate_example_data.do** - Creates simulated data for testing
- **README_ANALYSIS.md** - Detailed methodological documentation
- **QUICK_REFERENCE.md** - Quick reference guide for interpretation

## Research Questions

- **H3a**: Is the effect of news consumption (nwspol) on voting stronger than on activism?
- **H3b**: Is the effect of online posting (pstplonl) on activism stronger than on voting?
- **H3c**: Do these differences vary with age?

## Key Features

✓ Handles different outcome types (binary vs. count/ordinal)  
✓ Uses standardized coefficients for valid comparison  
✓ Provides formal statistical tests (SUEST)  
✓ Includes moderation analysis  
✓ Generates comprehensive visualizations  
✓ Complete documentation and examples  

## Documentation

- See **QUICK_REFERENCE.md** for quick start guide and interpretation
- See **README_ANALYSIS.md** for detailed methodology and theory

## Requirements

- Stata 14 or later
- Optional packages: `estout`, `coefplot`, `gologit2` (installed automatically if needed)

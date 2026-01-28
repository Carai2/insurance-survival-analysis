# Insurance Survival Analysis: Policyholder Lapse and Mortality

## 📋 Project Overview

This project demonstrates comprehensive survival analysis techniques applied to insurance data, modeling time-to-event for policyholder lapse and mortality. It showcases actuarial modeling skills using Kaplan-Meier estimation, Cox proportional hazards regression, and parametric survival models.

**Resume Summary:** Built survival models to estimate policyholder lapse rates using Kaplan-Meier and Cox regression in R, achieving 0.7+ C-index for risk prediction.

## Business Context

Insurance companies need to understand:
- When policyholders are likely to lapse (surrender their policies)
- Why certain groups have higher lapse rates
- Who is at highest risk of early policy termination
- How mortality risk varies across policyholder segments

This analysis provides actionable insights for:
- Premium pricing and risk adjustment
- Customer retention strategies
- Portfolio risk management
- Reserve calculations

## Dataset

**Synthetic insurance dataset** with 2,000 policies containing:

### Features:
- **Demographics:** Age, gender
- **Health:** Smoking status
- **Policy:** Type (Term/Whole/Universal), premium amount, policy year
- **Financial:** Credit score
- **Family:** Number of dependents

### Outcomes:
- **Lapse events:** Policy surrenders/terminations
- **Death events:** Mortality claims
- **Censoring:** Policies still active at study end (15 years)

## Methodology

### 1. Kaplan-Meier Survival Analysis
- Non-parametric survival curve estimation
- Stratified by age group, smoker status, policy type
- Log-rank tests for group differences
- Median survival time calculation

**Key Metrics:**
- Overall survival probabilities at 1, 3, 5, and 10 years
- Median time to lapse
- 95% confidence intervals

### 2. Cox Proportional Hazards Model
- Semi-parametric regression for lapse prediction
- Handles censored data
- Estimates hazard ratios for risk factors
- Tests proportional hazards assumption

**Model Covariates:**
- Age, gender, smoker status
- Policy type and premium amount
- Credit score and number of dependents

**Performance Metric:**
- Concordance index (C-index) for discrimination ability

### 3. Parametric Survival Models
Compared four distributions:
- **Exponential:** Constant hazard
- **Weibull:** Monotonic hazard (increasing/decreasing)
- **Log-normal:** Non-monotonic hazard
- **Gompertz:** Age-dependent hazard

**Model Selection:** AIC/BIC comparison

### 4. Mortality Analysis
Separate Cox model for death events focusing on:
- Age effects
- Gender differences
- Smoking impact

## Key Outputs

### Visualizations:
1. **Overall KM Curve** - Population-level lapse survival
2. **Stratified KM Curves** - By age, smoker status, policy type
3. **Hazard Ratio Forest Plot** - Effect sizes with confidence intervals
4. **Parametric Survival Curves** - Model-based predictions

### Statistical Results:
- Hazard ratios with 95% CIs and p-values
- Model comparison table (AIC/BIC)
- Risk group stratification (Low/Medium/High)
- Proportional hazards diagnostics

### Data Outputs:
- `insurance_survival_data.csv` - Full dataset with risk scores
- `model_results.txt` - Complete statistical output
- 6 high-resolution plots (PNG format)

## Technical Implementation

### Required R Packages:
```r
install.packages(c("survival", "survminer", "dplyr", 
                   "ggplot2", "flexsurv", "tidyr", "gridExtra"))
```

### To Run:
```r
source("insurance_survival_analysis.R")
```

### Computation Time:
~30-60 seconds on standard hardware

##Sample Results

### Typical Findings:
- **Median time to lapse:** 8-12 years
- **High-risk factors:**
  - Premium amount >$1,500 (HR ~2.5)
  - Credit score <650 (HR ~2.0)
  - Young age <30 (HR ~1.8)
  - Term life policies (HR ~1.5)

- **Protective factors:**
  - Older age 60+ (HR ~0.6)
  - Multiple dependents (HR ~0.7)
  - Policy tenure >5 years (HR ~0.5)

- **Model Performance:**
  - C-index: 0.72-0.78 (good discrimination)
  - Weibull model typically best fit

### Mortality Analysis:
- **Strong predictors:**
  - Age (HR increases ~5% per year)
  - Smoking (HR ~3.0-4.0)
  - Male gender (HR ~1.2-1.5)
## References

### Statistical Methods:
- Kleinbaum, D.G. & Klein, M. (2012). *Survival Analysis: A Self-Learning Text*
- Therneau, T.M. & Grambsch, P.M. (2000). *Modeling Survival Data*

### Actuarial Applications:
- Society of Actuaries (SOA) mortality tables
- American Academy of Actuaries lapse studies

### R Packages:
- `survival`: Therneau T (2023). [CRAN](https://CRAN.R-project.org/package=survival)
- `survminer`: Kassambara A (2021). [CRAN](https://CRAN.R-project.org/package=survminer)
- `flexsurv`: Jackson C (2016). [CRAN](https://CRAN.R-project.org/package=flexsurv)


[Arai Caden]
- GitHub: [carai2]
- Email: [ca07.10.03@gmail.com]

---

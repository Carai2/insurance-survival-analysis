# Technical Appendix: Mathematical Formulations

## Survival Analysis Fundamentals

### 1. Survival Function

The **survival function** S(t) represents the probability that an individual survives beyond time t:

```
S(t) = P(T > t)
```

Where T is a random variable representing the time to event.

**Properties:**
- S(0) = 1 (everyone starts alive/active)
- S(∞) = 0 (everyone eventually experiences the event)
- S(t) is non-increasing

---

### 2. Hazard Function

The **hazard function** h(t) represents the instantaneous risk of the event occurring at time t, given survival up to t:

```
h(t) = lim(Δt→0) [P(t ≤ T < t + Δt | T ≥ t) / Δt]
```

**Relationship to survival function:**

```
S(t) = exp(-∫₀ᵗ h(u) du) = exp(-H(t))
```

Where H(t) is the **cumulative hazard function**.

**Interpretation:**
- h(t) = instantaneous failure rate
- If h(t) is constant, we have an exponential distribution
- If h(t) increases, failures accelerate over time
- If h(t) decreases, early failures dominate

---

### 3. Probability Density Function

The **probability density function** f(t):

```
f(t) = -dS(t)/dt = h(t) × S(t)
```

This is the probability of the event occurring exactly at time t.

---

## Kaplan-Meier Estimator

### Formulation

The **Kaplan-Meier estimator** of the survival function:

```
Ŝ(t) = ∏(tᵢ ≤ t) (1 - dᵢ/nᵢ)
```

Where:
- tᵢ = distinct event times (ordered)
- dᵢ = number of events at time tᵢ
- nᵢ = number at risk just before tᵢ (includes those who haven't experienced event or been censored)

### Example Calculation

| Time | At Risk (nᵢ) | Events (dᵢ) | Censored (cᵢ) | Survival Probability |
|------|--------------|-------------|---------------|----------------------|
| 0 | 100 | 0 | 0 | 1.000 |
| 1 | 100 | 10 | 5 | 1.000 × (1 - 10/100) = 0.900 |
| 2 | 85 | 8 | 3 | 0.900 × (1 - 8/85) = 0.815 |
| 3 | 74 | 5 | 2 | 0.815 × (1 - 5/74) = 0.760 |

**Key Point:** At-risk set nᵢ decreases by:
- Events: removed permanently
- Censoring: removed at censoring time (contribute until then)

### Variance Estimation (Greenwood's Formula)

```
Var[Ŝ(t)] = Ŝ(t)² × ∑(tᵢ ≤ t) [dᵢ / (nᵢ × (nᵢ - dᵢ))]
```

**95% Confidence Interval (log-log transformation):**

```
Ŝ(t)^exp(±1.96 × SE[log(-log Ŝ(t))])
```

Where SE is the standard error derived from Greenwood's formula.

---

## Cox Proportional Hazards Model

### Model Specification

The **Cox model** relates the hazard at time t for an individual with covariates X to a baseline hazard:

```
h(t|X) = h₀(t) × exp(β₁X₁ + β₂X₂ + ... + βₚXₚ)
```

**Equivalent formulation:**

```
h(t|X) = h₀(t) × exp(β'X)
```

Where:
- h₀(t) = baseline hazard (arbitrary, unspecified function)
- β = vector of regression coefficients
- X = vector of covariates

### Proportional Hazards Assumption

For two individuals with covariate vectors X₁ and X₂:

```
h(t|X₁) / h(t|X₂) = exp(β'(X₁ - X₂))
```

This ratio is **constant over time** (proportional).

### Hazard Ratio

For a one-unit increase in covariate Xⱼ (holding others constant):

```
HR = exp(βⱼ)
```

**Interpretation:**
- HR > 1: Increased hazard (risk factor)
- HR < 1: Decreased hazard (protective factor)
- HR = 1: No effect

**Example:**
- If β₁ = 0.916 for smoking (Yes vs. No)
- HR = exp(0.916) = 2.50
- Smokers have 2.5× the hazard of lapsing compared to non-smokers

### Partial Likelihood

Cox uses **partial likelihood** (not full likelihood) to estimate β without specifying h₀(t):

```
L(β) = ∏ᵢ [exp(β'Xᵢ) / ∑ⱼ∈R(tᵢ) exp(β'Xⱼ)]^δᵢ
```

Where:
- Product over all observed event times
- R(tᵢ) = risk set at time tᵢ (all individuals still at risk)
- δᵢ = event indicator (1 if event, 0 if censored)

**Intuition:** At each event time, compares the "risk" of the individual who had the event to all who could have had it.

### Estimation

Maximize log partial likelihood:

```
log L(β) = ∑ᵢ δᵢ [β'Xᵢ - log(∑ⱼ∈R(tᵢ) exp(β'Xⱼ))]
```

Solved via **Newton-Raphson** or other iterative optimization.

### Baseline Hazard Estimation (Breslow)

After estimating β, the baseline cumulative hazard:

```
Ĥ₀(t) = ∑(tᵢ ≤ t) [dᵢ / ∑ⱼ∈R(tᵢ) exp(β̂'Xⱼ)]
```

### Predicted Survival

For an individual with covariates X:

```
Ŝ(t|X) = [Ŝ₀(t)]^exp(β̂'X)
```

Where Ŝ₀(t) = exp(-Ĥ₀(t)) is the baseline survival.

---

## Proportional Hazards Testing

### Schoenfeld Residuals

For covariate j, the **Schoenfeld residual** at event time tᵢ:

```
rⱼᵢ = Xⱼᵢ - X̄ⱼ(tᵢ)
```

Where X̄ⱼ(tᵢ) is the risk-weighted average of Xⱼ in the risk set at tᵢ.

**Test:** Regress scaled Schoenfeld residuals on time (or functions of time).
- **Null hypothesis:** β is constant over time (proportional hazards holds)
- **Test statistic:** Chi-square distributed
- **Rejection:** p < 0.05 suggests non-proportional hazards

### Global Test

```
χ² = ∑ⱼ χⱼ²
```

Tests proportional hazards for all covariates jointly.

---

## Concordance Index (C-Index)

### Definition

The **C-index** measures the proportion of all pairs of subjects where the model correctly predicts which one will experience the event first.

```
C = P(X̂ᵢ > X̂ⱼ | Tᵢ < Tⱼ)
```

Where:
- X̂ = predicted risk score (e.g., linear predictor β̂'X)
- T = observed event time

### Calculation

```
C = (# concordant pairs) / (# comparable pairs)
```

**Comparable pairs:** (i, j) where:
- Tᵢ < Tⱼ (i had event earlier)
- If j is censored, require Tⱼ > Tᵢ

**Concordant:** Model assigns higher risk to i than j

**Interpretation:**
- C = 0.5: Random prediction
- C = 0.7: Acceptable discrimination
- C = 0.8: Excellent discrimination
- C = 1.0: Perfect prediction

---

## Parametric Survival Models

### 1. Exponential Distribution

**Hazard:** Constant over time

```
h(t) = λ
S(t) = exp(-λt)
f(t) = λ × exp(-λt)
```

**Mean survival time:** 1/λ

**Use case:** Simplest model; appropriate when hazard is truly constant.

### 2. Weibull Distribution

**Hazard:** Monotonic (increasing or decreasing)

```
h(t) = λγ(λt)^(γ-1)
S(t) = exp(-(λt)^γ)
```

**Parameters:**
- λ = scale parameter
- γ = shape parameter

**Shape interpretation:**
- γ < 1: Decreasing hazard (early failures)
- γ = 1: Constant hazard (exponential)
- γ > 1: Increasing hazard (aging/wearout)

**Regression form:**

```
log T = β'X + σε
```

Where ε ~ extreme value distribution.

### 3. Log-Normal Distribution

**Hazard:** Non-monotonic (rises then falls)

```
S(t) = 1 - Φ((log t - μ) / σ)
```

Where Φ is the standard normal CDF.

**Use case:** When hazard increases initially but decreases later (e.g., infant mortality).

### 4. Gompertz Distribution

**Hazard:** Exponentially increasing (aging model)

```
h(t) = λ × exp(αt)
S(t) = exp((λ/α) × (1 - exp(αt)))
```

**Use case:** Mortality modeling (hazard accelerates with age).

### Regression with Covariates

For Weibull with covariates:

```
h(t|X) = λγ(λt)^(γ-1) × exp(β'X)
```

**Accelerated Failure Time (AFT) form:**

```
log T = μ + β'X + σε
```

Where:
- μ = intercept
- σ = scale parameter
- ε ~ distribution-specific error

**Interpretation of β in AFT:**
- β > 0: Covariate prolongs survival (protective)
- β < 0: Covariate shortens survival (risk factor)

This is opposite to PH models!

---

## Model Comparison

### Akaike Information Criterion (AIC)

```
AIC = -2 × log L + 2p
```

Where:
- log L = log-likelihood at maximum
- p = number of parameters

**Smaller AIC = better fit** (penalizes complexity)

### Bayesian Information Criterion (BIC)

```
BIC = -2 × log L + p × log(n)
```

Where n = sample size.

**BIC penalizes complexity more heavily** than AIC for large n.

### Likelihood Ratio Test

For nested models (e.g., Model 1 is a special case of Model 2):

```
LR = -2 × (log L₁ - log L₂)
```

Under H₀ (Model 1 is sufficient):

```
LR ~ χ²(df)
```

Where df = difference in number of parameters.

---

## Log-Rank Test

### Purpose
Test whether survival curves differ between k groups.

### Test Statistic

For two groups (can generalize to k):

```
χ² = (O₁ - E₁)² / Var(O₁ - E₁)
```

Where:
- O₁ = observed events in group 1
- E₁ = expected events in group 1 under H₀ (no difference)

**At each event time tᵢ:**

```
E₁ᵢ = n₁ᵢ × (dᵢ / nᵢ)
```

Where:
- n₁ᵢ = at risk in group 1 at tᵢ
- dᵢ = total events at tᵢ
- nᵢ = total at risk at tᵢ

**Variance:**

```
Var(O₁ - E₁) = ∑ᵢ [n₁ᵢ × n₂ᵢ × dᵢ × (nᵢ - dᵢ)] / [nᵢ² × (nᵢ - 1)]
```

### Distribution

Under H₀:

```
χ² ~ χ²(k-1)
```

For k groups, df = k - 1.

---

## Risk Score and Prediction

### Linear Predictor

From Cox model:

```
η̂ᵢ = β̂₁X₁ᵢ + β̂₂X₂ᵢ + ... + β̂ₚXₚᵢ
```

**Risk score:** exp(η̂ᵢ)

Higher η̂ᵢ → higher risk.

### Predicted Survival at Time t

```
Ŝ(t|Xᵢ) = [Ŝ₀(t)]^exp(η̂ᵢ)
```

**Example:**
- If Ŝ₀(5) = 0.70 (baseline 5-year survival)
- And exp(η̂ᵢ) = 2.0 (individual has twice baseline hazard)
- Then Ŝ(5|Xᵢ) = 0.70² = 0.49

---

## Time-Varying Covariates (Extension)

### Model

```
h(t|X(t)) = h₀(t) × exp(β'X(t))
```

Where X(t) can change over time.

### Data Structure

Use **counting process** format:

| ID | Start | Stop | Event | X₁ | X₂(t) |
|----|-------|------|-------|----|-------|
| 1 | 0 | 1 | 0 | 50 | 100 |
| 1 | 1 | 3 | 0 | 50 | 120 |
| 1 | 3 | 5 | 1 | 50 | 130 |

Each row is a time interval with constant covariates.

### Estimation

Same partial likelihood approach, but risk sets and covariates evaluated at each event time using current values.

---

## Competing Risks (Extension)

### Setup

Multiple event types (e.g., lapse, death, maturity).

### Cause-Specific Hazard

For event type k:

```
hₖ(t) = lim(Δt→0) [P(t ≤ T < t + Δt, type = k | T ≥ t) / Δt]
```

### Cumulative Incidence Function (CIF)

Probability of event type k by time t:

```
CIFₖ(t) = ∫₀ᵗ hₖ(u) × S(u) du
```

Where S(u) is the overall survival (no event of any type).

### Model

Fit separate Cox models for each cause-specific hazard.

---

## Software Implementation (R)

### Kaplan-Meier
```r
library(survival)
km_fit <- survfit(Surv(time, status) ~ group, data = df)
```

### Cox Model
```r
cox_fit <- coxph(Surv(time, status) ~ x1 + x2, data = df)
summary(cox_fit)
```

### Parametric Models
```r
library(flexsurv)
weibull_fit <- flexsurvreg(Surv(time, status) ~ x1 + x2, 
                           data = df, dist = "weibull")
```

### Proportional Hazards Test
```r
cox.zph(cox_fit)
```

### Predictions
```r
# Predicted risk score
risk_score <- predict(cox_fit, type = "lp")

# Predicted survival
pred_surv <- survfit(cox_fit, newdata = new_data)
```

---

## References

1. **Kleinbaum, D.G. & Klein, M.** (2012). *Survival Analysis: A Self-Learning Text* (3rd ed.). Springer.

2. **Therneau, T.M. & Grambsch, P.M.** (2000). *Modeling Survival Data: Extending the Cox Model*. Springer.

3. **Cox, D.R.** (1972). Regression Models and Life-Tables. *Journal of the Royal Statistical Society, Series B*, 34(2), 187-220.

4. **Kaplan, E.L. & Meier, P.** (1958). Nonparametric Estimation from Incomplete Observations. *Journal of the American Statistical Association*, 53(282), 457-481.

5. **Harrell, F.E. et al.** (1996). Multivariable Prognostic Models: Issues in Developing Models, Evaluating Assumptions and Adequacy, and Measuring and Reducing Errors. *Statistics in Medicine*, 15(4), 361-387.

---

## Notation Summary

| Symbol | Meaning |
|--------|---------|
| T | Random variable for time to event |
| t | Specific time point |
| S(t) | Survival function |
| h(t) | Hazard function |
| H(t) | Cumulative hazard function |
| f(t) | Probability density function |
| h₀(t) | Baseline hazard |
| β | Regression coefficients (vector) |
| X | Covariates (vector) |
| HR | Hazard ratio |
| δ | Event indicator (1 = event, 0 = censored) |
| n | Sample size |
| d | Number of events |
| λ | Scale parameter (exponential/Weibull) |
| γ | Shape parameter (Weibull) |
| μ | Location parameter (log-normal) |
| σ | Scale/dispersion parameter |

---

*This appendix provides the mathematical foundation for the survival analysis methods used in the project. For practical implementation, see the main R script.*

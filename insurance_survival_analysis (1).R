# =============================================================================
# Insurance Survival Analysis: Policyholder Lapse and Mortality
# =============================================================================
# Author: [Your Name]
# Date: [Current Date]
# Description: Comprehensive survival analysis of insurance policy lapses
#              and mortality using Kaplan-Meier, Cox PH, and parametric models
# =============================================================================

# Load required libraries
library(survival)
library(survminer)
library(dplyr)
library(ggplot2)
library(flexsurv)
library(tidyr)
library(gridExtra)

set.seed(42)

# =============================================================================
# 1. DATA GENERATION
# =============================================================================

generate_insurance_data <- function(n = 2000) {
  # Policyholder characteristics
  data <- data.frame(
    policy_id = 1:n,
    age = round(rnorm(n, mean = 45, sd = 12)),
    gender = sample(c("M", "F"), n, replace = TRUE, prob = c(0.48, 0.52)),
    smoker = sample(c("Yes", "No"), n, replace = TRUE, prob = c(0.15, 0.85)),
    policy_type = sample(c("Term", "Whole", "Universal"), n, 
                         replace = TRUE, prob = c(0.5, 0.3, 0.2)),
    premium_amount = round(rnorm(n, mean = 1200, sd = 400)),
    credit_score = round(rnorm(n, mean = 700, sd = 80)),
    num_dependents = sample(0:5, n, replace = TRUE, prob = c(0.15, 0.25, 0.30, 0.20, 0.08, 0.02)),
    policy_year = round(runif(n, min = 0, max = 15))
  )
  
  # Ensure age is reasonable
  data$age <- pmax(18, pmin(85, data$age))
  data$credit_score <- pmax(300, pmin(850, data$credit_score))
  data$premium_amount <- pmax(200, data$premium_amount)
  
  # Calculate baseline hazard rates based on realistic factors
  # Higher hazard = more likely to lapse/die sooner
  
  # LAPSE MODEL
  lapse_hazard <- 0.05 + 
    (data$age < 30) * 0.08 +                    # Young people lapse more
    (data$age > 65) * 0.04 +                    # Older people less likely to lapse
    (data$premium_amount > 1500) * 0.10 +       # High premiums increase lapse
    (data$credit_score < 650) * 0.12 +          # Poor credit increases lapse
    (data$smoker == "Yes") * 0.03 +             # Smokers slightly more likely to lapse
    (data$policy_type == "Term") * 0.06 +       # Term policies lapse more
    (data$num_dependents == 0) * 0.05 -         # No dependents = higher lapse
    (data$policy_year > 5) * 0.08               # Policies get stickier over time
  
  # MORTALITY MODEL (for life insurance claims)
  mortality_hazard <- 0.002 +
    (data$age - 18) * 0.0008 +                  # Age effect
    (data$smoker == "Yes") * 0.015 +            # Smoking dramatically increases mortality
    (data$gender == "M") * 0.005 +              # Males have slightly higher mortality
    ((data$age > 70) & (data$smoker == "Yes")) * 0.02  # Interaction effect
  
  # Generate time-to-event using exponential distribution
  # We'll generate both lapse and death times, then use the first event
  
  data$time_to_lapse <- rexp(n, rate = lapse_hazard)
  data$time_to_death <- rexp(n, rate = mortality_hazard)
  
  # Determine which event occurs first
  data$time_to_event <- pmin(data$time_to_lapse, data$time_to_death)
  data$event_type <- ifelse(data$time_to_lapse < data$time_to_death, "Lapse", "Death")
  
  # Censoring: some policies are still active at study end (15 years)
  study_end <- 15
  data$observed_time <- pmin(data$time_to_event, study_end)
  data$event_occurred <- as.integer(data$time_to_event <= study_end)
  
  # For lapse-only analysis
  data$lapse_occurred <- as.integer(
    (data$event_type == "Lapse") & (data$time_to_lapse <= study_end)
  )
  
  # For mortality-only analysis
  data$death_occurred <- as.integer(
    (data$event_type == "Death") & (data$time_to_death <= study_end)
  )
  
  # Round times
  data$observed_time <- round(data$observed_time, 2)
  
  # Create risk groups
  data$age_group <- cut(data$age, 
                        breaks = c(0, 30, 45, 60, 100),
                        labels = c("18-30", "31-45", "46-60", "60+"))
  
  data$premium_group <- cut(data$premium_amount,
                            breaks = quantile(data$premium_amount, c(0, 0.33, 0.67, 1)),
                            labels = c("Low", "Medium", "High"),
                            include.lowest = TRUE)
  
  return(data)
}

# Generate dataset
insurance_data <- generate_insurance_data(n = 2000)

# Display summary
cat("\n=== Dataset Summary ===\n")
cat("Total policies:", nrow(insurance_data), "\n")
cat("Lapse events:", sum(insurance_data$lapse_occurred), "\n")
cat("Death events:", sum(insurance_data$death_occurred), "\n")
cat("Censored policies:", sum(insurance_data$event_occurred == 0), "\n")
cat("Mean follow-up time:", round(mean(insurance_data$observed_time), 2), "years\n")

# =============================================================================
# 2. KAPLAN-MEIER SURVIVAL ANALYSIS
# =============================================================================

cat("\n=== KAPLAN-MEIER ANALYSIS ===\n")

# Overall survival (time until lapse)
km_fit_overall <- survfit(Surv(observed_time, lapse_occurred) ~ 1, 
                          data = insurance_data)

cat("\nOverall Lapse Survival:\n")
print(summary(km_fit_overall, times = c(1, 3, 5, 10)))

# Median survival time
cat("\nMedian time to lapse:", 
    round(summary(km_fit_overall)$table["median"], 2), "years\n")

# KM by age group
km_fit_age <- survfit(Surv(observed_time, lapse_occurred) ~ age_group, 
                      data = insurance_data)

# KM by smoker status
km_fit_smoker <- survfit(Surv(observed_time, lapse_occurred) ~ smoker, 
                         data = insurance_data)

# KM by policy type
km_fit_policy <- survfit(Surv(observed_time, lapse_occurred) ~ policy_type, 
                         data = insurance_data)

# Log-rank test for differences
logrank_age <- survdiff(Surv(observed_time, lapse_occurred) ~ age_group, 
                        data = insurance_data)
cat("\nLog-rank test (Age Group):\n")
print(logrank_age)

logrank_smoker <- survdiff(Surv(observed_time, lapse_occurred) ~ smoker, 
                           data = insurance_data)
cat("\nLog-rank test (Smoker Status):\n")
print(logrank_smoker)

# =============================================================================
# 3. COX PROPORTIONAL HAZARDS MODEL
# =============================================================================

cat("\n=== COX PROPORTIONAL HAZARDS MODEL ===\n")

# Fit Cox model for lapse
cox_lapse <- coxph(Surv(observed_time, lapse_occurred) ~ 
                     age + gender + smoker + policy_type + 
                     premium_amount + credit_score + num_dependents,
                   data = insurance_data)

cat("\nCox Model Summary (Lapse):\n")
print(summary(cox_lapse))

# Check proportional hazards assumption
cox_zph <- cox.zph(cox_lapse)
cat("\nProportional Hazards Test:\n")
print(cox_zph)

# Hazard ratios with confidence intervals
hr_table <- data.frame(
  Variable = names(coef(cox_lapse)),
  HR = exp(coef(cox_lapse)),
  Lower_95 = exp(confint(cox_lapse)[, 1]),
  Upper_95 = exp(confint(cox_lapse)[, 2]),
  P_value = summary(cox_lapse)$coefficients[, 5]
)
rownames(hr_table) <- NULL

cat("\nHazard Ratios:\n")
print(hr_table, digits = 3)

# Concordance index (C-index)
cat("\nConcordance Index:", round(cox_lapse$concordance["concordance"], 3), "\n")

# =============================================================================
# 4. PARAMETRIC SURVIVAL MODELS
# =============================================================================

cat("\n=== PARAMETRIC SURVIVAL MODELS ===\n")

# Fit different parametric distributions
models <- list(
  exponential = flexsurvreg(Surv(observed_time, lapse_occurred) ~ 
                              age + smoker + premium_amount + credit_score,
                            data = insurance_data, dist = "exp"),
  
  weibull = flexsurvreg(Surv(observed_time, lapse_occurred) ~ 
                          age + smoker + premium_amount + credit_score,
                        data = insurance_data, dist = "weibull"),
  
  lognormal = flexsurvreg(Surv(observed_time, lapse_occurred) ~ 
                            age + smoker + premium_amount + credit_score,
                          data = insurance_data, dist = "lognormal"),
  
  gompertz = flexsurvreg(Surv(observed_time, lapse_occurred) ~ 
                           age + smoker + premium_amount + credit_score,
                         data = insurance_data, dist = "gompertz")
)

# Compare models using AIC
aic_comparison <- data.frame(
  Model = names(models),
  AIC = sapply(models, function(x) x$AIC),
  BIC = sapply(models, function(x) AIC(x, k = log(nrow(insurance_data))))
)
aic_comparison <- aic_comparison[order(aic_comparison$AIC), ]

cat("\nModel Comparison (AIC/BIC):\n")
print(aic_comparison, row.names = FALSE)

# Best model
best_model_name <- aic_comparison$Model[1]
best_model <- models[[best_model_name]]

cat("\nBest fitting model:", best_model_name, "\n")
cat("\nBest Model Summary:\n")
print(best_model)

# =============================================================================
# 5. MORTALITY ANALYSIS (Separate Analysis)
# =============================================================================

cat("\n=== MORTALITY ANALYSIS ===\n")

# Cox model for mortality
cox_mortality <- coxph(Surv(observed_time, death_occurred) ~ 
                         age + gender + smoker,
                       data = insurance_data)

cat("\nCox Model Summary (Mortality):\n")
print(summary(cox_mortality))

# Mortality hazard ratios
hr_mortality <- data.frame(
  Variable = names(coef(cox_mortality)),
  HR = exp(coef(cox_mortality)),
  Lower_95 = exp(confint(cox_mortality)[, 1]),
  Upper_95 = exp(confint(cox_mortality)[, 2]),
  P_value = summary(cox_mortality)$coefficients[, 5]
)
rownames(hr_mortality) <- NULL

cat("\nMortality Hazard Ratios:\n")
print(hr_mortality, digits = 3)

# =============================================================================
# 6. VISUALIZATIONS
# =============================================================================

cat("\n=== Creating Visualizations ===\n")

# Plot 1: Overall KM curve
p1 <- ggsurvplot(km_fit_overall,
                 data = insurance_data,
                 conf.int = TRUE,
                 risk.table = TRUE,
                 title = "Overall Policy Lapse Survival Curve",
                 xlab = "Time (years)",
                 ylab = "Survival Probability (No Lapse)",
                 palette = "#2E9FDF",
                 ggtheme = theme_minimal())

# Plot 2: KM by age group
p2 <- ggsurvplot(km_fit_age,
                 data = insurance_data,
                 conf.int = TRUE,
                 pval = TRUE,
                 risk.table = TRUE,
                 title = "Policy Lapse by Age Group",
                 xlab = "Time (years)",
                 ylab = "Survival Probability",
                 legend.title = "Age Group",
                 ggtheme = theme_minimal())

# Plot 3: KM by smoker status
p3 <- ggsurvplot(km_fit_smoker,
                 data = insurance_data,
                 conf.int = TRUE,
                 pval = TRUE,
                 risk.table = TRUE,
                 title = "Policy Lapse by Smoker Status",
                 xlab = "Time (years)",
                 ylab = "Survival Probability",
                 legend.title = "Smoker",
                 palette = c("#E7B800", "#2E9FDF"),
                 ggtheme = theme_minimal())

# Plot 4: KM by policy type
p4 <- ggsurvplot(km_fit_policy,
                 data = insurance_data,
                 conf.int = TRUE,
                 pval = TRUE,
                 risk.table = TRUE,
                 title = "Policy Lapse by Policy Type",
                 xlab = "Time (years)",
                 ylab = "Survival Probability",
                 legend.title = "Policy Type",
                 ggtheme = theme_minimal())

# Plot 5: Hazard ratio forest plot
hr_plot_data <- hr_table[hr_table$P_value < 0.05, ]

if(nrow(hr_plot_data) > 0) {
  p5 <- ggplot(hr_plot_data, aes(x = HR, y = reorder(Variable, HR))) +
    geom_point(size = 3, color = "#2E9FDF") +
    geom_errorbarh(aes(xmin = Lower_95, xmax = Upper_95), height = 0.2) +
    geom_vline(xintercept = 1, linetype = "dashed", color = "red") +
    labs(title = "Hazard Ratios for Policy Lapse (Significant Predictors)",
         x = "Hazard Ratio (95% CI)",
         y = "Variable") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5))
}

# Plot 6: Parametric model comparison
param_plot_data <- data.frame(
  time = seq(0, 15, by = 0.1)
)

# Get predictions from best model for average covariate values
avg_covariates <- data.frame(
  age = mean(insurance_data$age),
  smoker = "No",
  premium_amount = mean(insurance_data$premium_amount),
  credit_score = mean(insurance_data$credit_score)
)

pred_surv <- summary(best_model, 
                     newdata = avg_covariates, 
                     t = param_plot_data$time, 
                     type = "survival")

param_plot_data$survival <- pred_surv[[1]]$est

p6 <- ggplot(param_plot_data, aes(x = time, y = survival)) +
  geom_line(color = "#2E9FDF", size = 1) +
  labs(title = paste("Predicted Survival Curve -", best_model_name, "Model"),
       subtitle = "Average Policyholder Profile",
       x = "Time (years)",
       y = "Survival Probability") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5))

# Save plots
ggsave("km_overall.png", plot = p1$plot, width = 10, height = 6, dpi = 300)
ggsave("km_age.png", plot = p2$plot, width = 10, height = 8, dpi = 300)
ggsave("km_smoker.png", plot = p3$plot, width = 10, height = 8, dpi = 300)
ggsave("km_policy_type.png", plot = p4$plot, width = 10, height = 8, dpi = 300)

if(exists("p5")) {
  ggsave("hazard_ratios.png", plot = p5, width = 10, height = 6, dpi = 300)
}

ggsave("parametric_survival.png", plot = p6, width = 10, height = 6, dpi = 300)

# =============================================================================
# 7. RISK SCORING AND PREDICTIONS
# =============================================================================

cat("\n=== RISK SCORING ===\n")

# Calculate risk scores (linear predictor from Cox model)
insurance_data$lapse_risk_score <- predict(cox_lapse, type = "lp")

# Categorize into risk groups
insurance_data$risk_category <- cut(insurance_data$lapse_risk_score,
                                     breaks = quantile(insurance_data$lapse_risk_score, 
                                                      c(0, 0.33, 0.67, 1)),
                                     labels = c("Low Risk", "Medium Risk", "High Risk"),
                                     include.lowest = TRUE)

# Risk group summary
risk_summary <- insurance_data %>%
  group_by(risk_category) %>%
  summarise(
    N = n(),
    Lapse_Rate = mean(lapse_occurred),
    Avg_Premium = mean(premium_amount),
    Avg_Age = mean(age),
    Pct_Smoker = mean(smoker == "Yes") * 100
  )

cat("\nRisk Group Summary:\n")
print(risk_summary, digits = 3)

# =============================================================================
# 8. EXPORT RESULTS
# =============================================================================

# Save dataset
write.csv(insurance_data, "insurance_survival_data.csv", row.names = FALSE)

# Save model results
sink("model_results.txt")
cat("=== INSURANCE SURVIVAL ANALYSIS RESULTS ===\n\n")
cat("Dataset: ", nrow(insurance_data), "policies\n\n")
cat("--- KAPLAN-MEIER RESULTS ---\n")
print(summary(km_fit_overall, times = c(1, 3, 5, 10)))
cat("\n--- COX MODEL (LAPSE) ---\n")
print(summary(cox_lapse))
cat("\n--- HAZARD RATIOS ---\n")
print(hr_table)
cat("\n--- MODEL COMPARISON ---\n")
print(aic_comparison)
cat("\n--- BEST PARAMETRIC MODEL ---\n")
print(best_model)
cat("\n--- MORTALITY ANALYSIS ---\n")
print(summary(cox_mortality))
cat("\n--- RISK GROUPS ---\n")
print(risk_summary)
sink()

cat("\n=== Analysis Complete ===\n")
cat("Results saved to:\n")
cat("  - insurance_survival_data.csv\n")
cat("  - model_results.txt\n")
cat("  - km_overall.png\n")
cat("  - km_age.png\n")
cat("  - km_smoker.png\n")
cat("  - km_policy_type.png\n")
cat("  - hazard_ratios.png\n")
cat("  - parametric_survival.png\n")

cat("\n=== Key Findings ===\n")
cat("1. Median time to lapse:", round(summary(km_fit_overall)$table["median"], 2), "years\n")
cat("2. C-index (Cox model):", round(cox_lapse$concordance["concordance"], 3), "\n")
cat("3. Best parametric model:", best_model_name, "\n")
cat("4. Significant predictors: ", 
    sum(hr_table$P_value < 0.05), "/", nrow(hr_table), "\n")

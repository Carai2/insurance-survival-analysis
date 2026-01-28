# Installation and Setup Guide

## Prerequisites

### R Version
- R version ≥ 4.0.0 recommended
- Download from: https://cran.r-project.org/

### RStudio (Optional but Recommended)
- Download from: https://posit.co/download/rstudio-desktop/

## Package Installation

### Method 1: Automatic Installation

Run this in your R console:

```r
# Install required packages
required_packages <- c(
  "survival",      # Core survival analysis
  "survminer",     # Survival visualization
  "dplyr",         # Data manipulation
  "ggplot2",       # Graphics
  "flexsurv",      # Parametric survival models
  "tidyr",         # Data tidying
  "gridExtra"      # Multiple plots
)

# Check and install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

# Load all packages
lapply(required_packages, library, character.only = TRUE)
```

### Method 2: Manual Installation

```r
install.packages("survival")
install.packages("survminer")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("flexsurv")
install.packages("tidyr")
install.packages("gridExtra")
```

## Package Versions (as of 2024)

| Package | Version | Purpose |
|---------|---------|---------|
| survival | 3.5+ | Survival analysis foundation |
| survminer | 0.4.9+ | Enhanced KM plots |
| flexsurv | 2.2+ | Parametric survival models |
| ggplot2 | 3.4+ | Data visualization |
| dplyr | 1.1+ | Data manipulation |
| tidyr | 1.3+ | Data reshaping |
| gridExtra | 2.3+ | Plot arrangement |

## Quick Start

### Step 1: Download Files
Download these files to your working directory:
- `insurance_survival_analysis.R` (main script)
- `README.md` (documentation)

### Step 2: Set Working Directory

```r
# In RStudio: Session > Set Working Directory > Choose Directory
# Or manually:
setwd("path/to/your/project/folder")
```

### Step 3: Run the Analysis

```r
# Source the entire script
source("insurance_survival_analysis.R")
```

**Expected runtime:** 30-60 seconds

### Step 4: View Outputs

After running, you'll have:

**Data files:**
- `insurance_survival_data.csv` (2,000 policies with risk scores)
- `model_results.txt` (full statistical output)

**Visualizations:**
- `km_overall.png` (overall survival curve)
- `km_age.png` (survival by age group)
- `km_smoker.png` (survival by smoker status)
- `km_policy_type.png` (survival by policy type)
- `hazard_ratios.png` (forest plot of HRs)
- `parametric_survival.png` (best parametric model)

## Troubleshooting

### Issue: Package installation fails

**Solution:**
```r
# Try installing from a different mirror
chooseCRANmirror()
# Or specify a mirror directly
install.packages("survival", repos = "https://cloud.r-project.org")
```

### Issue: "Could not find function" error

**Solution:**
```r
# Make sure all packages are loaded
library(survival)
library(survminer)
library(flexsurv)
library(ggplot2)
library(dplyr)
```

### Issue: Plots don't appear

**Solution:**
```r
# Check your working directory
getwd()

# List files in directory
list.files(pattern = "\\.png$")

# Explicitly save a plot
ggsave("test_plot.png", plot = last_plot())
```

### Issue: Memory errors (unlikely with 2000 rows)

**Solution:**
```r
# Increase memory limit (Windows)
memory.limit(size = 4000)

# Or reduce sample size in generate_insurance_data()
insurance_data <- generate_insurance_data(n = 1000)  # Instead of 2000
```

## Customization

### Change Sample Size

```r
# In the script, modify line:
insurance_data <- generate_insurance_data(n = 5000)  # Larger sample
```

### Modify Study Duration

```r
# In generate_insurance_data function, change:
study_end <- 20  # Instead of 15 years
```

### Add Your Own Variables

```r
# In the data.frame() within generate_insurance_data(), add:
new_variable = sample(c("Category1", "Category2"), n, replace = TRUE)

# Then include in Cox model:
cox_lapse <- coxph(Surv(observed_time, lapse_occurred) ~ 
                     age + gender + smoker + new_variable, ...)
```

### Change Plot Themes

```r
# Replace theme_minimal() with:
theme_bw()      # Black and white
theme_classic() # Classic look
theme_light()   # Light background
```

## Running Sections Independently

You can run the script in sections:

### Just generate data:
```r
source("insurance_survival_analysis.R")
# Stop after "DATA GENERATION" section
```

### Just run KM analysis:
```r
# After generating data:
km_fit_overall <- survfit(Surv(observed_time, lapse_occurred) ~ 1, 
                          data = insurance_data)
print(km_fit_overall)
```

### Just run Cox model:
```r
cox_lapse <- coxph(Surv(observed_time, lapse_occurred) ~ 
                     age + gender + smoker + policy_type + 
                     premium_amount + credit_score + num_dependents,
                   data = insurance_data)
summary(cox_lapse)
```

## Advanced: Running from Command Line

```bash
# Navigate to project directory
cd /path/to/project

# Run script
Rscript insurance_survival_analysis.R

# Or with output to log file
Rscript insurance_survival_analysis.R > analysis_log.txt 2>&1

## System Requirements

- **RAM:** 1+ GB (2000 rows is very light)
- **Storage:** ~50 MB for outputs
- **OS:** Windows, macOS, or Linux (R is cross-platform)

## Getting Help

### R Documentation
```r
?survfit       # Kaplan-Meier help
?coxph         # Cox model help
?flexsurvreg   # Parametric models help
```

### Package Vignettes
```r
browseVignettes("survival")
browseVignettes("survminer")
```

### Online Resources
- **Survival package manual:** https://cran.r-project.org/web/packages/survival/
- **Survminer tutorials:** http://www.sthda.com/english/wiki/survival-analysis
- **Stack Overflow:** Search "R survival analysis"

# ==============================================================================
# Tech Employment Analysis Script for Canada (2011-2025)
# ==============================================================================

# Load required libraries with error handling
required_packages <- c("tidyverse", "lubridate", "forecast")
optional_packages <- c("bcp", "corrplot", "knitr", "kableExtra")

# Load essential packages
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    cat("Essential package", pkg, "is not installed.\n")
    cat(" Please run: install.packages('", pkg, "')\n", sep = "")
    stop("Missing required package: ", pkg)
  }
}

# Try to load optional packages
bcp_available <- FALSE
corrplot_available <- FALSE
knitr_available <- FALSE

for (pkg in optional_packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(" ", pkg, "loaded successfully\n")
    if (pkg == "bcp") bcp_available <- TRUE
    if (pkg == "corrplot") corrplot_available <- TRUE
    if (pkg == "knitr") knitr_available <- TRUE
  } else {
    cat(" ", pkg, "not available - some advanced features will be skipped\n")
  }
}

# Load cleaned data
print(" Loading cleaned data...")
load("data/processed/tech_employment_clean.RData")

# Or read from CSV if RData not available
# tech_data_clean <- read_csv("data/processed/tech_employment_clean.csv")

# ==============================================================================
# 1. EMPLOYMENT TRENDS ANALYSIS
# ==============================================================================

print("📈 Analyzing employment trends...")

# Calculate year-over-year growth rates
employment_trends <- tech_data_clean %>%
  filter(labor_type == "Employment") %>%
  arrange(tech_sector, date) %>%
  group_by(tech_sector) %>%
  mutate(
    yoy_growth = (value_scaled / lag(value_scaled, 12) - 1) * 100,
    yoy_change = value_scaled - lag(value_scaled, 12),
    monthly_growth = (value_scaled / lag(value_scaled, 1) - 1) * 100
  ) %>%
  ungroup()

# Calculate annual averages
annual_employment <- employment_trends %>%
  group_by(tech_sector, year) %>%
  summarise(
    avg_employment = mean(value_scaled, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(tech_sector, year) %>%
  group_by(tech_sector) %>%
  mutate(
    annual_growth = (avg_employment / lag(avg_employment) - 1) * 100,
    annual_change = avg_employment - lag(avg_employment)
  ) %>%
  ungroup()

# ==============================================================================
# 2. UNEMPLOYMENT ANALYSIS
# ==============================================================================

print(" Analyzing unemployment trends...")

unemployment_analysis <- tech_data_clean %>%
  filter(labor_type %in% c("Unemployment", "Unemployment Rate")) %>%
  pivot_wider(
    names_from = labor_type,
    values_from = value_scaled,
    names_prefix = "unemp_"
  ) %>%
  clean_names() %>%
  arrange(tech_sector, date) %>%
  group_by(tech_sector) %>%
  mutate(
    unemployment_change = unemp_unemployment - lag(unemp_unemployment, 12),
    rate_change = unemp_unemployment_rate - lag(unemp_unemployment_rate, 12)
  ) %>%
  ungroup()

# ==============================================================================
# 3. COMPARATIVE ANALYSIS BETWEEN SECTORS
# ==============================================================================

print(" Comparing sectors...")

sector_comparison <- tech_data_clean %>%
  filter(labor_type == "Employment") %>%
  group_by(tech_sector, year) %>%
  summarise(
    avg_employment = mean(value_scaled, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from = tech_sector,
    values_from = avg_employment,
    names_prefix = "sector_"
  ) %>%
  clean_names() %>%
  mutate(
    total_tech_employment = sector_professional_technical_services + sector_information_culture,
    prof_tech_share = (sector_professional_technical_services / total_tech_employment) * 100,
    info_culture_share = (sector_information_culture / total_tech_employment) * 100
  )

# ==============================================================================
# 4. SEASONAL ANALYSIS
# ==============================================================================

print("🗓️ Analyzing seasonal patterns...")

seasonal_analysis <- tech_data_clean %>%
  filter(labor_type == "Employment") %>%
  group_by(tech_sector, month) %>%
  summarise(
    avg_employment = mean(value_scaled, na.rm = TRUE),
    median_employment = median(value_scaled, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(tech_sector, month) %>%
  group_by(tech_sector) %>%
  mutate(
    seasonal_index = (avg_employment / mean(avg_employment)) * 100
  ) %>%
  ungroup()

# ==============================================================================
# 5. GROWTH RATE ANALYSIS
# ==============================================================================

print(" Calculating growth statistics...")

growth_summary <- annual_employment %>%
  filter(!is.na(annual_growth)) %>%
  group_by(tech_sector) %>%
  summarise(
    avg_growth_rate = mean(annual_growth, na.rm = TRUE),
    median_growth_rate = median(annual_growth, na.rm = TRUE),
    min_growth_rate = min(annual_growth, na.rm = TRUE),
    max_growth_rate = max(annual_growth, na.rm = TRUE),
    sd_growth_rate = sd(annual_growth, na.rm = TRUE),
    cv_growth_rate = sd_growth_rate / abs(avg_growth_rate),
    years_positive_growth = sum(annual_growth > 0, na.rm = TRUE),
    years_negative_growth = sum(annual_growth < 0, na.rm = TRUE),
    .groups = "drop"
  )

# ==============================================================================
# 6. CORRELATION ANALYSIS 
# ==============================================================================

print(" Analyzing correlations...")

correlation_data <- tech_data_clean %>%
  select(date, tech_sector, labor_type, value_scaled) %>%
  pivot_wider(
    names_from = c(tech_sector, labor_type),
    values_from = value_scaled,
    names_sep = "_"
  ) %>%
  select(-date) %>%
  cor(use = "complete.obs")

# Plot correlation matrix if corrplot is available
if (corrplot_available) {
  png("data/processed/correlation_plot.png", width = 800, height = 600)
  corrplot(correlation_data, method = "color", type = "upper", 
           order = "hclust", tl.cex = 0.8, tl.col = "black")
  dev.off()
  cat(" Correlation plot saved to: data/processed/correlation_plot.png\n")
}

# ==============================================================================
# 7. RECENT TRENDS (2020-2025)
# ==============================================================================

print(" Analyzing recent trends...")

recent_trends <- tech_data_clean %>%
  filter(
    year >= 2020,
    labor_type == "Employment"
  ) %>%
  arrange(tech_sector, date) %>%
  group_by(tech_sector) %>%
  mutate(
    trend_index = (value_scaled / first(value_scaled)) * 100,
    recovery_indicator = case_when(
      trend_index > 100 ~ "Above pre-2020 levels",
      trend_index >= 95 ~ "Near pre-2020 levels",
      TRUE ~ "Below pre-2020 levels"
    )
  ) %>%
  ungroup()

# ==============================================================================
# 8. SUMMARY STATISTICS
# ==============================================================================

print(" Creating summary tables...")

# Overall summary
overall_summary <- tech_data_clean %>%
  group_by(tech_sector, labor_type) %>%
  summarise(
    min_value = min(value_scaled, na.rm = TRUE),
    max_value = max(value_scaled, na.rm = TRUE),
    mean_value = mean(value_scaled, na.rm = TRUE),
    median_value = median(value_scaled, na.rm = TRUE),
    sd_value = sd(value_scaled, na.rm = TRUE),
    records = n(),
    .groups = "drop"
  )

# Peak and trough analysis
peak_trough <- tech_data_clean %>%
  filter(labor_type == "Employment") %>%
  group_by(tech_sector) %>%
  summarise(
    peak_value = max(value_scaled, na.rm = TRUE),
    peak_date = date[which.max(value_scaled)],
    trough_value = min(value_scaled, na.rm = TRUE),
    trough_date = date[which.min(value_scaled)],
    .groups = "drop"
  )

# ==============================================================================
# 9. EXPORT RESULTS
# ==============================================================================

print(" Saving analysis results...")

# Save main datasets
write_csv(employment_trends, "data/processed/employment_trends.csv")
write_csv(unemployment_analysis, "data/processed/unemployment_analysis.csv")
write_csv(sector_comparison, "data/processed/sector_comparison.csv")
write_csv(seasonal_analysis, "data/processed/seasonal_analysis.csv")
write_csv(growth_summary, "data/processed/growth_summary.csv")
write_csv(recent_trends, "data/processed/recent_trends.csv")
write_csv(overall_summary, "data/processed/overall_summary.csv")
write_csv(peak_trough, "data/processed/peak_trough.csv")

# Save correlation matrix
write_csv(as.data.frame(correlation_data), "data/processed/correlation_matrix.csv")

# Save all analysis objects
save(
  employment_trends, unemployment_analysis, sector_comparison,
  seasonal_analysis, growth_summary, recent_trends, overall_summary,
  peak_trough, correlation_data,
  file = "data/processed/tech_employment_analysis.RData"
)

print(" Analysis completed successfully!")
print(" Analysis files saved:")
print("  - employment_trends.csv")
print("  - unemployment_analysis.csv") 
print("  - sector_comparison.csv")
print("  - seasonal_analysis.csv")
print("  - growth_summary.csv")
print("  - recent_trends.csv")
print("  - overall_summary.csv")
print("  - peak_trough.csv")
print("  - correlation_matrix.csv")
print("  - tech_employment_analysis.RData")

# Display key insights
print("\n📊 KEY INSIGHTS:")
print("================")
print("Growth Summary:")
print(growth_summary)
print("\nPeak & Trough Analysis:")
print(peak_trough)
print("\nRecent Recovery Status:")
recent_status <- recent_trends %>%
  filter(date == max(date)) %>%
  select(tech_sector, recovery_indicator)
print(recent_status)
# ==============================================================================
# Advanced Tech Employment Analysis Script for Canada (2011-2025)
# ==============================================================================

# Load required libraries with error handling
essential_packages <- c("tidyverse", "forecast", "tseries")
advanced_packages <- c("changepoint", "bcp", "VARselect", "vars", "urca", "broom", "modelr")

# Load essential packages
for (pkg in essential_packages) {
  if (!require(pkg, character.only = TRUE)) {
    cat("Essential package", pkg, "is not installed.\n")
    cat("Please run: install.packages('", pkg, "')\n", sep = "")
    stop("Missing required package: ", pkg)
  }
}

# Check availability of advanced packages
changepoint_available <- require("changepoint", quietly = TRUE)
bcp_available <- require("bcp", quietly = TRUE)
vars_available <- require("vars", quietly = TRUE) && require("VARselect", quietly = TRUE)
broom_available <- require("broom", quietly = TRUE)

cat("Package availability check:\n")
cat("  Essential packages: loaded\n")
cat("  changepoint:", ifelse(changepoint_available, "available", "not available"), "\n")
cat("  bcp:", ifelse(bcp_available, "available", "not available"), "\n")
cat("  VAR analysis:", ifelse(vars_available, "available", "not available"), "\n")
cat("  broom:", ifelse(broom_available, "available", "not available"), "\n")

# Load data
print("Loading data for advanced analysis...")
load("data/processed/tech_employment_analysis.RData")
load("data/processed/tech_employment_clean.RData")

# ==============================================================================
# 1. TIME SERIES ANALYSIS & FORECASTING
# ==============================================================================

print("Performing time series analysis and forecasting...")

# Prepare time series data
ts_data <- employment_trends %>%
  filter(!is.na(value_scaled)) %>%
  arrange(tech_sector, date) %>%
  group_by(tech_sector) %>%
  mutate(
    employment_ts = ts(value_scaled, frequency = 12, start = c(2011, 1))
  ) %>%
  ungroup()

# Perform time series analysis for each sector
forecast_results <- list()

for(sector in unique(ts_data$tech_sector)) {
  sector_data <- ts_data %>%
    filter(tech_sector == sector) %>%
    arrange(date)
  
  # Create time series object
  employment_ts <- ts(sector_data$value_scaled, frequency = 12, 
                      start = c(year(min(sector_data$date)), month(min(sector_data$date))))
  
  # Decomposition
  decomp <- decompose(employment_ts, type = "additive")
  
  # Stationarity test
  adf_test <- adf.test(employment_ts)
  
  # Auto ARIMA model
  arima_model <- auto.arima(employment_ts, seasonal = TRUE, stepwise = FALSE)
  
  # Forecast 12 months ahead
  forecast_12m <- forecast(arima_model, h = 12)
  
  # Store results
  forecast_results[[sector]] <- list(
    sector = sector,
    model = arima_model,
    forecast = forecast_12m,
    decomposition = decomp,
    adf_test = adf_test,
    aic = AIC(arima_model),
    bic = BIC(arima_model)
  )
}

# ==============================================================================
# 2. STRUCTURAL BREAK ANALYSIS (if available)
# ==============================================================================

if (changepoint_available) {
  print("Analyzing structural breaks...")
  
  structural_breaks <- list()
  
  for(sector in unique(ts_data$tech_sector)) {
    sector_data <- ts_data %>%
      filter(tech_sector == sector) %>%
      arrange(date)
    
    # Changepoint detection
    cpt_mean <- cpt.mean(sector_data$value_scaled, method = "PELT")
    
    structural_breaks[[sector]] <- list(
      sector = sector,
      changepoints_mean = cpts(cpt_mean),
      break_dates = sector_data$date[cpts(cpt_mean)]
    )
  }
} else {
  print("Structural break analysis skipped - changepoint package not available")
  structural_breaks <- list()
}

# ==============================================================================
# 3. CYCLICAL ANALYSIS
# ==============================================================================

print("Analyzing business cycles...")

# Simple HP filter function if package not available
simple_hp_filter <- function(x, lambda = 1600) {
  n <- length(x)
  I <- diag(n)
  D <- diff(I, differences = 2)
  trend <- solve(I + lambda * t(D) %*% D) %*% x
  cycle <- x - trend
  list(trend = as.numeric(trend), cycle = as.numeric(cycle))
}

cyclical_analysis <- list()

for(sector in unique(ts_data$tech_sector)) {
  sector_data <- ts_data %>%
    filter(tech_sector == sector) %>%
    arrange(date)
  
  # HP filter for trend and cycle
  hp_filter <- simple_hp_filter(sector_data$value_scaled)
  
  # Cycle characteristics
  cycle_data <- tibble(
    date = sector_data$date,
    trend = hp_filter$trend,
    cycle = hp_filter$cycle
  )
  
  # Identify peaks and troughs
  peaks <- which(diff(sign(diff(cycle_data$cycle))) == -2) + 1
  troughs <- which(diff(sign(diff(cycle_data$cycle))) == 2) + 1
  
  cyclical_analysis[[sector]] <- list(
    sector = sector,
    cycle_data = cycle_data,
    peaks = peaks,
    troughs = troughs,
    cycle_length = mean(diff(peaks), na.rm = TRUE),
    cycle_amplitude = sd(cycle_data$cycle, na.rm = TRUE)
  )
}

# ==============================================================================
# 4. VOLATILITY ANALYSIS
# ==============================================================================

print("Analyzing employment volatility...")

volatility_analysis <- employment_trends %>%
  filter(!is.na(yoy_growth)) %>%
  group_by(tech_sector) %>%
  summarise(
    volatility = sd(yoy_growth, na.rm = TRUE),
    mean_growth = mean(yoy_growth, na.rm = TRUE),
    cv = abs(volatility / mean_growth),
    downside_volatility = sd(yoy_growth[yoy_growth < 0], na.rm = TRUE),
    upside_volatility = sd(yoy_growth[yoy_growth > 0], na.rm = TRUE),
    max_drawdown = max(cummax(yoy_growth) - yoy_growth, na.rm = TRUE),
    sharpe_ratio = mean_growth / volatility,
    .groups = "drop"
  ) %>%
  arrange(desc(volatility))

# ==============================================================================
# 5. REGIME ANALYSIS
# ==============================================================================

print("Identifying employment regimes...")

regime_analysis <- list()

for(sector in unique(ts_data$tech_sector)) {
  sector_data <- ts_data %>%
    filter(tech_sector == sector) %>%
    arrange(date)
  
  # K-means clustering for regime identification
  growth_data <- sector_data %>%
    filter(!is.na(yoy_growth)) %>%
    select(yoy_growth)
  
  set.seed(123)
  kmeans_result <- kmeans(growth_data$yoy_growth, centers = 3, nstart = 25)
  
  # Assign regimes
  regime_data <- sector_data %>%
    filter(!is.na(yoy_growth)) %>%
    mutate(
      regime = kmeans_result$cluster,
      regime_label = case_when(
        regime == which.max(kmeans_result$centers) ~ "High Growth",
        regime == which.min(kmeans_result$centers) ~ "Low Growth",
        TRUE ~ "Moderate Growth"
      )
    )
  
  regime_analysis[[sector]] <- list(
    sector = sector,
    regime_data = regime_data,
    regime_centers = kmeans_result$centers,
    regime_summary = regime_data %>%
      group_by(regime_label) %>%
      summarise(
        count = n(),
        avg_growth = mean(yoy_growth, na.rm = TRUE),
        duration = n() / 12,  # years
        .groups = "drop"
      )
  )
}

# ==============================================================================
# 6. CORRELATION AND CAUSALITY ANALYSIS
# ==============================================================================

print("Analyzing correlations and causality...")

# Prepare data for VAR analysis
var_data <- tech_data_clean %>%
  filter(labor_type == "Employment") %>%
  select(date, tech_sector, value_scaled) %>%
  pivot_wider(names_from = tech_sector, values_from = value_scaled) %>%
  arrange(date) %>%
  na.omit()

# Vector Autoregression (VAR) analysis if packages available
if(vars_available && ncol(var_data) > 2) {
  # Select optimal lag length
  var_select <- VARselect(var_data[, -1], lag.max = 12, type = "const")
  optimal_lags <- var_select$selection["AIC(n)"]
  
  # Fit VAR model
  var_model <- VAR(var_data[, -1], p = optimal_lags, type = "const")
  
  # Granger causality tests
  granger_tests <- list()
  sectors <- names(var_data)[-1]
  
  for(i in 1:length(sectors)) {
    for(j in 1:length(sectors)) {
      if(i != j) {
        granger_test <- causality(var_model, cause = sectors[i])
        granger_tests[[paste(sectors[i], "->", sectors[j])]] <- granger_test
      }
    }
  }
  
  # Impulse response analysis
  irf_analysis <- irf(var_model, n.ahead = 12)
} else {
  print("VAR analysis skipped - required packages not available or insufficient data")
  granger_tests <- list()
  irf_analysis <- NULL
}

# ==============================================================================
# 7. RISK ANALYSIS
# ==============================================================================

print("Performing risk analysis...")

risk_analysis <- employment_trends %>%
  filter(!is.na(yoy_growth)) %>%
  group_by(tech_sector) %>%
  summarise(
    # Value at Risk (VaR)
    var_5pct = quantile(yoy_growth, 0.05, na.rm = TRUE),
    var_1pct = quantile(yoy_growth, 0.01, na.rm = TRUE),
    # Expected Shortfall
    es_5pct = mean(yoy_growth[yoy_growth <= quantile(yoy_growth, 0.05, na.rm = TRUE)], na.rm = TRUE),
    es_1pct = mean(yoy_growth[yoy_growth <= quantile(yoy_growth, 0.01, na.rm = TRUE)], na.rm = TRUE),
    # Probability of negative growth
    prob_negative = mean(yoy_growth < 0, na.rm = TRUE),
    # Maximum consecutive losses
    max_consecutive_losses = max(rle(yoy_growth < 0)$lengths[rle(yoy_growth < 0)$values], na.rm = TRUE),
    .groups = "drop"
  )

# ==============================================================================
# 8. LEADING INDICATORS ANALYSIS
# ==============================================================================

print("Analyzing leading indicators...")

# Create lagged variables
leading_indicators <- employment_trends %>%
  arrange(tech_sector, date) %>%
  group_by(tech_sector) %>%
  mutate(
    employment_lag1 = lag(value_scaled, 1),
    employment_lag3 = lag(value_scaled, 3),
    employment_lag6 = lag(value_scaled, 6),
    employment_lag12 = lag(value_scaled, 12),
    growth_lag1 = lag(yoy_growth, 1),
    growth_lag3 = lag(yoy_growth, 3),
    growth_lag6 = lag(yoy_growth, 6),
    ma_3m = zoo::rollmean(value_scaled, k = 3, fill = NA, align = "right"),
    ma_6m = zoo::rollmean(value_scaled, k = 6, fill = NA, align = "right"),
    ma_12m = zoo::rollmean(value_scaled, k = 12, fill = NA, align = "right")
  ) %>%
  ungroup()

# Cross-correlation analysis
cross_correlation <- list()

for(sector in unique(leading_indicators$tech_sector)) {
  sector_data <- leading_indicators %>%
    filter(tech_sector == sector) %>%
    na.omit()
  
  if(nrow(sector_data) > 0) {
    # Cross-correlation with different lags
    ccf_result <- ccf(sector_data$employment_lag3, sector_data$value_scaled, 
                      lag.max = 12, plot = FALSE)
    
    cross_correlation[[sector]] <- list(
      sector = sector,
      ccf_result = ccf_result,
      max_correlation = max(ccf_result$acf),
      optimal_lag = ccf_result$lag[which.max(ccf_result$acf)]
    )
  }
}

# ==============================================================================
# 9. EXPORT ADVANCED ANALYSIS RESULTS
# ==============================================================================

print("Saving advanced analysis results...")

# Create advanced analysis directory
if (!dir.exists("data/processed/advanced")) {
  dir.create("data/processed/advanced", recursive = TRUE)
}

# Save forecast results
forecast_summary <- map_dfr(forecast_results, function(x) {
  tibble(
    sector = x$sector,
    model = as.character(x$model),
    aic = x$aic,
    bic = x$bic,
    forecast_mean = mean(x$forecast$mean),
    forecast_lower = mean(x$forecast$lower[,2]),
    forecast_upper = mean(x$forecast$upper[,2])
  )
})

write_csv(forecast_summary, "data/processed/advanced/forecast_summary.csv")

# Save structural breaks if available
if(length(structural_breaks) > 0) {
  breaks_summary <- map_dfr(structural_breaks, function(x) {
    tibble(
      sector = x$sector,
      num_breaks = length(x$changepoints_mean),
      break_dates = paste(x$break_dates, collapse = ", ")
    )
  })
  write_csv(breaks_summary, "data/processed/advanced/structural_breaks.csv")
}

# Save volatility analysis
write_csv(volatility_analysis, "data/processed/advanced/volatility_analysis.csv")

# Save risk analysis
write_csv(risk_analysis, "data/processed/advanced/risk_analysis.csv")

# Save regime analysis summary
regime_summary <- map_dfr(regime_analysis, function(x) {
  x$regime_summary %>%
    mutate(sector = x$sector) %>%
    select(sector, everything())
})

write_csv(regime_summary, "data/processed/advanced/regime_analysis.csv")

# Save all advanced analysis objects
save(
  forecast_results, structural_breaks, cyclical_analysis,
  volatility_analysis, regime_analysis, risk_analysis,
  leading_indicators, cross_correlation,
  file = "data/processed/advanced/advanced_analysis.RData"
)

print("Advanced analysis completed successfully!")
print("Advanced analysis files saved:")
print("  - forecast_summary.csv")
print("  - structural_breaks.csv")
print("  - volatility_analysis.csv")
print("  - risk_analysis.csv")
print("  - regime_analysis.csv")
print("  - advanced_analysis.RData")

# ==============================================================================
# 10. DISPLAY ADVANCED INSIGHTS
# ==============================================================================

print("\nADVANCED ANALYSIS INSIGHTS:")
print("==============================")

print("Volatility Rankings:")
print(volatility_analysis %>% 
        select(tech_sector, volatility, cv, sharpe_ratio) %>%
        arrange(desc(volatility)))

print("\nRisk Metrics:")
print(risk_analysis %>%
        select(tech_sector, var_5pct, prob_negative, max_consecutive_losses))

print("\nForecast Summary:")
print(forecast_summary %>%
        select(sector, forecast_mean, forecast_lower, forecast_upper))

if(length(structural_breaks) > 0) {
  print("\nStructural Breaks:")
  print(breaks_summary)
}

print("\nRegime Analysis:ي")
print(regime_summary %>%
        group_by(sector) %>%
        summarise(
          dominant_regime = regime_label[which.max(duration)],
          avg_regime_duration = mean(duration),
          .groups = "drop"
        ))

print("\nAdvanced analysis package completed!")
print("Ready for sophisticated forecasting and risk assessment!")
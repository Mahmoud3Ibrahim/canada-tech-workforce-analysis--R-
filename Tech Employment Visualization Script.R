# ==============================================================================
# Tech Employment Visualization Script for Canada (2011-2025)
# ==============================================================================

# Load required libraries with error handling
essential_packages <- c("tidyverse", "ggplot2", "lubridate", "scales")
optional_packages <- c("plotly", "viridis", "patchwork", "RColorBrewer", "htmlwidgets")

# Load essential packages
for (pkg in essential_packages) {
  if (!require(pkg, character.only = TRUE)) {
    cat("Essential package", pkg, "is not installed.\n")
    cat("Please run: install.packages('", pkg, "')\n", sep = "")
    stop("Missing required package: ", pkg)
  }
}

# Try to load optional packages
plotly_available <- require("plotly", quietly = TRUE)
viridis_available <- require("viridis", quietly = TRUE)
patchwork_available <- require("patchwork", quietly = TRUE)
rcolorbrewer_available <- require("RColorBrewer", quietly = TRUE)
htmlwidgets_available <- require("htmlwidgets", quietly = TRUE)

cat("Package availability check:\n")
cat("  Essential packages: loaded\n")
cat("  plotly:", ifelse(plotly_available, "available", "not available"), "\n")
cat("  viridis:", ifelse(viridis_available, "available", "not available"), "\n")
cat("  patchwork:", ifelse(patchwork_available, "available", "not available"), "\n")

# Set theme for all plots
theme_set(theme_minimal(base_size = 12))

# Define color palette
if (viridis_available) {
  tech_colors <- viridis::viridis(4)
} else if (rcolorbrewer_available) {
  tech_colors <- RColorBrewer::brewer.pal(4, "Set2")
} else {
  tech_colors <- c("#2E86AB", "#A23B72", "#F18F01", "#C73E1D")
}

# Load analysis data
print("Loading analysis data...")
load("data/processed/tech_employment_analysis.RData")
load("data/processed/tech_employment_clean.RData")

# Create visuals directory if it doesn't exist
if (!dir.exists("visuals")) {
  dir.create("visuals", recursive = TRUE)
}

# ==============================================================================
# 1. EMPLOYMENT TRENDS OVER TIME
# ==============================================================================

print("Creating employment trends visualization...")

p1 <- employment_trends %>%
  filter(!is.na(value_scaled)) %>%
  ggplot(aes(x = date, y = value_scaled, color = tech_sector)) +
  geom_line(size = 1.2, alpha = 0.8) +
  geom_smooth(method = "loess", se = FALSE, size = 0.8, alpha = 0.6) +
  scale_color_manual(values = tech_colors) +
  scale_y_continuous(labels = scales::number_format(scale = 1e-3, suffix = "K")) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  labs(
    title = "Tech Employment Trends in Canada (2011-2025)",
    subtitle = "Employment levels by technology sector",
    x = "Year",
    y = "Employment (Thousands)",
    color = "Tech Sector",
    caption = "Data: Statistics Canada"
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12, color = "gray60"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("visuals/01_employment_trends.png", p1, width = 12, height = 8, dpi = 300)

# ==============================================================================
# 2. YEAR-OVER-YEAR GROWTH RATES
# ==============================================================================

print("Creating growth rate visualization...")

p2 <- employment_trends %>%
  filter(!is.na(yoy_growth), abs(yoy_growth) < 50) %>%
  ggplot(aes(x = date, y = yoy_growth, color = tech_sector)) +
  geom_line(size = 1, alpha = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_smooth(method = "loess", se = TRUE, alpha = 0.3) +
  scale_color_manual(values = tech_colors) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  labs(
    title = "Year-over-Year Employment Growth Rates",
    subtitle = "Annual percentage change in tech employment",
    x = "Year",
    y = "Growth Rate (%)",
    color = "Tech Sector",
    caption = "Data: Statistics Canada"
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 16, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("visuals/02_growth_rates.png", p2, width = 12, height = 8, dpi = 300)

# ==============================================================================
# 3. ANNUAL EMPLOYMENT COMPARISON
# ==============================================================================

print("Creating annual comparison...")

p3 <- annual_employment %>%
  filter(year >= 2011, year <= 2024) %>%
  ggplot(aes(x = year, y = avg_employment, fill = tech_sector)) +
  geom_col(position = "dodge", alpha = 0.8) +
  geom_text(aes(label = scales::number(avg_employment, scale = 1e-3, suffix = "K")), 
            position = position_dodge(width = 0.9), 
            vjust = -0.5, size = 3) +
  scale_fill_manual(values = tech_colors) +
  scale_y_continuous(labels = scales::number_format(scale = 1e-3, suffix = "K")) +
  scale_x_continuous(breaks = seq(2011, 2024, 2)) +
  labs(
    title = "Annual Tech Employment by Sector",
    subtitle = "Average employment levels per year",
    x = "Year",
    y = "Employment (Thousands)",
    fill = "Tech Sector",
    caption = "Data: Statistics Canada"
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 16, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("visuals/03_annual_comparison.png", p3, width = 12, height = 8, dpi = 300)

# ==============================================================================
# 4. UNEMPLOYMENT ANALYSIS
# ==============================================================================

print("Creating unemployment visualization...")

p4 <- unemployment_analysis %>%
  filter(!is.na(unemp_unemployment_rate)) %>%
  ggplot(aes(x = date, y = unemp_unemployment_rate, color = tech_sector)) +
  geom_line(size = 1.2, alpha = 0.8) +
  geom_smooth(method = "loess", se = TRUE, alpha = 0.3) +
  scale_color_manual(values = tech_colors) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  labs(
    title = "Tech Unemployment Rates in Canada",
    subtitle = "Unemployment rate trends by technology sector",
    x = "Year",
    y = "Unemployment Rate (%)",
    color = "Tech Sector",
    caption = "Data: Statistics Canada"
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 16, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("visuals/04_unemployment_rates.png", p4, width = 12, height = 8, dpi = 300)

# ==============================================================================
# 5. SEASONAL PATTERNS
# ==============================================================================

print("Creating seasonal patterns visualization...")

p5 <- seasonal_analysis %>%
  mutate(month_name = month.abb[month]) %>%
  ggplot(aes(x = reorder(month_name, month), y = seasonal_index, fill = tech_sector)) +
  geom_col(position = "dodge", alpha = 0.8) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "gray50") +
  scale_fill_manual(values = tech_colors) +
  labs(
    title = "Seasonal Employment Patterns in Tech Sectors",
    subtitle = "Seasonal index (100 = average)",
    x = "Month",
    y = "Seasonal Index",
    fill = "Tech Sector",
    caption = "Data: Statistics Canada"
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 16, face = "bold")
  )

ggsave("visuals/05_seasonal_patterns.png", p5, width = 12, height = 8, dpi = 300)

# ==============================================================================
# 6. SECTOR COMPARISON PIE CHART
# ==============================================================================

print("Creating sector comparison pie chart...")

latest_comparison <- sector_comparison %>%
  filter(year == max(year, na.rm = TRUE)) %>%
  select(year, sector_professional_technical_services, sector_information_culture) %>%
  pivot_longer(cols = starts_with("sector_"), 
               names_to = "sector", 
               values_to = "employment") %>%
  mutate(
    sector = case_when(
      sector == "sector_professional_technical_services" ~ "Professional & Technical Services",
      sector == "sector_information_culture" ~ "Information & Culture",
      TRUE ~ sector
    ),
    percentage = employment / sum(employment) * 100
  )

p6 <- latest_comparison %>%
  ggplot(aes(x = "", y = employment, fill = sector)) +
  geom_bar(stat = "identity", width = 1, alpha = 0.8) +
  coord_polar("y", start = 0) +
  scale_fill_manual(values = tech_colors[1:2]) +
  geom_text(aes(label = paste0(round(percentage, 1), "%")), 
            position = position_stack(vjust = 0.5), 
            size = 5, fontface = "bold") +
  labs(
    title = paste("Tech Employment Distribution in", max(sector_comparison$year, na.rm = TRUE)),
    subtitle = "Share of total tech employment by sector",
    fill = "Tech Sector",
    caption = "Data: Statistics Canada"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, color = "gray60", hjust = 0.5),
    legend.position = "bottom"
  )

ggsave("visuals/06_sector_distribution.png", p6, width = 10, height = 8, dpi = 300)

# ==============================================================================
# 7. RECENT TRENDS (2020-2025)
# ==============================================================================

print("Creating recent trends visualization...")

p7 <- recent_trends %>%
  ggplot(aes(x = date, y = trend_index, color = tech_sector)) +
  geom_line(size = 1.5, alpha = 0.8) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "gray50", size = 1) +
  geom_point(data = recent_trends %>% filter(date == max(date)), 
             size = 4, alpha = 0.8) +
  scale_color_manual(values = tech_colors) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Tech Employment Recovery Since 2020",
    subtitle = "Employment index (2020 = 100%)",
    x = "Year",
    y = "Employment Index",
    color = "Tech Sector",
    caption = "Data: Statistics Canada"
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 16, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("visuals/07_recent_recovery.png", p7, width = 12, height = 8, dpi = 300)

# ==============================================================================
# 8. COMPREHENSIVE DASHBOARD (if patchwork available)
# ==============================================================================

if (patchwork_available) {
  print("Creating comprehensive dashboard...")
  
  dashboard <- (p1 / p2) | (p3 / p4)
  
  dashboard_annotated <- dashboard +
    plot_annotation(
      title = "Canada Tech Employment Analysis Dashboard (2011-2025)",
      subtitle = "Comprehensive overview of technology sector employment trends",
      caption = "Data: Statistics Canada | Analysis: Tech Employment Study",
      theme = theme(
        plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 14, color = "gray60", hjust = 0.5),
        plot.caption = element_text(size = 10, color = "gray40", hjust = 0.5)
      )
    )
  
  ggsave("visuals/08_comprehensive_dashboard.png", dashboard_annotated, 
         width = 16, height = 12, dpi = 300)
} else {
  print("Dashboard creation skipped - patchwork package not available")
}

# ==============================================================================
# 9. GROWTH SUMMARY VISUALIZATION
# ==============================================================================

print("Creating growth summary visualization...")

p9 <- growth_summary %>%
  select(tech_sector, avg_growth_rate, min_growth_rate, max_growth_rate) %>%
  pivot_longer(cols = ends_with("_rate"), 
               names_to = "metric", 
               values_to = "growth_rate") %>%
  mutate(
    metric = case_when(
      metric == "avg_growth_rate" ~ "Average Growth",
      metric == "min_growth_rate" ~ "Minimum Growth",
      metric == "max_growth_rate" ~ "Maximum Growth",
      TRUE ~ metric
    )
  ) %>%
  ggplot(aes(x = tech_sector, y = growth_rate, fill = metric)) +
  geom_col(position = "dodge", alpha = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  scale_fill_manual(values = c("#2E86AB", "#A23B72", "#F18F01")) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  labs(
    title = "Employment Growth Rate Summary by Sector",
    subtitle = "Average, minimum, and maximum annual growth rates",
    x = "Tech Sector",
    y = "Growth Rate (%)",
    fill = "Growth Metric",
    caption = "Data: Statistics Canada"
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 16, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("visuals/09_growth_summary.png", p9, width = 12, height = 8, dpi = 300)

# ==============================================================================
# 10. INTERACTIVE PLOTLY CHARTS (if available)
# ==============================================================================

if (plotly_available && htmlwidgets_available) {
  print("Creating interactive visualizations...")
  
  interactive_trends <- plot_ly(
    data = employment_trends %>% filter(!is.na(value_scaled)),
    x = ~date,
    y = ~value_scaled,
    color = ~tech_sector,
    colors = tech_colors,
    type = "scatter",
    mode = "lines",
    line = list(width = 3),
    hovertemplate = paste(
      "<b>%{fullData.name}</b><br>",
      "Date: %{x}<br>",
      "Employment: %{y:,.0f}<br>",
      "<extra></extra>"
    )
  ) %>%
    layout(
      title = list(
        text = "Interactive Tech Employment Trends in Canada (2011-2025)",
        font = list(size = 16, color = "black")
      ),
      xaxis = list(title = "Year"),
      yaxis = list(title = "Employment (Thousands)"),
      hovermode = "x unified",
      showlegend = TRUE
    )
  
  htmlwidgets::saveWidget(
    interactive_trends, 
    "visuals/10_interactive_trends.html",
    selfcontained = TRUE
  )
  
  interactive_growth <- plot_ly(
    data = employment_trends %>% filter(!is.na(yoy_growth), abs(yoy_growth) < 50),
    x = ~date,
    y = ~yoy_growth,
    color = ~tech_sector,
    colors = tech_colors,
    type = "scatter",
    mode = "lines",
    line = list(width = 3),
    hovertemplate = paste(
      "<b>%{fullData.name}</b><br>",
      "Date: %{x}<br>",
      "Growth Rate: %{y:.1f}%<br>",
      "<extra></extra>"
    )
  ) %>%
    layout(
      title = list(
        text = "Interactive Year-over-Year Growth Rates",
        font = list(size = 16, color = "black")
      ),
      xaxis = list(title = "Year"),
      yaxis = list(title = "Growth Rate (%)"),
      hovermode = "x unified",
      showlegend = TRUE
    ) %>%
    add_hline(y = 0, line = list(dash = "dash", color = "gray"))
  
  htmlwidgets::saveWidget(
    interactive_growth, 
    "visuals/11_interactive_growth.html",
    selfcontained = TRUE
  )
} else {
  print("Interactive visualizations skipped - plotly or htmlwidgets not available")
}

# ==============================================================================
# 11. SUMMARY STATISTICS TABLE
# ==============================================================================

print("Creating summary statistics table...")

summary_table <- growth_summary %>%
  mutate(
    avg_growth_rate = paste0(round(avg_growth_rate, 1), "%"),
    min_growth_rate = paste0(round(min_growth_rate, 1), "%"),
    max_growth_rate = paste0(round(max_growth_rate, 1), "%"),
    sd_growth_rate = paste0(round(sd_growth_rate, 1), "%"),
    cv_growth_rate = round(cv_growth_rate, 2)
  ) %>%
  select(
    `Tech Sector` = tech_sector,
    `Avg Growth` = avg_growth_rate,
    `Min Growth` = min_growth_rate,
    `Max Growth` = max_growth_rate,
    `Std Dev` = sd_growth_rate,
    `CV` = cv_growth_rate,
    `Years +ve` = years_positive_growth,
    `Years -ve` = years_negative_growth
  )

write_csv(summary_table, "visuals/12_summary_statistics.csv")

# ==============================================================================
# 12. EXPORT VISUALIZATION SUMMARY
# ==============================================================================

print("Creating visualization index...")

visualization_files <- c(
  "01_employment_trends.png",
  "02_growth_rates.png", 
  "03_annual_comparison.png",
  "04_unemployment_rates.png",
  "05_seasonal_patterns.png",
  "06_sector_distribution.png",
  "07_recent_recovery.png",
  "09_growth_summary.png",
  "12_summary_statistics.csv"
)

# Add conditional files
if (patchwork_available) {
  visualization_files <- c(visualization_files, "08_comprehensive_dashboard.png")
}
if (plotly_available && htmlwidgets_available) {
  visualization_files <- c(visualization_files, 
                           "10_interactive_trends.html",
                           "11_interactive_growth.html")
}

visualization_index <- tibble(
  file_name = visualization_files,
  description = c(
    "Employment levels trends over time by sector",
    "Year-over-year growth rates with trend lines",
    "Annual employment comparison between sectors",
    "Unemployment rates by technology sector",
    "Seasonal employment patterns analysis",
    "Current sector distribution pie chart",
    "Recent recovery trends since 2020",
    "Growth rate summary statistics",
    "Summary statistics table",
    if (patchwork_available) "Comprehensive 4-panel dashboard" else NULL,
    if (plotly_available && htmlwidgets_available) c("Interactive employment trends chart", "Interactive growth rates chart") else NULL
  )
)

write_csv(visualization_index, "visuals/00_visualization_index.csv")

print("All visualizations created successfully!")
print("Files saved in 'visuals/' directory:")
print("=====================================")
for(i in 1:nrow(visualization_index)) {
  print(paste("Chart", i, ":", visualization_index$file_name[i], "-", visualization_index$description[i]))
}

# ==============================================================================
# 13. DISPLAY KEY INSIGHTS
# ==============================================================================

print("\nKEY VISUAL INSIGHTS:")
print("======================")

latest_employment <- employment_trends %>%
  filter(date == max(date, na.rm = TRUE)) %>%
  select(tech_sector, value_scaled, date)

print("Latest Employment Figures:")
print(latest_employment)

print("\nGrowth Performance Summary:")
print(growth_summary %>% 
        select(tech_sector, avg_growth_rate, years_positive_growth, years_negative_growth))

recovery_status <- recent_trends %>%
  filter(date == max(date)) %>%
  select(tech_sector, trend_index, recovery_indicator)

print("\nRecovery Status (vs 2020):")
print(recovery_status)

print("\nVisualization package completed!")
print("Ready for presentation and analysis!")
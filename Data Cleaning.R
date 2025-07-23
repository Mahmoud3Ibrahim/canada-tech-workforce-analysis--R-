# ==============================================================================
# Data Cleaning Script for Canada Tech Employment Analysis
# ==============================================================================

# Load required libraries with error handling
required_packages <- c("tidyverse", "lubridate", "janitor", "readr")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    cat(" Package", pkg, "is not installed.\n")
    cat(" Please run: install.packages('", pkg, "')\n", sep = "")
    cat(" Or run the 00_install_packages.R script first.\n")
    stop("Missing required package: ", pkg)
  }
}

# Read the data
print(" Loading data...")
raw_data <- read_csv("tech_employment_full.csv")

# Display basic data information
print(" Basic data information:")
print(paste("Number of rows:", nrow(raw_data)))
print(paste("Number of columns:", ncol(raw_data)))

# Clean column names
data_clean <- raw_data %>%
  clean_names() %>%
  # Rename columns for easier handling
  rename(
    date = ref_date,
    geography = geo,
    labor_characteristic = labour_force_characteristics,
    industry = north_american_industry_classification_system_naics,
    value = value
  )

# Convert dates
print(" Converting dates...")
data_clean <- data_clean %>%
  mutate(
    date = ym(date),
    year = year(date),
    month = month(date),
    year_month = paste(year, sprintf("%02d", month), sep = "-")
  )

# Filter data for technology sectors only and required period (2011-2025)
print(" Filtering tech data for period 2011-2025...")
tech_data <- data_clean %>%
  filter(
    # Filter technology sectors
    str_detect(industry, "Professional, scientific and technical services") |
      str_detect(industry, "Information, culture and recreation"),
    # Filter time period
    year >= 2011,
    # Filter Canada only
    geography == "Canada",
    # Filter estimates only
    statistics == "Estimate"
  )

# Add sector classification
print(" Classifying sectors...")
tech_data <- tech_data %>%
  mutate(
    tech_sector = case_when(
      str_detect(industry, "Professional, scientific and technical services") ~ "Professional & Technical Services",
      str_detect(industry, "Information, culture and recreation") ~ "Information & Culture",
      TRUE ~ "Other"
    )
  )

# Clean and validate data
print(" Cleaning and validating data...")
tech_data_clean <- tech_data %>%
  # Remove rows with missing values
  filter(!is.na(value)) %>%
  # Remove negative values (if any)
  filter(value >= 0) %>%
  # Create meaningful labels for labor characteristics
  mutate(
    labor_type = case_when(
      labor_characteristic == "Labour force" ~ "Labor Force",
      labor_characteristic == "Employment" ~ "Employment",
      labor_characteristic == "Unemployment" ~ "Unemployment",
      labor_characteristic == "Unemployment rate" ~ "Unemployment Rate",
      TRUE ~ labor_characteristic
    )
  )

# Convert values to proper scale (thousands to actual numbers)
print(" Converting values to proper scale...")
tech_data_clean <- tech_data_clean %>%
  mutate(
    # Convert thousands to actual numbers for most metrics
    value_scaled = case_when(
      labor_type == "Unemployment Rate" ~ value,  # Rate stays as is
      str_detect(uom, "thousands") ~ value * 1000,  # Convert thousands to actual
      TRUE ~ value
    ),
    # Add units for clarity
    units = case_when(
      labor_type == "Unemployment Rate" ~ "Percentage",
      str_detect(uom, "thousands") ~ "Persons",
      TRUE ~ "Unknown"
    )
  )

# Create summary statistics
print(" Creating summary statistics...")
data_summary <- tech_data_clean %>%
  group_by(tech_sector, labor_type) %>%
  summarise(
    min_value = min(value_scaled, na.rm = TRUE),
    max_value = max(value_scaled, na.rm = TRUE),
    mean_value = mean(value_scaled, na.rm = TRUE),
    median_value = median(value_scaled, na.rm = TRUE),
    records_count = n(),
    .groups = "drop"
  )

# Display summary
print(" Data Summary:")
print(data_summary)

# Check for data quality issues
print(" Data quality checks:")
print(paste("Records with missing values:", sum(is.na(tech_data_clean$value_scaled))))
print(paste("Records with negative values:", sum(tech_data_clean$value_scaled < 0, na.rm = TRUE)))
print(paste("Unique tech sectors:", length(unique(tech_data_clean$tech_sector))))
print(paste("Date range:", min(tech_data_clean$date), "to", max(tech_data_clean$date)))

# Save cleaned data
print(" Saving cleaned data...")
write_csv(tech_data_clean, "data/processed/tech_employment_clean.csv")
write_csv(data_summary, "data/processed/tech_employment_summary.csv")

# Save R data object for analysis
save(tech_data_clean, data_summary, file = "data/processed/tech_employment_clean.RData")

print(" Data cleaning completed successfully!")
print(" Files saved:")
print("  - data/processed/tech_employment_clean.csv")
print("  - data/processed/tech_employment_summary.csv")
print("  - data/processed/tech_employment_clean.RData")
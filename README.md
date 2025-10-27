# Canada Tech Workforce Analysis (R)

This project analyzes the evolution of Canada's technology workforce using open data from Statistics Canada and other labour reports.  
It focuses on how employment in the tech sector has changed between 2011 and 2025, which provinces lead in job creation, and how wages evolved during that time.

> This project was created as part of a data analysis portfolio to demonstrate data wrangling, visualization, and reporting skills in R.

---

## 1. Project Overview

- **Goal:** Understand employment and wage trends in Canada's tech sector between 2011 and 2025.  
- **Tools:** R (tidyverse, ggplot2, dplyr, lubridate).  
- **Data:** Statistics Canada labour force datasets (NAICS 54 – Professional, Scientific and Technical Services) and ICTC labour market reports.  

The analysis is divided into three main stages:
1. Data collection and cleaning  
2. Exploratory analysis and visualization  
3. Summary insights and interpretation

---

## 2. Repository Structure

data/          # Raw and cleaned datasets (.csv)  
scripts/       # R scripts for cleaning, transformation, and plotting  
visuals/       # Exported charts and graphs for the README  
output/        # Summary tables and temporary results  

---

## 3. Key Insights

- Employment in software, data, and engineering-related roles has grown more than 60% since 2011.  
- Ontario, British Columbia, and Quebec lead the Canadian tech job market.  
- The Prairies (Alberta, Manitoba, Saskatchewan) show moderate but consistent growth.  
- Wage growth in tech fields outpaced the national average by around 20%.  
- Post-pandemic data shows stabilization, with continued expansion in cloud and AI-related occupations.  

---

## 4. Visuals

### 1. Employment Trends (2011–2025)
![Employment Trends](visuals/10_interactive_trends_files/01_employment_trends.png)

---

### 2. Growth Rates by Year
![Growth Rates](visuals/10_interactive_trends_files/02_growth_rates.png)

---

### 3. Annual Comparison by Province
![Annual Comparison](visuals/10_interactive_trends_files/03_annual_comparison.png)

---

### 4. Unemployment Rates in Tech Sector
![Unemployment Rates](visuals/10_interactive_trends_files/04_unemployment_rates.png)

---

### 5. Seasonal Employment Patterns
![Seasonal Patterns](visuals/10_interactive_trends_files/05_seasonal_patterns.png)

---

### 6. Sector Distribution (NAICS 54)
![Sector Distribution](visuals/10_interactive_trends_files/06_sector_distribution.png)

---

### 7. Post-Pandemic Recovery
![Recent Recovery](visuals/10_interactive_trends_files/07_recent_recovery.png)

---

### 8. Comprehensive Dashboard Summary
![Comprehensive Dashboard](visuals/10_interactive_trends_files/08_comprehensive_dashboard.png)

---

### 9. Summary of Growth and Wages
![Growth Summary](visuals/10_interactive_trends_files/09_growth_summary.png)

---

More visuals and interactive charts are included in the Power BI dashboard and R scripts under the `/visuals` folder.

---

## 5. Data Sources

- [Statistics Canada – Labour Force Survey (Table 14-10-0200-01)](https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410020001)  
- [ICTC – Information and Communications Technology Council Reports](https://www.ictc-ctic.ca/research-reports/)  
- [Government of Canada Open Data Portal](https://open.canada.ca/en/open-data)  

All datasets were accessed in 2024 for educational and analytical purposes.

---

## 6. How to Run Locally

1. Clone the repository:
   ```bash
   git clone https://github.com/Mahmoud3Ibrahim/canada-tech-workforce-analysis--R-
   cd canada-tech-workforce-analysis--R-
   ```

2. Install required packages before running any scripts:
   ```r
   install.packages(c("tidyverse", "dplyr", "ggplot2", "lubridate", "readr"))
   ```

3. Run scripts in order:
   - `Data Cleaning.R` → prepares and normalizes datasets  
   - `Tech Employment Analysis.R` → performs EDA and creates plots  
   - `Tech Employment Visualization Script.R` → saves visuals in `/visuals/10_interactive_trends_files/`

---

## 7. Next Steps

- Add regression models to test relationships between wages and employment growth  
- Integrate time-series forecasting for job demand post-2025  
- Create an interactive Power BI dashboard for presentation  
- Link immigration data to workforce trends

---

## 8. Author

**Mahmoud Ibrahim**  
Ottawa, Canada  
Data Analysis and Web Development  
[LinkedIn](https://www.linkedin.com/in/mahmoud3ibrahim)

---

## 9. License

MIT License

# Canada Tech Workforce Analysis (R)

This project analyzes the evolution of Canada's technology workforce using open data from Statistics Canada and other labor reports.  
It focuses on how employment in the tech sector has changed between 2011 and 2025, which provinces lead in job creation, and how wages evolved during that time.

> This project was created as part of a data analysis portfolio to demonstrate data wrangling, visualization, and reporting skills in R.

---

## 1. Project Overview

- **Goal:** Understand employment and wage trends in Canada's tech sector between 2011 and 2025.  
- **Tools:** R (tidyverse, ggplot2, dplyr, lubridate).  
- **Data:** Statistics Canada labor force datasets (NAICS 54 – Professional, Scientific and Technical Services) and ICTC labor market reports.  

The analysis is divided into three main stages:
1. Data collection and cleaning.  
2. Exploratory analysis and visualization.  
3. Summary insights and interpretation.

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

### National Tech Employment Trend (2011–2025)
![Tech Jobs Growth](visuals/tech_jobs_growth.png)

---

### Regional Workforce Comparison
![Tech Workforce by Province](visuals/tech_regions.png)

---

### Wage Growth vs Employment Growth
![Wage vs Employment](visuals/wage_vs_employment.png)

---

### Gender Representation in Tech
![Gender Representation](visuals/gender_in_tech.png)

---

### Provincial Wage Distribution
![Wage Distribution](visuals/wage_distribution.png)

---

More visuals and charts are included in the Power BI dashboard and R scripts under the `/visuals` folder.

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

2. Open `scripts/clean_data.R` in RStudio and run the following before execution:
   ```r
   install.packages(c("tidyverse", "dplyr", "ggplot2", "lubridate", "readr"))
   ```

3. Run scripts in order:
   - `clean_data.R` → prepares and normalizes datasets.  
   - `analyze_trends.R` → performs EDA and creates plots.  
   - `export_charts.R` → saves visuals in `/visuals`.

---

## 7. Next Steps

- Build regression models to test relationships between wages and employment growth.  
- Add time-series forecasting for tech job demand post-2025.  
- Create an interactive Power BI version of the dashboard for public viewing.  
- Integrate external datasets (AI, software exports, and immigration data).

---

## 8. Author

**Mahmoud Ibrahim**  
Ottawa, Canada  
Data Analysis and Web Development  
[LinkedIn](https://www.linkedin.com/in/mahmoud3ibrahim)

---

## 9. License

MIT License

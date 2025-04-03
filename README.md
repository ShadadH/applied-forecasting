# Forecasting Projects – Applied Forecasting (Spring 2025)

This repository contains a series of forecasting projects completed for the course **Applied Forecasting (Christian Haefke, NYUAD – Spring 2025)**. Each project applies time series forecasting techniques to real-world economic data using tools from the `fpp3` R ecosystem.

---

## 📁 Repository Structure

```
Forecasting-Projects/
├── gdp_forecasting/         # Forecasting Canadian Nominal GDP (via deflator, population, and RGDP per capita)
├── stock_forecasting/       # [To be added] Stock price forecasts using ARIMA/ETS models
├── inflation_forecasting/   # [To be added] Inflation modeling using time series decomposition
├── README.md                # This file
```

---

## ✅ Project 1: GDP Forecasting (Canada)

Forecasting Canada's nominal GDP by separately modeling and forecasting:

- **GDP Deflator**
- **Population**
- **Real GDP per Capita**

These forecasts are then combined to generate nominal GDP predictions through:
```math
\text{Nominal GDP} = \text{GDP Deflator} \times \text{Real GDP per Capita} \times \text{Population}
```

### 🔍 Key Insights

- **Naïve and Drift models** were explored, with transformations and residual diagnostics applied iteratively.
- **Naïve model** worked best for **population**, consistent with long-term demographic trends.
- **Drift model** provided the best fit for **GDP Deflator** and **Real GDP per Capita**, based on low forecast error metrics and acceptable Ljung-Box test results.
- Combined nominal GDP forecasts aligned well with observed data trends.

### 📊 Data Sources

| Variable             | Source                      | Frequency | Period         |
|----------------------|-----------------------------|-----------|----------------|
| Nominal GDP          | FRED (NGDPSAXDCCAQ)         | Quarterly | 1970 Q1–2024 Q3|
| Real GDP per Capita  | FRED (NGDPRSAXDCCAQ)        | Quarterly | 1970 Q1–2024 Q3|
| Population           | Government of Canada        | Quarterly | 1970 Q1–2024 Q3|

### 📄 Files

- `gdp_forecasting/script/`: R scripts used for data wrangling, modeling, residual diagnostics, and forecasting
- `gdp_forecasting/GDP Forecasting Report.pdf`: Final write-up and results

---

## 📦 Requirements

To reproduce the projects, install the following R packages:
```r
install.packages("pacman")
pacman::p_load(fpp3, fredr, readr, dplyr, ggplot2)
```

Add your FRED API key to `.Renviron`:
```
FRED_API_KEY=your_key_here
```

---

## 📌 Next Projects

- **Stock Forecasting**: Coming soon...
- **Inflation Modeling**: Coming soon...

---

## 👤 Author

**Shadad Hossain**  
Applied Forecasting – NYU Abu Dhabi, Spring 2025

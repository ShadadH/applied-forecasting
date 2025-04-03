# ----------------------------
# Forecasting Canada’s GDP Metrics
# ----------------------------

# Load Required Packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(fredr, fpp3, readr, dplyr, ggplot2)

# Set FRED API Key (Use environment variable for security)
# Add this line to your .Renviron file: FRED_API_KEY=your_key_here
fredr_set_key(Sys.getenv("FRED_API_KEY"))

# ----------------------------
# Step 1: Load and Prepare Data
# ----------------------------

# Fetch Nominal and Real GDP Data from FRED
nominal_gdp <- fredr(
  series_id = "NGDPSAXDCCAQ",
  observation_start = as.Date("1970-01-01"),
  frequency = "q"
) %>%
  select(date, value) %>%
  rename(Nominal_GDP = value)

real_gdp <- fredr(
  series_id = "NGDPRSAXDCCAQ",
  observation_start = as.Date("1970-01-01"),
  frequency = "q"
) %>%
  select(date, value) %>%
  rename(Real_GDP = value)

# Load population data
population <- read_csv("Formatted_Time_Series_Data.csv") %>%
  rename(date = Quarter) %>%
  mutate(date = as.Date(date))

# Align Data Lengths
real_gdp <- real_gdp[-c(1:3, nrow(real_gdp)), ]
nominal_gdp <- nominal_gdp[-c(1:3), ]
population <- population[-nrow(population), ]

# ----------------------------
# Step 2: Compute Additional Metrics
# ----------------------------

# GDP Deflator
gdp_data <- full_join(nominal_gdp, real_gdp, by = "date") %>%
  mutate(GDP_Deflator = (Nominal_GDP / Real_GDP) * 100)

# Real GDP per Capita
gdp_data <- full_join(gdp_data, population, by = "date") %>%
  mutate(Real_GDP_per_Capita = (Real_GDP / Population) * 1e6)

# Convert to tsibble
gdp_data <- gdp_data %>%
  mutate(Quarter = yearquarter(date)) %>%
  select(Quarter, Nominal_GDP, Real_GDP, GDP_Deflator, Population, Real_GDP_per_Capita) %>%
  as_tsibble(index = Quarter)

# ----------------------------
# Step 3: Summary Statistics
# ----------------------------

gdp_summary_all <- gdp_data %>%
  summarise(
    Mean_Nominal_GDP = mean(Nominal_GDP, na.rm = TRUE),
    SD_Nominal_GDP = sd(Nominal_GDP, na.rm = TRUE),
    Mean_GDP_Deflator = mean(GDP_Deflator, na.rm = TRUE),
    SD_GDP_Deflator = sd(GDP_Deflator, na.rm = TRUE),
    Mean_Population = mean(Population, na.rm = TRUE),
    SD_Population = sd(Population, na.rm = TRUE),
    Mean_Real_GDP_Per_Capita = mean(Real_GDP_per_Capita, na.rm = TRUE),
    SD_Real_GDP_Per_Capita = sd(Real_GDP_per_Capita, na.rm = TRUE)
  )

print(gdp_summary_all)

# ----------------------------
# Step 4: Train/Test Split
# ----------------------------

train_data <- gdp_data %>% filter(Quarter < yearquarter("2000 Q1"))
test_data  <- gdp_data %>% filter(Quarter >= yearquarter("2000 Q1"))

# ----------------------------
# Step 5: Fit Forecasting Models
# ----------------------------

fit_deflator <- train_data %>%
  model(
    Mean = MEAN(GDP_Deflator),
    Naïve = NAIVE(GDP_Deflator),
    Drift = RW(GDP_Deflator ~ drift())
  )

fit_population <- train_data %>%
  model(
    Mean = MEAN(Population),
    Naïve = NAIVE(Population),
    Drift = RW(Population ~ drift())
  )

fit_real_gdp <- train_data %>%
  model(
    Mean = MEAN(Real_GDP_per_Capita),
    Naïve = NAIVE(Real_GDP_per_Capita),
    Drift = RW(Real_GDP_per_Capita ~ drift())
  )

fit_nominal_gdp <- train_data %>%
  model(
    Mean = MEAN(Nominal_GDP),
    Naïve = NAIVE(Nominal_GDP),
    Drift = RW(Nominal_GDP ~ drift())
  )

# ----------------------------
# Step 6: Visualize Residuals
# ----------------------------

# GDP Deflator
fit_deflator %>% select(Naïve) %>% gg_tsresiduals() +
  labs(title = "Residuals: Naïve Model - GDP Deflator")

fit_deflator %>% select(Mean) %>% gg_tsresiduals() +
  labs(title = "Residuals: Mean Model - GDP Deflator")

fit_deflator %>% select(Drift) %>% gg_tsresiduals() +
  labs(title = "Residuals: Drift Model - GDP Deflator")

# Population
fit_population %>% select(Mean) %>% gg_tsresiduals() +
  labs(title = "Residuals: Mean Model - Population")

fit_population %>% select(Naïve) %>% gg_tsresiduals() +
  labs(title = "Residuals: Naïve Model - Population")

fit_population %>% select(Drift) %>% gg_tsresiduals() +
  labs(title = "Residuals: Drift Model - Population")

# Real GDP per Capita
fit_real_gdp %>% select(Mean) %>% gg_tsresiduals() +
  labs(title = "Residuals: Mean Model - Real GDP per Capita")

fit_real_gdp %>% select(Drift) %>% gg_tsresiduals() +
  labs(title = "Residuals: Drift Model - Real GDP per Capita")

fit_real_gdp %>% select(Naïve) %>% gg_tsresiduals() +
  labs(title = "Residuals: Naïve Model - Real GDP per Capita")

# ----------------------------
# Step 7: Residual Diagnostics
# ----------------------------

# Extract residuals
residuals_deflator <- augment(fit_deflator)
residuals_population <- augment(fit_population)
residuals_real_gdp <- augment(fit_real_gdp)

# Ljung-Box Test for Autocorrelation
residuals_deflator %>% features(.resid, ljung_box, lag = 10)
residuals_population %>% features(.resid, ljung_box, lag = 10)
residuals_real_gdp %>% features(.resid, ljung_box, lag = 10)

# ----------------------------
# Step 8: Forecast & Evaluate
# ----------------------------

# Forecast using test data
fc_deflator <- fit_deflator %>% forecast(new_data = test_data)
fc_population <- fit_population %>% forecast(new_data = test_data)
fc_real_gdp <- fit_real_gdp %>% forecast(new_data = test_data)
fc_nominal_gdp <- fit_nominal_gdp %>% forecast(new_data = test_data)

# Forecast Accuracy
accuracy(fc_deflator, test_data)
accuracy(fc_population, test_data)
accuracy(fc_real_gdp, test_data)
accuracy(fc_nominal_gdp, test_data)

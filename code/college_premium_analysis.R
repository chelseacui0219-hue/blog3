# ============================================================
# Blog Post 3: The College Wage Premium in the U.S., 2002-2025
# Data source: IPUMS CPS ASEC
# ===========================================================

library(tidyverse)   # dplyr, tidyr, ggplot2, readr, tibble
library(survey)      # svydesign, svyby, svyquantile
library(ipumsr)      # read_ipums_micro
library(here)        # here()

# ============================================================
cps <- read_ipums_micro(
  ddi = here("data", "raw", "cps_00001.xml"),
  data = here("data", "raw", "cps_00001.dat")
)

glimpse(cps)

# ============================================================
cps_clean <- cps |>
  # filter out invalid income, code as 9999999
  filter(
    INCWAGE > 0, INCWAGE < 9999990,
    INCWAGE_CPIU_2010 > 0, INCWAGE_CPIU_2010 < 9999990
  ) |>
  # Only retain high school (73) and undergraduate (111) graduates 
  filter(EDUC %in% c(73, 111)) |>
  # restrict age from 25 to 64
  filter(AGE >= 25, AGE <= 64) |>
  # save group with job
  filter(WKSWORK1 > 0, UHRSWORKLY > 0, UHRSWORKLY < 999) |>
  # define education, age, and gender group
  mutate(
    education = case_when(
      EDUC == 73  ~ "High school",
      EDUC == 111 ~ "Bachelor's"
    ),
    age_group = case_when(
      AGE >= 25 & AGE <= 34 ~ "25-34",
      AGE >= 35 & AGE <= 44 ~ "35-44",
      AGE >= 45 & AGE <= 54 ~ "45-54",
      AGE >= 55 & AGE <= 64 ~ "55-64"
    ),
    age_broad = if_else(AGE <= 44, "25-44", "45-64"),
    sex_label = case_when(
      as.numeric(SEX) == 1 ~ "Male",
      as.numeric(SEX) == 2 ~ "Female"
    ),
    # change IPUMS tag to numeric
    INCWAGE_CPIU_2010 = as.numeric(INCWAGE_CPIU_2010)
  )

nrow(cps_clean)   


dir.create(here("data", "clean"), recursive = TRUE, showWarnings = FALSE)
write_csv(cps_clean, here("data", "clean", "cps_clean.csv"))

# ============================================================
#education

svy <- svydesign(ids = ~1, weights = ~ASECWT, data = cps_clean)

weighted_medians <- svyby(
  ~INCWAGE_CPIU_2010,
  ~YEAR + education,
  svy,
  svyquantile,
  quantiles = 0.5
)

weighted_medians


premium <- weighted_medians |>
  as_tibble() |>
  select(YEAR, education, median_wage = INCWAGE_CPIU_2010) |>
  pivot_wider(names_from = education, values_from = median_wage) |>
  mutate(
    log_premium = log(`Bachelor's`) - log(`High school`),
    pct_premium = (exp(log_premium) - 1) * 100
  )

premium


dir.create(here("data", "clean"), recursive = TRUE, showWarnings = FALSE)
write_csv(premium, here("data", "clean", "premium_overall.csv"))

# ============================================================


p1 <- premium |>
  ggplot(aes(x = YEAR, y = pct_premium)) +
  geom_line(color = "#2c7fb8", linewidth = 1.2) +
  geom_point(color = "#2c7fb8", size = 3) +
  geom_text(aes(label = round(pct_premium, 1)), vjust = -1, size = 3.5) +
  labs(
    title = "The College Wage Premium, 2002–2025",
    subtitle = "Percentage difference in median annual earnings, bachelor's vs. high school",
    x = NULL,
    y = "College premium (%)",
    caption = "Data source: IPUMS CPS ASEC. Weighted using ASECWT. Earnings in 2010 dollars."
  ) +
  scale_x_continuous(breaks = premium$YEAR) +
  theme_minimal(base_size = 13)

p1

# ============================================================
#age

weighted_medians_age <- svyby(
  ~INCWAGE_CPIU_2010,
  ~YEAR + education + age_group,
  svy,
  svyquantile,
  quantiles = 0.5
)

age_premium <- weighted_medians_age |>
  as_tibble() |>
  select(YEAR, education, age_group, median_wage = INCWAGE_CPIU_2010) |>
  pivot_wider(names_from = education, values_from = median_wage) |>
  mutate(
    pct_premium = (`Bachelor's` / `High school` - 1) * 100
  )

write_csv(age_premium, here("data", "clean", "premium_by_age.csv"))

# ============================================================


age_medians <- weighted_medians_age |>
  as_tibble() |>
  select(YEAR, education, age_group, median_wage = INCWAGE_CPIU_2010)

p2 <- age_medians |>
  ggplot(aes(x = YEAR, y = median_wage, color = education)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  facet_wrap(~ age_group, nrow = 2) +
  scale_color_manual(values = c("Bachelor's" = "#2c7fb8", "High school" = "#d7191c")) +
  labs(
    title = "Median Earnings by Education and Age Group",
    subtitle = "Bachelor's vs. high school, 2002–2025",
    x = NULL,
    y = "Median annual earnings (2010 $)",
    color = NULL,
    caption = "Data source: IPUMS CPS ASEC. Weighted using ASECWT."
  ) +
  theme_minimal(base_size = 12)

p2

# ============================================================
# gender

weighted_medians_sex <- svyby(
  ~INCWAGE_CPIU_2010,
  ~YEAR + education + sex_label,
  svy,
  svyquantile,
  quantiles = 0.5
)

sex_premium <- weighted_medians_sex |>
  as_tibble() |>
  select(YEAR, education, sex_label, median_wage = INCWAGE_CPIU_2010) |>
  pivot_wider(names_from = education, values_from = median_wage) |>
  mutate(
    pct_premium = (`Bachelor's` / `High school` - 1) * 100
  )

write_csv(sex_premium, here("data", "clean", "premium_by_sex.csv"))

# ============================================================

p3 <- sex_premium |>
  ggplot(aes(x = YEAR, y = pct_premium, color = sex_label)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_color_manual(values = c("Female" = "#d7191c", "Male" = "#2c7fb8")) +
  labs(
    title = "The College Premium by Gender, 2002–2025",
    subtitle = "Women's college premium has grown faster than men's",
    x = NULL,
    y = "College premium (%)",
    color = NULL,
    caption = "Data source: IPUMS CPS ASEC. Weighted using ASECWT. Earnings in 2010 dollars."
  ) +
  scale_x_continuous(breaks = unique(sex_premium$YEAR)) +
  theme_minimal(base_size = 13)

p3

# ============================================================


dir.create(here("output"), recursive = TRUE, showWarnings = FALSE)

ggsave(here("output", "premium_overall.png"), plot = p1,
       width = 8, height = 6, dpi = 300)

ggsave(here("output", "premium_by_age.png"), plot = p2,
       width = 9, height = 6, dpi = 300)

ggsave(here("output", "premium_by_sex.png"), plot = p3,
       width = 8, height = 6, dpi = 300)

# ============================================================


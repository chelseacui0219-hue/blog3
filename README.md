# The College Wage Premium in the U.S., 2002–2025

An analysis of the returns to college education using IPUMS CPS ASEC
microdata, with weighted estimates and visualizations.

## Research Question

**How has the college wage premium changed in the United States
between 2002 and 2025, and how does the trend differ across age
groups and genders?**

The college wage premium is the percentage difference in median
annual earnings between bachelor's degree holders and high school
graduates. It could directly measure the financial return to
higher education.

## Data Source

| Item | Description |
|------|-------------|
| Source | [IPUMS CPS](https://cps.ipums.org/) |
| Sample | Annual Social and Economic Supplement (ASEC) |
| Years | 2002, 2007, 2010, 2015, 2019, 2022, 2025 |
| Observations | 1,307,642 raw; 257,323 after filtering |
| Weight | `ASECWT` (Annual Social and Economic Supplement Weight) |
| Earnings | `INCWAGE_CPIU_2010` (adjusted to 2010 dollars) |

IPUMS CPS provides harmonized microdata from the Current Population
Survey, the primary source of U.S. labor force statistics.

## Repository Structure

```
blog3/
├── data/
│   ├── raw/                                  # IPUMS CPS raw data
│   │   ├── cps_00001.dat
│   │   └── cps_00001.xml
│   └── clean/                                # Cleaned data
│       ├── cps_clean.csv
│       ├── premium_overall.csv
│       ├── premium_by_age.csv
│       └── premium_by_sex.csv
├── code/
│   └── college_premium_analysis.R            # Full analysis script
├── output/                                   # Charts
│   ├── premium_overall.png
│   ├── premium_by_age.png
│   └── premium_by_sex.png
└── README.md
```

## How to Reproduce

1. Clone this repository
2. Download the IPUMS CPS extract and place `cps_00001.dat` and
   `cps_00001.xml` in `data/raw/`
3. Install required packages:
   ```r
   install.packages(c("tidyverse", "survey", "ipumsr", "here"))
   ```
4. Run:
   ```r
   source("code/college_premium_analysis.R")
   ```
5. All cleaned data and charts will be regenerated automatically.

## Key Findings

1. **The premium is not growing steadily** the way it did in the
   1980s and 1990s. The post-2015 plateau is real.
2. **Old workers face more volatility** than younger
   generation.
3. **The gender gap in returns has widened.** Women's premium
   rose steadily while men's fluctuated and
   ended lower than where it started. This reflects the
   declining fortunes of male high school graduates more than
   it reflects gains for female college graduates.

## Methodology

All statistics are **weighted using `ASECWT`** to represent the
U.S. population, not just the CPS sample. Weighted medians are
computed using the `survey` package, which properly accounts for
the CPS sampling design.

The college premium is defined as:

```
Premium = (Median earnings of bachelor's graduates / Median earnings of high school graduates) - 1
```

Earnings are adjusted to 2010 dollars using the CPI-U index
provided by IPUMS.

## Limitations

- **Snapshot of ASEC years**: Only 7 years are included, not all
  years from 2002–2025.
- **Median-based**: The premium measures the middle of the
  distribution, not the full range.
- **Education as a binary**: Only high school and bachelor's
  graduates are compared; associate's and graduate degrees are
  excluded.
- **Descriptive, not causal**: These findings describe the
  correlation between education and earnings, not the causal
  effect of college.

## Data Attribution

All data comes from IPUMS CPS:

> Sarah Flood, Miriam King, Renae Rodgers, Steven Ruggles,
> J. Robert Warren, Daniel Backman, Annie Chen, Grace Cooper,
> Stephanie Richards, Megan Schouweiler, and Michael Westberry.
> IPUMS CPS: Version 12.0 [dataset]. Minneapolis, MN: IPUMS, 2024.
> https://doi.org/10.18128/D030.V12.0

## License

This project is for educational purposes.
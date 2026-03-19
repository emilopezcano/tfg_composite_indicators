# PCA Analysis for Composite Indicators

## Project Overview

This R project performs a hierarchical Principal Component Analysis (PCA) to create composite indicators from individual indicators organized by dimensions.

### Workflow

1. **PCA by Dimension**: Each dimension (e.g., ENV, SOCIAL, etc.) is analyzed separately using PCA on its indicators
2. **Extract Principal Components**: The first 3 principal components from each dimensional PCA are retained
3. **Final Aggregate PCA**: A final PCA is performed on the principal components from all dimensions to create a composite indicator

This approach allows for:
- Dimensionality reduction within each dimension
- Weighted aggregation of dimensions based on explained variance
- Better interpretation through separate component analysis

## Project Structure

```
pca_analysis.Rproj          # RStudio Project file
├── data/                   # Input data folder
│   └── indConComponentes.csv  # Source data (CSV format)
├── scripts/               # R analysis scripts
│   ├── 00_install_packages.R   # Install required dependencies
│   ├── 01_pca_analysis.R       # Main analysis (all years combined)
│   ├── 02_post_analysis_examples.R    # Analysis examples
│   ├── 03_diagnostic_check.R          # Data diagnostic tool
│   ├── 04_pca_by_year_EXAMPLE_2022.R  # PCA by year - Example for 2022 ⭐
│   └── 05_pca_batch_all_years.R       # PCA by year - Batch process all years ⭐
├── results/              # Output folder (created during analysis)
│   ├── composite_indicator.csv # Final composite indicator scores
│   ├── loadings_*.csv         # PCA loadings for each dimension
│   └── *.png                  # Visualization outputs
├── results_2022/         # Results for year 2022 (created by script 04 or 05)
├── results_2023/         # Results for year 2023
├── GUIA_PCA_BY_YEAR.md   # Complete guide for PCA by year ⭐
├── EXPLICACION_ARCHIVOS.md # File explanations
├── .Rprofile            # Project initialization settings
└── README.md            # This file
```

**NEW (v2.0) - PCA BY YEAR ANALYSIS:**
Scripts 04 and 05 implement a new workflow where each year is analyzed separately.
See [GUIA_PCA_BY_YEAR.md](GUIA_PCA_BY_YEAR.md) for detailed instructions.

## Required Data

The input file (`data/indConComponentes.csv`) should contain:
- `indicator_id`: Unique identifier for each indicator
- `date`: Date of the observation
- `period_id`: Period identifier
- `geo_id`: Geographic region identifier
- `value`: Standardized indicator value
- `dimension_id`: Dimension to which the indicator belongs
- Other columns (automatically excluded)

## Setup Instructions

### 1. Install R and RStudio

- Download and install [R](https://www.r-project.org/)
- Download and install [RStudio Desktop](https://posit.co/download/rstudio-desktop/)

### 2. Open the Project in RStudio

1. Open RStudio
2. Go to `File → Open Project`
3. Navigate to the project folder and open `pca_analysis.Rproj`

### 3. Install Required Packages

1. In RStudio Console, run:
```r
source("scripts/00_install_packages.R")
```

2. Wait for all packages to install (this may take a few minutes on first run)

### 4. Place Your Data

1. Copy your CSV file to the `data/` folder
2. Ensure it's named `indConComponentes.csv` (or update the path in line 16 of `01_pca_analysis.R`)

## Running the Analysis

1. Open `scripts/01_pca_analysis.R` in the RStudio Editor
2. Source the entire script using `Ctrl+Shift+S` (Windows/Linux) or `Cmd+Shift+S` (Mac)
3. Or run the script step-by-step:
   - Select code sections using `Ctrl+Enter` to run highlighted code

## Output Files

The analysis generates the following outputs in the `results/` folder:

| File | Description |
|------|-------------|
| `composite_indicator.csv` | Final composite indicator scores (0-100 scale) with geographic region, year, and index values |
| `loadings_*.csv` | PCA loadings (contributions) for each dimension showing how indicators contribute to PCs |
| `01_composite_distribution.png` | Histogram and density plot of the composite indicator distribution |
| `02_top_regions_timeseries.png` | Time series plot of composite indicator for top 5 performing regions |
| `03_final_pca_biplot.png` | Biplot showing contributions of dimensions to final PCA |

## Key Outputs in Console

The console output displays:

1. **Data Summary**: Overview of data structure and missing values
2. **PCA Results by Dimension**:
   - Number of indicators in each dimension
   - Variance explained by first 3 principal components
   - Top contributing indicators to PC1
3. **Final PCA Results**:
   - Variance explained at aggregate level
   - Contributions of each dimension to final composite indicator
4. **File Paths**: Confirmation of saved result files

## Customization Options

### Modify PCA Component Count

In `01_pca_analysis.R`, line 124 and 145, change `ncp = 3` to a different number:
```r
pca <- PCA(pca_data_clean, scale.unit = TRUE, ncp = 5, graph = FALSE)  # Keep 5 components instead
```

### Change Missing Value Threshold

In line 142, modify the threshold for removing indicators:
```r
select(where(~mean(is.na(.)) < 0.3))  # Remove indicators with >30% missing data instead of 50%
```

### Adjust Output Scale

In line 179, modify the normalization scale:
```r
to = c(0, 100)  # Change to different range, e.g., c(0, 10) or c(-100, 100)
```

## Troubleshooting

### Package Installation Fails
- Ensure you have internet connection
- Try installing packages individually: `install.packages("tidyverse")`
- Check R version compatibility (R 4.0+ recommended)

### File Not Found Error
- Verify `indConComponentes.csv` is in the `data/` folder
- Check file path is correct in line 16 of `01_pca_analysis.R`

### Memory Issues with Large Datasets
- The script handles datasets with thousands of rows automatically
- For very large files (>100MB), consider filtering by year/region first

## Dependencies

| Package | Purpose |
|---------|---------|
| `tidyverse` | Data manipulation and visualization (dplyr, ggplot2, etc.) |
| `data.table` | Fast data frame operations |
| `FactoMineR` | Principal Component Analysis |
| `factoextra` | PCA visualization and extraction |
| `ggplot2` | Advanced graphics |
| `scales` | Data scaling utilities |

## References

- **PCA Method**: Jolliffe, I. T. (2002). Principal Component Analysis.
- **Composite Indicators**: OECD Handbook on Constructing Composite Indicators
- **FactoMineR Package**: Lê, S., Josse, J., & Husson, F. (2008).

## License

This analysis framework is provided as-is for educational and research purposes.

## Contact & Support

For questions about the analysis methodology or script customization, consult the inline comments in the R scripts.

---

**Last Updated**: February 2026  
**R Version**: 4.0+  
**RStudio Version**: 2023+

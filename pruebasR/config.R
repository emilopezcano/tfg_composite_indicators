################################################################################
# Configuration File for PCA Analysis
# Modify these settings to customize the analysis behavior
################################################################################

# ============================================================================
# FILE PATHS
# ============================================================================

# Input data file path (relative to project root)
DATA_FILE <- "data/indConComponentes.csv"

# Results output directory
RESULTS_DIR <- "results/"

# ============================================================================
# PCA SETTINGS
# ============================================================================

# Number of principal components to extract per dimension
# Higher values retain more variance but reduce dimensionality reduction
PCA_N_COMPONENTS <- 3

# Variance threshold for removing indicators (0-1)
# Indicators with missing data > this threshold will be removed
# Example: 0.5 means remove if >50% missing values
MISSING_VALUE_THRESHOLD <- 0.5

# Imputation method for remaining missing values
# Options: "mean" (default), "median", "knn"
IMPUTATION_METHOD <- "mean"

# Scale PCA variables
# TRUE = standardize to mean=0, sd=1 (recommended)
# FALSE = use original scale
SCALE_UNIT <- TRUE

# ============================================================================
# OUTPUT NORMALIZATION
# ============================================================================

# Normalize final composite indicator to this range
# Common options: c(0, 100), c(0, 10), c(-1, 1), c(0, 1)
OUTPUT_SCALE <- c(0, 100)

# ============================================================================
# VISUALIZATION SETTINGS
# ============================================================================

# Image resolution (DPI)
IMAGE_DPI <- 300

# Image width (in inches)
IMAGE_WIDTH <- 10

# Image height (in inches)
IMAGE_HEIGHT <- 6

# Color palette for plots
# Options: "Set1", "Set2", "Dark2", "Pastel1", "Blues", "RdBu"
COLOR_PALETTE <- "Set1"

# Top N regions to show in time series plot
N_TOP_REGIONS <- 5

# ============================================================================
# ANALYSIS OPTIONS
# ============================================================================

# Automatically save detailed PCA reports
SAVE_PCA_REPORTS <- TRUE

# Save PC scores for further analysis
SAVE_PC_SCORES <- TRUE

# Create correlation matrices heatmaps
CREATE_CORRELATION_PLOTS <- TRUE

# Verbose console output
VERBOSE <- TRUE

# ============================================================================
# ADVANCED OPTIONS
# ============================================================================

# Minimum number of observations per dimension to perform PCA
MIN_OBSERVATIONS <- 10

# Handle negative variance explained (edge cases)
ALLOW_NEGATIVE_VARIANCE <- FALSE

# Random seed for reproducibility
RANDOM_SEED <- 42

# Encoding of input CSV file
CSV_ENCODING <- "UTF-8"

# Number of decimal places for output
DECIMAL_PLACES <- 2

################################################################################
# END OF CONFIGURATION
################################################################################

################################################################################
# QUICK DIAGNOSTIC - Copy & Paste this into RStudio Console
# Find out why some dimensions are missing loadings files
################################################################################

library(tidyverse)

# Load and prepare data (same as main script)
df <- read.csv("data/indConComponentes.csv", encoding = "UTF-8")

df_analysis <- df %>%
  select(indicator_id, date, period_id, geo_id, value, dimension_id) %>%
  mutate(date = as.Date(date)) %>%
  distinct() %>%
  filter(!is.na(value))

# ============================================================================
# CHECK EACH DIMENSION
# ============================================================================

cat("\n", rep("=", 80), "\n")
cat("DIAGNOSTIC: Why Missing Loadings Files?")
cat("\n", rep("=", 80), "\n\n")

for (dim in sort(unique(df_analysis$dimension_id))) {
  
  cat("DIMENSION: ", dim, "\n", rep("-", 80), "\n\n")
  
  # Get indicators for this dimension
  df_dim <- df_analysis %>%
    filter(dimension_id == dim) %>%
    mutate(obs_id = paste0(geo_id, "_", format(date, "%Y")))
  
  indicators <- unique(df_dim$indicator_id)
  cat("✓ Total indicators found: ", length(indicators), "\n")
  cat("  Indicators: ", paste(indicators, collapse = ", "), "\n\n")
  
  # Create wide format (like PCA script does)
  pca_data <- df_dim %>%
    select(obs_id, indicator_id, value) %>%
    pivot_wider(
      names_from = indicator_id,
      values_from = value,
      values_fill = NA
    ) %>%
    column_to_rownames(var = "obs_id")
  
  # Check missing values
  cat("Data completeness analysis:\n")
  for (ind in indicators) {
    total <- nrow(pca_data)
    valid <- sum(!is.na(pca_data[[ind]]))
    missing_pct <- round((1 - valid/total) * 100, 1)
    
    will_keep <- if (missing_pct <= 50) "✓ KEEP" else "❌ REMOVE"
    
    cat(sprintf("  %s: %d/%d values (%d%% missing) %s\n", 
                ind, valid, total, missing_pct, will_keep))
  }
  
  # Clean data (remove high-missing indicators, like main script)
  pca_data_clean <- pca_data %>%
    select(where(~mean(is.na(.)) < 0.5))
  
  cat("\n")
  if (ncol(pca_data_clean) >= 2) {
    cat("✓✓✓ PCA WILL BE PERFORMED\n")
    cat("    → loadings_", dim, ".csv WILL BE CREATED\n", sep = "")
    cat("    → Using ", ncol(pca_data_clean), " indicators\n", sep = "")
  } else {
    cat("❌❌❌ PCA CANNOT BE PERFORMED\n")
    cat("    → loadings_", dim, ".csv WILL NOT be created\n", sep = "")
    cat("    → Reason: Only ", ncol(pca_data_clean), " indicator(s) after cleanup\n", sep = "")
    cat("    → This dimension is EXCLUDED from final composite indicator\n")
    
    if (ncol(pca_data_clean) == 1) {
      cat("    → Remove the step: select(where(~mean(is.na(.)) < 0.5))\n")
      cat("    → OR increase threshold from 50% to allow this dimension\n")
    }
  }
  
  cat("\n\n")
}

cat(rep("=", 80), "\n\n")

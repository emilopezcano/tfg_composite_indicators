################################################################################
# DIAGNOSTIC: Check data availability by dimension
# Identifies why some dimensions might have missing loadings
################################################################################

library(tidyverse)
library(data.table)

# Load raw data
df <- read.csv("data/indConComponentes.csv", encoding = "UTF-8")

cat("\n", rep("=", 70), "\n")
cat("DATA DIAGNOSTIC REPORT")
cat("\n", rep("=", 70), "\n\n")

# Prepare data
df_analysis <- df %>%
  select(indicator_id, date, period_id, geo_id, value, 
         indicator_direction, dimension_id, value_ori) %>%
  mutate(date = as.Date(date),
         year = format(date, "%Y")) %>%
  distinct() %>%
  filter(!is.na(value))

# Analysis by dimension
for (dim in sort(unique(df_analysis$dimension_id))) {
  
  cat("\n", rep("-", 70), "\n")
  cat("DIMENSION:", dim, "\n")
  cat(rep("-", 70), "\n\n")
  
  df_dim <- df_analysis %>%
    filter(dimension_id == dim)
  
  # Create wide format
  df_dim <- df_dim %>%
    mutate(obs_id = paste0(geo_id, "_", year))
  
  pca_data <- df_dim %>%
    select(obs_id, indicator_id, value) %>%
    pivot_wider(
      names_from = indicator_id,
      values_from = value,
      values_fill = NA
    )
  
  # Indicators in this dimension
  indicators <- colnames(pca_data)[-1]  # Exclude obs_id
  
  cat("Total indicators:", length(indicators), "\n")
  cat("Indicators:", paste(indicators, collapse = ", "), "\n\n")
  
  # Data completeness analysis
  cat("Data Completeness by Indicator:\n")
  completeness <- data.frame(
    indicator = indicators,
    total_obs = NA,
    non_na = NA,
    missing_pct = NA,
    status = NA
  )
  
  for (i in 1:length(indicators)) {
    ind <- indicators[i]
    total <- nrow(pca_data)
    non_na <- sum(!is.na(pca_data[[ind]]))
    missing_pct <- (1 - non_na/total) * 100
    
    # Determine if it will be kept or removed
    if (missing_pct > 50) {
      status <- "❌ REMOVED (>50% missing)"
    } else {
      status <- "✓ KEPT"
    }
    
    completeness$total_obs[i] <- total
    completeness$non_na[i] <- non_na
    completeness$missing_pct[i] <- round(missing_pct, 1)
    completeness$status[i] <- status
  }
  
  print(completeness)
  
  # Count kept indicators
  kept_indicators <- sum(completeness$missing_pct <= 50)
  
  cat("\n")
  if (kept_indicators >= 2) {
    cat("✓ Will perform PCA: ", kept_indicators, " indicators will be used\n", sep = "")
    cat("   → loadings_", dim, ".csv WILL BE CREATED\n", sep = "")
  } else {
    cat("❌ PCA NOT POSSIBLE: Only ", kept_indicators, " indicator(s) with <50% missing\n", sep = "")
    cat("   → loadings_", dim, ".csv WILL NOT BE CREATED\n", sep = "")
    cat("   → This dimension is EXCLUDED from final PCA\n")
  }
  
  cat("\n")
}

cat("\n", rep("=", 70), "\n")
cat("SUMMARY")
cat("\n", rep("=", 70), "\n\n")

# Overall summary
all_dims <- sort(unique(df_analysis$dimension_id))
cat("Total dimensions in dataset:", length(all_dims), "\n")
cat("Dimensions:", paste(all_dims, collapse = ", "), "\n\n")

# Check which dimensions should have loadings
cat("Expected loadings files:\n")
for (dim in all_dims) {
  df_dim <- df_analysis %>%
    filter(dimension_id == dim) %>%
    mutate(obs_id = paste0(geo_id, "_", year))
  
  pca_data <- df_dim %>%
    select(obs_id, indicator_id, value) %>%
    pivot_wider(
      names_from = indicator_id,
      values_from = value,
      values_fill = NA
    )
  
  indicators <- colnames(pca_data)[-1]
  missing_pct <- colMeans(is.na(pca_data[-1])) * 100
  kept <- sum(missing_pct <= 50)
  
  if (kept >= 2) {
    cat("  ✓ loadings_", dim, ".csv (", kept, " indicators)\n", sep = "")
  } else {
    cat("  ❌ loadings_", dim, ".csv NOT CREATED (Only ", kept, " indicator available)\n", sep = "")
  }
}

cat("\n", rep("=", 70), "\n")

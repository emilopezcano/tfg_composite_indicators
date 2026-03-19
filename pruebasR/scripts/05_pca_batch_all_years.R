################################################################################
# PCA ANALYSIS BY YEAR - ALL YEARS AUTOMATED
#
# This script runs the PCA analysis for EVERY year in your dataset
# It creates a separate analysis for each year
# Results go to: results_2022/, results_2023/, results_2024/, etc.
################################################################################

library(tidyverse)
library(data.table)
library(FactoMineR)
library(factoextra)
library(ggplot2)

# Set path
data_path <- "data/indConComponentes.csv"

# Load data to find available years
df <- read.csv(data_path, encoding = "UTF-8")
available_years <- sort(unique(as.numeric(format(as.Date(df$date), "%Y"))))

cat("\n", rep("=", 80), "\n")
cat("PCA ANALYSIS BY YEAR - BATCH PROCESSING")
cat("\n", rep("=", 80), "\n\n")

cat("Available years:", paste(available_years, collapse = ", "), "\n\n")

# OPTION 1: Analyze SPECIFIC years (uncomment and modify)
# years_to_analyze <- c(2022, 2023)

# OPTION 2: Analyze ALL years (comment out above and uncomment below)
years_to_analyze <- available_years

cat("Years to analyze:", paste(years_to_analyze, collapse = ", "), "\n\n")

################################################################################
# FUNCTION: Perform PCA for a single year
################################################################################

perform_pca_for_year <- function(analysis_year, data_path) {
  
  cat("\n", rep("▓", 80), "\n")
  cat("PROCESSING YEAR:", analysis_year)
  cat("\n", rep("▓", 80), "\n\n")
  
  # Setup
  results_path <- paste0("results_", analysis_year, "/")
  if (!dir.exists(results_path)) {
    dir.create(results_path)
  }
  
  # Load and filter data
  df <- read.csv(data_path, encoding = "UTF-8")
  
  df_analysis <- df %>%
    select(indicator_id, date, period_id, geo_id, value, dimension_id) %>%
    mutate(date = as.Date(date),
           year = as.numeric(format(date, "%Y"))) %>%
    distinct() %>%
    filter(!is.na(value),
           year == analysis_year)
  
  cat("Observations:", nrow(df_analysis), "\n")
  cat("Regions:", n_distinct(df_analysis$geo_id), "\n")
  cat("Dimensions:", paste(unique(df_analysis$dimension_id), collapse = ", "), "\n\n")
  
  # PCA BY DIMENSION
  pca_results <- list()
  dimension_pcs <- list()
  
  for (dim in sort(unique(df_analysis$dimension_id))) {
    
    df_dim <- df_analysis %>%
      filter(dimension_id == dim)
    
    df_dim$obs_id <- df_dim$geo_id
    
    # Create wide format
    pca_data <- df_dim %>%
      select(obs_id, indicator_id, value) %>%
      pivot_wider(
        names_from = indicator_id,
        values_from = value,
        values_fill = NA
      ) %>%
      column_to_rownames(var = "obs_id")
    
    # Clean data
    pca_data_clean <- pca_data %>%
      select(where(~mean(is.na(.)) <= 0.5))
    
    # Impute NAs
    pca_data_clean <- pca_data_clean %>%
      mutate(across(everything(), ~ifelse(is.na(.), mean(., na.rm = TRUE), .)))
    
    # Perform PCA if possible (need at least 2 indicators)
    if (ncol(pca_data_clean) >= 2) {
      
      # Always extract 2 components (limited by n_variables-1)
      n_comps <- min(2, ncol(pca_data_clean) - 1)
      
      pca <- PCA(pca_data_clean, scale.unit = TRUE, ncp = n_comps, graph = FALSE)
      pca_results[[dim]] <- pca
      
      # Extract PC scores with dynamic column naming
      pc_scores <- as.data.frame(pca$ind$coord)
      pc_scores$region <- rownames(pc_scores)
      
      # Dynamically rename only the PCs that exist
      pc_col_names <- colnames(pc_scores)[grep("^Dim\\.", colnames(pc_scores))]
      new_names <- paste0(dim, "_PC", 1:length(pc_col_names))
      names(pc_scores)[names(pc_scores) %in% pc_col_names] <- new_names
      
      pc_scores <- pc_scores %>%
        select(region, starts_with(dim))
      
      dimension_pcs[[dim]] <- pc_scores
      
      # Save loadings (PC1 and PC2 if exists)
      loadings_df <- data.frame(
        indicator = rownames(pca$var$contrib),
        PC1 = pca$var$contrib[, 1]
      )
      
      # Add PC2 if it exists
      if (ncol(pca$var$contrib) >= 2) {
        loadings_df$PC2 <- pca$var$contrib[, 2]
      } else {
        loadings_df$PC2 <- 0
      }
      
      write.csv(loadings_df,
                file.path(results_path, paste0("loadings_", dim, "_", analysis_year, ".csv")),
                row.names = FALSE)
      
      cat("✓", dim, "-", ncol(pca_data_clean), "indicators\n")
      
    } else {
      cat("❌", dim, "- Insufficient data\n")
    }
  }
  
  # FINAL PCA - AGGREGATE DIMENSIONS
  if (length(dimension_pcs) >= 2) {
    
    final_pca_data <- Reduce(
      function(x, y) full_join(x, y, by = "region"),
      dimension_pcs
    ) %>%
      column_to_rownames(var = "region")
    
    final_pca_data_complete <- final_pca_data %>%
      filter(complete.cases(.))
    
    if (nrow(final_pca_data_complete) > 0) {
      
      final_pca <- PCA(final_pca_data_complete, scale.unit = TRUE, ncp = 2, graph = FALSE)
      
      # Extract composite scores
      composite_indicator <- as.data.frame(final_pca$ind$coord[, 1, drop = FALSE])
      composite_indicator$region <- rownames(composite_indicator)
      composite_indicator <- composite_indicator %>%
        rename(composite_index = Dim.1) %>%
        select(region, composite_index) %>%
        mutate(
          year = analysis_year,
          composite_index_normalized = scales::rescale(composite_index, to = c(0, 100))
        ) %>%
        select(region, year, composite_index, composite_index_normalized)
      
      # Save results
      write.csv(composite_indicator,
                file.path(results_path, paste0("composite_indicator_", analysis_year, ".csv")),
                row.names = FALSE)
      
      # Save final loadings (PC1 and PC2)
      final_loadings_df <- data.frame(
        dimension = rownames(final_pca$var$contrib),
        PC1 = final_pca$var$contrib[, 1]
      )
      
      # Add PC2 if it exists
      if (ncol(final_pca$var$contrib) >= 2) {
        final_loadings_df$PC2 <- final_pca$var$contrib[, 2]
      } else {
        final_loadings_df$PC2 <- 0
      }
      
      write.csv(final_loadings_df,
                file.path(results_path, paste0("loadings_final_", analysis_year, ".csv")),
                row.names = FALSE)
      
      # Create visualizations
      p1 <- ggplot(composite_indicator, aes(x = composite_index_normalized)) +
        geom_histogram(bins = 10, fill = "steelblue", alpha = 0.7, color = "black") +
        geom_density(aes(y = after_stat(count)), color = "red", linewidth = 1) +
        labs(title = paste("Composite Indicator -", analysis_year),
             x = "Index (0-100)", y = "Frequency") +
        theme_minimal()
      
      ggsave(file.path(results_path, paste0("01_distribution_", analysis_year, ".png")),
             p1, width = 10, height = 6, dpi = 300)
      
      p2 <- composite_indicator %>%
        arrange(desc(composite_index_normalized)) %>%
        ggplot(aes(x = reorder(region, composite_index_normalized), 
                   y = composite_index_normalized,
                   fill = composite_index_normalized)) +
        geom_col() +
        coord_flip() +
        scale_fill_gradient(low = "red", high = "green") +
        labs(title = paste("Rankings -", analysis_year),
             x = "Region", y = "Index (0-100)") +
        theme_minimal()
      
      ggsave(file.path(results_path, paste0("02_rankings_", analysis_year, ".png")),
             p2, width = 10, height = 12, dpi = 300)
      
      cat("\n✓✓✓ Year", analysis_year, "complete!\n")
      cat("   Mean score:", round(mean(composite_indicator$composite_index_normalized), 2), "/100\n")
      
      return(composite_indicator)
      
    }
  }
  
  cat("\n❌ Could not complete year", analysis_year, "\n")
  return(NULL)
  
}

################################################################################
# RUN ANALYSIS FOR ALL SELECTED YEARS
################################################################################

all_results <- list()

for (year in years_to_analyze) {
  result <- perform_pca_for_year(year, data_path)
  if (!is.null(result)) {
    all_results[[as.character(year)]] <- result
  }
}

################################################################################
# COMBINE RESULTS ACROSS YEARS
################################################################################

if (length(all_results) > 0) {
  
  cat("\n", rep("=", 80), "\n")
  cat("COMBINING RESULTS ACROSS ALL YEARS")
  cat("\n", rep("=", 80), "\n\n")
  
  # Bind all results
  all_years_combined <- bind_rows(all_results)
  
  # Save combined results
  write.csv(all_years_combined, 
            "results/COMBINED_composite_indicators_all_years.csv",
            row.names = FALSE)
  
  cat("✓ Saved: COMBINED_composite_indicators_all_years.csv\n\n")
  
  # Create comparison plot
  p_compare <- all_years_combined %>%
    group_by(year) %>%
    summarise(
      mean_score = mean(composite_index_normalized),
      sd_score = sd(composite_index_normalized),
      .groups = 'drop'
    ) %>%
    ggplot(aes(x = year, y = mean_score)) +
    geom_line(linewidth = 1.5, color = "steelblue") +
    geom_point(size = 4, color = "steelblue") +
    geom_errorbar(aes(ymin = mean_score - sd_score, ymax = mean_score + sd_score),
                  width = 0.3, color = "gray") +
    labs(
      title = "Mean Composite Indicator by Year (±1 SD)",
      x = "Year",
      y = "Mean Score (0-100)"
    ) +
    theme_minimal() +
    theme(plot.title = element_text(face = "bold", size = 14))
  
  ggsave("results/comparison_across_years.png", p_compare, width = 12, height = 6, dpi = 300)
  cat("✓ Saved: comparison_across_years.png\n\n")
  
}

################################################################################
# SUMMARY
################################################################################

cat("\n", rep("▓", 80), "\n")
cat("✓✓✓ BATCH PROCESSING COMPLETE ✓✓✓")
cat("\n", rep("▓", 80), "\n\n")

cat("Years processed:", paste(names(all_results), collapse = ", "), "\n\n")
cat("Output structure:\n")
cat("  results_2022/ → All 2022 analyses\n")
cat("  results_2023/ → All 2023 analyses\n")
cat("  results_xxxx/ → etc.\n\n")
cat("Combined file: results/COMBINED_composite_indicators_all_years.csv\n\n")

# Summary table
if (length(all_results) > 0) {
  summary_stats <- all_years_combined %>%
    group_by(year) %>%
    summarise(
      n_regions = n(),
      mean = round(mean(composite_index_normalized), 2),
      sd = round(sd(composite_index_normalized), 2),
      min = round(min(composite_index_normalized), 2),
      max = round(max(composite_index_normalized), 2),
      .groups = 'drop'
    )
  
  cat("Summary Statistics:\n")
  print(summary_stats)
}

cat("\n", rep("▓", 80), "\n")

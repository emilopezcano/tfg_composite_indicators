################################################################################
# PCA BY YEAR - AGGREGATION VIA SIMPLE AVERAGE
#
# This script performs PCA at dimension level, then aggregates to composite
# indicator using SIMPLE AVERAGE (not PCA aggregation)
# 
# Process:
# 1. For each dimension: PCA with 2 components
# 2. Extract PC1 scores for each region per dimension
# 3. Average the 3 dimension PC1s to create composite indicator
# 4. Normalize to 0-100 scale
#
# Works for: 2022 (modify ANALYSIS_YEAR for other years)
################################################################################

library(tidyverse)
library(data.table)
library(FactoMineR)
library(factoextra)
library(ggplot2)
library(scales)

# ============================================================================
# CONFIGURATION
# ============================================================================

ANALYSIS_YEAR <- 2022

# Paths
data_path <- "data/indConComponentes.csv"
results_path <- paste0("results_", ANALYSIS_YEAR, "_avgagg/")

# Create results folder
if (!dir.exists(results_path)) {
  dir.create(results_path, showWarnings = FALSE)
}

cat("\n", rep("=", 80), "\n")
cat("PCA ANALYSIS BY YEAR - AVERAGE AGGREGATION")
cat("\n", rep("=", 80), "\n\n")

cat("Year: ", ANALYSIS_YEAR, "\n")
cat("Aggregation method: Simple AVERAGE of dimension PC1s\n")
cat("Results path: ", results_path, "\n\n")

################################################################################
# 1. LOAD AND PREPARE DATA
################################################################################

cat("Loading data...\n")
df <- read.csv(data_path, encoding = "UTF-8")

# Extract year from date
df$year <- as.numeric(format(as.Date(df$date), "%Y"))

# Filter for analysis year
df_analysis <- df %>%
  filter(year == ANALYSIS_YEAR) %>%
  drop_na(value)

cat("✓ Loaded", nrow(df), "total rows\n")
cat("✓ Records for", ANALYSIS_YEAR, ":", nrow(df_analysis), "\n\n")

################################################################################
# 2. PCA BY DIMENSION
################################################################################

cat("\n", rep("-", 80), "\n")
cat("PCA BY DIMENSION")
cat("\n", rep("-", 80), "\n\n")

unique_dims <- unique(df_analysis$dimension_id)
pca_results <- list()
dimension_pcs <- list()

for (dim in unique_dims) {
  
  cat("Processing dimension:", dim, "\n")
  cat(rep("·", 40), "\n")
  
  # Filter data for this dimension
  pca_data <- df_analysis %>%
    filter(dimension_id == dim) %>%
    select(geo_id, indicator_id, value) %>%
    pivot_wider(names_from = indicator_id, 
                values_from = value,
                values_fn = mean)
  
  # Set region as rowname
  pca_data_matrix <- as.data.frame(pca_data)
  rownames(pca_data_matrix) <- pca_data_matrix$geo_id
  pca_data_matrix$geo_id <- NULL
  
  # Remove completely empty columns
  pca_data_clean <- pca_data_matrix %>%
    select(where(~!all(is.na(.))))
  
  cat("Initial indicators: ", ncol(pca_data_clean), "\n", sep = "")
  
  # Remove indicators with >50% missing values
  pca_data_clean <- pca_data_clean %>%
    select(where(~mean(is.na(.)) <= 0.5))
  
  cat("After >50% missing filter: ", ncol(pca_data_clean), "\n", sep = "")
  
  # Impute remaining NAs with mean
  pca_data_clean <- pca_data_clean %>%
    mutate(across(everything(), ~ifelse(is.na(.), mean(., na.rm = TRUE), .)))
  
  cat("After cleanup: ", ncol(pca_data_clean), " indicators\n\n", sep = "")
  
  # Perform PCA if we have at least 2 indicators
  if (ncol(pca_data_clean) >= 2) {
    
      # Always extract 2 components (limited by n_variables-1)
      n_comps <- min(2, ncol(pca_data_clean) - 1)
      pca <- PCA(pca_data_clean, scale.unit = TRUE, ncp = n_comps, graph = FALSE)
      
      pca_results[[dim]] <- pca
      
      # Extract PC scores for each region
      pc_scores <- as.data.frame(pca$ind$coord)
      pc_scores$region <- rownames(pc_scores)
      
      # Dynamically rename only the PCs that exist
      pc_col_names <- colnames(pc_scores)[grep("^Dim\\.", colnames(pc_scores))]
      new_names <- paste0(dim, "_PC", 1:length(pc_col_names))
      names(pc_scores)[names(pc_scores) %in% pc_col_names] <- new_names
      
      pc_scores <- pc_scores %>%
        select(region, starts_with(dim))
      
      dimension_pcs[[dim]] <- pc_scores
      
      # Print top contributing indicators
      cat("Top contributing indicators to PC1:\n")
      loadings <- pca$var$contrib[, 1] %>% sort(decreasing = TRUE)
      print(round(loadings[1:min(5, length(loadings))], 2))
      cat("\n")
      
      # Save loadings for documentation (only PC1 and PC2 if they exist)
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
                file.path(results_path, paste0("loadings_", dim, "_", ANALYSIS_YEAR, ".csv")),
                row.names = FALSE)
      
      cat("✓ Saved: loadings_", dim, "_", ANALYSIS_YEAR, ".csv\n\n", sep = "")
    
  } else {
    cat("⚠ Not enough indicators for PCA (need ≥ 2)\n\n")
  }
}

################################################################################
# 3. AGGREGATE TO COMPOSITE INDICATOR - SIMPLE AVERAGE METHOD
################################################################################

cat("\n", rep("-", 80), "\n")
cat("AGGREGATION: SIMPLE AVERAGE OF DIMENSION PC1s")
cat("\n", rep("-", 80), "\n\n")

# Combine all dimension PC scores
final_data <- Reduce(function(x, y) full_join(x, y, by = "region"), dimension_pcs)
rownames(final_data) <- final_data$region
final_data$region <- NULL

# Extract only PC1 from each dimension
pc1_columns <- colnames(final_data)[grep("_PC1$", colnames(final_data))]

cat("Dimensions included in average:\n")
for (col in pc1_columns) {
  cat("  -", col, "\n")
}
cat("\n")

# Calculate simple average of PC1s
composite_indicator <- data.frame(
  region = rownames(final_data),
  composite_index = rowMeans(final_data[, pc1_columns], na.rm = TRUE)
)

# Normalize to 0-100 scale
composite_indicator <- composite_indicator %>%
  mutate(
    year = ANALYSIS_YEAR,
    composite_index_normalized = scales::rescale(composite_index, to = c(0, 100))
  ) %>%
  select(region, year, composite_index, composite_index_normalized)

# Print summary
cat("✓ Composite indicator created via simple average\n\n")

cat("Summary Statistics:\n")
cat("  Mean: ", round(mean(composite_indicator$composite_index_normalized), 2), "\n", sep = "")
cat("  Median: ", round(median(composite_indicator$composite_index_normalized), 2), "\n", sep = "")
cat("  Min: ", round(min(composite_indicator$composite_index_normalized), 2), "\n", sep = "")
cat("  Max: ", round(max(composite_indicator$composite_index_normalized), 2), "\n")
cat("  SD: ", round(sd(composite_indicator$composite_index_normalized), 2), "\n\n")

# Show ranking for 2022
cat("\n", rep("-", 80), "\n")
cat("TOP & BOTTOM REGIONS FOR", ANALYSIS_YEAR)
cat("\n", rep("-", 80), "\n\n")

composite_ranked <- composite_indicator %>%
  arrange(desc(composite_index_normalized))

cat("TOP 5 Regions:\n")
print(head(composite_ranked, 5) %>% select(-year))
cat("\nBOTTOM 5 Regions:\n")
print(tail(composite_ranked, 5) %>% select(-year))
cat("\n")

################################################################################
# 4. SAVE RESULTS
################################################################################

# Save composite indicator
write.csv(composite_indicator,
          file.path(results_path, paste0("composite_indicator_", ANALYSIS_YEAR, ".csv")),
          row.names = FALSE)

cat("✓ Saved: composite_indicator_", ANALYSIS_YEAR, ".csv\n", sep = "")

# Save aggregation method info
method_info <- data.frame(
  aggregation_method = "Simple Average",
  description = "PC1 from each dimension averaged to create composite",
  dimensions_used = paste(pc1_columns, collapse = ", "),
  year = ANALYSIS_YEAR
)

write.csv(method_info,
          file.path(results_path, paste0("aggregation_method_", ANALYSIS_YEAR, ".csv")),
          row.names = FALSE)

cat("✓ Saved: aggregation_method_", ANALYSIS_YEAR, ".csv\n\n", sep = "")

################################################################################
# 5. VISUALIZATIONS
################################################################################

cat("Creating visualizations...\n\n")

# Distribution plot
p1 <- ggplot(composite_indicator, aes(x = composite_index_normalized)) +
  geom_histogram(bins = 10, fill = "steelblue", alpha = 0.7, color = "black") +
  geom_density(aes(y = after_stat(count)), color = "red", linewidth = 1) +
  labs(
    title = paste("Composite Indicator (Average Aggregation) -", ANALYSIS_YEAR),
    x = "Composite Index (0-100)",
    y = "Frequency",
    subtitle = paste("N =", nrow(composite_indicator), "regions")
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

ggsave(file.path(results_path, paste0("01_distribution_", ANALYSIS_YEAR, ".png")),
       p1, width = 10, height = 6, dpi = 300)
cat("✓ Saved: 01_distribution_", ANALYSIS_YEAR, ".png\n", sep = "")

# Bar plot ranked regions
p2 <- composite_ranked %>%
  ggplot(aes(x = reorder(region, composite_index_normalized), 
             y = composite_index_normalized,
             fill = composite_index_normalized)) +
  geom_col() +
  coord_flip() +
  scale_fill_gradient(low = "red", high = "green") +
  labs(
    title = paste("Region Rankings (Average Aggregation) -", ANALYSIS_YEAR),
    x = "Region",
    y = "Composite Index (0-100)",
    fill = "Index"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.y = element_text(size = 9)
  )

ggsave(file.path(results_path, paste0("02_rankings_", ANALYSIS_YEAR, ".png")),
       p2, width = 12, height = 8, dpi = 300)
cat("✓ Saved: 02_rankings_", ANALYSIS_YEAR, ".png\n", sep = "")

# Box plot with mean line
p3 <- ggplot(composite_indicator, aes(y = composite_index_normalized)) +
  geom_boxplot(fill = "lightblue", alpha = 0.7) +
  geom_point(aes(x = 1), position = position_jitter(width = 0.1), alpha = 0.6) +
  geom_hline(aes(yintercept = mean(composite_index_normalized)), 
             color = "red", linetype = "dashed", linewidth = 1) +
  labs(
    title = paste("Distribution Overview (Average Aggregation) -", ANALYSIS_YEAR),
    y = "Composite Index (0-100)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    plot.title = element_text(face = "bold", size = 14)
  )

ggsave(file.path(results_path, paste0("03_distribution_boxplot_", ANALYSIS_YEAR, ".png")),
       p3, width = 8, height = 6, dpi = 300)
cat("✓ Saved: 03_distribution_boxplot_", ANALYSIS_YEAR, ".png\n\n", sep = "")

################################################################################
# SUMMARY
################################################################################

cat("\n", rep("=", 80), "\n")
cat("ANALYSIS COMPLETE")
cat("\n", rep("=", 80), "\n\n")

cat("Aggregation Method: SIMPLE AVERAGE\n")
cat("Components averaged: PC1 from each dimension\n")
cat("Results folder: ", results_path, "\n\n")

cat("Output files:\n")
cat("  ✓ composite_indicator_", ANALYSIS_YEAR, ".csv (main result)\n", sep = "")
cat("  ✓ loadings_*.csv (indicator contributions by dimension)\n")
cat("  ✓ aggregation_method_", ANALYSIS_YEAR, ".csv (method details)\n", sep = "")
cat("  ✓ 01_distribution_*.png\n")
cat("  ✓ 02_rankings_*.png\n")
cat("  ✓ 03_distribution_boxplot_*.png\n\n")

cat("Next steps:\n")
cat("  1. Review composite_indicator_", ANALYSIS_YEAR, ".csv results\n", sep = "")
cat("  2. Compare with PCA aggregation (Script 04) if needed\n")
cat("  3. For other years: modify ANALYSIS_YEAR and run again\n\n")

################################################################################
# PCA Analysis for Composite Indicators
# Hierarchical PCA: PCA by dimension + Final PCA for composite indicator
################################################################################

# Load required libraries
library(tidyverse)
library(data.table)
library(factoextra)
library(FactoMineR)
library(ggplot2)

# Set paths
data_path <- "data/indConComponentes.csv"
results_path <- "results/"

################################################################################
# 1. LOAD AND CLEAN DATA
################################################################################

# Load data
df <- read.csv(data_path, encoding = "UTF-8")

# Display basic information
cat("\n=== DATA SUMMARY ===\n")
cat("Dimensions:", dim(df), "\n")
cat("Columns:", names(df), "\n\n")

# Check unique dimensions
cat("Unique dimensions:\n")
print(table(df$dimension_id))
cat("\n")

# Check unique indicators per dimension
cat("Unique indicators per dimension:\n")
dimension_indicators <- df %>%
  select(dimension_id, indicator_id) %>%
  distinct() %>%
  group_by(dimension_id) %>%
  summarise(n_indicators = n_distinct(indicator_id), .groups = 'drop')
print(dimension_indicators)

################################################################################
# 2. PREPARE DATA - Remove component information, work with indicators only
################################################################################

# Select relevant columns for analysis (exclude component_id)
df_analysis <- df %>%
  select(indicator_id, date, period_id, geo_id, value, 
         indicator_direction, dimension_id, value_ori) %>%
  mutate(
    date = as.Date(date),
    year = format(date, "%Y")
  ) %>%
  distinct()  # Remove duplicates if any

# Remove missing values
df_analysis <- df_analysis %>%
  filter(!is.na(value))

cat("\n=== DATA AFTER CLEANING ===\n")
cat("Dimensions:", dim(df_analysis), "\n")
cat("Years available:", unique(df_analysis$year), "\n")
cat("Geographic regions:", n_distinct(df_analysis$geo_id), "\n")

################################################################################
# 3. PREPARE DATA FOR PCA BY DIMENSION
################################################################################

# Create wide format: rows = geo_id x year, columns = indicators
# For each dimension separately

pca_results <- list()
dimension_pcs <- list()

for (dim in unique(df_analysis$dimension_id)) {
  cat("\n", rep("=", 60), "\n")
  cat("PCA FOR DIMENSION:", dim, "\n")
  cat(rep("=", 60), "\n\n")
  
  # Filter data for this dimension
  df_dim <- df_analysis %>%
    filter(dimension_id == dim)
  
  # Create unique identifier for each observation
  df_dim <- df_dim %>%
    mutate(obs_id = paste0(geo_id, "_", year))
  
  # Get indicator list for this dimension
  indicators_in_dim <- unique(df_dim$indicator_id)
  cat("Indicators in", dim, ":", length(indicators_in_dim), "\n")
  print(indicators_in_dim)
  cat("\n")
  
  # Create wide format for PCA
  pca_data <- df_dim %>%
    select(obs_id, indicator_id, value) %>%
    pivot_wider(
      names_from = indicator_id,
      values_from = value,
      values_fill = NA
    ) %>%
    column_to_rownames(var = "obs_id")
  
  # Check data completeness
  missing_pct <- colMeans(is.na(pca_data)) * 100
  cat("Missing values by indicator (%):\n")
  print(missing_pct)
  cat("\n")
  
  # Remove indicators with too many missing values (>50%)
  pca_data_clean <- pca_data %>%
    select(where(~mean(is.na(.)) < 0.5))
  
  # Impute remaining NAs with mean
  pca_data_clean <- pca_data_clean %>%
    mutate(across(everything(), ~ifelse(is.na(.), mean(., na.rm = TRUE), .)))
  
  cat("Indicators used:", ncol(pca_data_clean), "\n\n")
  
  # Perform PCA
  if (ncol(pca_data_clean) >= 2) {
    pca <- PCA(pca_data_clean, 
               scale.unit = TRUE, 
               ncp = 3,  # Keep 3 principal components
               graph = FALSE)
    
    pca_results[[dim]] <- pca
    
    # Extract PC scores
    pc_scores <- as.data.frame(pca$ind$coord)
    pc_scores$obs_id <- rownames(pc_scores)
    pc_scores <- pc_scores %>%
      rename_with(~paste0(dim, "_PC", 1:3), all_of(c("Dim.1", "Dim.2", "Dim.3")))
    
    dimension_pcs[[dim]] <- pc_scores
    
    # Print summary
    cat("Variance explained by first 3 PCs:\n")
    var_exp <- pca$eig[1:3, 2] %>% round(2)
    print(data.frame(
      PC = 1:3,
      Variance_Explained = var_exp,
      Cumulative = cumsum(var_exp)
    ))
    cat("\n")
    cat("Loadings (contributions) of indicators to PC1:\n")
    loadings <- pca$var$contrib[, 1] %>% sort(decreasing = TRUE)
    print(round(loadings, 2))
    cat("\n")
    
  } else {
    cat("WARNING: Not enough indicators for PCA in dimension", dim, "\n\n")
  }
}

################################################################################
# 4. FINAL PCA - Aggregate dimensions via PCA
################################################################################

cat("\n", rep("=", 60), "\n")
cat("FINAL PCA: AGGREGATING DIMENSIONS\n")
cat(rep("=", 60), "\n\n")

# Combine all dimension PC scores
final_pca_data <- Reduce(
  function(x, y) full_join(x, y, by = "obs_id"),
  dimension_pcs
) %>%
  column_to_rownames(var = "obs_id")

# Remove rows with missing values
final_pca_data <- final_pca_data %>%
  filter(complete.cases(.))

cat("Observations for final PCA:", nrow(final_pca_data), "\n")
cat("Dimensions (PCs) for final PCA:", ncol(final_pca_data), "\n\n")

# Perform final PCA
final_pca <- PCA(final_pca_data,
                 scale.unit = TRUE,
                 ncp = 3,
                 graph = FALSE)

# Extract composite indicator scores
composite_indicator <- as.data.frame(final_pca$ind$coord[, 1, drop = FALSE])
composite_indicator$obs_id <- rownames(composite_indicator)
composite_indicator <- composite_indicator %>%
  rename(composite_index = Dim.1) %>%
  select(obs_id, composite_index)

# Normalize to 0-100 scale
composite_indicator <- composite_indicator %>%
  mutate(
    composite_index_normalized = scales::rescale(
      composite_index, 
      to = c(0, 100)
    )
  )

cat("Final PCA Summary:\n")
cat("Variance explained by first 3 PCs:\n")
var_exp_final <- final_pca$eig[1:3, 2] %>% round(2)
print(data.frame(
  PC = 1:3,
  Variance_Explained = var_exp_final,
  Cumulative = cumsum(var_exp_final)
))

cat("\nLoadings (contributions) of dimensions to PC1:\n")
loadings_final <- final_pca$var$contrib[, 1] %>% sort(decreasing = TRUE)
print(round(loadings_final, 2))

################################################################################
# 5. SAVE RESULTS
################################################################################

# Split composite indicator back into separate columns for better understanding
composite_results <- composite_indicator %>%
  separate(obs_id, into = c("geo_id", "year"), sep = "_", remove = FALSE) %>%
  select(geo_id, year, obs_id, composite_index, composite_index_normalized)

# Save results
write.csv(composite_results, 
          file.path(results_path, "composite_indicator.csv"),
          row.names = FALSE)

cat("\n✓ Composite indicator saved to: results/composite_indicator.csv\n")

# Save PCA loadings for documentation
for (dim in names(pca_results)) {
  loadings_df <- data.frame(
    indicator = rownames(pca_results[[dim]]$var$contrib),
    PC1 = pca_results[[dim]]$var$contrib[, 1],
    PC2 = pca_results[[dim]]$var$contrib[, 2],
    PC3 = pca_results[[dim]]$var$contrib[, 3]
  )
  
  write.csv(loadings_df,
            file.path(results_path, paste0("loadings_", dim, ".csv")),
            row.names = FALSE)
  
  cat("✓ Loadings for", dim, "saved to: results/loadings_", dim, ".csv\n", sep = "")
}

################################################################################
# 6. VISUALIZATIONS
################################################################################

cat("\n=== CREATING VISUALIZATIONS ===\n\n")

# Composite indicator distribution
p1 <- ggplot(composite_results, aes(x = composite_index_normalized)) +
  geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
  geom_density(aes(y = after_stat(count)), color = "red", linewidth = 1) +
  labs(
    title = "Distribution of Composite Indicator",
    x = "Composite Index (0-100)",
    y = "Frequency"
  ) +
  theme_minimal()

ggsave(file.path(results_path, "01_composite_distribution.png"), 
       p1, width = 10, height = 6)
cat("✓ Composite distribution plot saved\n")

# Time series by top regions
top_geo <- composite_results %>%
  group_by(geo_id) %>%
  summarise(mean_index = mean(composite_index_normalized, na.rm = TRUE)) %>%
  top_n(5, mean_index) %>%
  pull(geo_id)

p2 <- composite_results %>%
  filter(geo_id %in% top_geo) %>%
  ggplot(aes(x = year, y = composite_index_normalized, color = geo_id, group = geo_id)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  labs(
    title = "Composite Indicator - Top 5 Regions",
    x = "Year",
    y = "Composite Index (0-100)",
    color = "Region"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave(file.path(results_path, "02_top_regions_timeseries.png"),
       p2, width = 12, height = 6)
cat("✓ Time series plot saved\n")

# Final PCA biplot (for documentation)
png(file.path(results_path, "03_final_pca_biplot.png"), width = 800, height = 600)
plot(final_pca, choix = "var", new.plot = TRUE)
dev.off()
cat("✓ Final PCA biplot saved\n")

cat("\n", rep("=", 60), "\n")
cat("ANALYSIS COMPLETE!")
cat("\nResults saved in: ", normalizePath(results_path), "\n")
cat(rep("=", 60), "\n")

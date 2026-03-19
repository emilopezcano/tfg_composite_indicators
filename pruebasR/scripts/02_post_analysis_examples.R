################################################################################
# Post-Analysis Examples
# Examples of how to use the composite indicator results
################################################################################

library(tidyverse)
library(ggplot2)

# Read the composite indicator results
composite_results <- read.csv("results/composite_indicator.csv")

# ============================================================================
# EXAMPLE 1: Basic Summary Statistics
# ============================================================================

cat("\n=== COMPOSITE INDICATOR SUMMARY STATISTICS ===\n\n")

# Overall statistics
summary(composite_results$composite_index_normalized)

# By region
cat("\nMean Composite Index by Region:\n")
by_region <- composite_results %>%
  group_by(geo_id) %>%
  summarise(
    Mean = round(mean(composite_index_normalized, na.rm = TRUE), 2),
    SD = round(sd(composite_index_normalized, na.rm = TRUE), 2),
    Min = round(min(composite_index_normalized, na.rm = TRUE), 2),
    Max = round(max(composite_index_normalized, na.rm = TRUE), 2),
    N = n(),
    .groups = 'drop'
  ) %>%
  arrange(desc(Mean))

print(by_region)

# By year
cat("\nMean Composite Index by Year:\n")
by_year <- composite_results %>%
  group_by(year) %>%
  summarise(
    Mean = round(mean(composite_index_normalized, na.rm = TRUE), 2),
    SD = round(sd(composite_index_normalized, na.rm = TRUE), 2),
    N = n(),
    .groups = 'drop'
  ) %>%
  arrange(year)

print(by_year)

# ============================================================================
# EXAMPLE 2: Identify Best and Worst Performers
# ============================================================================

cat("\n=== TOP AND BOTTOM PERFORMERS ===\n\n")

# Overall top 10 region-year combinations
cat("Top 10 Best Performers:\n")
print(
  composite_results %>%
    arrange(desc(composite_index_normalized)) %>%
    head(10) %>%
    select(geo_id, year, composite_index_normalized)
)

cat("\nTop 10 Worst Performers:\n")
print(
  composite_results %>%
    arrange(composite_index_normalized) %>%
    head(10) %>%
    select(geo_id, year, composite_index_normalized)
)

# ============================================================================
# EXAMPLE 3: Visualization - Region Comparison
# ============================================================================

cat("\n=== CREATING VISUALIZATIONS ===\n\n")

# Box plot by region
p_region <- ggplot(composite_results, 
                   aes(x = reorder(geo_id, composite_index_normalized, FUN = median), 
                       y = composite_index_normalized)) +
  geom_boxplot(fill = "steelblue", alpha = 0.7) +
  coord_flip() +
  labs(
    title = "Composite Indicator Distribution by Region",
    x = "Region",
    y = "Composite Index (0-100)"
  ) +
  theme_minimal()

ggsave("results/03_comparison_by_region.png", p_region, width = 10, height = 8)
cat("✓ Region comparison plot saved\n")

# ============================================================================
# EXAMPLE 4: Trend Analysis
# ============================================================================

cat("\n=== TREND ANALYSIS ===\n\n")

# Linear trend for each region
trends <- composite_results %>%
  group_by(geo_id) %>%
  do({
    model <- lm(composite_index_normalized ~ as.numeric(year), data = .)
    data.frame(
      geo_id = unique(.$geo_id),
      slope = round(coef(model)[2], 4),
      intercept = round(coef(model)[1], 2),
      r_squared = round(summary(model)$r.squared, 3)
    )
  }) %>%
  ungroup() %>%
  arrange(desc(abs(slope)))

cat("Regions with Strongest Improvement (positive slope):\n")
print(head(trends, 5))

cat("\nRegions with Most Decline (negative slope):\n")
print(tail(trends, 5))

# ============================================================================
# EXAMPLE 5: Ranking Overall Performance
# ============================================================================

cat("\n=== OVERALL PERFORMANCE RANKING ===\n\n")

overall_ranking <- composite_results %>%
  group_by(geo_id) %>%
  summarise(
    Avg_Score = round(mean(composite_index_normalized, na.rm = TRUE), 2),
    Latest_Score = composite_index_normalized[which.max(year)],
    .groups = 'drop'
  ) %>%
  arrange(desc(Avg_Score)) %>%
  mutate(Rank = row_number())

print(overall_ranking)

# ============================================================================
# EXAMPLE 6: Export for Further Analysis
# ============================================================================

cat("\n=== EXPORTING RESULTS ===\n\n")

# Export results with additional metrics
export_data <- composite_results %>%
  group_by(geo_id, year) %>%
  mutate(
    Quartile = ntile(composite_index_normalized, 4),
    Performance_Level = case_when(
      composite_index_normalized >= 75 ~ "High",
      composite_index_normalized >= 50 ~ "Medium-High",
      composite_index_normalized >= 25 ~ "Medium-Low",
      TRUE ~ "Low"
    )
  ) %>%
  ungroup()

write.csv(export_data, "results/composite_indicator_enriched.csv", row.names = FALSE)
cat("✓ Enriched results exported to: results/composite_indicator_enriched.csv\n")

cat("\n=== EXAMPLES COMPLETE ===\n")

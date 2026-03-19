################################################################################
# PCA ANALYSIS BY YEAR - EXAMPLE FOR 2022
# 
# Workflow:
# 1. Filter data for year 2022
# 2. For EACH DIMENSION: PCA on 2022 indicators → Extract PC1
# 3. Aggregate: PCA on the 3 dimension PCs → Final composite score 2022
#
# After understanding this, copy & modify for other years (2023, 2024, etc.)
################################################################################

library(tidyverse)
library(data.table)
library(FactoMineR)
library(factoextra)
library(ggplot2)

# Set year to analyze
ANALYSIS_YEAR <- 2022

# Set paths
data_path <- "data/indConComponentes.csv"
results_path <- paste0("results_", ANALYSIS_YEAR, "/")

# Create output directory if it doesn't exist
if (!dir.exists(results_path)) {
  dir.create(results_path)
}

################################################################################
# 1. LOAD AND FILTER DATA FOR 2022
################################################################################

cat("\n", rep("=", 80), "\n")
cat("PCA ANALYSIS FOR YEAR:", ANALYSIS_YEAR)
cat("\n", rep("=", 80), "\n\n")

# Load data
df <- read.csv(data_path, encoding = "UTF-8")

# Prepare data
df_analysis <- df %>%
  select(indicator_id, date, period_id, geo_id, value, dimension_id) %>%
  mutate(date = as.Date(date),
         year = as.numeric(format(date, "%Y"))) %>%
  distinct() %>%
  filter(!is.na(value),
         year == ANALYSIS_YEAR)  # ← FILTER BY YEAR

cat("Data loaded and filtered for year", ANALYSIS_YEAR, "\n")
cat("Total observations:", nrow(df_analysis), "\n")
cat("Regions available:", n_distinct(df_analysis$geo_id), "\n")
cat("Dimensions:", paste(unique(df_analysis$dimension_id), collapse = ", "), "\n\n")

################################################################################
# 2. PCA BY DIMENSION FOR 2022
################################################################################

pca_results <- list()
dimension_pcs <- list()

for (dim in sort(unique(df_analysis$dimension_id))) {
  
  cat(rep("=", 80), "\n")
  cat("PCA FOR DIMENSION:", dim, "| YEAR:", ANALYSIS_YEAR, "\n")
  cat(rep("=", 80), "\n\n")
  
  # Filter for this dimension and year 2022
  df_dim <- df_analysis %>%
    filter(dimension_id == dim)
  
  # Create row identifier (just geo_id for this year)
  df_dim$obs_id <- df_dim$geo_id
  
  # List of indicators in this dimension
  indicators_in_dim <- unique(df_dim$indicator_id)
  cat("Indicators in", dim, ":", length(indicators_in_dim), "\n")
  print(indicators_in_dim)
  cat("\n")
  
  # Create wide format: rows = regions, columns = indicators
  pca_data <- df_dim %>%
    select(obs_id, indicator_id, value) %>%
    pivot_wider(
      names_from = indicator_id,
      values_from = value,
      values_fill = NA
    ) %>%
    column_to_rownames(var = "obs_id")
  
  # Check data completeness
  cat("Data availability by indicator:\n")
  completeness <- data.frame(
    indicator = colnames(pca_data),
    n_valid = colSums(!is.na(pca_data)),
    total = nrow(pca_data),
    missing_pct = round(colMeans(is.na(pca_data)) * 100, 1)
  )
  completeness$status <- ifelse(completeness$missing_pct > 50, 
                                "❌ REMOVE (>50% missing)",
                                "✓ KEEP")
  print(completeness)
  cat("\n")
  
  # Remove indicators with too many missing values (>50%)
  pca_data_clean <- pca_data %>%
    select(where(~mean(is.na(.)) <= 0.5))
  
  # Impute remaining NAs with mean
  pca_data_clean <- pca_data_clean %>%
    mutate(across(everything(), ~ifelse(is.na(.), mean(., na.rm = TRUE), .)))
  
  cat("After cleanup: ", ncol(pca_data_clean), " indicators\n\n", sep = "")
  
  # Perform PCA if we have at least 2 indicators
  if (ncol(pca_data_clean) >= 2) {
    
    # Always extract 2 components (limited by n_variables-1)
    n_comps <- 1
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
    
    # Print PCA summary
    cat("✓ PCA performed successfully\n\n")
    cat("Variance explained by Principal Components:\n")
    var_exp <- pca$eig[1:nrow(pca$eig), 2] %>% round(2)
    print(data.frame(
      PC = 1:length(var_exp),
      Variance_Explained_Pct = var_exp,
      Cumulative_Pct = cumsum(var_exp)
    ))
    cat("\n")
    
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
    cat("❌ PCA NOT POSSIBLE: Only ", ncol(pca_data_clean), 
        " indicator(s) available\n", sep = "")
    cat("   (Need at least 2 indicators)\n\n")
  }
}

################################################################################
# 3. FINAL PCA - AGGREGATE DIMENSIONS FOR 2022
################################################################################

cat("\n", rep("=", 80), "\n")
cat("FINAL PCA: AGGREGATING DIMENSIONS | YEAR:", ANALYSIS_YEAR)
cat("\n", rep("=", 80), "\n\n")

# Check if we have PC scores from at least 2 dimensions
if (length(dimension_pcs) < 2) {
  cat("❌ ERROR: Need at least 2 dimensions with valid PCA")
  cat("\nCannot create composite indicator.\n")
  stop("Insufficient dimensions for final PCA")
}

# Combine PC scores from all dimensions
final_pca_data <- Reduce(
  function(x, y) full_join(x, y, by = "region"),
  dimension_pcs
) %>%
  column_to_rownames(var = "region")

# Remove rows with any missing values
final_pca_data_complete <- final_pca_data %>%
  filter(complete.cases(.))

cat("Dimensions in final PCA: ", ncol(final_pca_data_complete), "\n")
cat("Regions with complete data: ", nrow(final_pca_data_complete), "\n\n")

# Perform final PCA
final_pca <- PCA(final_pca_data_complete,
                 scale.unit = TRUE,
                 ncp = 1,
                 graph = FALSE)

# Extract composite scores (use PC1 as main score)
composite_indicator <- as.data.frame(final_pca$ind$coord[, 1, drop = FALSE])
composite_indicator$region <- rownames(composite_indicator)
composite_indicator <- composite_indicator %>%
  rename(composite_index = Dim.1) %>%
  select(region, composite_index)

# Normalize to 0-100 scale
composite_indicator <- composite_indicator %>%
  mutate(
    year = ANALYSIS_YEAR,
    composite_index_normalized = scales::rescale(composite_index, to = c(0, 100))
  ) %>%
  select(region, year, composite_index, composite_index_normalized)

# Print summary
cat("✓ Final PCA completed\n\n")
cat("Variance explained by Principal Components:\n")
var_exp_final <- final_pca$eig[1:3, 2] %>% round(2)
print(data.frame(
  PC = 1:3,
  Variance_Explained_Pct = var_exp_final,
  Cumulative_Pct = cumsum(var_exp_final)
))
cat("\n")

cat("Contribution of dimensions to PC1:\n")
loadings_final <- final_pca$var$contrib[, 1] %>% sort(decreasing = TRUE)
print(round(loadings_final, 2))
cat("\n")

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

#############################################

# Creamos una tabla con los resultados de todas las dimensiones por región
resultados_regiones <- Reduce(
  function(x, y) full_join(x, y, by = "region"),
  dimension_pcs
)

# Guardamos el archivo
write.csv(resultados_regiones, 
          file.path(results_path, paste0("ranking_regiones_por_dimension_", ANALYSIS_YEAR, ".csv")), 
          row.names = FALSE)

cat("✓ CREADO: ranking_regiones_por_dimension_", ANALYSIS_YEAR, ".csv\n")

##################################################

# 1. Tomamos los datos que se usaron para el PCA (ya limpios e imputados)
datos_completos_dim <- pca_data_clean
datos_completos_dim$region <- rownames(pca_data_clean)

# 2. Le pegamos la columna del Score (PC1) que acabamos de calcular
datos_completos_dim <- left_join(datos_completos_dim, pc_scores, by = "region")

# 3. Guardamos esta tabla maestra
nombre_archivo <- paste0("detalle_indicadores_y_scores_", dim, "_", ANALYSIS_YEAR, ".csv")
write.csv(datos_completos_dim, file.path(results_path, nombre_archivo), row.names = FALSE)

cat("✓ CREADO: ", nombre_archivo, " (Contiene indicadores y el score por región)\n")

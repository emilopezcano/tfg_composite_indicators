################################################################################
# PCA ANALYSIS: PESOS DE INDICADORES - ENFOQUE POR AÑO
# 
# Workflow:
# 1. Para CADA AÑO:
#    a. Para CADA DIMENSIÓN: PCA → Extract loadings PC1 como pesos
#                                 → Calcular scores ponderados
#    b. PCA FINAL: Usar dimension scores → Extract pesos de dimensiones
#                                        → Calcular índice sintético
# 2. Combinar y exportar resultados de todos los años
#
# Output: 
#   - composite_indicator_all_years.csv (índice final)
#   - loadings_[DIM]_[YEAR].csv (pesos por indicador)
#   - dimension_scores_[YEAR].csv (scores por dimensión)
################################################################################

library(tidyverse)
library(data.table)
library(FactoMineR)
library(factoextra)
library(ggplot2)

# Set paths
data_path <- "D:/Datos Anabel/OneDrive/Documentos/MATEMÁTICAS URJC/CUARTO CURSO/TFG/tfg_composite_indicators/data/df_indicadores_completo.rds"
results_path <- "results/"

# Ensure results directory exists
if (!dir.exists(results_path)) {
  dir.create(results_path, recursive = TRUE)
}

################################################################################
# 0. FUNCIONES AUXILIARES
################################################################################

# Función para estandarizar (0-100)
scale_0_100 <- function(x) {
  x_min <- min(x, na.rm = TRUE)
  x_max <- max(x, na.rm = TRUE)
  if (x_max == x_min) return(rep(50, length(x)))  # Si no hay varianza
  ((x - x_min) / (x_max - x_min)) * 100
}

# Función para crear matriz de datos para PCA
create_pca_matrix <- function(df, dimension_filter = NULL) {
  df_filtered <- df
  if (!is.null(dimension_filter)) {
    df_filtered <- df_filtered %>% filter(dimension_id == dimension_filter)
  }
  
  pca_data <- df_filtered %>%
    select(geo_id, indicator_id, value) %>%
    pivot_wider(
      names_from = indicator_id,
      values_from = value,
      values_fill = NA
    ) %>%
    column_to_rownames(var = "geo_id")
  
  return(pca_data)
}

################################################################################
# 1. LOAD AND PREPARE DATA
################################################################################

cat("\n", rep("=", 80), "\n")
cat("CARGANDO DATOS\n")
cat(rep("=", 80), "\n\n")

df <- readRDS(data_path)

# Prepare data: standardize column names and formats
df_analysis <- df %>%
  select(indicator_id, date, period_id, geo_id, indicator_value, dimension_id) %>%
  rename(value = indicator_value) %>%
  mutate(
    date = as.Date(date),
    year = as.numeric(format(date, "%Y"))
  ) %>%
  distinct() %>%
  filter(!is.na(value))

# Get list of years to analyze
years_to_analyze <- sort(unique(df_analysis$year))
cat("Años disponibles:", paste(years_to_analyze, collapse = ", "), "\n")
cat("Dimensiones:", paste(sort(unique(df_analysis$dimension_id)), collapse = ", "), "\n\n")

# Filter España (ESP) only for now - puedes cambiar esto
df_analysis <- df_analysis %>%
  filter(geo_id == "ESP")

cat("Análisis para región: ESP\n")
cat("Observaciones después de filtrado:", nrow(df_analysis), "\n\n")

################################################################################
# 2. PCA ANALYSIS BY YEAR AND DIMENSION
################################################################################

# Lista para almacenar resultados
all_results <- list()
all_loadings <- list()
all_dimension_scores <- list()
all_final_scores <- list()

for (year in years_to_analyze) {
  
  cat("\n", rep("=", 80), "\n")
  cat("ANÁLISIS PARA AÑO:", year, "\n")
  cat(rep("=", 80), "\n\n")
  
  # Filter for current year
  df_year <- df_analysis %>% filter(year == year)
  
  if (nrow(df_year) == 0) {
    cat("⚠️  No hay datos para el año", year, "\n\n")
    next
  }
  
  # ============================================================================
  # 2a. PCA POR DIMENSIÓN
  # ============================================================================
  
  dimension_scores <- data.frame(year = year, region = "ESP")
  dimension_loadings <- list()
  
  for (dim in sort(unique(df_year$dimension_id))) {
    
    cat("  📊 Dimensión:", dim, "\n")
    
    # Create PCA matrix for dimension
    df_dim <- df_year %>% filter(dimension_id == dim)
    
    # Aggregate duplicates (average by indicator)
    pca_data_raw <- df_dim %>%
      select(indicator_id, value) %>%
      group_by(indicator_id) %>%
      summarise(value = mean(value, na.rm = TRUE), .groups = 'drop') %>%
      pivot_wider(
        names_from = indicator_id,
        values_from = value,
        values_fill = NA
      )
    
    # Convert all to numeric and remove non-numeric columns
    pca_data <- pca_data_raw %>%
      mutate(across(everything(), as.numeric))
    
    # Check if we have data
    if (ncol(pca_data) < 2) {
      cat("     ⚠️  Menos de 2 indicadores, saltando...\n")
      next
    }
    
    # Remove cols with >50% missing
    pca_data_clean <- pca_data %>%
      select(where(~mean(is.na(.)) <= 0.5))
    
    # Impute remaining NAs with mean
    pca_data_clean <- pca_data_clean %>%
      mutate(across(everything(), ~ifelse(is.na(.), mean(., na.rm = TRUE), .)))
    
    # Remove columns with zero variance (constant values)
    pca_data_clean <- pca_data_clean %>%
      select(where(~{v <- var(., na.rm = TRUE); if(is.na(v)) FALSE else v > 1e-10}))
    
    n_indicators <- ncol(pca_data_clean)
    
    if (n_indicators < 2) {
      cat("     ⚠️  Menos de 2 indicadores con varianza, saltando...\n\n")
      next
    }
    
    cat("     Indicadores con varianza:", n_indicators, "\n")
    
    # Ensure all values are numeric and valid
    pca_data_clean <- pca_data_clean %>%
      mutate(across(everything(), ~as.numeric(.)))
    
    # Final check: remove any row with all NAs
    pca_data_clean <- pca_data_clean[rowSums(is.na(pca_data_clean)) < ncol(pca_data_clean), ]
    
    if (nrow(pca_data_clean) < 2) {
      cat("     ⚠️  Insuficientes observaciones válidas, saltando...\n\n")
      next
    }
    
    # Perform PCA
    n_comps <- min(2, n_indicators - 1)
    tryCatch({
      pca_dim <- PCA(pca_data_clean, 
                     scale.unit = TRUE, 
                     ncp = n_comps, 
                     graph = FALSE)
    }, error = function(e) {
      cat("     ⚠️  Error en PCA:", conditionMessage(e), "\n\n")
      return(NULL)
    })
    
    if (is.null(pca_dim)) next
    
    # ========================================================================
    # Extract loadings (contributions) of PC1 as weights
    # ========================================================================
    
    loadings <- data.frame(
      indicator_id = rownames(pca_dim$var$contrib),
      weight = pca_dim$var$contrib[, 1],  # PC1 loadings
      contrib_pct = pca_dim$var$contrib[, 1]
    ) %>%
      arrange(desc(weight))
    
    # Normalize weights to sum to 1 (optional, but makes interpretation easier)
    loadings$weight_normalized <- loadings$weight / sum(loadings$weight)
    
    # Add dimension and year info
    loadings$dimension_id <- dim
    loadings$year <- year
    
    dimension_loadings[[dim]] <- loadings
    
    cat("     Varianza PC1:", round(pca_dim$eig[1, 2], 2), "%\n")
    cat("     Top 3 indicadores:\n")
    print(loadings[1:min(3, nrow(loadings)), c("indicator_id", "weight")])
    cat("\n")
    
    # ========================================================================
    # Calculate dimension score using weights
    # ========================================================================
    
    # Use normalized weights to calculate weighted score
    weighted_score <- 0
    for (ind in loadings$indicator_id) {
      ind_value <- df_dim %>%
        filter(indicator_id == ind) %>%
        pull(value) %>%
        mean(na.rm = TRUE)
      
      weight <- loadings %>%
        filter(indicator_id == ind) %>%
        pull(weight_normalized)
      
      if (length(ind_value) > 0 && !is.na(ind_value)) {
        weighted_score <- weighted_score + ind_value * weight
      }
    }
    
    # Standardize to 0-100
    dimension_scores[[dim]] <- weighted_score
    
  }
  
  # ========================================================================
  # 2b. PCA FINAL: Agregar dimensiones
  # ========================================================================
  
  cat("\n  📊 Agregación Final (todas las dimensiones)\n")
  
  # Create matrix with dimension scores
  dim_names <- names(dimension_scores)[-c(1, 2)]  # Exclude year and region
  
  if (length(dim_names) >= 2) {
    
    # Reshape dimension_scores as matrix
    final_pca_data <- data.frame(
      t(unlist(dimension_scores[dim_names]))
    )
    
    # Perform final PCA
    pca_final <- PCA(final_pca_data,
                     scale.unit = TRUE,
                     ncp = min(2, length(dim_names) - 1),
                     graph = FALSE)
    
    # Extract weights for dimensions (from PC1 loadings)
    final_loadings <- data.frame(
      dimension_id = colnames(final_pca_data),
      weight = pca_final$var$contrib[, 1]
    ) %>%
      arrange(desc(weight))
    
    final_loadings$weight_normalized <- final_loadings$weight / sum(final_loadings$weight)
    final_loadings$year <- year
    
    cat("     Varianza PC1:", round(pca_final$eig[1, 2], 2), "%\n")
    cat("     Pesos de dimensiones:\n")
    print(final_loadings[, c("dimension_id", "weight")])
    cat("\n")
    
    # ======================================================================
    # Calculate composite index
    # ======================================================================
    
    composite_score <- sum(
      unlist(dimension_scores[dim_names]) * 
        final_loadings$weight_normalized
    )
    
    # Standardize to 0-100
    composite_score_scaled <- scale_0_100(c(composite_score))[1]
    
  } else {
    
    cat("     ⚠️  Menos de 2 dimensiones, usando promedio simple\n")
    composite_score_scaled <- mean(unlist(dimension_scores[dim_names]), na.rm = TRUE)
    final_loadings <- NULL
    
  }
  
  # ========================================================================
  # 2c. Guardar resultados del año
  # ========================================================================
  
  # Combine all loadings for this year
  all_loadings_year <- bind_rows(dimension_loadings)
  
  # Save loadings
  for (dim in unique(all_loadings_year$dimension_id)) {
    loadings_dim <- all_loadings_year %>%
      filter(dimension_id == dim) %>%
      select(indicator_id, weight, weight_normalized, contrib_pct)
    
    write.csv(
      loadings_dim,
      file = paste0(results_path, "loadings_", dim, "_", year, ".csv"),
      row.names = FALSE,
      fileEncoding = "UTF-8"
    )
  }
  
  # Save dimension scores
  dim_scores_df <- data.frame(
    year = year,
    region = "ESP",
    t(dimension_scores[!names(dimension_scores) %in% c("year", "region")])
  )
  
  write.csv(
    dim_scores_df,
    file = paste0(results_path, "dimension_scores_", year, ".csv"),
    row.names = FALSE,
    fileEncoding = "UTF-8"
  )
  
  # Store for final aggregation
  all_final_scores[[as.character(year)]] <- data.frame(
    year = year,
    region = "ESP",
    t(dimension_scores[!names(dimension_scores) %in% c("year", "region")]),
    composite_index = composite_score_scaled
  )
  
}

################################################################################
# 3. COMBINE AND EXPORT ALL RESULTS
################################################################################

cat("\n", rep("=", 80), "\n")
cat("COMBINANDO RESULTADOS FINALES\n")
cat(rep("=", 80), "\n\n")

# Combine all final scores
final_results <- bind_rows(all_final_scores)

# Export main results
write.csv(
  final_results,
  file = paste0(results_path, "composite_indicator_all_years.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

cat("✅ Archivo principal guardado: ", 
    paste0(results_path, "composite_indicator_all_years.csv"), "\n\n")

# Print summary
cat("RESUMEN DE RESULTADOS:\n")
cat(rep("-", 80), "\n")
print(final_results)
cat("\n")

################################################################################
# 4. VISUALIZACIÓN (OPCIONAL)
################################################################################

cat("\n", rep("=", 80), "\n")
cat("GENERANDO VISUALIZACIONES\n")
cat(rep("=", 80), "\n\n")

# Plot: Evolution of composite index over time
p1 <- final_results %>%
  ggplot(aes(x = year, y = composite_index, color = region, group = region)) +
  geom_line(size = 1) +
  geom_point(size = 3) +
  theme_minimal() +
  labs(
    title = "Evolución del Índice Sintético (2016-2024)",
    x = "Año",
    y = "Índice Sintético (0-100)",
    color = "Región"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    legend.position = "bottom"
  )

ggsave(
  paste0(results_path, "01_evolution_composite_index.png"),
  p1,
  width = 10,
  height = 6,
  dpi = 300
)

# Plot: Contribution of dimensions over time
dimension_cols <- colnames(final_results)[grepl("_score$|_index", colnames(final_results)) & 
                                           !grepl("composite", colnames(final_results))]

if (length(dimension_cols) > 0) {
  final_results_long <- final_results %>%
    pivot_longer(
      cols = all_of(dimension_cols),
      names_to = "dimension",
      values_to = "score"
    )
  
  p2 <- final_results_long %>%
    ggplot(aes(x = year, y = score, fill = dimension)) +
    geom_bar(stat = "identity", position = "stack") +
    theme_minimal() +
    labs(
      title = "Contribución de Dimensiones al Índice Sintético",
      x = "Año",
      y = "Score",
      fill = "Dimensión"
    ) +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      legend.position = "bottom"
    )
  
  ggsave(
    paste0(results_path, "02_dimensions_contribution.png"),
    p2,
    width = 10,
    height = 6,
    dpi = 300
  )
}

cat("✅ Visualizaciones guardadas en:", results_path, "\n\n")

################################################################################
# 5. RESUMEN FINAL
################################################################################

cat("\n", rep("=", 80), "\n")
cat("✅ ANÁLISIS COMPLETADO\n")
cat(rep("=", 80), "\n\n")

cat("ARCHIVOS GENERADOS:\n")
cat("  1. Main output: composite_indicator_all_years.csv\n")
cat("  2. Loadings: loadings_[DIM]_[YEAR].csv (pesos de indicadores)\n")
cat("  3. Dimension scores: dimension_scores_[YEAR].csv\n")
cat("  4. Visualizations: 01_evolution_*.png, 02_dimensions_*.png\n\n")

cat("PRÓXIMOS PASOS:\n")
cat("  - Revisar los pesos en loadings_*.csv\n")
cat("  - Verificar si los pesos son consistentes entre años\n")
cat("  - Si quieres pesos globales, promediar los PCA de todos los años\n")
cat("  - Ajustar el código si quieres analizar múltiples regiones\n\n")

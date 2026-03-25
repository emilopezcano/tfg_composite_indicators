################################################################################
# PCA ANALYSIS: PESOS GLOBALES FIJOS (ENFOQUE 2)
#
# Workflow:
# 1. UNA SOLA VEZ: Calcular PCA con TODOS los datos (todos los años)
#    → Extract loadings PC1 como pesos GLOBALES (iguales para todos los años)
# 2. Para CADA AÑO:
#    → Aplicar pesos globales fijos
#    → Calcular scores por dimensión
#    → Calcular índice final
#
# Ventaja: Pesos consistentes entre años → comparación temporal válida
# Desventaja: Puede no capturar cambios estructurales entre años
#
# Output: 
#   - composite_indicator_global_weights.csv
#   - global_loadings_[DIM].csv (pesos fijos para toda la serie)
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
# FUNCIONES AUXILIARES
################################################################################

scale_0_100 <- function(x) {
  x_min <- min(x, na.rm = TRUE)
  x_max <- max(x, na.rm = TRUE)
  if (x_max == x_min) return(rep(50, length(x)))
  ((x - x_min) / (x_max - x_min)) * 100
}

################################################################################
# 1. LOAD AND PREPARE DATA
################################################################################

cat("\n", rep("=", 80), "\n")
cat("CARGANDO DATOS - ENFOQUE: PESOS GLOBALES FIJOS\n")
cat(rep("=", 80), "\n\n")

df <- readRDS(data_path)

df_analysis <- df %>%
  select(indicator_id, date, period_id, geo_id, indicator_value, dimension_id) %>%
  rename(value = indicator_value) %>%
  mutate(
    date = as.Date(date),
    year = as.numeric(format(date, "%Y"))
  ) %>%
  distinct() %>%
  filter(!is.na(value),
         geo_id == "ESP")  # Solo ESP

years_to_analyze <- sort(unique(df_analysis$year))
dimensions <- sort(unique(df_analysis$dimension_id))

cat("Años disponibles:", paste(years_to_analyze, collapse = ", "), "\n")
cat("Dimensiones:", paste(dimensions, collapse = ", "), "\n\n")

################################################################################
# 2. PHASE 1: CALCULATE GLOBAL WEIGHTS (from ALL data)
################################################################################

cat("FASE 1: Calculando pesos globales con TODOS los datos\n")
cat(rep("=", 80), "\n\n")

global_loadings <- list()
global_final_loadings <- list()

# Step 1: PCA per dimension using ALL years
for (dim in dimensions) {
  
  cat("  📊 Dimensión:", dim, "\n")
  
  df_dim_all <- df_analysis %>%
    filter(dimension_id == dim)
  
  # Create matrix: rows = years, cols = indicators
  # If multiple values per year-indicator, take mean
  pca_data <- df_dim_all %>%
    select(year, indicator_id, value) %>%
    group_by(year, indicator_id) %>%
    summarise(value = mean(value, na.rm = TRUE), .groups = 'drop') %>%
    pivot_wider(
      names_from = indicator_id,
      values_from = value,
      values_fill = NA
    ) %>%
    column_to_rownames(var = "year")
  
  # Convert all to numeric
  pca_data <- pca_data %>%
    mutate(across(everything(), as.numeric))
  
  if (ncol(pca_data) < 2) {
    cat("     ⚠️  Menos de 2 indicadores\n\n")
    next
  }
  
  # Clean data
  pca_data_clean <- pca_data %>%
    select(where(~mean(is.na(.)) <= 0.5))
  
  pca_data_clean <- pca_data_clean %>%
    mutate(across(everything(), ~ifelse(is.na(.), mean(., na.rm = TRUE), .)))
  
  # Remove columns with zero variance
  pca_data_clean <- pca_data_clean %>%
    select(where(~{v <- var(., na.rm = TRUE); if(is.na(v)) FALSE else v > 1e-10}))
  
  n_indicators <- ncol(pca_data_clean)
  
  if (n_indicators < 2) {
    cat("     ⚠️  Menos de 2 indicadores con varianza\n\n")
    next
  }
  
  cat("     Indicadores:", n_indicators, "\n")
  
  # PCA
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
  
  # Extract global loadings
  loadings <- data.frame(
    indicator_id = rownames(pca_dim$var$contrib),
    weight = pca_dim$var$contrib[, 1]
  ) %>%
    arrange(desc(weight))
  
  loadings$weight_normalized <- loadings$weight / sum(loadings$weight)
  loadings$dimension_id <- dim
  
  global_loadings[[dim]] <- loadings
  
  cat("     Varianza PC1:", round(pca_dim$eig[1, 2], 2), "%\n")
  cat("     Top 3 indicadores:\n")
  print(loadings[1:min(3, nrow(loadings)), c("indicator_id", "weight")])
  
  # Save global loadings
  write.csv(
    loadings %>% select(indicator_id, weight, weight_normalized),
    file = paste0(results_path, "global_loadings_", dim, ".csv"),
    row.names = FALSE,
    fileEncoding = "UTF-8"
  )
  
  cat("\n")
  
}

# Step 2: Final PCA for dimension aggregation using ALL years
cat("\n  📊 PCA Final para agregación de dimensiones\n")

# Create matrix: rows = years, cols = dimension scores
# Using global weights to calculate dimension scores for each year

dimension_scores_matrix <- data.frame(year = years_to_analyze)

for (dim in dimensions) {
  
  if (!dim %in% names(global_loadings)) next
  
  loadings_dim <- global_loadings[[dim]]
  
  # Calculate weighted dimension score for EACH year
  dim_scores <- c()
  
  for (yr in years_to_analyze) {
    df_dim_year <- df_analysis %>% 
      filter(dimension_id == dim, year == yr)
    
    if (nrow(df_dim_year) == 0) {
      dim_scores <- c(dim_scores, NA)
      next
    }
    
    weighted_score <- 0
    weights_sum <- 0
    
    for (ind in loadings_dim$indicator_id) {
      ind_value <- df_dim_year %>%
        filter(indicator_id == ind) %>%
        pull(value) %>%
        mean(na.rm = TRUE)
      
      weight <- loadings_dim %>%
        filter(indicator_id == ind) %>%
        pull(weight_normalized)
      
      if (!is.na(ind_value) && length(weight) > 0) {
        weighted_score <- weighted_score + ind_value * weight
        weights_sum <- weights_sum + weight
      }
    }
    
    if (weights_sum > 0) {
      dim_scores <- c(dim_scores, weighted_score / weights_sum)
    } else {
      dim_scores <- c(dim_scores, NA)
    }
  }
  
  dimension_scores_matrix[[dim]] <- dim_scores
}

# Remove year column for PCA (use as row names instead)
final_pca_data <- dimension_scores_matrix %>%
  column_to_rownames(var = "year") %>%
  mutate(across(everything(), as.numeric))

# Remove columns with all NAs
final_pca_data <- final_pca_data %>%
  select(where(~!all(is.na(.))))

# Impute NAs with column mean
final_pca_data <- final_pca_data %>%
  mutate(across(everything(), ~ifelse(is.na(.), mean(., na.rm = TRUE), .)))

if (ncol(final_pca_data) >= 2 && nrow(final_pca_data) >= 2) {
  pca_final <- PCA(final_pca_data,
                   scale.unit = TRUE,
                   ncp = min(2, ncol(final_pca_data) - 1),
                   graph = FALSE)
  
  final_loadings <- data.frame(
    dimension_id = colnames(final_pca_data),
    weight = pca_final$var$contrib[, 1]
  ) %>%
  arrange(desc(weight))

  final_loadings$weight_normalized <- final_loadings$weight / sum(final_loadings$weight)

  cat("     Varianza PC1:", round(pca_final$eig[1, 2], 2), "%\n")
  cat("     Pesos de dimensiones:\n")
  print(final_loadings[, c("dimension_id", "weight")])

  # Save final loadings
  write.csv(
    final_loadings %>% select(dimension_id, weight, weight_normalized),
    file = paste0(results_path, "global_loadings_final_dimensions.csv"),
    row.names = FALSE,
    fileEncoding = "UTF-8")
  
  cat("\n")
} else {
  cat("     ⚠️  Insuficientes dimensiones para PCA final\n")
  final_loadings <- NULL
}

################################################################################
# 3. PHASE 2: APPLY GLOBAL WEIGHTS TO EACH YEAR
################################################################################

cat("\n", rep("=", 80), "\n")
cat("FASE 2: Aplicando pesos globales a cada año\n")
cat(rep("=", 80), "\n\n")

all_results <- list()

for (year in years_to_analyze) {
  
  cat("Año:", year, "\n")
  
  df_year <- df_analysis %>% filter(year == year)
  
  if (nrow(df_year) == 0) {
    cat("  ⚠️  Sin datos\n\n")
    next
  }
  
  dimension_scores <- list(year = year, region = "ESP")
  
  # Apply global weights per dimension
  for (dim in dimensions) {
    
    if (!dim %in% names(global_loadings)) next
    
    loadings_dim <- global_loadings[[dim]]
    df_dim_year <- df_year %>% filter(dimension_id == dim)
    
    if (nrow(df_dim_year) == 0) {
      dimension_scores[[dim]] <- NA
      next
    }
    
    weighted_score <- 0
    weights_count <- 0
    
    for (ind in loadings_dim$indicator_id) {
      ind_value <- df_dim_year %>%
        filter(indicator_id == ind) %>%
        pull(value) %>%
        mean(na.rm = TRUE)
      
      weight <- loadings_dim %>%
        filter(indicator_id == ind) %>%
        pull(weight_normalized)
      
      if (!is.na(ind_value) && length(weight) > 0) {
        weighted_score <- weighted_score + ind_value * weight
        weights_count <- weights_count + weight
      }
    }
    
    if (weights_count > 0) {
      dimension_scores[[dim]] <- weighted_score / weights_count
    } else {
      dimension_scores[[dim]] <- NA
    }
  }
  
  # Apply global dimension weights
  dim_cols <- setdiff(names(dimension_scores), c("year", "region"))
  
  # Only calculate composite if final_loadings was calculated
  if (is.null(final_loadings)) {
    composite_score <- NA
  } else {
    dims_present <- dim_cols[dim_cols %in% final_loadings$dimension_id]
    
    if (length(dims_present) > 0) {
      composite_score <- sum(
        sapply(dims_present, function(d) {
          val <- dimension_scores[[d]]
          weight <- final_loadings %>%
            filter(dimension_id == d) %>%
            pull(weight_normalized)
          
          if (is.na(val) || length(weight) == 0) return(0)
          return(val * weight)
        }), na.rm = TRUE
      )
    } else {
      composite_score <- NA
    }
  }
  
  composite_score_scaled <- scale_0_100(c(composite_score))[1]
  
  result_year <- data.frame(
    year = year,
    region = "ESP"
  )
  
  for (dim in dim_cols) {
    result_year[[dim]] <- dimension_scores[[dim]]
  }
  
  result_year$composite_index <- composite_score_scaled
  
  all_results[[as.character(year)]] <- result_year
  
  cat("  ", dim_cols, ":", round(unlist(dimension_scores[dim_cols]), 2), "\n")
  cat("  Índice final:", round(composite_score_scaled, 2), "\n\n")
  
}

################################################################################
# 4. EXPORT RESULTS
################################################################################

cat(rep("=", 80), "\n")
cat("EXPORTANDO RESULTADOS\n")
cat(rep("=", 80), "\n\n")

final_results <- bind_rows(all_results)

write.csv(
  final_results,
  file = paste0(results_path, "composite_indicator_global_weights.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

cat("✅ Archivo principal guardado: composite_indicator_global_weights.csv\n\n")

cat("RESULTADOS:\n")
print(final_results)

################################################################################
# 5. VISUALIZACIÓN
################################################################################

cat("\n", rep("=", 80), "\n")
cat("GENERANDO VISUALIZACIONES\n")
cat(rep("=", 80), "\n\n")

# Plot evolution
p1 <- final_results %>%
  ggplot(aes(x = year, y = composite_index)) +
  geom_line(size = 1, color = "steelblue") +
  geom_point(size = 3, color = "steelblue") +
  theme_minimal() +
  labs(
    title = "Evolución del Índice Sintético (Pesos Globales)",
    x = "Año",
    y = "Índice Sintético (0-100)"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold")
  )

ggsave(
  paste0(results_path, "03_evolution_global_weights.png"),
  p1,
  width = 10,
  height = 6,
  dpi = 300
)

cat("✅ Visualizaciones guardadas\n\n")

cat("\n", rep("=", 80), "\n")
cat("✅ ANÁLISIS COMPLETADO (ENFOQUE: PESOS GLOBALES)\n")
cat(rep("=", 80), "\n\n")

cat("ARCHIVOS GENERADOS:\n")
cat("  - composite_indicator_global_weights.csv (resultado principal)\n")
cat("  - global_loadings_[DIM].csv (pesos de indicadores - FIJOS para todos los años)\n")
cat("  - global_loadings_final_dimensions.csv (pesos de dimensiones)\n")
cat("  - 03_evolution_global_weights.png\n\n")

cat("VENTAJAS DE ESTE ENFOQUE:\n")
cat("  ✓ Pesos consistentes entre años\n")
cat("  ✓ Comparación temporal válida\n")
cat("  ✓ Más simple de interpretar\n")
cat("  ✗ Puede no capturar cambios estructurales\n\n")

################################################################################
# PCA ANALYSIS 2022 - CÁLCULO DE INDICADOR COMPUESTO E IMPACTOS
################################################################################

library(tidyverse)
library(FactoMineR)
library(factoextra)
library(scales)

# Configuración inicial
ANALYSIS_YEAR <- 2022
data_path <- "data/indConComponentes.csv"
results_path <- paste0("results_", ANALYSIS_YEAR, "/")

if (!dir.exists(results_path)) { dir.create(results_path) }

# 1. CARGA Y FILTRADO
df <- read.csv(data_path, encoding = "UTF-8")

df_analysis <- df %>%
  select(indicator_id, date, geo_id, value, dimension_id) %>%
  mutate(date = as.Date(date),
         year = as.numeric(format(date, "%Y"))) %>%
  distinct() %>%
  filter(!is.na(value), year == ANALYSIS_YEAR)

################################################################################
# 2. PCA POR DIMENSIÓN (Cálculo de Impactos Individuales)
################################################################################

pca_results <- list()
dimension_pcs <- list()

for (dim in sort(unique(df_analysis$dimension_id))) {
  
  cat("\nProcesando Dimensión:", dim, "\n")
  
  # Preparar datos en formato ancho (Wide)
  pca_data <- df_analysis %>%
    filter(dimension_id == dim) %>%
    select(geo_id, indicator_id, value) %>%
    pivot_wider(names_from = indicator_id, values_from = value) %>%
    column_to_rownames(var = "geo_id")
  
  # Limpieza: quitar indicadores con >50% NAs e imputar media
  pca_data_clean <- pca_data %>% 
    select(where(~mean(is.na(.)) <= 0.5)) %>%
    mutate(across(everything(), ~ifelse(is.na(.), mean(., na.rm = TRUE), .)))
  
  if (ncol(pca_data_clean) >= 2) {
    
    # EJECUTAR PCA (Forzamos 1 sola componente)
    pca <- PCA(pca_data_clean, scale.unit = TRUE, ncp = 1, graph = FALSE)
    pca_results[[dim]] <- pca
    
    # Guardar Score (PC1) de la dimensión
    pc_scores <- as.data.frame(pca$ind$coord)
    pc_scores$region <- rownames(pc_scores)
    col_pc_name <- paste0(dim, "_PC1")
    colnames(pc_scores)[1] <- col_pc_name
    
    dimension_pcs[[dim]] <- pc_scores %>% select(region, all_of(col_pc_name))
    
    # --- CÁLCULO DE MATRIZ DE IMPACTO ---
    # 1. Escalar datos (Z-scores internos del PCA)
    pca_data_scaled <- as.data.frame(scale(pca_data_clean))
    
    # 2. Cargas (Loadings/Coordenadas de las variables)
    loadings_pc1 <- pca$var$coord[, 1]
    
    # 3. IMPACTO = Valor estandarizado * Carga
    impact_matrix <- as.data.frame(t(t(pca_data_scaled) * loadings_pc1))
    impact_matrix$region <- rownames(impact_matrix)
    impact_matrix$SCORE_DIMENSION <- pc_scores[[col_pc_name]]
    
    # Organizar y guardar impacto por dimensión
    impact_matrix <- impact_matrix %>% select(region, SCORE_DIMENSION, everything())
    write.csv(impact_matrix, 
              file.path(results_path, paste0("impacto_indicadores_", dim, "_", ANALYSIS_YEAR, ".csv")), 
              row.names = FALSE)
    
    # Guardar pesos generales de los indicadores
    loadings_df <- data.frame(indicator = rownames(pca$var$contrib), 
                              Contribucion_Pct = pca$var$contrib[, 1])
    write.csv(loadings_df, 
              file.path(results_path, paste0("pesos_indicadores_", dim, "_", ANALYSIS_YEAR, ".csv")), 
              row.names = FALSE)
    
    cat("✓ Archivos de impacto y pesos generados para", dim, "\n")
  }
}

################################################################################
# 3. PCA FINAL (AGREGACIÓN DE DIMENSIONES)
################################################################################

# Unir los scores de las 3 dimensiones
final_pca_data <- Reduce(function(x, y) full_join(x, y, by = "region"), dimension_pcs) %>%
  column_to_rownames(var = "region") %>%
  drop_na()

# PCA Final sobre las dimensiones
final_pca <- PCA(final_pca_data, scale.unit = TRUE, ncp = 1, graph = FALSE)

# Crear el Indicador Compuesto Final
composite_indicator <- as.data.frame(final_pca$ind$coord[, 1, drop = FALSE]) %>%
  rename(score_puro = Dim.1) %>%
  mutate(region = rownames(.),
         year = ANALYSIS_YEAR,
         indice_0_100 = rescale(score_puro, to = c(0, 100))) %>%
  select(region, year, score_puro, indice_0_100) %>%
  arrange(desc(indice_0_100))

# GUARDAR RESULTADOS FINALES
write.csv(composite_indicator, 
          file.path(results_path, paste0("INDICADOR_FINAL_", ANALYSIS_YEAR, ".csv")), 
          row.names = FALSE)

# Guardar ranking de dimensiones (Scores intermedios)
ranking_dimensiones <- final_pca_data %>% rownames_to_column(var = "region")
write.csv(ranking_dimensiones, 
          file.path(results_path, paste0("ranking_dimensiones_", ANALYSIS_YEAR, ".csv")), 
          row.names = FALSE)

cat("\n======================================================\n")
cat("ANÁLISIS COMPLETADO CON ÉXITO\n")
cat("Archivos generados en:", results_path, "\n")
cat("======================================================\n")

# Mostrar Top 5
print(head(composite_indicator))

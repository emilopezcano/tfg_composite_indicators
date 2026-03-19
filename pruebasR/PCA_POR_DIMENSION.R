# ==============================================================================
# SOLUCIÓN: EXTRAER PCA POR DIMENSIÓN/SUBDIMENSION
# ==============================================================================

library(COINr)
library(dplyr)

# ==============================================================================
# OPCIÓN A: PCA PARA CADA DIMENSIÓN (Lo que probablemente querías)
# ==============================================================================

cat("📊 OPCIÓN A: PCA por Dimensión\n")
cat("================================\n\n")

# 1. Identificar dimensiones únicas
dimensiones <- my_coin$Meta$Ind %>%
  filter(Level == 1) %>%
  pull(Parent) %>%
  unique()

cat("Dimensiones encontradas:", paste(dimensiones, collapse = ", "), "\n\n")

# 2. Para CADA dimensión, hacer PCA separado
pca_por_dimension <- list()

for (dim in dimensiones) {
  cat("Procesando dimensión:", dim, "\n")
  
  # Obtener indicadores de esta dimensión
  indicadores_dim <- my_coin$Meta$Ind %>%
    filter(Level == 1, Parent == dim) %>%
    pull(iCode)
  
  # Extraer datos normalizados de estos indicadores
  datos_dim <- my_coin$Data$Normalised %>%
    select(all_of(indicadores_dim)) %>%
    na.omit()
  
  # Hacer PCA
  pca_res <- prcomp(datos_dim, scale = FALSE)
  
  # Calcular varianza explicada
  var_explained <- (pca_res$sdev^2) / sum(pca_res$sdev^2)
  var_acumulada <- cumsum(var_explained)
  
  # Guardar resultados
  pca_por_dimension[[dim]] <- list(
    pca_object = pca_res,
    var_exp = var_explained,
    var_acum = var_acumulada,
    n_indicadores = length(indicadores_dim),
    indicadores = indicadores_dim
  )
  
  # Mostrar resultados
  cat(sprintf("  ✅ %d indicadores | PC1 explica: %.2f%%\n", 
              length(indicadores_dim), var_explained[1] * 100))
}

# ==============================================================================
# TABLA RESUMEN: VARIANZA POR DIMENSIÓN
# ==============================================================================

cat("\n\n📋 TABLA RESUMEN:\n")
cat("=================\n\n")

pca_summary <- data.frame(
  Dimension = names(pca_por_dimension),
  N_Indicadores = sapply(pca_por_dimension, function(x) x$n_indicadores),
  PC1_VAR = sapply(pca_por_dimension, function(x) x$var_exp[1] * 100),
  PC2_VAR = sapply(pca_por_dimension, function(x) ifelse(length(x$var_exp) >= 2, x$var_exp[2] * 100, NA)),
  PC1_ACUMULADA = sapply(pca_por_dimension, function(x) x$var_acum[1] * 100)
) %>%
  mutate(
    PC1_VAR = round(PC1_VAR, 2),
    PC2_VAR = round(PC2_VAR, 2),
    PC1_ACUMULADA = round(PC1_ACUMULADA, 2)
  )

print(pca_summary)

# ==============================================================================
# DETALLE: LOADINGS POR DIMENSIÓN
# ==============================================================================

cat("\n\n📌 LOADINGS DE PC1 POR DIMENSIÓN:\n")
cat("===================================\n\n")

for (dim in names(pca_por_dimension)) {
  cat("Dimensión:", dim, "\n")
  cat("-----------\n")
  
  loadings <- pca_por_dimension[[dim]]$pca_object$rotation[, 1]
  
  loadings_df <- data.frame(
    Indicador = names(loadings),
    Loading_PC1 = as.numeric(loadings)
  ) %>%
    arrange(desc(abs(Loading_PC1)))
  
  print(loadings_df)
  cat("\n")
}

# ==============================================================================
# VISUALIZACIÓN: VARIANZA POR DIMENSIÓN
# ==============================================================================

cat("\n\n📈 Generando gráficos...\n")

library(ggplot2)

# Gráfico 1: PC1 por dimensión
p1 <- ggplot(pca_summary, aes(x = reorder(Dimension, -PC1_VAR), y = PC1_VAR, fill = Dimension)) +
  geom_bar(stat = "identity", alpha = 0.8) +
  geom_text(aes(label = paste0(round(PC1_VAR, 1), "%")), vjust = -0.5, size = 4) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Varianza Explicada por PC1 en Cada Dimensión",
    x = "Dimensión",
    y = "Varianza Explicada (%)",
    subtitle = "Cuánta heterogeneidad captura la primera componente principal"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 13),
    plot.subtitle = element_text(hjust = 0.5, size = 11),
    legend.position = "none"
  ) +
  ylim(0, max(pca_summary$PC1_VAR) * 1.15)

print(p1)

# Gráfico 2: Comparación completa
pca_long <- pca_summary %>%
  select(Dimension, PC1_VAR, PC2_VAR) %>%
  pivot_longer(cols = c(PC1_VAR, PC2_VAR), names_to = "Componente", values_to = "Varianza") %>%
  filter(!is.na(Varianza))

p2 <- ggplot(pca_long, aes(x = Dimension, y = Varianza, fill = Componente)) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.8) +
  geom_text(aes(label = paste0(round(Varianza, 1), "%")), 
            position = position_dodge(width = 0.9), vjust = -0.4, size = 3.5) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Varianza Explicada por PC1 y PC2 (por Dimensión)",
    x = "Dimensión",
    y = "Varianza (%)",
    fill = "Componente"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 13),
    legend.position = "bottom"
  )

print(p2)

# ==============================================================================
# GUARDAR RESULTADOS
# ==============================================================================

cat("\n\n💾 Guardando resultados...\n")

# Guardar tabla resumen
write.csv(pca_summary, "results_2022/pca_varianza_por_dimension.csv", row.names = FALSE)
cat("✅ Guardado: results_2022/pca_varianza_por_dimension.csv\n")

# Guardar detalle de loadings
loadings_completo <- lapply(names(pca_por_dimension), function(dim) {
  loadings <- pca_por_dimension[[dim]]$pca_object$rotation[, 1]
  data.frame(
    Dimension = dim,
    Indicador = names(loadings),
    Loading_PC1 = as.numeric(loadings),
    Abs_Loading = abs(as.numeric(loadings)),
    stringsAsFactors = FALSE
  )
}) %>% bind_rows() %>%
  arrange(Dimension, desc(Abs_Loading))

write.csv(loadings_completo, "results_2022/pca_loadings_por_dimension.csv", row.names = FALSE)
cat("✅ Guardado: results_2022/pca_loadings_por_dimension.csv\n")

cat("\n✅ ANÁLISIS COMPLETADO\n")

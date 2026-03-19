# ==============================================================================
# VER LA VARIANZA EXPLICADA POR EL PCA
# ==============================================================================

# La información del PCA está en my_coin$Analysis

# ==============================================================================
# 1. VARIANZA EXPLICADA POR COMPONENTE
# ==============================================================================

cat("\n📊 VARIANZA EXPLICADA POR PCA (Nivel 1 - Indicadores):\n")
cat("======================================================\n\n")

# Acceder a los resultados del PCA
pca_results <- my_coin$Analysis$PCA

# Ver la varianza acumulada
print("Varianza acumulada por componente:")
print(pca_results$var_exp_cumsum)

cat("\n")

# Ver la varianza de cada componente
print("Varianza explicada por cada componente:")
print(pca_results$var_exp)

# ==============================================================================
# 2. ENFOQUE EN PC1
# ==============================================================================

cat("\n\n🎯 ENFOQUE EN LA PRIMERA COMPONENTE PRINCIPAL (PC1):\n")
cat("====================================================\n\n")

# Varianza explicada por PC1
var_pc1 <- pca_results$var_exp[1]
var_pc1_pct <- pca_results$var_exp_cumsum[1]

cat(sprintf("PC1 explica: %.2f%% de la varianza total\n", var_pc1_pct * 100))

# ==============================================================================
# 3. LOADINGS (CONTRIBUCIÓN DE CADA INDICADOR EN PC1)
# ==============================================================================

cat("\n\n📋 LOADINGS DE PC1 (Peso de cada indicador):\n")
cat("=============================================\n\n")

# Los loadings están en:
loadings_pc1 <- pca_results$loadings[, 1]  # Primera columna = PC1

print(loadings_pc1)

# Tabla más legible
loadings_df <- data.frame(
  Indicador = names(loadings_pc1),
  Loading_PC1 = as.numeric(loadings_pc1),
  Abs_Loading = abs(as.numeric(loadings_pc1))
) %>%
  arrange(desc(Abs_Loading))

print("\nOrdenado por importancia:")
print(loadings_df)

# ==============================================================================
# 4. VISUALIZACIÓN - GRÁFICO DE VARIANZA
# ==============================================================================

cat("\n\n📈 Creando gráficos de varianza...\n")

library(ggplot2)

# Datos para gráfico
var_data <- data.frame(
  PC = paste0("PC", 1:length(pca_results$var_exp)),
  Varianza = pca_results$var_exp * 100,
  Acumulada = pca_results$var_exp_cumsum * 100
)

# Gráfico 1: Varianza individual de cada PC
p1 <- ggplot(var_data, aes(x = PC, y = Varianza)) +
  geom_bar(stat = "identity", fill = "#377EB8", alpha = 0.7) +
  geom_text(aes(label = paste0(round(Varianza, 1), "%")), 
            vjust = -0.5, size = 4) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Varianza Explicada por Componente Principal",
    x = "Componente",
    y = "Varianza Explicada (%)",
    subtitle = "Descomposición de la variabilidad total"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 13),
    plot.subtitle = element_text(hjust = 0.5, size = 11),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

print(p1)

# Gráfico 2: Varianza acumulada
p2 <- ggplot(var_data, aes(x = PC, y = Acumulada, group = 1)) +
  geom_line(color = "#E41A1C", linewidth = 1.2) +
  geom_point(size = 3, color = "#E41A1C") +
  geom_hline(yintercept = 80, linetype = "dashed", color = "grey50", 
             label = "80% de varianza") +
  geom_text(aes(label = paste0(round(Acumulada, 1), "%")), 
            vjust = -0.7, size = 4) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Varianza Acumulada (PCA)",
    x = "Componente",
    y = "Varianza Acumulada (%)",
    subtitle = "Cuánta información retiene cada número de componentes"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 13),
    plot.subtitle = element_text(hjust = 0.5, size = 11),
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  ylim(0, 105)

print(p2)

# ==============================================================================
# 5. GRÁFICO DE LOADINGS
# ==============================================================================

# Preparar datos
loadings_plot <- data.frame(
  Indicador = names(loadings_pc1),
  Loading = as.numeric(loadings_pc1)
) %>%
  arrange(Loading) %>%
  mutate(Color = ifelse(Loading > 0, "Positivo", "Negativo"))

p3 <- ggplot(loadings_plot, aes(x = reorder(Indicador, Loading), 
                                 y = Loading, fill = Color)) +
  geom_bar(stat = "identity", alpha = 0.8) +
  coord_flip() +
  scale_fill_manual(values = c("Positivo" = "#4DAF4A", "Negativo" = "#E41A1C")) +
  theme_minimal(base_size = 11) +
  labs(
    title = "Loadings de PC1: Contribución de Indicadores",
    x = "Indicador",
    y = "Loading (Peso en PC1)",
    subtitle = "Qué variables impulsan la primera componente principal"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 13),
    plot.subtitle = element_text(hjust = 0.5, size = 11),
    legend.position = "bottom"
  ) +
  geom_hline(yintercept = 0, linetype = "solid", color = "grey30", linewidth = 0.3)

print(p3)

# ==============================================================================
# 6. RESUMEN EJECUTIVO
# ==============================================================================

cat("\n\n✅ RESUMEN DEL ANÁLISIS PCA:\n")
cat("=============================\n\n")

cat(sprintf("📌 PC1 explica: %.2f%% de la varianza\n", var_pc1_pct * 100))
cat(sprintf("📌 Para explicar 80%% de varianza: necesitas %d componentes\n", 
            which(pca_results$var_exp_cumsum >= 0.80)[1]))
cat(sprintf("📌 Total de componentes: %d\n", length(pca_results$var_exp)))

cat("\n📊 Top 5 indicadores con mayor carga en PC1:\n")
print(head(loadings_df, 5))

cat("\n")

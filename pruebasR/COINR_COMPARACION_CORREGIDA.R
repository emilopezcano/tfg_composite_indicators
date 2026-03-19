# ==============================================================================
# SCRIPT CORREGIDO: COMPARACIÓN DE 3 MÉTODOS DE PONDERACIÓN EN COINr
# ==============================================================================
# El error original: accesión a my_coin$Weights en lugar de my_coin$Meta$Weights
# y uso de parámetro "weights=" en lugar de "w=" en Aggregate()
# ==============================================================================

library(COINr)
library(dplyr)
library(tidyr)
library(ggplot2)

# ==============================================================================
# PARTE 0: CARGA DE DATOS (asumiendo que ya tienes my_coin configurado)
# ==============================================================================
# Si necesitas recargar:
# indicators <- readRDS("~/MATEMÁTICAS URJC/CUARTO CURSO/TFG/tfg_composite_indicators/data/indicators.rds")
# indicators_data <- readRDS("~/MATEMÁTICAS URJC/CUARTO CURSO/TFG/tfg_composite_indicators/data/indicators_data.rds")
# [código de preparación...]
# my_coin <- new_coin(iData = iData_filtrado, iMeta = iMeta_filtrado)
# my_coin <- Impute(my_coin, dset = "Raw", f_i = "i_median")
# my_coin <- qNormalise(my_coin, dset = "Imputed", f_n = "n_minmax", f_n_para = list(l_u = c(0, 100)))

# ==============================================================================
# PASO 1: AGREGACIÓN INICIAL (TODOS LOS NIVELES) - NECESARIA ANTES DE PCA
# ==============================================================================
print("⏳ Paso 1: Agregación inicial con pesos originales...")
my_coin <- Aggregate(
  my_coin,
  dset = "Normalised",
  w = "Original",                    # ← Acceso CORRECTO a pesos originales
  f_ag = "a_amean",
  out2 = "coin"
)
print("✅ Agregación completada")

# ==============================================================================
# PASO 2: GENERAR PESOS PCA (CORRECCIÓN CLAVE)
# ==============================================================================
print("\n⏳ Paso 2: Generando pesos PCA...")
my_coin <- get_PCA(
  my_coin,
  dset = "Aggregated",              # Debe ser "Aggregated" no "Normalised"
  Level = 1,                        # Calculamos PCA en indicadores base
  weights_to = "PCA_Weights",       # ← Nombre de la nueva tabla de pesos
  out2 = "coin"
)

# VERIFICACIÓN CORRECTA (Meta, no Weights)
print("\n📊 Verificando PCA_Weights en la estructura correcta:")
print(head(my_coin$Meta$Weights$PCA_Weights, 5))  # ← ACCESO CORRECTO

if (is.null(my_coin$Meta$Weights$PCA_Weights)) {
  stop("❌ ERROR: PCA_Weights aún es NULL. Revisa la agregación anterior.")
} else {
  print(paste("✅ PCA_Weights generados correctamente. Filas:", nrow(my_coin$Meta$Weights$PCA_Weights)))
}

# ==============================================================================
# PASO 3: GENERAR PESOS OPTIMIZADOS (CORRECCIÓN CLAVE)
# ==============================================================================
print("\n⏳ Paso 3: Generando pesos optimizados...")
my_coin <- get_opt_weights(
  my_coin,
  dset = "Aggregated",              # Agregación previa OBLIGATORIA
  Level = 1,                        # Optimizar a nivel indicadores
  itarg = "equal",                  # Target: igual importancia
  optype = "balance",               # Tipo de optimización
  weights_to = "Opt_Weights",       # ← Nombre de la nueva tabla de pesos
  out2 = "coin"
)

# VERIFICACIÓN CORRECTA (Meta, no Weights)
print("\n📊 Verificando Opt_Weights en la estructura correcta:")
print(head(my_coin$Meta$Weights$Opt_Weights, 5))  # ← ACCESO CORRECTO

if (is.null(my_coin$Meta$Weights$Opt_Weights)) {
  stop("❌ ERROR: Opt_Weights aún es NULL. Revisa la optimización.")
} else {
  print(paste("✅ Opt_Weights generados correctamente. Filas:", nrow(my_coin$Meta$Weights$Opt_Weights)))
}

# ==============================================================================
# PASO 4: COMPARAR LOS 3 CONJUNTOS DE PESOS
# ==============================================================================
print("\n\n🔍 COMPARACIÓN DE PESOS A NIVEL INDICADORES:")
print("============================================")

# Extraer solo pesos de nivel 1 (indicadores)
pesos_comparacion <- data.frame(
  iCode = my_coin$Meta$Weights$Original$iCode,
  Original = my_coin$Meta$Weights$Original$Weight,
  stringsAsFactors = FALSE
) %>%
  left_join(
    data.frame(
      iCode = my_coin$Meta$Weights$PCA_Weights$iCode,
      PCA = my_coin$Meta$Weights$PCA_Weights$Weight,
      stringsAsFactors = FALSE
    ),
    by = "iCode"
  ) %>%
  left_join(
    data.frame(
      iCode = my_coin$Meta$Weights$Opt_Weights$iCode,
      Opt = my_coin$Meta$Weights$Opt_Weights$Weight,
      stringsAsFactors = FALSE
    ),
    by = "iCode"
  ) %>%
  # Filtrar solo indicadores (Level 1)
  filter(iCode %in% my_coin$Meta$Ind$iCode)

# Mostrar la comparación
print(pesos_comparacion)

# Verificar que realmente son diferentes
cat("\n\n📈 RESUMEN ESTADÍSTICO DE PESOS:\n")
cat("Original - Min:", round(min(pesos_comparacion$Original, na.rm=T), 4), 
    "Max:", round(max(pesos_comparacion$Original, na.rm=T), 4), "\n")
cat("PCA      - Min:", round(min(pesos_comparacion$PCA, na.rm=T), 4), 
    "Max:", round(max(pesos_comparacion$PCA, na.rm=T), 4), "\n")
cat("Optimiz  - Min:", round(min(pesos_comparacion$Opt, na.rm=T), 4), 
    "Max:", round(max(pesos_comparacion$Opt, na.rm=T), 4), "\n")

# Correlación entre pesos
print("\n📊 Correlación Pearson entre conjuntos de pesos:")
print(round(cor(pesos_comparacion[, c("Original", "PCA", "Opt")], use = "complete.obs"), 3))

# ==============================================================================
# PASO 5: GENERAR LAS 3 AGREGACIONES CON DIFERENTES PESOS
# ==============================================================================
print("\n\n⏳ Paso 4: Generando 3 agregaciones con diferentes pesos...")

# A) Pesos IGUALES
print("\n  → Agregación con pesos ORIGINALES (iguales)...")
my_coin <- Aggregate(
  my_coin,
  dset = "Normalised",
  w = "Original",                   # ← Acceso CORRECTO
  f_ag = "a_amean",
  write_to = "Agg_Equal",
  out2 = "coin"
)
print("     ✅ Completada: Agg_Equal")

# B) Pesos PCA
print("\n  → Agregación con pesos PCA...")
my_coin <- Aggregate(
  my_coin,
  dset = "Normalised",
  w = "PCA_Weights",                # ← Acceso CORRECTO
  f_ag = "a_amean",
  write_to = "Agg_PCA",
  out2 = "coin"
)
print("     ✅ Completada: Agg_PCA")

# C) Pesos OPTIMIZADOS
print("\n  → Agregación con pesos OPTIMIZADOS...")
my_coin <- Aggregate(
  my_coin,
  dset = "Normalised",
  w = "Opt_Weights",                # ← Acceso CORRECTO
  f_ag = "a_amean",
  write_to = "Agg_Opt",
  out2 = "coin"
)
print("     ✅ Completada: Agg_Opt")

# ==============================================================================
# PASO 6: FUNCIÓN AUXILIAR PARA EXTRAER RANKINGS
# ==============================================================================
df_rank <- function(coin, dset, ind_col = "TotalIndex") {
  df <- coin$Data[[dset]]
  
  # Verificación explícita de la columna
  if (!ind_col %in% names(df)) {
    stop("Columna '", ind_col, "' no encontrada en ", dset)
  }
  
  data.frame(
    uCode = df$uCode,
    Rank = rank(-df[[ind_col]], ties.method = "min"),
    Index = df[[ind_col]]
  )
}

# ==============================================================================
# PASO 7: TABLA COMPARATIVA DE RANKINGS
# ==============================================================================
print("\n\n📋 TABLA COMPARATIVA DE RANKINGS Y ÍNDICES:")
print("==========================================")

comparativa <- df_rank(my_coin, "Agg_Equal") %>%
  rename(Iguales_Rank = Rank, Iguales_Index = Index) %>%
  left_join(
    df_rank(my_coin, "Agg_PCA") %>% 
      rename(PCA_Rank = Rank, PCA_Index = Index),
    by = "uCode"
  ) %>%
  left_join(
    df_rank(my_coin, "Agg_Opt") %>% 
      rename(Opt_Rank = Rank, Opt_Index = Index),
    by = "uCode"
  )

print(comparativa)

# ==============================================================================
# PASO 8: ANÁLISIS DE VARIACIÓN
# ==============================================================================
print("\n\n📊 DIFERENCIAS EN ÍNDICES:")
print("==========================")

comparativa <- comparativa %>%
  mutate(
    Dif_PCA_vs_Equal = round(abs(PCA_Index - Iguales_Index), 2),
    Dif_Opt_vs_Equal = round(abs(Opt_Index - Iguales_Index), 2),
    Dif_PCA_vs_Opt = round(abs(PCA_Index - Opt_Index), 2),
    Max_Dif_Index = round(pmax(Dif_PCA_vs_Equal, Dif_Opt_vs_Equal, Dif_PCA_vs_Opt), 2)
  ) %>%
  mutate(
    Dif_PCA_Rank = abs(PCA_Rank - Iguales_Rank),
    Dif_Opt_Rank = abs(Opt_Rank - Iguales_Rank),
    Dif_PCA_Opt_Rank = abs(PCA_Rank - Opt_Rank),
    Max_Dif_Rank = pmax(Dif_PCA_Rank, Dif_Opt_Rank, Dif_PCA_Opt_Rank)
  )

# Mostrar diferencias
print(comparativa %>%
  select(uCode, Iguales_Index, PCA_Index, Opt_Index, 
         Max_Dif_Index, Iguales_Rank, PCA_Rank, Opt_Rank, Max_Dif_Rank))

# ==============================================================================
# PASO 9: ESTADÍSTICAS DE ESTABILIDAD
# ==============================================================================
print("\n\n✅ ANÁLISIS DE ESTABILIDAD:")
print("===========================")

cat("\n📈 Correlaciones ÍNDICES (Pearson):\n")
cor_idx <- cor(comparativa[, c("Iguales_Index", "PCA_Index", "Opt_Index")], use = "complete.obs")
print(round(cor_idx, 4))

cat("\n📊 Correlaciones RANKINGS (Spearman):\n")
cor_rank <- cor(comparativa[, c("Iguales_Rank", "PCA_Rank", "Opt_Rank")], 
                method = "spearman", use = "complete.obs")
print(round(cor_rank, 4))

cat("\n⚠️ VARIACIÓN MÁXIMA DE ÍNDICES (PUNTOS):\n")
print(paste("Media:", round(mean(comparativa$Max_Dif_Index), 2)))
print(paste("Máximo:", round(max(comparativa$Max_Dif_Index), 2)))
print(paste("Mínimo:", round(min(comparativa$Max_Dif_Index), 2)))

cat("\n⚠️ VARIACIÓN MÁXIMA DE RANKINGS (POSICIONES):\n")
print(paste("Media:", round(mean(comparativa$Max_Dif_Rank), 2)))
print(paste("Máximo:", round(max(comparativa$Max_Dif_Rank), 2)))
print(paste("Mínimo:", round(min(comparativa$Max_Dif_Rank), 2)))

cat("\nUnidades con variación > 2 puestos:", 
    sum(comparativa$Max_Dif_Rank > 2, na.rm = TRUE), 
    "de", nrow(comparativa), "\n")

# ==============================================================================
# PASO 10: TOP 10 CON MAYOR VARIACIÓN
# ==============================================================================
print("\n\n🔴 TOP 10 REGIONES CON MAYOR VARIACIÓN:")
print("========================================")

print(comparativa %>%
  arrange(desc(Max_Dif_Rank)) %>%
  select(uCode, 
         Iguales_Rank, PCA_Rank, Opt_Rank, Max_Dif_Rank,
         Iguales_Index, PCA_Index, Opt_Index, Max_Dif_Index) %>%
  head(10))

# ==============================================================================
# PASO 11: VISUALIZACIÓN - BUMP CHART
# ==============================================================================
print("\n\n📈 Generando visualización...")

# Preparar datos para visualización
top20_data <- comparativa %>%
  mutate(promedio_rank = rowMeans(select(., ends_with("_Rank")), na.rm = TRUE)) %>%
  arrange(promedio_rank) %>%
  head(20)

# Colores aún más diferenciados
colores_fijos <- c(
  "#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00",
  "#FFFF33", "#A65628", "#F781BF", "#999999", "#66CCFF",
  "#FF66CC", "#CCFF66", "#FF9999", "#99FF99", "#9999FF",
  "#FFCC99", "#CC9999", "#99CC99", "#99CCCC", "#FF99CC"
)

top20_data$Color <- colores_fijos[1:nrow(top20_data)]

# Formato largo
comparativa_long <- top20_data %>%
  select(uCode, Iguales_Rank, PCA_Rank, Opt_Rank) %>%
  pivot_longer(
    cols = c(Iguales_Rank, PCA_Rank, Opt_Rank),
    names_to = "Metodo",
    values_to = "Posicion"
  ) %>%
  mutate(
    Metodo = factor(Metodo,
                   levels = c("Iguales_Rank", "PCA_Rank", "Opt_Rank"),
                   labels = c("Pesos Iguales", "Pesos PCA", "Pesos Optimizados")),
    Color = rep(colores_fijos[1:nrow(top20_data)], 3)
  ) %>%
  arrange(Metodo, Posicion)

# Etiquetas Y
etiquetas_y <- paste0(1:nrow(top20_data), "\n(", top20_data$uCode, ")")

# Gráfico BUMP CHART
p1 <- ggplot(comparativa_long,
            aes(x = Metodo, y = Posicion, group = uCode, color = uCode)) +
  geom_line(linewidth = 1.5, alpha = 0.7) +
  geom_point(size = 4.5, alpha = 1) +
  scale_y_reverse(
    breaks = 1:nrow(top20_data),
    labels = etiquetas_y
  ) +
  scale_color_manual(values = setNames(top20_data$Color, top20_data$uCode)) +
  theme_minimal(base_size = 12) +
  labs(
    title = "🎯 Variación de Rankings entre Métodos de Ponderación",
    subtitle = paste0("Top ", nrow(top20_data), " regiones | Líneas horizontales = Máxima estabilidad"),
    x = "Método de Ponderación",
    y = "Ranking (Posición + Región)",
    color = "Región"
  ) +
  theme(
    legend.position = "right",
    legend.text = element_text(size = 8),
    plot.title = element_text(hjust = 0.5, size = 15, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 11),
    axis.text.y = element_text(size = 8.5, hjust = 1),
    axis.text.x = element_text(size = 11, face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_line(color = "grey85", linewidth = 0.2)
  )

print(p1)

# ==============================================================================
# PASO 12: GRÁFICO DE ÍNDICES
# ==============================================================================

# Datos para gráfico de índices
comparativa_idx_long <- comparativa %>%
  arrange(Iguales_Index) %>%
  select(uCode, Iguales_Index, PCA_Index, Opt_Index) %>%
  pivot_longer(
    cols = c(Iguales_Index, PCA_Index, Opt_Index),
    names_to = "Metodo",
    values_to = "Index_Value"
  ) %>%
  mutate(
    Metodo = factor(Metodo,
                   levels = c("Iguales_Index", "PCA_Index", "Opt_Index"),
                   labels = c("Pesos Iguales", "Pesos PCA", "Pesos Optimizados"))
  )

p2 <- ggplot(comparativa_idx_long, aes(x = reorder(uCode, Index_Value), y = Index_Value, fill = Metodo)) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.8) +
  coord_flip() +
  scale_fill_manual(
    values = c("Pesos Iguales" = "#377EB8", "Pesos PCA" = "#E41A1C", "Pesos Optimizados" = "#4DAF4A")
  ) +
  theme_minimal(base_size = 11) +
  labs(
    title = "📊 Comparación de Índices Sintéticos por Región",
    x = "Región",
    y = "Valor del Índice (0-100)",
    fill = "Método"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    legend.position = "bottom"
  )

print(p2)

print("\n\n✅ ANÁLISIS COMPLETADO")

# SCRIPT DE DIAGNÓSTICO RÁPIDO
# Ejecuta esto para verificar dónde está el problema

# ==============================================================================
# 1. VERIFICAR ESTRUCTURA DEL OBJETO COIN
# ==============================================================================
cat("═══════════════════════════════════════════════════════════════\n")
cat("1️⃣  VERIFICANDO ESTRUCTURA DEL OBJETO COIN\n")
cat("═══════════════════════════════════════════════════════════════\n\n")

cat("¿El objeto es de clase coin?\n")
print(class(my_coin))

cat("\n¿Existen los Meta$Weights esperados?\n")
print(names(my_coin$Meta$Weights))

cat("\n¿Existen los Data sets esperados?\n")
print(names(my_coin$Data))

# ==============================================================================
# 2. VERIFICAR SI LOS PESOS FUERON CREADOS CORRECTAMENTE
# ==============================================================================
cat("\n\n═══════════════════════════════════════════════════════════════\n")
cat("2️⃣  VERIFICANDO GENERACIÓN DE PESOS\n")
cat("═══════════════════════════════════════════════════════════════\n\n")

# Original
cat("📌 Pesos ORIGINALES:\n")
cat("  - Número de filas:", nrow(my_coin$Meta$Weights$Original), "\n")
print(head(my_coin$Meta$Weights$Original, 3))

# PCA
cat("\n📌 Pesos PCA:\n")
if (is.null(my_coin$Meta$Weights$PCA_Weights)) {
  cat("  ⚠️  PCA_Weights es NULL - No se generaron correctamente\n")
  cat("      Asegúrate que:\n")
  cat("      1. Ejecutaste get_PCA() con out2='coin'\n")
  cat("      2. Agregaste antes (dset='Aggregated')\n")
} else {
  cat("  - Número de filas:", nrow(my_coin$Meta$Weights$PCA_Weights), "\n")
  print(head(my_coin$Meta$Weights$PCA_Weights, 3))
}

# Optímizados
cat("\n📌 Pesos OPTIMIZADOS:\n")
if (is.null(my_coin$Meta$Weights$Opt_Weights)) {
  cat("  ⚠️  Opt_Weights es NULL - No se generaron correctamente\n")
  cat("      Asegúrate que:\n")
  cat("      1. Ejecutaste get_opt_weights() con out2='coin'\n")
  cat("      2. Agregaste antes (dset='Aggregated')\n")
} else {
  cat("  - Número de filas:", nrow(my_coin$Meta$Weights$Opt_Weights), "\n")
  print(head(my_coin$Meta$Weights$Opt_Weights, 3))
}

# ==============================================================================
# 3. VERIFICAR SI LOS PESOS SON DIFERENTES
# ==============================================================================
cat("\n\n═══════════════════════════════════════════════════════════════\n")
cat("3️⃣  VERIFICANDO SI LOS PESOS SON DIFERENTES\n")
cat("═══════════════════════════════════════════════════════════════\n\n")

# Extractar solo indicadores nivel 1
pesos_L1_original <- my_coin$Meta$Weights$Original %>%
  filter(Level == 1) %>%
  select(iCode, Weight) %>%
  rename(Original = Weight)

if (!is.null(my_coin$Meta$Weights$PCA_Weights)) {
  pesos_L1_pca <- my_coin$Meta$Weights$PCA_Weights %>%
    filter(Level == 1) %>%
    select(iCode, Weight) %>%
    rename(PCA = Weight)
  
  pesos_L1 <- pesos_L1_original %>%
    left_join(pesos_L1_pca, by = "iCode")
} else {
  pesos_L1 <- pesos_L1_original
}

if (!is.null(my_coin$Meta$Weights$Opt_Weights)) {
  pesos_L1_opt <- my_coin$Meta$Weights$Opt_Weights %>%
    filter(Level == 1) %>%
    select(iCode, Weight) %>%
    rename(Opt = Weight)
  
  pesos_L1 <- pesos_L1 %>%
    left_join(pesos_L1_opt, by = "iCode")
}

cat("Pesos a nivel indicadores (Level 1):\n")
print(pesos_L1)

cat("\n\nEstadísticas:\n")
cat("Original - Rango: ", min(pesos_L1$Original), " a ", max(pesos_L1$Original), "\n")
if (!is.null(my_coin$Meta$Weights$PCA_Weights)) {
  cat("PCA      - Rango: ", min(pesos_L1$PCA, na.rm=T), " a ", max(pesos_L1$PCA, na.rm=T), "\n")
}
if (!is.null(my_coin$Meta$Weights$Opt_Weights)) {
  cat("Opt      - Rango: ", min(pesos_L1$Opt, na.rm=T), " a ", max(pesos_L1$Opt, na.rm=T), "\n")
}

cat("\n¿Son todos los pesos EXACTAMENTE iguales a 1?\n")
cat("Si sí, los pesos no se optimizaron correctamente.\n")

# ==============================================================================
# 4. VERIFICAR DATOS AGREGADOS
# ==============================================================================
cat("\n\n═══════════════════════════════════════════════════════════════\n")
cat("4️⃣  VERIFICANDO DATOS AGREGADOS\n")
cat("═══════════════════════════════════════════════════════════════\n\n")

cat("¿Existen datasets agregados?\n")
cat("  - Agg_Equal:", ("Agg_Equal" %in% names(my_coin$Data)), "\n")
cat("  - Agg_PCA:", ("Agg_PCA" %in% names(my_coin$Data)), "\n")
cat("  - Agg_Opt:", ("Agg_Opt" %in% names(my_coin$Data)), "\n")

# ==============================================================================
# 5. VERIFICAR ÍNDICES FINALES
# ==============================================================================
cat("\n\n═══════════════════════════════════════════════════════════════\n")
cat("5️⃣  VERIFICANDO ÍNDICES FINALES\n")
cat("═══════════════════════════════════════════════════════════════\n\n")

if ("Agg_Equal" %in% names(my_coin$Data)) {
  cat("Primeras 5 filas - Agg_Equal:\n")
  print(head(my_coin$Data$Agg_Equal[, c("uCode", "TotalIndex")], 5))
}

if ("Agg_PCA" %in% names(my_coin$Data)) {
  cat("\nPrimeras 5 filas - Agg_PCA:\n")
  print(head(my_coin$Data$Agg_PCA[, c("uCode", "TotalIndex")], 5))
}

if ("Agg_Opt" %in% names(my_coin$Data)) {
  cat("\nPrimeras 5 filas - Agg_Opt:\n")
  print(head(my_coin$Data$Agg_Opt[, c("uCode", "TotalIndex")], 5))
}

# ==============================================================================
# 6. COMPARACIÓN FINAL DE ÍNDICES
# ==============================================================================
cat("\n\n═══════════════════════════════════════════════════════════════\n")
cat("6️⃣  COMPARACIÓN DE ÍNDICES\n")
cat("═══════════════════════════════════════════════════════════════\n\n")

if (all(c("Agg_Equal", "Agg_PCA", "Agg_Opt") %in% names(my_coin$Data))) {
  
  comparativa_diag <- data.frame(
    uCode = my_coin$Data$Agg_Equal$uCode,
    Equal = round(my_coin$Data$Agg_Equal$TotalIndex, 3),
    PCA = round(my_coin$Data$Agg_PCA$TotalIndex, 3),
    Opt = round(my_coin$Data$Agg_Opt$TotalIndex, 3)
  )
  
  comparativa_diag <- comparativa_diag %>%
    mutate(
      Dif_PCA = abs(PCA - Equal),
      Dif_Opt = abs(Opt - Equal)
    )
  
  print(comparativa_diag)
  
  cat("\n\nRESULTADOS:\n")
  cat("¿Todos los índices son idénticos?\n")
  cat("  - Equal vs PCA: máx diferencia =", max(comparativa_diag$Dif_PCA), "\n")
  cat("  - Equal vs Opt: máx diferencia =", max(comparativa_diag$Dif_Opt), "\n")
  
  if (max(comparativa_diag$Dif_PCA) == 0 & max(comparativa_diag$Dif_Opt) == 0) {
    cat("\n⚠️  PROBLEMA DETECTADO: Los índices son idénticos\n")
    cat("    Esto significa que los pesos no se están usando correctamente.\n")
    cat("\n    CHECKLIST:\n")
    cat("    ☐ ¿PCA_Weights y Opt_Weights NO son NULL?\n")
    cat("    ☐ ¿Los pesos tienen valores DIFERENTES (no todos = 1)?\n")
    cat("    ☐ ¿Usaste w= (no weights=) en Aggregate()?\n")
    cat("    ☐ ¿Agregaste ANTES de generar PCA (dset='Aggregated')?\n")
  } else {
    cat("\n✅ CORRECTO: Los índices muestran variación\n")
  }
  
} else {
  cat("⚠️  No existen todos los datasets necesarios.\n")
}

# ==============================================================================
# 7. REPORTE FINAL
# ==============================================================================
cat("\n\n═══════════════════════════════════════════════════════════════\n")
cat("REPORTE FINAL DE DIAGNÓSTICO\n")
cat("═══════════════════════════════════════════════════════════════\n\n")

diagnostico <- list(
  coin_correcto = class(my_coin) == "coin",
  meta_weights_existe = !is.null(my_coin$Meta$Weights),
  pca_weights_existe = !is.null(my_coin$Meta$Weights$PCA_Weights),
  opt_weights_existe = !is.null(my_coin$Meta$Weights$Opt_Weights),
  agg_equal_existe = "Agg_Equal" %in% names(my_coin$Data),
  agg_pca_existe = "Agg_PCA" %in% names(my_coin$Data),
  agg_opt_existe = "Agg_Opt" %in% names(my_coin$Data)
)

for (i in seq_along(diagnostico)) {
  status <- ifelse(diagnostico[[i]], "✅", "❌")
  cat(status, names(diagnostico)[i], "\n")
}

cat("\n")
if (all(unlist(diagnostico))) {
  cat("✅ TODO ESTÁ BIEN - El problema NO es estructural\n")
  cat("   Verifica los valores específicos en las tablas de arriba\n")
} else {
  cat("❌ PROBLEMA DETECTADO - Ver las secciones de arriba\n")
}

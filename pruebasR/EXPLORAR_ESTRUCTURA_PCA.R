# ==============================================================================
# EXPLORAR LA ESTRUCTURA REAL DEL PCA EN TU OBJETO COIN
# ==============================================================================

cat("🔍 EXPLORANDO ESTRUCTURA DEL PCA EN MY_COIN\n")
cat("============================================\n\n")

# 1. Ver qué hay en $Analysis
cat("1️⃣  Contenido de my_coin$Analysis:\n")
print(names(my_coin$Analysis))

# 2. Ver si existe PCA
cat("\n2️⃣  ¿Existe my_coin$Analysis$PCA?\n")
print(!is.null(my_coin$Analysis$PCA))

# 3. Si existe, explorar su estructura
if (!is.null(my_coin$Analysis$PCA)) {
  cat("\n3️⃣  Estructura de my_coin$Analysis$PCA:\n")
  print(str(my_coin$Analysis$PCA, max.level = 2))
  
  cat("\n4️⃣  Nombres en my_coin$Analysis$PCA:\n")
  print(names(my_coin$Analysis$PCA))
  
  # Ver la varianza explicada
  cat("\n5️⃣  Varianza explicada disponible:\n")
  if (!is.null(my_coin$Analysis$PCA$var_exp)) {
    print("   ✅ my_coin$Analysis$PCA$var_exp existe")
    print(my_coin$Analysis$PCA$var_exp)
  }
  
  # Ver los loadings
  cat("\n6️⃣  Loadings disponibles:\n")
  if (!is.null(my_coin$Analysis$PCA$loadings)) {
    print("   ✅ my_coin$Analysis$PCA$loadings existe")
    print(head(my_coin$Analysis$PCA$loadings))
  }
}

# ==============================================================================
# ALTERNATIVA: SI EL PCA SE CONECTÓ POR NIVEL/DIMENSIÓN
# ==============================================================================

cat("\n\n7️⃣  Buscando PCA por dimensiones/niveles...\n")
print(names(my_coin$Analysis))

# Si hubiera PCA por dimensión, sería algo así:
# my_coin$Analysis$PCA_ENV
# my_coin$Analysis$PCA_ECO
# etc.

cat("\n📌 Si ves nombres como 'PCA_ECO', 'PCA_ENV', etc., ")
cat("eso significa que hay PCA separado por dimensión.\n")

# ==============================================================================
# RESUMEN
# ==============================================================================

cat("\n\n✅ ESTRUCTURA ENCONTRADA:\n")

if (!is.null(my_coin$Analysis$PCA)) {
  cat("   El PCA se almacena en: my_coin$Analysis$PCA\n")
  cat("   Esto es para TODOS los indicadores en conjunto (Level 1)\n\n")
  
  cat("   📊 Para acceder a la varianza de PC1:\n")
  cat("      my_coin$Analysis$PCA$var_exp[1]\n\n")
  
  cat("   📊 Para ver todos los componentes:\n")
  cat("      my_coin$Analysis$PCA$var_exp\n\n")
} else {
  cat("   ⚠️  No se encontró my_coin$Analysis$PCA\n")
  cat("   Verifica que ejecutaste get_PCA() correctamente\n")
}

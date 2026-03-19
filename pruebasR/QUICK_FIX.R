# QUICK FIX - CAMBIOS MÍNIMOS EN TU CÓDIGO ORIGINAL
# Copia-pega exactamente lo que necesitas cambiar

# ==============================================================================
# CAMBIO 1: Reemplaza esto en la verificación de PCA_Weights
# ==============================================================================

# ❌ LO QUE TIENES AHORA:
# print(my_coin$Weights$PCA_Weights[1:5,])  # ← ¡DIAGNÓSTICO CLAVE!

# ✅ CÁMBIALO A:
print("Pesos PCA generados:")
print(my_coin$Meta$Weights$PCA_Weights[1:5,])  # ← CORRECCIÓN: Meta$Weights

# ==============================================================================
# CAMBIO 2: Reemplaza esto en la verificación de Opt_Weights
# ==============================================================================

# ❌ LO QUE TIENES AHORA:
# print(my_coin$Weights$Opt_Weights[1:5,])  # ← ¡DIAGNÓSTICO CLAVE!

# ✅ CÁMBIALO A:
print("Pesos Optimizados generados:")
print(my_coin$Meta$Weights$Opt_Weights[1:5,])  # ← CORRECCIÓN: Meta$Weights

# ==============================================================================
# CAMBIO 3: Reemplaza la agregación A (Pesos IGUALES)
# ==============================================================================

# ❌ LO QUE TIENES AHORA:
# my_coin <- Aggregate(
#   my_coin, dset = "Normalised", 
#   weights = "Original",      # ← PARÁMETRO INCORRECTO
#   f_ag = "a_amean", 
#   write_to = "Agg_Equal",
#   out2 = "coin"
# )

# ✅ CÁMBIALO A:
my_coin <- Aggregate(
  my_coin, dset = "Normalised", 
  w = "Original",                # ← CORRECCIÓN: "w" no "weights"
  f_ag = "a_amean", 
  write_to = "Agg_Equal",
  out2 = "coin"
)

# ==============================================================================
# CAMBIO 4: Reemplaza la agregación B (PCA)
# ==============================================================================

# ❌ LO QUE TIENES AHORA:
# my_coin <- Aggregate(
#   my_coin, dset = "Normalised", 
#   weights = "PCA_Weights",   # ← PARÁMETRO INCORRECTO
#   f_ag = "a_amean", 
#   write_to = "Agg_PCA",
#   out2 = "coin"
# )

# ✅ CÁMBIALO A:
my_coin <- Aggregate(
  my_coin, dset = "Normalised", 
  w = "PCA_Weights",             # ← CORRECCIÓN: "w" no "weights"
  f_ag = "a_amean", 
  write_to = "Agg_PCA",
  out2 = "coin"
)

# ==============================================================================
# CAMBIO 5: Reemplaza la agregación C (Optimizados)
# ==============================================================================

# ❌ LO QUE TIENES AHORA:
# my_coin <- Aggregate(
#   my_coin, dset = "Normalised", 
#   weights = "Opt_Weights",   # ← PARÁMETRO INCORRECTO
#   f_ag = "a_amean", 
#   write_to = "Agg_Opt",
#   out2 = "coin"
# )

# ✅ CÁMBIALO A:
my_coin <- Aggregate(
  my_coin, dset = "Normalised", 
  w = "Opt_Weights",             # ← CORRECCIÓN: "w" no "weights"
  f_ag = "a_amean", 
  write_to = "Agg_Opt",
  out2 = "coin"
)

# ==============================================================================
# CAMBIO 6: IMPORTANTE - Agregar esta línea ANTES de get_PCA()
# ==============================================================================

# Si aún no lo hiciste, agrega una agregación inicial ANTES de PCA
# (Si ya tienes "Aggregated" en my_coin$Data, puedes saltarte esto)

if (!("Aggregated" %in% names(my_coin$Data))) {
  print("⏳ Agregando datos inicialmente (requerido para PCA)...")
  my_coin <- Aggregate(
    my_coin,
    dset = "Normalised",
    f_ag = "a_amean",
    out2 = "coin"
  )
}

# ==============================================================================
# RESUMEN DE CAMBIOS
# ==============================================================================

# 1. my_coin$Weights           → my_coin$Meta$Weights
# 2. weights = "X"             → w = "X"
# 3. ANTES: PCA → Aggregate    → DESPUÉS: Aggregate → PCA → Aggregate x3

# Eso es todo lo que necesitas cambiar.

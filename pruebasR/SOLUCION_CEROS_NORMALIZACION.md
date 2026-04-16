# ¿POR QUÉ SALEN CEROS SI NORMALIZO ENTRE 1 Y 100?

## 🔴 El Problema

COINr normaliza **por moneda (por año)**, no globalmente. Esto significa:

```
Indicador X:
  - Año 2020: min=10, max=100  → normaliza [10,100] → rango [1,100]
  - Año 2021: min=10, max=10   → ¡VARIANZA CERO! → asigna al min predeterminado
  - Año 2022: min=5, max=80    → normaliza [5,80] → rango [1,100]
```

**Si un indicador tiene el MISMO VALOR para todos los países en un año, COINr no puede normalizarlo y genera NaN o 0.**

## 🟡 Por qué no funciona tu limpieza manual actual

Tu código actual hace esto:

```r
# Paso 1: Normaliza
purse_PCA <- Normalise(
  purse_PCA,
  dset = "Imputed",
  normalise_by = "all",  # ← Esto NO significa "global"
  f_n = "n_minmax"
)

# Paso 2: Limpia ceros
dset_norm_clean <- get_dset(purse_PCA, dset = "Normalised") %>%
  mutate(across(where(is.numeric), ~ if_else(.x <= 0, 1, .x)))

purse_PCA$Data$Normalised <- dset_norm_clean

# Paso 3: ⚠️ LUEGO HACES OTRA NORMALIZACIÓN
purse_PCA <- Normalise(purse_PCA, dset = "Imputed", ...)  # ← ¡Vuelve a generar ceros!
```

**Cada vez que llamas a `Normalise()`, recalcula y puede volver a generar ceros.**

## ✅ SOLUCIÓN: Normalización VERDADERAMENTE GLOBAL

```r
# ============================================================
# BLOQUE 1: Normalización GLOBAL (no por moneda)
# ============================================================

# Extraer todos los datos normalizados tal cual los tiene COINr
df_norm_step1 <- get_dset(purse_PCA, dset = "Imputed") %>%
  filter(uCode != "ESP")

# Identificar columnas numéricas (indicadores)
cols_numericas <- names(df_norm_step1)[
  sapply(df_norm_step1, is.numeric)
]

# Normalizar GLOBALMENTE sin especificar monedas
df_norm_global <- df_norm_step1 %>%
  mutate(across(
    all_of(cols_numericas),
    ~ {
      min_val <- min(.x, na.rm = TRUE)
      max_val <- max(.x, na.rm = TRUE)
      
      if (is.infinite(min_val) || is.infinite(max_val) || 
          is.na(min_val) || is.na(max_val)) {
        return(rep(50, length(.x)))  # Si hay problema, usa el medio
      }
      
      if (min_val == max_val) {
        return(rep(50, length(.x)))  # Si no hay varianza, usa el medio
      }
      
      # Normaliza entre 1 y 100
      ((.x - min_val) / (max_val - min_val)) * 99 + 1
    }
  )) %>%
  # GARANTIZAR que NO hay valores <= 0
  mutate(across(
    all_of(cols_numericas),
    ~ case_when(
      is.na(.x) ~ 1,
      .x <= 0   ~ 1,
      .x > 100  ~ 100,
      TRUE      ~ .x
    )
  ))

# Sobreescribir los datos en purse_PCA
purse_PCA$Data$Normalised <- df_norm_global

# Verificación
message("✓ Valores mínimos por columna:")
apply(df_norm_global %>% select(all_of(cols_numericas)), 2, min, na.rm=TRUE) %>% print()
message("✓ Valores máximos por columna:")
apply(df_norm_global %>% select(all_of(cols_numericas)), 2, max, na.rm=TRUE) %>% print()

message("✓ ¿Hay algún cero?: ", 
        any(df_norm_global %>% select(all_of(cols_numericas)) <= 0, na.rm=TRUE))

# ============================================================
# BLOQUE 2: Agregación por Media Geométrica (AHORA SÍ FUNCIONARÁ)
# ============================================================

purse_PCA_gmean <- Aggregate(
  purse_PCA,
  dset = "Normalised",
  f_ag = "a_gmean"
)

# Extraer ranking
df_rankings_gmean <- get_dset(purse_PCA_gmean, dset = "Aggregated") %>%
  filter(uCode != "ESP") %>%
  group_by(Time) %>%
  arrange(Time, desc(TotalIndex)) %>%
  mutate(Rank_Gmean = row_number()) %>%
  select(CCAA = uCode, Year = Time, Score_Gmean = TotalIndex, Rank_Gmean) %>%
  ungroup()

print(df_rankings_gmean)
```

## 📊 ALTERNATIVA: Si aún tienes problemas

Si el código anterior sigue dando problemas, usa esta versión aún más defensiva:

```r
# ============================================================
# ALTERNATIVA ULTRA-SEGURA: Media geométrica manual
# ============================================================

# 1. Extraer datos normalizados
df_agregado <- get_dset(purse_PCA, dset = "Normalised") %>%
  filter(uCode != "ESP")

# 2. Obtener indicadores (excluir uCode y Time)
indices_indicadores <- which(
  !names(df_agregado) %in% c("uCode", "Time")
)

# 3. Calcular media geométrica por fila (por región-año)
df_agregado$GeometricMean <- apply(
  df_agregado[, indices_indicadores],
  1,
  function(row) {
    # Filtrar NAs y valores <= 0
    row_limpia <- row[row > 0 & !is.na(row)]
    
    if (length(row_limpia) == 0) return(NA)
    if (length(row_limpia) == 1) return(row_limpia[1])
    
    # Media geométrica = exp(mean(log(valores)))
    exp(mean(log(row_limpia)))
  }
)

# 4. Ranking por año
ranking_final <- df_agregado %>%
  select(uCode, Time, GeometricMean) %>%
  group_by(Time) %>%
  arrange(Time, desc(GeometricMean)) %>%
  mutate(Rank = row_number()) %>%
  select(CCAA = uCode, Year = Time, Score = GeometricMean, Rank) %>%
  ungroup()

print(ranking_final)
```

## 🎯 RESUMEN: ¿Cuál es la CAUSA?

| Causa | Síntoma |
|-------|---------|
| **Indicadores con varianza=0 dentro de un año** | COINr no puede normalizarlos → NaN → se convierte en 0 |
| **Valores más pequeños en el rango [1,100]** | El mínimo es 1, pero a veces COINr fuerza a 0 como "missing" |
| **Llamar a `Normalise()` múltiples veces** | Cada llamada recalcula y puede generar nuevos ceros |
| **Datos de entrada con NAs o Infs** | Se propagan a través de la normalización |

## 💡 RECOMENDACIÓN FINAL

**Opción A (Recomendada):** Usa el Bloque 1 de arriba → normalización verdaderamente global + limpieza defensiva

**Opción B (Si eso no funciona):** Usa Media Geométrica Manual (Alternativa Ultra-Segura)

**Opción C (Si necesitas COINr para el flujo):** Cambia a `a_amean` (media aritmética) que es más tolerante con ceros

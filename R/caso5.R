## CASO 5: PCA/FA manual OCDE
```{r caso5_pesos_ocde}
# Función que calcula pesos OCDE para una dimensión (ECO, SOC o ENV)
calcular_pesos_ocde <- function(dim, df_datos, iMeta_ref, indicadores_eco = NULL) {
  
  # 1. Seleccionamos indicadores que pertenecen a la dimensión
  inds_dim <- iMeta_ref %>% filter(Level == 1, Parent == dim) %>% pull(iCode)
  df_dim <- df_datos %>% select(any_of(inds_dim))
  
  # En ECO usamos los no redundantes
  if (dim == "ECO" && !is.null(indicadores_eco)) {
    df_dim <- df_dim %>% select(any_of(indicadores_eco))
  }
  
  # Eliminamos variables con varianza 0 (necesario para el PCA)
  df_dim <- df_dim %>% select(where(~ var(.x, na.rm = TRUE) > 1e-10))
  
  # 2. Determinamos cuántos componentes retener (Criterio OCDE: Eigenvalue > 1)
  pca_previo <- prcomp(df_dim, center = TRUE, scale. = TRUE)
  n_factores <- sum(pca_previo$sdev^2 > 1)

  # Si solo sale 1 factor, no se puede rotar, usamos el PCA simple (los pesos 
  # se obtienen directamente de las cargas del primer componente)
  if (n_factores < 2) {
    loadings_pc1 <- abs(pca_previo$rotation[, 1]) # importancia de cada indicador
    pesos <- loadings_pc1^2 / sum(loadings_pc1^2) # OCDE usa cuadrados de cargas
    return(tibble(iCode = names(pesos), Weight_OCDE = pesos, Factor = "F1", Var_Factor = 1))
  }
  
  # 3. Rotación Varimax (Paso 3 del manual)
  # Usamos la función principal del paquete psych
  rotacion <- psych::principal(df_dim, nfactors = n_factores, rotate = "varimax")
  
  # 4. Asignamos cada indicador al factor donde más carga tiene (Paso 4 del manual)
  loadings_mat <- as.data.frame(unclass(rotacion$loadings))
  cargas_maximas <- loadings_mat %>%
    mutate(iCode = rownames(.),
           Factor_Asignado = colnames(loadings_mat)[apply(loadings_mat, 1, which.max)])
  
  # 5. Calculamos pesos intermedios y finales
  pesos_finales <- cargas_maximas %>%
    pivot_longer(cols = starts_with("RC"), names_to = "Factor", values_to = "Carga") %>%
    filter(Factor == Factor_Asignado) %>%
    group_by(Factor) %>%
    mutate(
      # Peso relativo dentro del grupo (indicadores más importantes pesan más)
      Weight_in_Factor = Carga^2 / sum(Carga^2)) %>%
    ungroup()
  
  # Calculamos la importancia de cada factor (varianza explicada)
  var_explicada <- rotacion$Vaccounted["Proportion Var", ]
  var_relativa <- var_explicada / sum(var_explicada)
  
  # Peso final = peso dentro del factor x importancia del factor
  pesos_finales <- pesos_finales %>%
    mutate(Var_Factor = as.numeric(var_relativa[Factor]),
           Weight_OCDE = Weight_in_Factor * Var_Factor)
  
  # Devolvemos pesos finales por indicador
  return(pesos_finales %>% select(iCode, Weight_OCDE, Factor, Var_Factor))
}

# Aplicamos la función a las 3 dimensiones
pesos_ocde_L1 <- map_df(c("ECO", "SOC", "ENV"), function(d) {
  res <- calcular_pesos_ocde(d, df_norm_todos, iMeta, indicadores_eco_finales)
  res$Dimension <- d
  res
})

# Mostramos resultados ordenados
print(pesos_ocde_L1 %>% arrange(Dimension, Factor, desc(Weight_OCDE)), n = 39)

# La suma de los pesos debería darnos 1  
cat("Suma total de pesos OCDE:", sum(pesos_ocde_L1$Weight_OCDE), "\n")

pesos_ocde_L1 %>% group_by(Dimension) %>%
  summarise(suma = sum(Weight_OCDE))
```

Calculamos el ranking final con el método de la OCDE PCA/FA: 
  ```{r caso5_ranking_ocde}
# 1. Usamos los identificadores ya filtrados
df_ids_panel <- get_dset(purse_PCA, dset = "Normalised") %>%
  filter(uCode != "ESP") %>%
  select(uCode, Time)

# 2. Preparamos pesos
pesos_finales_vector <- pesos_ocde_L1$Weight_OCDE
names(pesos_finales_vector) <- pesos_ocde_L1$iCode

# 3. Preparamos matriz de datos numéricos
matriz_datos <- df_norm_todos %>% 
  select(any_of(names(pesos_finales_vector))) %>% 
  as.matrix()

# Verificamos que las columnas están en el orden correcto para el producto matricial
matriz_datos <- matriz_datos[, names(pesos_finales_vector)]

# 4. Cálculo del Score (sin normalizar) y unión con IDs
df_STI_OCDE <- df_ids_panel %>%
  mutate(Score_OCDE = as.vector(matriz_datos %*% pesos_finales_vector)) %>%
  group_by(Time) %>%
  mutate(Posicion = row_number(desc(Score_OCDE))) %>%
  ungroup() %>%
  arrange(Time, Posicion)

# 5. Mostrar resultados
cat("\n=== RANKING OCDE (CASO 5) - AÑO 2024 ===\n")
df_STI_OCDE %>% 
  filter(Time == 2024) %>%
  select(uCode, Score_OCDE, Posicion) %>%
  print(n = 19)
```
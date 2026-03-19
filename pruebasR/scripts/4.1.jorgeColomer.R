#cargar primero el .csv!!!!
df <- indConComponentes

library(tidyverse)

# hago pruebas con el año 2022

df <- df |> mutate(date = as.Date(date),
               year = as.numeric(format(date, "%Y")))

df |> filter(year==2022, indicator_id=="IAMB0004") ####son valores NA los 2 iamb0004 que hay, por eso los quitamos en el paso siguiente. 


df |> filter(year==2022, !is.na(value)) |> select(indicator_id, value) |> summarise(n_distinct(indicator_id))

### si quiero ver el número de indicadores que tengo en 2022 por dimensión: 

conteo_por_dimension <- df  |> 
  filter(year == 2022, !is.na(value))  |> 
  group_by(dimension_id) |>              # Agrupamos por ECO, ENV, SOC
  summarise(num_indicadores = n_distinct(indicator_id))

print(conteo_por_dimension)

##############################################
#4.1. Jorge Colomer pero aplicado a nuestros datos. 
#primero, calculamos la correlación de coeficientes de los valores normalizados 
#de los indicadores individuales que pertenecen a la misma componente. 


# ==============================================================================
# ANÁLISIS DE CONSISTENCIA INTERNA Y CORRELACIÓN (SECCIÓN 4.1 TFG)
# ==============================================================================

# 1. CARGA DE LIBRERÍAS
# Si no las tienes, instala primero: install.packages(c("tidyverse", "performance", "psych", "ggcorrplot"))
library(tidyverse)
library(performance)
library(psych)
library(ggcorrplot)

# 2. CARGA Y PREPARACIÓN DE DATOS
# Asumimos que tu archivo se llama indConComponentes.csv

# 3. DEFINICIÓN DE LA FUNCIÓN DE ANÁLISIS
analizar_consistencia <- function(datos, dimension) {
  
  cat("\n", rep("=", 20), "ANÁLISIS DIMENSIÓN:", dimension, rep("=", 20), "\n")
  
  # A. Filtrado y transformación a formato ancho (Matriz para PCA/Correlación)
  df_wide <- datos |> 
    filter(dimension_id == dimension, year == 2022, !is.na(value)) |> 
    select(geo_id, indicator_id, value) |> 
    pivot_wider(names_from = indicator_id, values_from = value) |> 
    column_to_rownames(var = "geo_id")
  
  # B. Limpieza: Eliminar indicadores que no varían (SD = 0) o tienen NAs
  # El análisis de correlación falla si la desviación estándar es 0
  df_wide <- df_wide[, sapply(df_wide, sd, na.rm = TRUE) > 0]
  
  # C. Verificación de viabilidad
  if (ncol(df_wide) < 2) {
    cat("AVISO: No hay suficientes indicadores con variación en la dimensión", dimension, "\n")
    return(NULL)
  }
  
  # D. Matriz de Correlación (Figura 1)
  cor_mat <- cor(df_wide, use = "pairwise.complete.obs")
  
  p <- ggcorrplot(cor_mat, 
                  hc.order = TRUE, 
                  type = "lower",
                  lab = TRUE, 
                  lab_size = 3,
                  title = paste("Matriz de Correlación:", dimension),
                  colors = c("#E4672E", "white", "#6D9EC1"))
  print(p)
  
  # E. Test de Bartlett y KMO (Metodología de Lüdecke et al., 2021)
  # check_factorstructure() del paquete performance
  cat("\n--- Test de Adecuación (Bartlett & KMO) ---\n")
  print(check_factorstructure(df_wide))
  
  # F. Alpha de Cronbach (Consistencia Interna)
  # check.keys = TRUE invierte automáticamente indicadores con carga negativa
  cat("\n--- Consistencia Interna (Alpha de Cronbach) ---\n")
  alpha_res <- psych::alpha(df_wide, check.keys = TRUE)
  cat("Alpha de Cronbach estandarizado:", round(alpha_res$total$std.alpha, 3), "\n")
}

# 4. EJECUCIÓN PARA TODAS LAS DIMENSIONES
dimensiones <- c("ECO", "ENV", "SOC")

# Usamos walk para ejecutar la función en cada dimensión y ver los resultados
walk(dimensiones, ~analizar_consistencia(df, .x))

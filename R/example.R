library(dplyr)
library(tidyr)

#Leo las dos tablas de indicadores: la de los nombres y la de los valores
indicators <- readRDS("data/indicators.rds")
indicators_data <- readRDS("data/indicators_data.rds")

# Creo un nuevo df combinando las dos tablas por la columna indicator_id (y por indicator direction pq si no sale duplicada la columna)
all_data <- indicators |> 
  inner_join(indicators_data, by = c("indicator_id", "indicator_direction"))

##tabla con cloumnas: dimension_id y n (nº de indicadores diferentes que pertenecen a esa dimension)
all_data |> 
  distinct(indicator_id, dimension_id) |> 
  count(dimension_id)

#Cuántos nombres de indicadores tenemos en total en teoría (cuántos indicadores distintos): 
indicators |> 
  distinct(indicator_id) |> 
  count()
#111

#De cuántos indicadores tenemos datos realmente:
indicators_data |> 
  distinct(indicator_id) |> 
  count()
#21

################################################################################
#DUDAS: sólo tenemos datos de 21 indicadores, qué pasa con el resto?
################################################################################

#cuántos datos tenemos de cada indicador
table(all_data$indicator_id)

#veo a qué región corresponden los dos únicos datos que tenemos del indicador con ID: "IAMB0004" 
table(all_data[all_data$indicator_id=="IAMB0004",]$geo_id)
#que son Canarias y España nivel nacional


###############################################################################

# quiero ver cuantas geo_id hay y cuantos registros tiene cada una.
#Ceuta y Melilla son las que menos registros tienen (84), Canarias y España las que más (142) y el resto 115.

indicators_data %>%
  count(geo_id, name = "n_registros")

#filas con NA en value: 
indicators_data %>%
  filter(is.na(value)) %>%
  select(geo_id, indicator_id, date, value, value_ori, dimension_id)

#tenemos un NA en ceuta, uno en Melilla, uno en Canarias y uno en España. 

################################################################################
#DUDA: si tenemos el value_original y el NA está en value, si value es el valor 
#normalizado, no podemos calcularlo y que dejen de ser NA?
################################################################################










################################################################################
#PCA por dimensión
# Función 
hacer_pca_por_dimension <- function(dim) {
  
  cat("\n=======================\n")
  cat("PCA PARA DIMENSIÓN:", dim, "\n")
  cat("=======================\n")
  
  datos_dim <- all_data |> 
    filter(dimension_id == dim) |> 
    select(geo_id, date, indicator_id, value)
  
  # Pasar a wide (columna por indicador)
  matriz_dim <- datos_dim |> 
    pivot_wider(
      names_from = indicator_id,
      values_from = value
    )
  
  # Eliminar columnas no numéricas
  mat <- matriz_dim |> 
    select(where(is.numeric)) |> 
    na.omit()   # elimina filas incompletas
  
  # PCA escalado
  pca <- prcomp(mat, scale. = TRUE)
  
  print(summary(pca))   # varianza explicada
  print(pca$rotation)   # loadings
  
  return(pca)
}

pca_ECO <- hacer_pca_por_dimension("ECO")
pca_SOC <- hacer_pca_por_dimension("SOC")

#HAY 4 NAs en ENV
all_data |> 
  filter(dimension_id == "ENV") |> 
  count(is.na(value))


pca_ENV <- hacer_pca_por_dimension("ENV")


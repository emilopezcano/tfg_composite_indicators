# 1. Ver un resumen estadístico
datos = indicators_data
summary(datos$value)

# Quiero ver qué NA tengo. 

# 2. Ver las regiones con mayores valores
datos[order(datos$value, decreasing = TRUE), c("geo_id", "value", "value_ori")]

# quiero ver cuantas geo_id hay y cuantos registros tiene cada una.
#Ceuta y Melilla son las que menos registros tienen (84), Canarias y España las que más (142) y el resto 115.

library(dplyr)

datos %>%
  count(geo_id, name = "n_registros")

#filas con NA en value: 
datos %>%
  filter(is.na(value)) %>%
  select(geo_id, indicator_id, date, value, value_ori, dimension_id)

#tenemos un NA en ceuta, uno en Melilla, uno en Canarias y uno en España. 

################################################################################
#DUDA: si tenemos el value_original y el NA está en value, si value es el valor 
#estandarizado, no podemos calcularlo y que dejen de ser NA?
################################################################################


#AGRUPAR POR REGION
resumen_region <- datos %>%
  group_by(geo_id, dimension_id) %>%
  summarise(media = mean(value, na.rm = TRUE))

#pUEDO Ver qué regiones destacan en cada dimensión.

#pUEDO Crear un mapa de calor (heatmap) o gráfico de barras comparando regiones.

#Insight posible: ver qué comunidades tienen mejores resultados ambientales, económicos, etc.

#AGRUPO POR AÑO 
#evolución del valor medio de cada dimensión con el tiempo
resumen_tiempo <- datos %>%
  group_by(date, dimension_id) %>%
  summarise(media = mean(value, na.rm = TRUE))

library(ggplot2)
ggplot(resumen_tiempo, aes(x = date, y = media, color = dimension_id)) +
  geom_line(size = 1) +
  labs(title = "Evolución media por dimensión", y = "Valor medio estandarizado")

#Insight posible: ver si la dimensión ambiental mejora con los años, o si la social/empleo empeora.

#AGRUPAR POR INDICADOR
#calculo la media por indicador y por año
datos %>%
  group_by(indicator_id, date) %>%
  summarise(media = mean(value, na.rm = TRUE))
#veo que indicadores son mas variables (mayor sd)
datos %>%
  group_by(indicator_id) %>%
  summarise(sd_value = sd(value, na.rm = TRUE)) %>%
  arrange(desc(sd_value))
#Insight posible: detectar los indicadores más estables o los que cambian más entre regiones o años.

#CRUCES MAS INTERESANTES
#ranking anual por region
datos %>%
  group_by(date, geo_id) %>%
  summarise(score_medio = mean(value, na.rm = TRUE)) %>%
  arrange(date, desc(score_medio))
#comparar una region con la media nacional
datos %>%
  group_by(date, dimension_id) %>%
  mutate(media_nacional = mean(value, na.rm = TRUE),
         diferencia = value - media_nacional)
#Insight posible: identificar regiones que están sistemáticamente por encima o por debajo de la media en ciertas dimensiones

# ponerme las dudas en un word. y ya le pregutnaremos a Emilio
# hacerme un esquema del estado del arte de ver como dice que hagamos los indicadores


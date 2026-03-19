# Cargar librería
library(COINr)
library(tidyverse)

# Asumiendo que tu tabla está en formato LONG:
# indicator_id, geo_id, date, value

# 1. CONVERTIR A FORMATO WIDE (cada indicador es una columna)
coin_data <- all_data %>%
  select(geo_id, date, indicator_id, value) %>%
  pivot_wider(
    names_from = indicator_id,
    values_from = value,
    id_cols = c(geo_id, date)
  ) %>%
  # 2. RENOMBRAR geo_id a uCode (requerido por COINr)
  rename(uCode = geo_id) %>%
  # 3. CONVERTIR a data.frame
  as.data.frame()

# 4. CREAR METADATOS - MUY IMPORTANTE
iMeta <- data.frame(
  Indicator = colnames(coin_data)[3:ncol(coin_data)],  # Todos excepto uCode y date
  Direction = 1,    # 1 si "más es mejor", -1 si "menos es mejor"
  Weight = 1        # Pesos iguales o personalizados
)

# 5. CREAR OBJETO COIN
COIN <- new_coin(
  iData = coin_data,
  iMeta = iMeta,
  split_to = "all"
)

# Verificar que se creó correctamente
head(COIN$Data$Raw)

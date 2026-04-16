# ============================================================
# pruebas!!!
# PARÁMETRO DE CONTROL
# TRUE  → excluye 2020 (outlier COVID)
# FALSE → incluye 2020
# ============================================================
exclude_2020 <- FALSE

# install.packages(c('shiny.i18n', 'gfonts', 'shinyalert', 'leaflet', 'mapSpain', 'shinyBS', 'grafify', 'ompr', 'ompr.roi', 'ROI.plugin.symphony', 'countrycode', 'shinyvalidate', 'waiter', 'selenider', 'mapview', 'webshot2', 'Amelia', 'naniar', 'archive', 'rsvg', 'SDGdetector'))
# install.packages("src/evastur_0.21.0.tar.gz")
library(evastur)
library(dplyr)
library(tidyr)
library(tidyverse)

dfvar_ImpAmelia <- get_ft_data(
  data_type = "variable",
  .nuts_level = 2, # RECORDAR NUTS=3 SON PROVINCIAS; NUTS=2 SON CCAA
  type_id = tbl(con2, "dt_variables") |>
    distinct(variable_id) |>
    pull(variable_id),
  country = "ES",
  # .source_id = "EVASTUR",
  from_date = "2016-01-01",
  to_date = "2024-12-31"
) |>
  mutate(variable_value_flags = as.character(variable_value_flags))

# Calculamos las agregaciones de provincias a comunidades autónomas y año (en otro script)
source("R/gen_data_local_prov.R")

# Las unimos
dfvar_ImpAmelia <- bind_rows(dfvar_ImpAmelia, df_aggregated_geo) #creo que esto debe ser así, en vez de dfvar_prov

# Calculamos VTRA0009 = VTRA0006 + VTRA0008
df_vtra0009 <- dfvar_ImpAmelia |>
  filter(variable_id %in% c("VTRA0006", "VTRA0008")) |>
  pivot_wider(names_from = variable_id, values_from = variable_value) |>
  mutate(VTRA0009 = VTRA0006 + VTRA0008) |>
  select(-c(VTRA0006, VTRA0008)) |>
  pivot_longer(
    cols = starts_with("VTRA"),
    names_to = "variable_id",
    values_to = "variable_value"
  )

# Lo añadimos a dfvar_ImpAmelia
dfvar_ImpAmelia <- bind_rows(dfvar_ImpAmelia, df_vtra0009)

# ============================================================
# LIMPIEZA POST-AGREGACIÓN: SOLO NUTS 2
# ============================================================

# 1. Cargamos el catálogo oficial de CCAA (NUTS 2) desde la DB
geos_ccaa <- con2 |>
  tbl("dt_geo") |>
  filter(nuts_level == 2, country_iso2_code == "ES") |>
  collect() |>
  select(geo_id) # Nos quedamos solo con la columna de IDs

# 2. Filtramos dfvar_ImpAmelia para que solo contenga IDs de esa lista
# Esto eliminará automáticamente cualquier fila de NUTS 3 (provincias)
dfvar_ImpAmelia <- dfvar_ImpAmelia |>
  inner_join(geos_ccaa, by = "geo_id")

message("INFO: Datos filtrados. Ahora solo trabajamos con NUTS 2.")

# ============================================================
# EXCLUSIÓN OPCIONAL DE 2020
# ============================================================
if (exclude_2020) {
  message("INFO: Excluyendo el año 2020 (outlier COVID) del cálculo del índice.")
  dfvar_ImpAmelia <- dfvar_ImpAmelia |>
    filter(substr(date, 1, 4) != "2020")
}

dfinds_ImpAmelia <- dfvar_ImpAmelia |>
  distinct(variable_id) |>
  pull() |>
  get_computable_inds() |>
  get_indicators_metadata() |>
  filter(stringr::str_starts(indicator_id, "ICUS", negate = TRUE))

# INDICADORES CALCULADOS
cindicators_ImpAmelia <- compute_indicators(dfinds_ImpAmelia, dfvar_ImpAmelia, .geo_group_id = "ESP")

indicators_ImpAmelia <- con2 |>
  tbl("dt_indicators") |>
  inner_join(
    tbl(con2, "bt_indicator_subdimension") |> #añado en dbeaver los tres IAMB10,11,12 que faltan en la tabla
      filter(source_id == "EVASTUR") |>
      select(indicator_id, dimension_id),
    by = "indicator_id"
  ) |>
  select(
    indicator_id,
    dimension_id,
    indicator_original_name,
    indicator_direction,
    indicator_weight
  ) |>
  collect() |>
  semi_join(cindicators_ImpAmelia, by = "indicator_id")

df_indicadoresImpAmelia_completo <- indicators_ImpAmelia |>
  left_join(cindicators_ImpAmelia, by = "indicator_id") |>
  mutate(year = get_period(date, period_id))

geos <- con2 |>
  tbl("dt_geo") |>
  filter(nuts_level == 2, country_iso2_code == "ES") |>
  collect()

# indicators_data <- get_transformed_indicators(
#   dfind,
#   scaling_method = "zscore", # zscore, refval, minmax
#   scaling_type = "time",
#   refvalueq = NULL,
#   geo_total = "ESP"
# )

# ============================================================
# GUARDADO — sufijo automático según el modo elegido
# ============================================================
suffix <- if (exclude_2020) "_no2020" else ""

saveRDS(indicators_ImpAmelia,          paste0("data/indicators_ImpAmelia",          suffix, ".rds"))
saveRDS(cindicators_ImpAmelia,         paste0("data/cindicators_ImpAmelia",         suffix, ".rds"))
saveRDS(geos,                          "data/geos.rds")
saveRDS(df_indicadoresImpAmelia_completo, paste0("data/df_indicadoresImpAmelia_completo", suffix, ".rds"))

message("INFO: Archivos guardados con sufijo '", suffix, "'.")
# install.packages(c('shiny.i18n', 'gfonts', 'shinyalert', 'leaflet', 'mapSpain', 'shinyBS', 'grafify', 'ompr', 'ompr.roi', 'ROI.plugin.symphony', 'countrycode', 'shinyvalidate', 'waiter', 'selenider', 'mapview', 'webshot2', 'Amelia', 'naniar', 'archive', 'rsvg', 'SDGdetector'))
# install.packages("src/evastur_0.21.0.tar.gz")
library(evastur)
library(dplyr)
library(tidyr)
library(tidyverse)

dfvar2016_2024 <- get_ft_data(
  data_type = "variable",
  .nuts_level = 3, #RECORDAR NUTS=3 SON PROVINCIAS; NUTS=2 SON CCAA
  type_id = tbl(con2, "dt_variables") |>
    distinct(variable_id) |>
    pull(variable_id),
  country = "ES",
  # .source_id = "EVASTUR",
  from_date = "2016-01-01",
  to_date = "2024-12-31"
) |>
  mutate(variable_value_flags = as.character(variable_value_flags))


dfvar2016_2024$imputed[dfvar2016_2024$variable_value_flags == "{I}"] <- TRUE
dfvar2016_2024$variable_value[dfvar2016_2024$imputed] <- NA
dfvar2016_2024$variable_value[dfvar2016_2024$variable_value == "NaN"] <- NA

dfinds2016_2024 <- dfvar2016_2024 |>
  distinct(variable_id) |>
  pull() |>
  get_computable_inds() |>
  get_indicators_metadata() |>
  filter(stringr::str_starts(indicator_id, "ICUS", negate = TRUE))


# INDICADORES CALCULADOS
indicadores_calculados2016_2024 <- compute_indicators(dfinds2016_2024, dfvar2016_2024, .geo_group_id = "ESP")


indicators_meta2016_2024 <- con2 |>
  tbl("dt_indicators") |>
  inner_join(
    tbl(con2, "bt_indicator_subdimension") |>
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
  semi_join(indicadores_calculados2016_2024, by = "indicator_id")

df_indicadores2016_2024_completo <- indicators_meta2016_2024 |>
  left_join(indicadores_calculados2016_2024, by = "indicator_id") |>
  mutate(year = get_period(date, period_id))

geos <- con2 |>
  tbl("dt_geo") |>
  filter(nuts_level == 2, country_iso2_code == "ES") |>
  collect()


# indicators_meta2016_2024_data <- get_transformed_indicators_meta2016_2024(
#   dfind,
#   scaling_method = "zscore", # zscore, refval, minmax
#   scaling_type = "time",
#   refvalueq = NULL,
#   geo_total = "ESP"
# )

saveRDS(indicators_meta2016_2024, "data/indicators_meta2016_2024.rds")
saveRDS(indicadores_calculados2016_2024, "data/indicadores_calculados2016_2024.rds")
saveRDS(geos, "data/geos.rds")
saveRDS(df_indicadores2016_2024_completo, "data/df_indicadores2016_2024_completo.rds")

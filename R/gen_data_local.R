# install.packages(c('shiny.i18n', 'gfonts', 'shinyalert', 'leaflet', 'mapSpain', 'shinyBS', 'grafify', 'ompr', 'ompr.roi', 'ROI.plugin.symphony', 'countrycode', 'shinyvalidate', 'waiter', 'selenider', 'mapview', 'webshot2', 'Amelia', 'naniar', 'archive', 'rsvg', 'SDGdetector'))
# install.packages("src/evastur_0.21.0.tar.gz")
library(evastur)
library(dplyr)
library(tidyr)
dfvar <- get_ft_data(
  data_type = "variable",
  .nuts_level = 2,
  type_id = tbl(con2, "dt_variables") |>
    distinct(variable_id) |>
    pull(variable_id),
  country = "ES",
  # .source_id = "EVASTUR",
  from_date = "2011-01-01",
  to_date = "2025-12-31"
) |>
  mutate(variable_value_flags = as.character(variable_value_flags))

dfvar$imputed[dfvar$variable_value_flags == "{I}"] <- TRUE
dfvar$variable_value[dfvar$imputed] <- NA

dfinds <- dfvar |>
  distinct(variable_id) |>
  pull() |>
  get_computable_inds() |>
  get_indicators_metadata() |>
  filter(stringr::str_starts(indicator_id, "ICUS", negate = TRUE))


# INDICADORES CALCULADOS
cindicators <- compute_indicators(dfinds, dfvar, .geo_group_id = "ESP")


indicators <- con2 |>
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
  semi_join(cindicators, by = "indicator_id")

df_indicadores_completo <- indicators |>
  left_join(cindicators, by = "indicator_id") |>
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

saveRDS(indicators, "data/indicators.rds")
saveRDS(cindicators, "data/cindicators.rds")
saveRDS(geos, "data/geos.rds")
saveRDS(df_indicadores_completo, "data/df_indicadores_completo.rds")

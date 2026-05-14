# install.packages(c('shiny.i18n', 'gfonts', 'shinyalert', 'leaflet', 'mapSpain', 'shinyBS', 'grafify', 'ompr', 'ompr.roi', 'ROI.plugin.symphony', 'countrycode', 'shinyvalidate', 'waiter', 'selenider', 'mapview', 'webshot2', 'Amelia', 'naniar', 'archive', 'rsvg', 'SDGdetector'))
# install.packages("src/evastur_0.21.0.tar.gz")
library(evastur)
library(dplyr)
library(tidyr)
library(tidyverse)

dfvar_oecd <- get_ft_data(
  data_type = "variable",
  .nuts_level = 0, #RECORDAR NUTS=3 SON PROVINCIAS; NUTS=2 SON CCAA
  type_id = tbl(con2, "dt_variables") |>
    distinct(variable_id) |>
    pull(variable_id),
  # country = "ES",
  # .source_id = "EVASTUR",
  from_date = "2016-01-01",
  to_date = "2024-12-31"
) |>
  mutate(variable_value_flags = as.character(variable_value_flags))

dfvar_oecd$variable_value[dfvar_oecd$variable_value == "NaN"] <- NA

dfinds_oecd <- dfvar_oecd |>
  distinct(variable_id) |>
  pull() |>
  get_computable_inds() |>
  get_indicators_metadata() |>
  filter(stringr::str_starts(indicator_id, "ICUS", negate = TRUE))


# INDICADORES CALCULADOS
cindicators_oecd <- compute_indicators(dfinds_oecd, dfvar_oecd, .geo_group_id = "ESP")


indicators_oecd <- con2 |>
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
  semi_join(cindicators_oecd, by = "indicator_id")

df_indicadores_completo_oecd <- indicators_oecd |>
  left_join(cindicators_oecd, by = "indicator_id") |>
  mutate(year = get_period(date, period_id))

# df_indicadores_completo |> distinct(indicator_id) |> pull(indicator_id)


df_groups <- tbl(con2, "bt_geo_group") |> 
  filter(geo_group_id == "OECD") |> 
  collect()

oecd_data <- df_indicadores_completo_oecd |> 
  inner_join(df_groups, by = c("geo_id")) 
  
summary(oecd_data$indicator_value)


## grupos de países
tbl(con2, "dt_geo") |> 
  filter(nuts_level == 101)

##países del grupo

tbl(con2, "bt_geo_group") |> 
  filter(geo_group_id == "OECD") |> 
  collect()

saveRDS(indicators_oecd, "data/indicators_oecd.rds")
saveRDS(cindicators_oecd, "data/cindicators_oecd.rds")
#saveRDS(geos, "data/geos.rds")
saveRDS(df_indicadores_completo_oecd, "data/df_indicadores_completo_oecd.rds")


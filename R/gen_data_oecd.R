dfvar <- get_ft_data(
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

# df_indicadores_completo |> distinct(indicator_id) |> pull(indicator_id)


df_groups <- tbl(con2, "bt_geo_group") |> 
  filter(geo_group_id == "OECD") |> 
  collect()

oecd_data <- df_indicadores_completo |> 
  inner_join(df_groups, by = c("geo_id")) 
  
summary(oecd_data$indicator_value)


## grupos de países
tbl(con2, "dt_geo") |> 
  filter(nuts_level == 101)

##países del grupo

tbl(con2, "bt_geo_group") |> 
  filter(geo_group_id == "OECD") |> 
  collect()

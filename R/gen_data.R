# this only works from the evastur project, kept here for the records


devtools::load_all()
dfind <- get_ft_data(
  data_type = "indicator",
  .nuts_level = 2,
  type_id = tbl(con2, "dt_indicators") |>
    distinct(indicator_id) |>
    pull(indicator_id),
  country = "ES",
  .source_id = "EVASTUR",
  from_date = "1900-01-01",
  to_date = "2050-12-31"
)

indicators_data <- get_transformed_indicators(
  dfind,
  scaling_method = "zscore",
  scaling_type = "time",
  refvalueq = NULL,
  geo_total = "ESP"
)

indicators <- con2 |> 
  tbl("dt_indicators") |> 
  select(indicator_id, indicator_original_name, indicator_direction, indicator_weight) |> 
  collect()

saveRDS(indicators, "../../code/tfg_composite_indicators/data/indicators.rds")
saveRDS(indicators_data, "../../code/tfg_composite_indicators/data/indicators_data.rds")
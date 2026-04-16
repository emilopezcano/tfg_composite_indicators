## Tomo datos por provincias, pero quito datos del ISTAC que da datos por islas y es un lío.

dfvar_prov <- get_ft_data(
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
  mutate(variable_value_flags = as.character(variable_value_flags)) |>
  filter(stringr::str_starts(source_id, "ISTAC", negate = TRUE))

## Comunidades y ciudades autónomas
ccaa <- con2 |>
  tbl("dt_geo") |>
  filter(nuts_level == 2, country_iso2_code == "ES") |>
  select(geo_id_ccaa = geo_id, nuts2_code) |>
  collect()

## Provincias, quitando las islas que dan datos por provincia y no por isla.
prov <- con2 |>
  tbl("dt_geo") |>
  filter(
    nuts_level == 3,
    country_iso2_code == "ES"
  ) |>
  select(geo_id_prov = geo_id, nuts2_code, nuts3_code, geo_original_name) |>
  collect() |>
  filter(str_starts(nuts3_code, "ES7", negate = TRUE)) |>
  inner_join(ccaa, by = "nuts2_code")

## Me quedo solo con los datos de provincias

dfvar_prov <- dfvar_prov |>
  semi_join(prov, by = c("geo_id" = "geo_id_prov"))

## Busco agregaciones de variables, primero qué variables tengo en datos.
vars_in_data <- dfvar_prov |>
  distinct(variable_id) |>
  pull(variable_id)

## Funciones de agregación

vars_aggregations <- con2 |>
  tbl("dt_variables") |>
  filter(variable_id %in% vars_in_data) |>
  select(variable_id, variable_aggregation_time, variable_aggregation_geo) |>
  inner_join(
    tbl(con2, "dt_aggregations") |>
      select(aggregation_id, aggregation_rfunction_geo = aggregation_rfunction),
    by = c("variable_aggregation_geo" = "aggregation_id")
  ) |>
  # select(variable_id, variable_aggregation_geo, aggregation_rfunction_geo = aggregation_rfunction) |>
  inner_join(
    tbl(con2, "dt_aggregations") |>
      select(
        aggregation_id,
        aggregation_rfunction_time = aggregation_rfunction
      ),
    by = c("variable_aggregation_time" = "aggregation_id")
  ) |>
  collect()

## Recorro variables y comunidades, agrego por comunidad autónoma y luego por tiempo, para cada variable,
# y junto todo en un dataframe.
df_aggregated_geo <- 1:nrow(vars_aggregations) |>
  map(function(.x) {
    thisvar <- vars_aggregations$variable_id[.x]
    print(paste("Procesando variable", thisvar))

    1:nrow(ccaa) |>
      map(
        function(.y) {
          thisca <- ccaa$geo_id_ccaa[.y]
          print(paste("Procesando comunidad autónoma", thisca))
          df0 <- dfvar_prov |>
            filter(
              variable_id == thisvar,
              geo_id %in%
                (prov |> filter(geo_id_ccaa == thisca) |> pull(geo_id_prov))
            )
          df_agg <- df0 |>
            aggregate_variable_by_geo(
              .variable_id = thisvar,
              aggregation_function = vars_aggregations$aggregation_rfunction_geo[
                .x
              ],
              geo_group_id = thisca
            ) |>
            mutate(total = FALSE)
          df_agg |>
            aggregate_variable_by_time(
              thisvar,
              vars_aggregations$aggregation_rfunction_time[.x]
            ) |>
            mutate(
              period_id = "Y",
              source_id = "EVASTUR-AGGREGATION",
              variable_prov = FALSE,
              variable_secret = FALSE,
              imputed = FALSE,
              imputation_method = NA_character_,
              variable_value_flags = NA_character_,
              source_units = NA_character_

            ) |>
            select(-total)
        }
      )
  }) |>
  bind_rows()

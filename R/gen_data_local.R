# install.packages(c('shiny.i18n', 'gfonts', 'shinyalert', 'leaflet', 'mapSpain', 'shinyBS', 'grafify', 'ompr', 'ompr.roi', 'ROI.plugin.symphony', 'countrycode', 'shinyvalidate', 'waiter', 'selenider', 'mapview', 'webshot2', 'Amelia', 'naniar', 'archive', 'rsvg', 'SDGdetector'))
# install.packages("../evastur_0.21.0.tar.gz")
library(evastur)
library(dplyr)

dfvar <- get_ft_data(
  data_type = "variable",
  .nuts_level = 2,
  type_id = tbl(con2, "dt_variables") |>
    distinct(variable_id) |>
    pull(variable_id),
  country = "ES",
  # .source_id = "EVASTUR",
  from_date = "1900-01-01",
  to_date = "2050-12-31"
)

compute_indicators()

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
  scaling_method = "zscore", # zscore, refval, minmax
  scaling_type = "time",
  refvalueq = NULL,
  geo_total = "ESP"
)


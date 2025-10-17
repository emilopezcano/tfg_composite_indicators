library(dplyr)
indicators <- readRDS("data/indicators.rds")

indicators_data <- readRDS("data/indicators_data.rds")

all_data <- indicators |> 
  inner_join(indicators_data, by = "indicator_id")

## Indicadores en cada dimensión
all_data |> 
  distinct(indicator_id, dimension_id) |> 
  count(dimension_id)

library(tidyverse)
library(COINr)

# --- PASO 1: PREPARAR iData (Multianual) ---
iData <- all_data %>%
  # Importante: COINr para paneles necesita una columna llamada 'Time'
  mutate(Time = as.numeric(format(as.Date(date), "%Y"))) %>% 
  select(uCode = geo_id, Time, indicator_id, value) %>%
  pivot_wider(names_from = indicator_id, values_from = value)

# --- CORRECCIÓN DEL PASO 2: iMeta con columna 'Type' ---

# 2.1. Metadatos de los indicadores (Nivel 1)
iMeta_ind <- all_data %>%
  distinct(indicator_id, indicator_original_name, indicator_direction, indicator_weight, dimension_id) %>%
  select(iCode = indicator_id, 
         iName = indicator_original_name, 
         Direction = indicator_direction, 
         Weight = indicator_weight, 
         Parent = dimension_id) %>%
  mutate(Level = 1,
         Type = "Indicator", # <--- ESTA ES LA QUE FALTABA
         Direction = ifelse(Direction == "+", 1, -1))

# 2.2. Metadatos de las dimensiones (Nivel 2)
iMeta_dim <- iMeta_ind %>%
  distinct(Parent) %>%
  select(iCode = Parent) %>%
  mutate(iName = iCode,
         Direction = 1,
         Weight = 1,
         Parent = "TotalIndex",
         Type = "Aggregate", # <--- TAMBIÉN AQUÍ
         Level = 2)

# 2.3. Metadato del Índice Final (Nivel 3)
iMeta_total <- data.frame(
  iCode = "TotalIndex", 
  iName = "Índice Final", 
  Direction = 1, 
  Weight = 1, 
  Parent = NA, 
  Type = "Aggregate", # <--- Y AQUÍ
  Level = 3
)

# Unir todo
iMeta <- bind_rows(iMeta_ind, iMeta_dim, iMeta_total)

# --- PASO 3: CONSTRUCCIÓN DEL PANEL COIN (VERSIÓN BLINDADA) ---

# 1. Aseguramos que iData sea un data.frame base
iData_clean <- as.data.frame(iData)

# 2. Eliminamos filas con Time = NA (crítico para paneles)
iData_clean <- iData_clean[!is.na(iData_clean$Time), ]

# 3. Sincronización de metadatos
valid_codes <- c(colnames(iData_clean), iMeta$iCode[iMeta$Level > 1])
iMeta_final <- iMeta[iMeta$iCode %in% valid_codes, ]

# 4. Crear el objeto COIN (panel multianual)
years <- sort(unique(iData_clean$Time))

coins <- lapply(years, function(y){
  # Convertimos y a numeric explícitamente
  y <- as.numeric(y)
  
  # Filtrar iData_clean
  iData_y <- iData_clean[iData_clean$Time == y, ]
  
  # Crear coin para ese año
  c <- new_coin(
    iData = iData_y,
    iMeta = iMeta_final,
    level_names = c("Indicador", "Dimensión", "Índice")
  )
  
  Aggregate(c, dset = "Raw", f_ag = "a_amean")
})
names(coins) <- years


message("¡Si has llegado aquí, el problema está resuelto!")

# --- PASO 4: ANÁLISIS DE RESULTADOS ---

library(dplyr)
library(ggplot2)

# ------------------------------------------
# 1. Crear coins por año (ya agregados)
# ------------------------------------------
years <- sort(unique(iData_clean$Time))

coins <- lapply(years, function(y){
  iData_y <- iData_clean[iData_clean$Time == y, ]
  
  c <- new_coin(
    iData = iData_y,
    iMeta = iMeta_final,
    level_names = c("Indicador", "Dimensión", "Índice")
  )
  
  Aggregate(c, dset = "Raw", f_ag = "a_amean")
})
names(coins) <- years

# ------------------------------------------
# A. Ranking del último año (2025)
# ------------------------------------------
res_2025 <- get_results(
  coins[["2025"]],
  dset = "Aggregated",
  tab_type = "Full"
)

# Mostrar top 10 por TotalIndex
res_2025 %>%
  arrange(desc(TotalIndex)) %>%
  head(10)

# ------------------------------------------
# B. Función auxiliar para obtener panel_df
# ------------------------------------------
get_unit_df <- function(coin, unit, year){
  res <- get_unit_summary(
    coin,
    usel = unit,
    Levels = 3,           # Nivel agregado (TotalIndex)
    dset = "Aggregated"
  )
  
  # Detectar la columna de la unidad
  unit_col <- intersect(c("uCode", "Unit", "UnitName", "geo_id"), names(res))
  if(length(unit_col) == 0){
    stop("No se pudo encontrar la columna de unidad en get_unit_summary()")
  }
  
  # Renombrar a uCode
  res <- res %>% rename(uCode = !!unit_col)
  
  # Agregar año
  res$Time <- as.numeric(year)
  
  # Seleccionar solo columnas necesarias
  res %>% select(uCode, Time, TotalIndex)
}

# ------------------------------------------
# C. Evolución temporal de varias unidades
# ------------------------------------------
units <- c("ES-MD", "ES-AN", "ES-IB") # Unidades a comparar

panel_df <- lapply(names(coins), function(y){
  coin <- coins[[y]]
  
  df_list <- lapply(units, function(u){
    get_unit_df(coin, u, y)
  })
  
  bind_rows(df_list)
}) %>% bind_rows()

# Ver los primeros registros
head(panel_df)

# ------------------------------------------
# D. Gráfico de tendencias del TotalIndex
# ------------------------------------------
ggplot(panel_df, aes(x = Time, y = TotalIndex, color = uCode)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  labs(title = "Evolución del TotalIndex por región",
       x = "Año",
       y = "TotalIndex",
       color = "Región") +
  theme_minimal() +
  scale_x_continuous(breaks = years)

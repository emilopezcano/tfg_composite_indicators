# Decisión: ¿Qué Enfoque Usar?

## Resumen Rápido

Has creado dos scripts R que implementan diferentes estrategias para tu análisis:

| Aspecto | Enfoque 1: Por Año | Enfoque 2: Pesos Globales |
|--------|---|---|
| **Script** | `06_pca_pesos_por_dimensión.R` | `07_pca_pesos_globales.R` |
| **Pesos** | Diferentes para cada año | Iguales para todos los años |
| **Caso de uso** | Analizar cambios en estructura | Comparar tendencias con métrica consistente |
| **Comparabilidad** | ⚠️ Año a año puede no ser comparable | ✅ Completamente comparable |
| **Complejidad** | Media | Baja |
| **Interpretación** | "¿Cómo cambiaron las relaciones?" | "¿Cómo cambió el índice?" |

---

## Escenarios de Uso

### 🎯 Usa ENFOQUE 1 (Por Año) si:

- Quieres **detectar cambios en la estructura** de las relaciones entre indicadores
- Tus indicadores **cambian de importancia** año a año (ej: la pandemia cambió todo)
- Quieres hacer un **análisis exploratorio** detallado
- Planeas hacer **análisis de sensibilidad** (comparar resultados con/sin cambios)
- EJEMPLO: "En 2019 el turismo era importante, en 2020-2021 cambió completamente"

**Salida:**
```
results/
├── loadings_ECO_2022.csv     (pesos 2022)
├── loadings_ECO_2023.csv     (pesos 2023 - DIFERENTES)
├── dimension_scores_2022.csv
├── composite_indicator_all_years.csv
```

### 🎯 Usa ENFOQUE 2 (Pesos Globales) si:

- Quieres una **métrica consistente** para comparar años
- Necesitas que **el ranking sea válido** (región A siempre mejor que B)
- La estructura es **relativamente estable** en el tiempo
- Quieres usar el índice para **reportes y comunicación**
- EJEMPLO: "Me importa saber si quedamos mejor o peor cada año, con la misma métrica"

**Salida:**
```
results/
├── global_loadings_ECO.csv    (pesos FIJOS para todos los años)
├── global_loadings_final_dimensions.csv
├── composite_indicator_global_weights.csv
```

---

## Mi Recomendación

### Opción A: Híbrida (RECOMENDADA) 🌟

**Haz ambos y compare:**

1. Ejecuta `06_pca_pesos_por_dimensión.R`
   - Verás cómo cambian los pesos año a año
   - Descubrirás patrones interesantes
   
2. Ejecuta `07_pca_pesos_globales.R`
   - Obtendrás una métrica consistente
   
3. **Compara:**
   - ¿Los dos índices son similares? → Los pesos son estables → Usa Enfoque 2
   - ¿Son muy diferentes? → Hay cambios estructurales → Usa Enfoque 1 con cuidado

### Opción B: Solo Enfoque 1

Si quieres entender cómo **evolucionan las relaciones** entre indicadores.

### Opción C: Solo Enfoque 2

Si necesitas una **métrica simple y comparable** (lo más común en índices sintéticos publicados).

---

## Implementación Paso a Paso

### Paso 1: Instalar paquetes (si no lo has hecho)

```r
source("scripts/00_install_packages.R")
```

### Paso 2: Escoger enfoque y ejecutar

**Opción A1: Enfoque 1 (Por Año)**
```r
source("scripts/06_pca_pesos_por_dimensión.R")
```

**Opción A2: Enfoque 2 (Pesos Globales)**
```r
source("scripts/07_pca_pesos_globales.R")
```

**Opción A3: Ambos**
```r
# Ejecuta los dos en orden
source("scripts/06_pca_pesos_por_dimensión.R")
source("scripts/07_pca_pesos_globales.R")
```

### Paso 3: Revisar resultados

```r
# Para Enfoque 1:
loadings_2022 <- read.csv("results/loadings_ECO_2022.csv")
loadings_2023 <- read.csv("results/loadings_ECO_2023.csv")
# ¿Son diferentes? → cambios estructurales

# Para Enfoque 2:
comp_global <- read.csv("results/composite_indicator_global_weights.csv")
# Rankings consistentes
```

---

## Estructura de Datos de Salida

### Enfoque 1

**`composite_indicator_all_years.csv`**
```
year | region | eco_score | soc_score | env_score | composite_index
2022 | ESP    | 45.23     | 52.14     | 48.56     | 48.64
2023 | ESP    | 46.12     | 53.21     | 49.34     | 49.56
```

**`loadings_ECO_2022.csv`**
```
indicator_id | weight | weight_normalized
IECO0001     | 0.823  | 0.412
IECO0002     | 0.521  | 0.261
...
```

### Enfoque 2

**`composite_indicator_global_weights.csv`**
```
year | region | eco_score | soc_score | env_score | composite_index
2022 | ESP    | 45.10     | 52.05     | 48.42     | 48.50
2023 | ESP    | 46.05     | 53.15     | 49.25     | 49.48
```

**`global_loadings_ECO.csv`** (MISMO para todos los años)
```
indicator_id | weight | weight_normalized
IECO0001     | 0.801  | 0.410
IECO0002     | 0.512  | 0.262
...
```

---

## Preguntas Frecuentes

### P: ¿Qué significan los "pesos"?

R: Los **weights (pesos)** de PC1 son las contribuciones de cada indicador a la componente principal. 
- Peso alto = indicador importante en esa dimensión
- Peso bajo = indicador menos importante

### P: ¿Puedo cambiar el número de años?

R: Sí, edita esta línea en ambos scripts:
```r
# Para exclusion años específicos
df_analysis <- df_analysis %>%
  filter(year >= 2018 & year <= 2024)  # Solo 2018-2024
```

### P: ¿Qué pasa con los NA (valores faltantes)?

R: Los scripts:
1. Eliminan indicadores con >50% de NA
2. Imputan los NA restantes con la media

Puedes cambiar este comportamiento editando la sección "Clean data".

### P: ¿Puedo analizar múltiples regiones?

R: Actualmente los scripts usan solo "ESP" (España total). Para incluir regiones:

```r
# En lugar de:
filter(geo_id == "ESP")

# Usa:
# filter(!geo_id %in% c("ESP"))  # All except Spain total
# O deja que analice TODO
# Y luego agrupa resultados por región
```

### P: ¿Puedo usar dimensiones con distinto número de indicadores?

R: Sí, los scripts manejan dinámicamente cualquier número de indicadores.

---

## Próximos Pasos

1. **Ejecuta uno de los scripts** (recomendado: Enfoque 1 primero)
2. **Revisa los archivos generados** en `results/`
3. **Verifica que los pesos tengan sentido** (¿son los indicadores esperados los más importantes?)
4. **Ajusta si necesario** (cambiar umbral de NA, número de PCs, etc.)
5. **Documenta tus decisiones** en un README o informe

---

## Contacto / Debugging

Si algo no funciona:

1. Verifica que tienes el archivo `data/indConComponentes.csv`
2. Abre la consola de R y busca mensajes de error
3. Ejecuta el script línea por línea (`Ctrl+Enter`) para ver dónde falla
4. Revisa que `results/` exista y sea escribible

¡El código tiene mensajes de diagnóstico (`cat()`) que te dicen qué está pasando!

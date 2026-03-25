# 🚀 INICIO RÁPIDO: PCA para Pesos de Indicadores

## Lo que acabas de recibir

He creado **dos enfoques completos y documentados** para tu análisis PCA:

### 📁 Nuevos Archivos

```
scripts/
├── 06_pca_pesos_por_dimensión.R      ← ENFOQUE 1: Pesos variables por año
├── 07_pca_pesos_globales.R           ← ENFOQUE 2: Pesos fijos globales

Documentación/
├── GUIA_PCA_PESOS.md                 ← Explicación conceptual
├── COMPARACION_ENFOQUES_PCA.md       ← Comparación detallada
├── FLUJO_VISUAL_PCA.md               ← Diagramas de flujo
└── INICIO_RAPIDO.md                  ← Este archivo
```

---

## 3 Minutos: Entender la Diferencia

### Enfoque 1: PCA Por Año (Pesos Variables)
- **Cuándo:** Cada año se calcula un PCA separado
- **Resultado:** Pesos **diferentes** cada año
- **Usa si:** Quieres detectar cambios en importancia de indicadores
- **Ventaja:** Más preciso y flexible
- **Desventaja:** Pesos inconsistentes entre años

**Script:** `06_pca_pesos_por_dimensión.R`

### Enfoque 2: Pesos Globales (Fijos)
- **Cuándo:** Se calcula PCA UNA SOLA VEZ con todos los años
- **Resultado:** Pesos **iguales** para todos los años
- **Usa si:** Necesitas comparación válida entre años
- **Ventaja:** Simple y consistente
- **Desventaja:** Rígido, asume estabilidad

**Script:** `07_pca_pesos_globales.R`

---

## Ejecutar Paso a Paso

### Paso 0: Verificar datos

Abre RStudio y verifica que el archivo de datos existe:

```r
# En RStudio:
list.files("data/")  # Debe mostrar: indConComponentes.csv
```

### Paso 1: Instalar paquetes (primera vez)

```r
# En RStudio Console:
source("scripts/00_install_packages.R")
```

Espera a que termine (puede tomar 2-3 minutos).

### Paso 2a: RECOMENDADO - Ejecutar Enfoque 1 primero

```r
# En RStudio:
source("scripts/06_pca_pesos_por_dimensión.R")
```

El script mostrará progreso. Debería terminar en ~30 segundos.

**Output esperado:**
```
results/
├── composite_indicator_all_years.csv  ← ARCHIVO PRINCIPAL
├── loadings_ECO_2022.csv
├── loadings_ECO_2023.csv
├── loadings_ECO_2024.csv
├── loadings_SOC_2022.csv
├── loadings_SOC_2023.csv
├── loadings_SOC_2024.csv
├── dimension_scores_2022.csv
├── dimension_scores_2023.csv
├── dimension_scores_2024.csv
├── 01_evolution_composite_index.png
└── 02_dimensions_contribution.png
```

### Paso 2b: Opcional - Ejecutar Enfoque 2 para comparar

```r
# En RStudio:
source("scripts/07_pca_pesos_globales.R")
```

**Output esperado:**
```
results/
├── composite_indicator_global_weights.csv  ← ARCHIVO PRINCIPAL
├── global_loadings_ECO.csv
├── global_loadings_SOC.csv
├── global_loadings_final_dimensions.csv
└── 03_evolution_global_weights.png
```

### Paso 3: Revisar resultados

```r
# En RStudio:

# Para Enfoque 1:
comp1 <- read.csv("results/composite_indicator_all_years.csv")
print(comp1)

# Para Enfoque 2:
comp2 <- read.csv("results/composite_indicator_global_weights.csv")
print(comp2)

# Comparar visualmente:
plot(comp1$year, comp1$composite_index, ylim=c(0,100), main="Índices")
lines(comp2$year, comp2$composite_index, col="red")
legend("topright", c("Enfoque 1", "Enfoque 2"), col=c("black","red"), lty=1)
```

### Paso 4: Verificar pesos

```r
# Ver pesos de indicadores (Enfoque 1, año 2022):
loadings_eco <- read.csv("results/loadings_ECO_2022.csv")
print(loadings_eco)

# Ver pesos globales (Enfoque 2, para TODOS los años):
global_eco <- read.csv("results/global_loadings_ECO.csv")
print(global_eco)

# ¿Son parecidos? → Usa Enfoque 2 (más simple)
# ¿Son muy diferentes? → Usa Enfoque 1 (más preciso)
```

---

## Próximas Decisiones

### 1. ¿Cuál enfoque usar?

| Caso | Recomendación |
|------|---|
| Quiero la solución más simple | **Enfoque 2** |
| Quiero análisis detallado | **Enfoque 1** |
| No estoy seguro | **Ejecuta ambos y compara** |
| Necesito pesos para reportes | **Enfoque 2** |
| Quiero ver cambios temporales | **Enfoque 1** |

### 2. ¿Incluir múltiples regiones?

Actualmente: Solo España (ESP)

Para agregar regiones, edita la línea en ambos scripts:
```r
# Línea actual:
filter(geo_id == "ESP")

# Para incluir todas las regiones:
# filter(geo_id != "ESP")  # Todo menos España total
```

Luego el output tendrá columnas adicionales por región.

### 3. ¿Cambiar el período de años?

Lee la sección "Próximos pasos" en ambos scripts. 

Búsca:
```r
years_to_analyze <- sort(unique(df_analysis$year))
```

O filtra antes:
```r
df_analysis <- df_analysis %>%
  filter(year >= 2020)  # Solo 2020 en adelante
```

---

## Validación: ¿Está funcionando?

✅ **Visto bueno:**
- El script muestra progreso (líneas con "📊 Dimensión:", etc.)
- Se crean archivos en `results/`
- Los números tienen sentido (índices entre 0-100)
- Los pesos suman ~1.0

❌ **Problemas comunes:**

| Error | Solución |
|-------|----------|
| "File not found" | Verificar que `data/indConComponentes.csv` existe |
| "Package not found" | Ejecutar `source("scripts/00_install_packages.R")` |
| Índices fuera de rango | Normal si datos son extremos; revisar escalado |
| Archivos vacíos | Revisar que hay datos para esos años |
| Pesos sumando ~1.0 | Normal (weights normalizados) |

---

## ¿Qué significan los outputs?

### `composite_indicator_all_years.csv`

```
year │ region │ eco_score │ soc_score │ env_score │ composite_index
─────┼────────┼───────────┼───────────┼───────────┼─────────────────
2022 │   ESP  │   45.23   │   52.14   │   48.56   │   48.64
2023 │   ESP  │   46.12   │   53.21   │   49.34   │   49.56
2024 │   ESP  │   47.05   │   54.10   │   50.25   │   50.47
```

- **eco_score, soc_score, env_score:** Índice por dimensión (0-100)
- **composite_index:** Índice final combinado

### `loadings_ECO_2022.csv`

```
indicator_id       │ weight │ weight_normalized
─────────────────────┼────────┼────────────────────
IECO0001            │ 0.823  │ 0.412
IECO0002            │ 0.521  │ 0.261
IECO0003            │ 0.478  │ 0.239
IECO0004            │ 0.398  │ 0.199
```

- **weight:** Carga en PC1 (valor bruto)
- **weight_normalized:** Peso normalizado (suma 1.0)
  - Use este para aplicar manualmente

### `global_loadings_ECO.csv`

```
indicator_id       │ weight │ weight_normalized
─────────────────────┼────────┼────────────────────
IECO0001            │ 0.801  │ 0.410
IECO0002            │ 0.512  │ 0.262
IECO0003            │ 0.490  │ 0.251
IECO0004            │ 0.405  │ 0.207
```

**MISMO para todos los años** (a diferencia del Enfoque 1)

---

## Interpretación de Resultados

### ¿Los pesos tienen sentido?

Pregúntate:
- ¿Las variables más importantes tienen pesos altos? → ✅ Correcto
- ¿Las variables ruido tienen pesos bajos? → ✅ Correcto
- ¿Los pesos varían entre años en Enfoque 1? → ✅ Normal (detecta cambios)
- ¿Los pesos son iguales entre años en Enfoque 2? → ✅ Esperado

### ¿El índice final es creíble?

- ¿Sube y baja de forma coherente? → ✅ Probablemente bien
- ¿Refleja cambios en tus datos originales? → ✅ Bien
- ¿Es constante (no cambia)? → ⚠️ Revisa los datos
- ¿Tiene valores extremos? → Puede ser válido; revisa outliers

---

## Personalización: Ajustar Scripts

### Cambiar el umbral de NA

```r
# En ambos scripts, busca:
select(where(~mean(is.na(.)) <= 0.5))

# Cambia 0.5 a:
# 0.3 → más estricto (elimina variables con >30% NA)
# 0.7 → más permisivo (tolera >70% NA)
```

### Cambiar el método de imputación

```r
# En lugar de media:
mutate(across(everything(), ~ifelse(is.na(.), mean(., na.rm = TRUE), .)))

# Usa mediana:
mutate(across(everything(), ~ifelse(is.na(.), median(., na.rm = TRUE), .)))

# O elimina filas con NA:
drop_na()
```

### Usar más componentes principales

```r
# Actual:
n_comps <- min(2, ncol(pca_data_clean) - 1)

# Para usar 3 componentes:
n_comps <- min(3, ncol(pca_data_clean) - 1)
```

---

## Resumen Ejecutivo (para presentar)

**¿De qué trata esto?**

He creado un análisis de Componentes Principales (PCA) para:
1. Identificar la **importancia relativa** de cada indicador dentro de su dimensión
2. **Agregar indicadores** en scores por dimensión, usando pesos PCA
3. **Combinar dimensiones** en un índice sintético final
4. **Gestionar múltiples años** de datos con dos enfoques:
   - Enfoque 1: Pesos dinámicos (cambian cada año)
   - Enfoque 2: Pesos fijos (consistentes para comparación temporal)

**¿Cuál usar?**

- Para **reportes y comparación:** Enfoque 2 (pesos globales)
- Para **investigación detallada:** Enfoque 1 (pesos por año)

**¿Qué obtengo?**

- Índice sintético (0-100) para cada año
- Pesos de cada indicador (archivo CSV)
- Visualizaciones de evolución temporal
- Validación de estructura de datos

---

## Preguntas Finales

¿Te gustaría que:

1. ✅ Agregue análisis de múltiples regiones en lugar de solo ESP?
2. ✅ Cree visualizaciones adicionales (heatmaps, dendogramas)?
3. ✅ Implemente validación cruzada para robustecer pesos?
4. ✅ Agregue análisis de sensibilidad (cambios si excluyes variables)?
5. ✅ Cree un dashboard interactivo (Shiny)?

¡Avísame si necesitas ajustes!

---

## Cheat Sheet Rápido

```r
# Instalar paquetes
source("scripts/00_install_packages.R")

# Enfoque 1: Pesos por año
source("scripts/06_pca_pesos_por_dimensión.R")

# Enfoque 2: Pesos globales
source("scripts/07_pca_pesos_globales.R")

# Ver resultados
comp <- read.csv("results/composite_indicator_all_years.csv")
print(comp)

# Ver pesos
loadings <- read.csv("results/loadings_ECO_2022.csv")
print(loadings)
```

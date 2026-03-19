# 📊 PCA BY YEAR - GUÍA COMPLETA

## 🎯 ¿Qué cambió?

**Antes (análisis anterior):**
```
Todos los años juntos → 1 PCA por dimensión → 1 PCA final
Resultado: 1 indicador compuesto (promedio de todos los años)
```

**Ahora (nuevo flujo):**
```
2022: PCA(ECO 2022) + PCA(SOC 2022) + PCA(ENV 2022) → Indicador 2022
2023: PCA(ECO 2023) + PCA(SOC 2023) + PCA(ENV 2023) → Indicador 2023
2024: PCA(ECO 2024) + PCA(SOC 2024) + PCA(ENV 2024) → Indicador 2024
...
Resultado: Un indicador compuesto DIFERENTE para cada año
```

---

## 📂 Carpetas que se crearán

```
pruebasR/
├── results/                    ← Carpeta original (vacía ahora)
├── results_2022/              ← Nuevas carpetas por año
│   ├── composite_indicator_2022.csv
│   ├── loadings_ECO_2022.csv
│   ├── loadings_SOC_2022.csv
│   └── 01_distribution_2022.png
├── results_2023/
│   ├── composite_indicator_2023.csv
│   └── ...
└── results_2024/
    └── ...
```

---

## 🚀 PASO 1: Ejecutar SOLO el año 2022 (ejemplo)

1. Abre RStudio
2. Abre el archivo: **`scripts/04_pca_by_year_EXAMPLE_2022.R`**
3. Selecciona TODO el código (Ctrl+A)
4. Ejecuta (Ctrl+Enter)
5. Verás en consola:
   - Datos cargados para 2022
   - PCA por dimensión
   - Indicador compuesto final
   - Gráficos guardados

### Resultado:
- Nueva carpeta: `results_2022/`
- Archivos:
  - `composite_indicator_2022.csv` ← **Tus puntuaciones para 2022**
  - `loadings_ECO_2022.csv`, `loadings_SOC_2022.csv`, etc.
  - `01_distribution_2022.png`, `02_rankings_2022.png`

---

## 🔄 PASO 2: Hacer lo mismo para 2023

**Opción A: Copiar y modificar (manual)**

1. Abre: `scripts/04_pca_by_year_EXAMPLE_2022.R`
2. Presiona Ctrl+H (Find & Replace)
3. Busca: `2022`
4. Reemplaza con: `2023`
5. Ejecuta

**Opción B: Script automático (recomendado)**

1. Abre: `scripts/05_pca_batch_all_years.R`
2. En la línea ~40, encuentra:
```r
# OPTION 2: Analyze ALL years (comment out above and uncomment below)
years_to_analyze <- available_years
```
3. Descomenta esa línea (quita el `#`)
4. Comenta la línea anterior:
```r
# OPTION 1: Analyze SPECIFIC years (uncomment and modify)
# years_to_analyze <- c(2022, 2023)
```
5. Ejecuta Ctrl+A, luego Ctrl+Enter
6. ¡Listo! Hace todos los años automáticamente

---

## 📊 Entendiendo los archivos CSV generados

### `composite_indicator_2022.csv`

```csv
region,year,composite_index,composite_index_normalized
ES-AN,2022,-0.45,29.87
ES-AR,2022,0.12,40.22
ES-IB,2022,1.35,61.53
...
```

**Cómo leerlo:**
- `region`: Código de región
- `year`: 2022
- `composite_index`: Valor estandarizado (media ≈ 0)
- `composite_index_normalized`: ← **ESTE ES EL QUE USAS (0-100)**

**Ejemplo:**
- ES-IB en 2022 scored **61.53/100** (muy bueno)
- ES-AN en 2022 scored **29.87/100** (malo)
- Puedes comparar: ¿ES-IB mejoró en 2023?

---

### `loadings_ECO_2022.csv` (por cada dimensión)

```csv
indicator,PC1,PC2,PC3
IECO0001,25.78,1.03,1.57
IECO0002,21.30,6.35,10.10
IECO0005,4.79,29.12,50.05
```

**Cómo leerlo:**
- Números altos (>20) = indicador importante
- PC1 = componente más importante
- Muestra qué indicadores "pesan" en la dimensión económica 2022

---

### `loadings_final_2022.csv`

```csv
dimension,PC1,PC2,PC3
ECO_PC1,35.42,12.34,5.67
ECO_PC2,22.11,48.93,10.02
SOC_PC1,42.47,5.21,3.45
...
```

**Cómo leerlo:**
- Muestra cómo cada componente de dimensión contribuye al indicador final
- Valores altos = esa dimensión es importante en 2022
- Ejemplo: `ECO_PC1` con 35.42 significa que la dimensión económica (su primer PC) es MUY importante en 2022

---

## 📈 Script Batch (Procesar TODOS los años)

Usa `scripts/05_pca_batch_all_years.R` para:

1. **Procesar todos los años automáticamente**
2. **Crear carpeta `results/COMBINED_composite_indicators_all_years.csv`** con todos los años juntos
3. **Gráfico de comparación**: `comparison_across_years.png` (evolución de puntuación media)

### Pasos:

1. Abre RStudio
2. Abre: `scripts/05_pca_batch_all_years.R`
3. Línea ~40: Descomenta `years_to_analyze <- available_years`
4. Ejecuta Ctrl+A, Ctrl+Enter
5. Espera a que termine
6. Verás en consola que procesa 2016, 2017, 2018, etc.
7. Resultado: Carpetas `results_2016/`, `results_2017/`, etc.

---

## ✅ Resumen de pasos

### Para el ejemplo 2022:
1. Ejecuta `scripts/04_pca_by_year_EXAMPLE_2022.R`
2. Explora `results_2022/composite_indicator_2022.csv`
3. Entiende las puntuaciones

### Para otros años (una opción):

**Opción 1: Manual (uno a uno)**
- Copia 04_pca_by_year_EXAMPLE_2022.R
- Renómbralo a 04_pca_by_year_2023.R
- Reemplaza 2022 → 2023
- Ejecuta

**Opción 2: Script batch (todos juntos)**
- Usa 05_pca_batch_all_years.R
- Descomenta `years_to_analyze <- available_years`
- Ejecuta
- Procesa TODOS los años automáticamente

---

## 🎓 Interpretando resultados

### Antes vs Después (por región)

Tienes `results_2022/composite_indicator_2022.csv` y `results_2023/composite_indicator_2023.csv`

Puedes comparar:
```
ES-IB:  2022 = 61.53   →   2023 = 58.20  (bajó 3.33 puntos)
ES-AN:  2022 = 29.87   →   2023 = 35.41  (subió 5.54 puntos - ¡mejoró!)
```

### Evolución temporal

Con el script batch, obtienes `COMBINED_composite_indicators_all_years.csv`:
```
region,year,composite_index,composite_index_normalized
ES-AN,2016,...,35.20
ES-AN,2017,...,32.10
ES-AN,2018,...,38.50
...
```

Esto te permite:
- Hacer gráficos de tendencia por región
- Ver si tu indicador mejora o empeora en el tiempo
- Análisis de correlación con otras variables

---

## 🔧 Troubleshooting

### "❌ PCA NOT POSSIBLE: Only 1 indicator(s)"

**Significa:**
- Esa dimensión en ese año solo tiene 1 indicador con datos válidos
- PCA necesita al menos 2

**Solución:**
- Baja el umbral de datos faltantes en el código (línea ~120):
```r
select(where(~mean(is.na(.)) <= 0.7))  # En lugar de 0.5
```

### "❌ Could not complete year XXXX"

**Significa:**
- No hay suficientes dimensiones (necesita ≥2)
- Muy pocas regiones con datos completos

**Solución:**
- Revisa los datos de ese año en el CSV
- Quizás falta data ese año

### "Error: 'composite_indicator_normalized' doesn't exist"

Asegúrate que:
- Las librerías están instaladas: `install.packages("scales")`
- Ejecutas el código en orden (sin saltar secciones)

---

## 📚 Archivo a explorar después

Una vez que entiendas el 2022:

1. Ejecuta `scripts/05_pca_batch_all_years.R` para todos
2. Abre el CSV combinado: `COMBINED_composite_indicators_all_years.csv`
3. Ejecuta `scripts/02_post_analysis_examples.R` para análisis avanzados (rankings, tendencias, etc.)

---

## 🎯 Checklist de completitud

- [ ] ✓ Ejecuté `04_pca_by_year_EXAMPLE_2022.R`
- [ ] ✓ Vi que se creó `results_2022/`
- [ ] ✓ Abrí `results_2022/composite_indicator_2022.csv` en Excel
- [ ] ✓ Entendí cuál es la puntuación (normalized 0-100)
- [ ] ✓ Entendí qué son los loadings
- [ ] ✓ Listo para intentar 2023 y otros años

---

**¿Preguntas?** Consulta los comentarios en el código (tienen # explicaciones)

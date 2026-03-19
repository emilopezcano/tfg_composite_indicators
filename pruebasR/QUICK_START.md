# ⚡ QUICK START - PCA BY YEAR (v2.0)

## 👉 LO QUE NECESITAS HACER AHORA

### 1️⃣ Ejecuta el EJEMPLO para 2022 (5 minutos)

```
Abre RStudio
  ↓
Abre: scripts/04_pca_by_year_EXAMPLE_2022.R
  ↓
Ctrl+A (selecciona todo)
  ↓
Ctrl+Enter (ejecuta)
  ↓
Espera output en consola
  ↓
Abre carpeta results_2022/ con tus resultados ✓
```

**Qué pasará:**
- Se crearán archivos en `results_2022/`
- Verás puntuaciones para cada región (0-100)
- Es exactamente lo que quieres, pero solo para 2022

---

### 2️⃣ Entiende los resultados

Abre en Excel: `results_2022/composite_indicator_2022.csv`

```
region  | year | composite_index_normalized
ES-AN   | 2022 | 29.87
ES-IB   | 2022 | 61.53
ES-VC   | 2022 | 49.80
...
```

**Esto significa:**
- ES-IB en 2022 scored **61.53/100** (BUENO)
- ES-AN en 2022 scored **29.87/100** (MALO)

---

### 3️⃣ Haz lo mismo para otros años (OPCIÓN A: Manual)

Para 2023:

```
Abre: scripts/04_pca_by_year_EXAMPLE_2022.R
  ↓
Presiona: Ctrl+H (Find & Replace)
  ↓
Find:    2022
Replace: 2023
  ↓
Replace All
  ↓
Ctrl+A, Ctrl+Enter
  ↓
✓ Resultados en results_2023/
```

Repite para 2024, 2025, etc.

---

### 3️⃣ Haz TODOS los años JUNTOS (OPCIÓN B: Automático - RECOMENDADO)

```
Abre RStudio
  ↓
Abre: scripts/05_pca_batch_all_years.R
  ↓
Ctrl+A (selecciona todo)
  ↓
Ctrl+Enter (ejecuta)
  ↓
Espera (procesa 2016, 2017, 2018, ... automáticamente)
  ↓
✓ results_2022/, results_2023/, etc. creadas
✓ COMBINED_composite_indicators_all_years.csv creado
```

Este archivo combinado es PERFECTO para:
- Gráficos de evolución temporal
- Rankings por año
- Análisis de cambios

---

## 📊 Archivos generados

### Después de ejecutar script 04 (2022):

```
results_2022/
├── composite_indicator_2022.csv    ← Tus puntuaciones (LO IMPORTANTE)
├── loadings_ECO_2022.csv           ← Documentación técnica
├── loadings_SOC_2022.csv           ← Documentación técnica
├── loadings_final_2022.csv         ← Documentación técnica
├── 01_distribution_2022.png        ← Gráfico
└── 02_rankings_2022.png            ← Gráfico
```

### Después de ejecutar script 05 (todos los años):

```
results/
├── COMBINED_composite_indicators_all_years.csv  ← IMPORTANTE: todos los años
└── comparison_across_years.png                  ← Gráfico evolución

results_2016/
results_2017/
results_2018/
...
results_2023/
results_2024/
```

---

## 🎯 Diferencia con el análisis anterior

| Análisis anterior (script 01) | Nuevo (scripts 04-05) |
|------|------|
| Todos los años mezclados | Cada año por separado |
| 1 indicador compuesto general | 1 indicador compuesto POR AÑO |
| "`results/`" | "`results_2022/`, `results_2023/`", etc. |
| No ves evolución temporal | Ves cómo cambia cada región en el tiempo |

---

## 📈 Ejemplo: Analizar cambios temporales

Con el script 05 (todos los años):

Puedes ver:
```
ES-IB:  2022=61.53  →  2023=58.20  →  2024=55.10  (tendencia: bajando)
ES-AN:  2022=29.87  →  2023=35.41  →  2024=42.50  (tendencia: mejorando ✓)
```

Ahora ves EVOLUCIÓN, no solo una foto de un año.

---

## ✅ CHECKLIST: Estoy listo si...

- [ ] Instalé los paquetes (ejecuté script 00 hace tiempo)
- [ ] La carpeta `data/` tiene `indConComponentes.csv`
- [ ] Entiendo que voy a ejecutar script 04 para 2022
- [ ] Sé abrir `results_2022/composite_indicator_2022.csv` en Excel
- [ ] Entiendo que las puntuaciones son 0-100

**Si marcaste TODO:** ¡ESTÁS LISTO! Ejecuta script 04 ahora.

---

## 🚨 Si algo no funciona

### Error: "Could not find package..."
```r
source("scripts/00_install_packages.R")
```

### Error: "No input file..."
Asegúrate que `data/indConComponentes.csv` está en la carpeta `data/`.

### Error: "PCA NOT POSSIBLE"
Eso es NORMAL algunas veces. Significa esa dimensión no tiene datos suficientes en ese año.

---

## 📚 Documentación completa

- **GUIA_PCA_BY_YEAR.md** ← Lee esto para entender TODO
- **EXPLICACION_ARCHIVOS.md** ← Qué es cada archivo .csv
- **Scripts tienen comentarios** ← Lee los comentarios #

---

## 🎬 ACCIÓN INMEDIATA

1. **AHORA:** Abre `scripts/04_pca_by_year_EXAMPLE_2022.R`
2. **Ejecuta** (Ctrl+A, Ctrl+Enter)
3. **Abre** `results_2022/composite_indicator_2022.csv`
4. **Verifica** que ves puntuaciones (0-100)
5. **¡ÉXITO!** Ya entiendes el nuevo flujo

Luego intentas 2023, 2024, etc. siguiendo la OPCIÓN A o B de arriba.

---

**¿Preguntas?** Consulta GUIA_PCA_BY_YEAR.md

Vamos! 🚀

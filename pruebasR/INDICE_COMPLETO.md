# 📚 ÍNDICE COMPLETO DE ARCHIVOS

## 🎯 ARCHIVOS NUEVOS (v2.0 - PCA by Year)

Creados específicamente para hacer PCA separado por cada año.

### ⭐ Documentación (Lee estos primero)

| Archivo | Qué es | Cuándo leer |
|---------|--------|------------|
| **QUICK_START.md** | Guía rápida, 5 pasos | PRIMERO - Inicio |
| **GUIA_PCA_BY_YEAR.md** | Guía completa detallada | Después de Quick Start |
| **PASO_A_PASO_VISUAL.md** | Ejemplo visual de qué verás | Antes de ejecutar script 04 |
| **COMPARACION_ANTES_DESPUES.md** | Diferencia con análisis anterior | Para entender cambios |

### ⚙️ Scripts R (Ejecuta estos)

| Script | Qué hace | Cuándo usar |
|--------|----------|-----------|
| **scripts/04_pca_by_year_EXAMPLE_2022.R** | PCA para AÑO ESPECÍFICO (2022) | Para probar/entender el concepto |
| **scripts/05_pca_batch_all_years.R** | PCA para TODOS los años automáticamente | Cuando quieres procesar 2016-2024 |

---

## 📂 ARCHIVOS ANTIGUOS (v1.0)

Siguen siendo útiles para otros análisis.

| Script | Qué hace |
|--------|----------|
| **scripts/00_install_packages.R** | Instala dependencias (ejecutar 1 sola vez) |
| **scripts/01_pca_analysis.R** | PCA GLOBAL (all years mixed) |
| **scripts/02_post_analysis_examples.R** | Análisis adicionales |
| **scripts/03_diagnostic_check.R** | Diagnóstico de data |
| **EXPLICACION_ARCHIVOS.md** | Qué son los CSV/PNG generados |
| **README.md** | Documentación general del proyecto |
| **config.R** | Configuración personalizable |

---

## 🚀 FLUJO RECOMENDADO

### Primero (Hoy -> Esta semana)
1. Leer: **QUICK_START.md** (5 min)
2. Ejecutar: **scripts/00_install_packages.R** (si no lo hiciste antes)
3. Ejecutar: **scripts/04_pca_by_year_EXAMPLE_2022.R**
4. Verificar: `results_2022/composite_indicator_2022.csv` (en Excel)
5. Leer: **PASO_A_PASO_VISUAL.md** para entender cómo continuarl

### Después (Una vez entiendas 2022)
1. Leer: **GUIA_PCA_BY_YEAR.md** (completa)
2. Ejecutar: **scripts/05_pca_batch_all_years.R** (procesa 2016-2024)
3. Analizar: `results/COMBINED_composite_indicators_all_years.csv`

### Opcional (Análisis avanzado)
- Ejecutar: **scripts/02_post_analysis_examples.R**
- Crear visualizaciones personalizadas

---

## 📊 ARCHIVOS GENERADOS (Outputs)

Una vez que ejecutes los scripts, se crean:

### Por año (Ejemplo 2022):
```
results_2022/
├── composite_indicator_2022.csv    ← PRINCIPALES
├── loadings_ECO_2022.csv
├── loadings_SOC_2022.csv
├── loadings_ENV_2022.csv (si existe)
├── loadings_final_2022.csv
├── 01_distribution_2022.png
└── 02_rankings_2022.png
```

### Combinado (Todos los años):
```
results/
├── COMBINED_composite_indicators_all_years.csv ← IMPORTANTE
└── comparison_across_years.png
```

---

## 🗺️ MAPA DE NAVEGACIÓN

```
Empiezas aquí:
    ↓
    QUICK_START.md (este archivo te dice todo)
    ↓
    ↙         ↘
[Probar]      [Entender]
   ↓             ↓
Script 04 → PASO_A_PASO_VISUAL.md
   ↓             ↓
results_2022/   ↓ (entiendes?)
   ↓             ↓
   ↘         ↙
    GUIA_PCA_BY_YEAR.md
    ↓
    Script 05 (todos los años)
    ↓
    COMBINED_composite_indicators_all_years.csv
    ↓
    ¡ÉXITO! Ya tienes todo
```

---

## 💾 Archivos por contenido

### 📝 Guías de usuario (Markdown)
- QUICK_START.md
- GUIA_PCA_BY_YEAR.md
- PASO_A_PASO_VISUAL.md
- COMPARACION_ANTES_DESPUES.md
- EXPLICACION_ARCHIVOS.md (antigua)
- README.md (general del proyecto)

### 💻 Scripts R
- Instalación/Configuración:
  - 00_install_packages.R
  - config.R
  
- PCA por año (NUEVO):
  - 04_pca_by_year_EXAMPLE_2022.R ⭐
  - 05_pca_batch_all_years.R ⭐
  
- PCA global (viejo):
  - 01_pca_analysis.R
  
- Análisis:
  - 02_post_analysis_examples.R
  - 03_diagnostic_check.R

### 📊 Resultados (después de ejecutar)
- CSV de variables:
  - composite_indicator_YYYY.csv
  - COMBINED_composite_indicators_all_years.csv
  - loadings_DIMENSION_YYYY.csv
  - loadings_final_YYYY.csv

- Gráficos:
  - 01_distribution_YYYY.png
  - 02_rankings_YYYY.png
  - comparison_across_years.png

---

## ⚡ TL;DR (Super rápido)

**Hoy:**
1. Leer 3 min: QUICK_START.md
2. Ejecutar: scripts/04_pca_by_year_EXAMPLE_2022.R
3. Verificar: results_2022/ tiene archivos

**Esta semana:**
1. Leer: GUIA_PCA_BY_YEAR.md
2. Ejecutar: scripts/05_pca_batch_all_years.R
3. Analizar: COMBINED_composite_indicators_all_years.csv

**Listo!** Ya tienes indicadores por año para tus análisis.

---

## 🎯 Preguntas frecuentes

**P: ¿Dónde empiezo?**
R: QUICK_START.md

**P: ¿Script 04 o 05?**
R: 04 para probar (2022 solo), 05 para todos (más lento pero completo)

**P: ¿Qué archivo es el importante?**
R: `composite_indicator_YYYY.csv` - contiene tus puntuaciones

**P: ¿Diferencia entre v1 y v2?**
R: Ver COMPARACION_ANTES_DESPUES.md

**P: He ejecutado 04 ahora qué?**
R: Leer PASO_A_PASO_VISUAL.md para entender outputs

**P: Quiero procesar 2023, 2024, etc.**
R: Script 05 automáticamente o copiar/modificar script 04

---

## 🏆 Checklist: He completado v2.0 si...

- [ ] Leí QUICK_START.md
- [ ] Ejecuté script 04 exitosamente
- [ ] Abrí results_2022/composite_indicator_2022.csv en Excel
- [ ] Vi puntuaciones 0-100 para cada región
- [ ] Entiendo qué son los loadings
- [ ] Listo para intentar script 05

**Si marcaste TODO:** ¡Bienvenido a v2.0! 🎉

---

**Última actualización:** Febrero 2026
**Versión:** 2.0 (PCA by Year)
**Estado:** ✅ Completo y listo para usar

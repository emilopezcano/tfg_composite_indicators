# 👀 PASO A PASO: Qué verás cuando ejecutes Script 04

## 📺 Output en Consola (Ejemplo Real)

Cuando ejecutes `scripts/04_pca_by_year_EXAMPLE_2022.R`, verás esto:

```
================================================================================
PCA ANALYSIS FOR YEAR: 2022
================================================================================

Data loaded and filtered for year 2022 
Total observations: 456 
Regions available: 19 
Dimensions: ECO, SOC, ENV 

================================================================================
PCA FOR DIMENSION: ECO | YEAR: 2022
================================================================================

Indicators in ECO : 6
[1] "IECO0001" "IECO0002" "IECO0005" "IECO0009" "IECO0018" "IECO0019"

Data availability by indicator:
      indicator n_valid total missing_pct        status
1      IECO0001      19     19         0.0 ✓ KEEP
2      IECO0002      19     19         0.0 ✓ KEEP
3      IECO0005      19     19         0.0 ✓ KEEP
4      IECO0009      19     19         0.0 ✓ KEEP
5      IECO0018      19     19         0.0 ✓ KEEP
6      IECO0019      18     19         5.3 ✓ KEEP

After cleanup: 6 indicators

✓ PCA performed successfully

Variance explained by Principal Components:
  PC Variance_Explained_Pct Cumulative_Pct
1  1                   47.23          47.23
2  2                   22.15          69.38
3  3                   15.82          85.20

Top contributing indicators to PC1:
IECO0001 IECO0002 IECO0018 IECO0019 IECO0005 
    25.79    21.30    25.28    20.44     4.79 

✓ Saved: loadings_ECO_2022.csv

================================================================================
PCA FOR DIMENSION: SOC | YEAR: 2022
================================================================================

[Similar output for SOC...]

✓ Saved: loadings_SOC_2022.csv

================================================================================
FINAL PCA: AGGREGATING DIMENSIONS | YEAR: 2022
================================================================================

Dimensions in final PCA: 6
Regions with complete data: 19

✓ Final PCA completed

Variance explained by Principal Components:
  PC Variance_Explained_Pct Cumulative_Pct
1  1                   56.34          56.34
2  2                   28.11          84.45
3  3                   15.55         100.00

Contribution of dimensions to PC1:
ECO_PC1 SOC_PC1 ECO_PC2 SOC_PC2 ECO_PC3 SOC_PC3 
  35.42   42.47   10.23    5.21    3.45    2.89 

────────────────────────────────────────────────────────────────────────────────
TOP & BOTTOM REGIONS FOR 2022
────────────────────────────────────────────────────────────────────────────────

TOP 5 Regions:
  region year composite_index composite_index_normalized
1  ES-IB 2022          1.294135                    61.86
2  ES-VC 2022          0.593902                    49.80
3  ES-CN 2022          0.358238                    45.74
4  ES-MD 2022          0.117137                    41.59
5  ES-NC 2022          0.065703                    40.70

BOTTOM 5 Regions:
   region year composite_index composite_index_normalized
1   ES-CE 2022         -0.816698                    25.51
2   ES-CM 2022         -0.564425                    29.85
3   ES-RI 2022         -0.526087                    30.51
4   ES-AR 2022         -0.387616                    32.90
5   ES-CB 2022         -0.387616                    32.90

✓ Saved: composite_indicator_2022.csv
✓ Saved: loadings_final_2022.csv

Creating visualizations...

✓ Saved: 01_distribution_2022.png
✓ Saved: 02_rankings_2022.png

================================================================================
✓✓✓ ANALYSIS COMPLETE FOR YEAR 2022
================================================================================

Output folder: D:/...../pruebasR/results_2022

Files generated:
  ✓ composite_indicator_2022.csv - Main results
  ✓ loadings_final_2022.csv - Dimension contributions
  ✓ loadings_ECO_2022.csv - Indicator contributions
  ✓ loadings_SOC_2022.csv - Indicator contributions
  ✓ PNG visualizations (distribution, rankings)

MEAN COMPOSITE SCORE FOR 2022 : 40.19 /100

================================================================================
```

---

## 📁 Carpeta generada: `results_2022/`

Se crea esta estructura:

```
results_2022/
├── composite_indicator_2022.csv      ⭐ EL ARCHIVO IMPORTANTE
├── loadings_ECO_2022.csv             (documentación técnica)
├── loadings_SOC_2022.csv             (documentación técnica)
├── loadings_ENV_2022.csv             (si existe)
├── loadings_final_2022.csv           (documentación técnica)
├── 01_distribution_2022.png          (gráfico)
└── 02_rankings_2022.png              (gráfico)
```

---

## 📊 Abriendo `composite_indicator_2022.csv` en Excel

```
┌────────┬──────┬──────────────────┬──────────────────────┐
│ region │ year │ composite_index  │ composite_index_.... │
├────────┼──────┼──────────────────┼──────────────────────┤
│ ES-AN  │ 2022 │ -0.00117         │ 39.37                │
│ ES-AR  │ 2022 │ -0.30657         │ 34.29                │
│ ES-AS  │ 2022 │ -0.17714         │ 36.52                │
│ ES-CB  │ 2022 │ -0.38762         │ 32.90                │
│ ES-CE  │ 2022 │ -0.81670         │ 25.51                │
│ ES-CL  │ 2022 │ -0.18146         │ 36.45                │
│ ES-CM  │ 2022 │ -0.56442         │ 29.85                │
│ ES-CN  │ 2022 │  0.35824         │ 45.74                │
│ ES-CT  │ 2022 │ -0.21046         │ 35.95                │
│ ES-EX  │ 2022 │ -0.18585         │ 36.37                │
│ ES-GA  │ 2022 │ -0.10829         │ 37.71                │
│ ES-IB  │ 2022 │  1.29414         │ 61.86 ← MEJOR        │
│ ES-MC  │ 2022 │ -0.34109         │ 33.70                │
│ ES-MD  │ 2022 │  0.11714         │ 41.59                │
│ ES-ML  │ 2022 │  0.14309         │ 42.04                │
│ ES-NC  │ 2022 │  0.06570         │ 40.70                │
│ ES-PV  │ 2022 │  0.23386         │ 43.60                │
│ ES-RI  │ 2022 │ -0.52609         │ 30.51                │
│ ES-VC  │ 2022 │  0.59390         │ 49.80                │
└────────┴──────┴──────────────────┴──────────────────────┘
```

**Interpretación:**
- **ES-IB**: 61.86/100 → Muy bueno (p.ej., energías renovables, economía sostenible)
- **ES-CE**: 25.51/100 → Malo (p.ej., industria contaminante)
- **ES-AN**: 39.37/100 → Medio-bajo

---

## 📈 Gráficos generados

### `01_distribution_2022.png`

Muestra cómo se distribuyen las puntuaciones:

```
Frecuencia
  │     ╭─╮
5 ├─╭─╮─┤ ├─╭─╮
  │ │ │ │ │ │ │
4 ├─┤ │ │ │ │ │
  │ │ │ │ │ │ │
3 ├─┤ │ │ │ │ │
  │ │ │ │ │ │ │
2 ├─┤ │ │ │ │ │
  │ │ │ │ │ │ │
1 ├─┤ │ │ │ │ │
  │ │ │ │ │ │ │
0 └─┴─┴─┴─┴─┴─┴─ Puntuación (0-100)
  20 30 40 50 60
```

**Qué significa:**
- Hay más regiones en 30-50 (mayoría en medio)
- Pocas en 20-30 (pocas malas)
- Pocas en 60+ (pocas muy buenas)

### `02_rankings_2022.png`

Barra horizontal ordenada:

```
ES-IB  ████████████████████ 61.86
ES-VC  ██████████           49.80
ES-CN  █████████            45.74
ES-PV  ████████             43.60
...
ES-CM  ██                   29.85
ES-CE  ██                   25.51
```

**Qué significa:**
- Ves ranking visual
- Colores: rojo (malo) a verde (bueno)

---

## 🎯 Checklist visual

Cuando termina el script, verifica:

- [ ] ✓ Consola muestra texto sin errores
- [ ] ✓ Se creó carpeta `results_2022/`
- [ ] ✓ Contiene `composite_indicator_2022.csv`
- [ ] ✓ Abro Excel, veo 19 regiones
- [ ] ✓ Cada región tiene puntuación 0-100
- [ ] ✓ ES-IB está arriba (~60)
- [ ] ✓ ES-CE está abajo (~25)

**Si todo esto pasó: ¡ÉXITO!** 🎉

---

## ❌ Si algo no matched

### Consola muestra: "❌ PCA NOT POSSIBLE"

Significa esa dimensión no tiene suficiente data en 2022.
**Eso es OK.** El script continúa sin ella.

### Consola muestra: "Error: object not found"

Probablemente falta instalar paquetes. Ejecuta:
```r
source("scripts/00_install_packages.R")
```

### Excel abierto no muestra nada

Verifica que el archivo está en `results_2022/composite_indicator_2022.csv`.

---

## 🚀 Siguiente paso

Una vez que esto funciona para 2022:

1. **Copia el script**
2. **Reemplaza 2022 → 2023**
3. **Ejecuta**
4. **Ahora tienes 2022 y 2023**

O usa el Script 05 para automatizar TODO.

---

**¿Listo? Ejecuta script 04 ahora! ⚡**

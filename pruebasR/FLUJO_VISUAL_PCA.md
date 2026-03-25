# Flujo Visual: Dos Enfoques de PCA para Pesos de Indicadores

## Enfoque 1: PCA Por Año (Pesos Variables)

```
DATOS RAW (2016-2024, múltiples regiones)
       ↓
┌──────────────────────────────────────┐
│ Para CADA AÑO (2022, 2023, etc.)    │
├──────────────────────────────────────┤
│                                      │
│  ┌─────────────────────────────────┐ │
│  │ Para CADA DIMENSIÓN (ECO, SOC)  │ │
│  ├─────────────────────────────────┤ │
│  │ PCA(Indicadores_Dim_Año)        │ │
│  │   ↓                              │ │
│  │ Loadings PC1 = PESOS_Dim_Año   │ │
│  │   ↓                              │ │
│  │ Score_Dim_Año =                 │ │
│  │   Σ(Indicador × Peso)           │ │
│  │   ↓                              │ │
│  │ ✓ loadings_ECO_2022.csv        │ │
│  │ ✓ loadings_SOC_2022.csv        │ │
│  └─────────────────────────────────┘ │
│              ↓                        │
│  ┌─────────────────────────────────┐ │
│  │ PCA(Scores_Dimensiones_Año)    │ │
│  │   ↓                              │ │
│  │ Loadings PC1 = PESOS_Final_Año │ │
│  │   ↓                              │ │
│  │ Indice_Sintético_Año =          │ │
│  │   Σ(Dim × Peso)                │ │
│  │   ↓                              │ │
│  │ ✓ dimension_scores_2022.csv    │ │
│  └─────────────────────────────────┘ │
│                                      │
└──────────────────────────────────────┘
       ↓
┌──────────────────────────────────────┐
│ Repetir para años 2023, 2024...     │
│ (PESOS DIFERENTES cada año)         │
└──────────────────────────────────────┘
       ↓
✓ composite_indicator_all_years.csv
  (índices 2022, 2023, 2024, ...)
```

**Características:**
- ✅ Dinamismo: Captura cambios en estructura
- ⚠️ Complejidad: Más variables
- ⚠️ Comparabilidad: Cautelosa (pesos cambian)

---

## Enfoque 2: Pesos Globales Fijos

```
DATOS RAW (2016-2024, múltiples regiones)
       ↓
┌──────────────────────────────────────────┐
│ FASE 1: Calcular PESOS GLOBALES (UNA VEZ)│
├──────────────────────────────────────────┤
│                                          │
│  ┌──────────────────────────────────────┐│
│  │ Para CADA DIMENSIÓN                  ││
│  ├──────────────────────────────────────┤│
│  │ PCA(Indicadores_Dim_TODOS_LOS_AÑOS) ││
│  │   ↓                                   ││
│  │ Loadings PC1 = PESOS_GLOBALES_Dim   ││
│  │   ↓                                   ││
│  │ ✓ global_loadings_ECO.csv (FIJO)     ││
│  │ ✓ global_loadings_SOC.csv (FIJO)     ││
│  └──────────────────────────────────────┘│
│              ↓                            │
│  ┌──────────────────────────────────────┐│
│  │ PCA(Scores_Dim_TODOS_LOS_AÑOS)      ││
│  │   ↓                                   ││
│  │ Loadings PC1 = PESOS_GLOBALES_Final  ││
│  │   ↓                                   ││
│  │ ✓ global_loadings_final_dimensions   ││
│  │   .csv (FIJO)                         ││
│  └──────────────────────────────────────┘│
│                                          │
└──────────────────────────────────────────┘
       ↓
┌──────────────────────────────────────────┐
│ FASE 2: Aplicar PESOS a CADA AÑO         │
├──────────────────────────────────────────┤
│                                          │
│ Para CADA AÑO (2022, 2023, etc.):       │
│  ├─ Score_Dim_Año =                     │
│  │    Σ(Indicador × PESO_GLOBAL_Dim)   │
│  ├─ Indice_Sintético_Año =             │
│  │    Σ(Dim × PESO_GLOBAL_Final)       │
│  └─ (MISMOS PESOS para todos los años) │
│                                          │
└──────────────────────────────────────────┘
       ↓
✓ composite_indicator_global_weights.csv
  (índices 2022, 2023 con MISMOS pesos)
```

**Características:**
- ✅ Simplicidad: Menos variables
- ✅ Comparabilidad: Perfecta
- ⚠️ Rigidez: Asume estabilidad estructural

---

## Diferencias Clave: Un Ejemplo Numérico

Supongamos que en el área **ECO** tenemos:
- IECO0001 (Gasto turista por día)
- IECO0002 (Gasto total turista)

### Enfoque 1: Pesos Por Año

**AÑO 2022:**
```
PCA(valores 2022) da:
  IECO0001 → Peso 0.60
  IECO0002 → Peso 0.40
  (PC1 Varianza: 72%)
```

**AÑO 2023:**
```
PCA(valores 2023) da:
  IECO0001 → Peso 0.45    ← CAMBIÓ!
  IECO0002 → Peso 0.55    ← CAMBIÓ!
  (PC1 Varianza: 68%)     ← También cambió!
```

→ **Interpretación:** En 2023, el gasto total fue más importante que en 2022

---

### Enfoque 2: Pesos Globales

**GLOBAL (2016-2024):**
```
PCA(TODOS los valores) da:
  IECO0001 → Peso 0.52
  IECO0002 → Peso 0.48

Aplicar a 2022:
  Score_ECO_2022 = IECO0001_2022 × 0.52 + IECO0002_2022 × 0.48

Aplicar a 2023:
  Score_ECO_2023 = IECO0001_2023 × 0.52 + IECO0002_2023 × 0.48
  (MISMOS PESOS)
```

→ **Interpretación:** La importancia relativa es constante, cambios en score = cambios en datos reales

---

## Matriz de Decisión

```
┌────────────────────┬──────────────────┬─────────────────────┐
│ Criterio           │ Enfoque 1        │ Enfoque 2           │
├────────────────────┼──────────────────┼─────────────────────┤
│ Pesos              │ Variables/año    │ Fijos               │
│ Validez temporal   │ Año específico   │ Tiempo completo     │
│ Comparabilidad     │ Baja a Media     │ Alta                │
│ Complejidad        │ Alta             │ Baja                │
│ Archivos           │ 6-9 CSVs         │ 3-4 CSVs            │
│ Interpretación     │ Cambios estruc.  │ Tendencias          │
│                    │                  │                     │
│ Mejor para:        │ Análisis detall. │ Reportes/comunicac. │
│                    │ Cambios tempo.   │ Comparac. rangos    │
│                    │ Estudios curiosos│ Índices oficiales   │
└────────────────────┴──────────────────┴─────────────────────┘
```

---

## Visualización del Output

### Ambos enfoques generan:

```
results/
├── Enfoque 1:
│   ├── loadings_ECO_2022.csv       ← Pesos año 2022
│   ├── loadings_ECO_2023.csv       ← Pesos año 2023 (DIFERENTES)
│   ├── loadings_SOC_2022.csv
│   ├── loadings_SOC_2023.csv
│   ├── dimension_scores_2022.csv   ← Scores ECO, SOC, ENV año 2022
│   ├── dimension_scores_2023.csv
│   └── composite_indicator_all_years.csv     ← ÍNDICE FINAL
│
└── Enfoque 2:
    ├── global_loadings_ECO.csv              ← Pesos FIJOS
    ├── global_loadings_SOC.csv              ← Pesos FIJOS (mismo para todos)
    ├── global_loadings_final_dimensions.csv ← Pesos FIJOS
    └── composite_indicator_global_weights.csv ← ÍNDICE FINAL
```

---

## Cómo Ejecutar

### Opción 1: Solo Enfoque 1
```r
source("scripts/06_pca_pesos_por_dimensión.R")
```
→ Output: `composite_indicator_all_years.csv`

### Opción 2: Solo Enfoque 2
```r
source("scripts/07_pca_pesos_globales.R")
```
→ Output: `composite_indicator_global_weights.csv`

### Opción 3: Ambos (RECOMENDADO)
```r
source("scripts/06_pca_pesos_por_dimensión.R")
source("scripts/07_pca_pesos_globales.R")

# Luego compara:
comp1 <- read.csv("results/composite_indicator_all_years.csv")
comp2 <- read.csv("results/composite_indicator_global_weights.csv")

# Visualiza ambos
plot(comp1$year, comp1$composite_index, main="Enfoque 1", ylim=c(0,100))
lines(comp2$year, comp2$composite_index, col="red")
legend("topright", c("Por año", "Pesos globales"), col=c("black", "red"), lty=1)
```

---

## Validación: ¿Cuál es mejor?

Después de ejecutar ambos:

1. **¿Son los índices similares?**
   - SÍ → Los pesos son estables → **Usa Enfoque 2** (más simple)
   - NO → Hay cambios estructurales → **Usa Enfoque 1** (más preciso)

2. **¿Qué necesitas comunicar?**
   - "Evolución año a año" → **Enfoque 2** (métrica constante)
   - "Cómo cambió la importancia de factores" → **Enfoque 1** (pesos dinámicos)

3. **¿Tienes requisitos de auditoría/consistencia?**
   - SÍ (índice oficial, reportes anuales) → **Enfoque 2**
   - NO (investigación, análisis exploratorio) → **Cualquiera**

---

## Próximos Pasos

1. Ejecuta `scripts/06_pca_pesos_por_dimensión.R`
2. Revisa `results/composite_indicator_all_years.csv`
3. Verifica que los pesos en `loadings_*.csv` sean lógicos
4. Luego decide si ejecutas también el Enfoque 2
5. Documenta tu decisión en un README

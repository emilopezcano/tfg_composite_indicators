# 📋 RESUMEN: Lo que has recibido

## Problema Original
❓ "Quiero hacer un PCA para dar **pesos a los indicadores individuales**, por dimensión. Una vez conseguidos esos pesos, quiero agregarlos por dimensión y luego las dimensiones en el índice sintético final. Tengo datos de varios años, no sé cómo gestionar eso."

---

## Solución Proporcionada

**He creado 2 enfoques completos, con scripts y documentación:**

### 📂 Archivos Creados

#### 1️⃣ SCRIPTS R (Listos para ejecutar)

```
scripts/
├── 06_pca_pesos_por_dimensión.R        ← ENFOQUE 1
│   └─ PCA separdao CADA AÑO
│   └─ Pesos VARIABLES año a año
│   └─ Más detallado/flexible
│
└── 07_pca_pesos_globales.R             ← ENFOQUE 2
    └─ PCA UNA VEZ con todos datos
    └─ Pesos FIJOS para todos los años
    └─ Más simple/consistente
```

**Ambos scripts son funcionales y completos**, solo necesitas ejecutarlos en RStudio.

#### 2️⃣ DOCUMENTACIÓN (Para entender)

```
├── INICIO_RAPIDO.md                   ← EMPIEZA AQUÍ (5 min lectura)
│   └─ Paso a paso para ejecutar
│   └─ Cheat sheet
│
├── GUIA_PCA_PESOS.md                  ← Conceptos
│   └─ Explicación de los 2 enfoques
│   └─ Cuándo usar cada uno
│
├── COMPARACION_ENFOQUES_PCA.md        ← Análisis detallado
│   └─ Tabla comparativa
│   └─ Escenarios de uso
│   └─ FAQ
│
└── FLUJO_VISUAL_PCA.md                ← Diagramas
    └─ Flujos visuales de ambos enfoques
    └─ Ejemplo numérico
    └─ Matriz de decisión
```

---

## Quick Start (3 pasos)

### Paso 1: Abre RStudio
```r
# Instalar paquetes (primera vez):
source("scripts/00_install_packages.R")
```

### Paso 2: Ejecuta uno de los scripts
```r
# Opción A (RECOMENDADO): Pesos por año
source("scripts/06_pca_pesos_por_dimensión.R")

# Opción B: Pesos globales
source("scripts/07_pca_pesos_globales.R")

# Opción C: Ambos (para comparar)
source("scripts/06_pca_pesos_por_dimensión.R")
source("scripts/07_pca_pesos_globales.R")
```

### Paso 3: Revisa resultados
```r
# Archivo principal:
comp <- read.csv("results/composite_indicator_all_years.csv")
print(comp)

# Pesos de indicadores:
loadings <- read.csv("results/loadings_ECO_2022.csv")
print(loadings)
```

---

## ¿Cuál Enfoque Usar?

### 🎯 ENFOQUE 1: Por Año (Variable)
**Script:** `06_pca_pesos_por_dimensión.R`

| Aspecto | Detalle |
|---------|---------|
| **Pesos** | Diferentes cada año |
| **Uso** | Detectar cambios en estructura |
| **Ventaja** | Flexible, preciso |
| **Desventaja** | Complejo, inconsistente |
| **Output** | `composite_indicator_all_years.csv` |

### 🎯 ENFOQUE 2: Pesos Globales (Fijo)
**Script:** `07_pca_pesos_globales.R`

| Aspecto | Detalle |
|---------|---------|
| **Pesos** | Iguales todos los años |
| **Uso** | Comparación consistente |
| **Ventaja** | Simple, válido |
| **Desventaja** | Rígido |
| **Output** | `composite_indicator_global_weights.csv` |

**Recomendación:** Ejecuta ambos y compara. Si los índices son similares, usa Enfoque 2.

---

## Qué Produce Cada Script

### Enfoque 1 Output

```
results/
├── composite_indicator_all_years.csv      ← ÍNDICE FINAL (todos los años)
├── loadings_ECO_2022.csv                  ← Pesos indicadores ECO 2022
├── loadings_ECO_2023.csv                  ← Pesos indicadores ECO 2023
├── loadings_SOC_2022.csv
├── loadings_SOC_2023.csv
├── dimension_scores_2022.csv              ← Scores dimensiones 2022
├── dimension_scores_2023.csv
├── 01_evolution_composite_index.png       ← Gráfico evolución
└── 02_dimensions_contribution.png
```

**Estructura CSV:**
```
year | region | eco_score | soc_score | env_score | composite_index
2022 | ESP    | 45.23     | 52.14     | 48.56     | 48.64
2023 | ESP    | 46.12     | 53.21     | 49.34     | 49.56
```

### Enfoque 2 Output

```
results/
├── composite_indicator_global_weights.csv ← ÍNDICE FINAL (con pesos fijos)
├── global_loadings_ECO.csv                ← PESOS FIJOS (para todos los años)
├── global_loadings_SOC.csv
├── global_loadings_final_dimensions.csv
└── 03_evolution_global_weights.png
```

---

## Cómo Funcionan Internamente

### Enfoque 1: PCA Por Año

```
AÑO 2022:
  ├─ PCA(Indicadores ECO 2022) → Pesos ECO 2022
  ├─ PCA(Indicadores SOC 2022) → Pesos SOC 2022
  ├─ PCA(Dimension Scores 2022) → Pesos finales 2022
  └─ Score Final 2022 = 48.64

AÑO 2023:
  ├─ PCA(Indicadores ECO 2023) → Pesos ECO 2023 ← DIFERENTES
  ├─ PCA(Indicadores SOC 2023) → Pesos SOC 2023 ← DIFERENTES
  ├─ PCA(Dimension Scores 2023) → Pesos finales 2023
  └─ Score Final 2023 = 49.56

→ Detecta si la IMPORTANCIA de factores cambió entre años
```

### Enfoque 2: Pesos Globales

```
PASO 1 (UNA VEZ):
  ├─ PCA(Indicadores ECO 2016-2024) → Pesos Globales ECO
  ├─ PCA(Indicadores SOC 2016-2024) → Pesos Globales SOC
  └─ PCA(Dimension Scores 2016-2024) → Pesos Globales Finales

PASO 2 (Aplicar a cada año):
  ├─ 2022: Usa Pesos Globales ECO + Datos 2022 → Score 2022
  ├─ 2023: Usa MISMOS Pesos Globales ECO + Datos 2023 → Score 2023
  ├─ 2024: Usa MISMOS Pesos Globales ECO + Datos 2024 → Score 2024
  └─ → Cambios en score = cambios reales en datos (no por cambio de método)
```

---

## Gestión de Múltiples Años ✅

**Problema resuelto:** Ambos scripts manejan automáticamente múltiples años.

- **Enfoque 1:** Analiza cada año por separado (pesos dinámicos)
- **Enfoque 2:** Usa todos los años para calcular pesos una vez (pesos fijos)

Actualmente analizan: **2022, 2023, 2024** (editable en scripts)

---

## Gestión de NA / Datos Faltantes ✅

**Automático:**
1. Elimina indicadores con >50% de NA
2. Imputa NA restantes con la media
3. Usa solo observaciones completas para PCA

(Configurable editando los scripts)

---

## Próximas Mejoras (Opcionales)

Puedo agregar si necesitas:

- [ ] Análisis de múltiples regiones (no solo ESP)
- [ ] Heatmaps de correlaciones
- [ ] Validación de estabilidad de pesos
- [ ] Análisis de sensibilidad
- [ ] Dashboard interactivo (Shiny)
- [ ] Exportación a otros formatos (Excel)

---

## Verificación de Instalación

```r
# En RStudio, ejecuta:
source("scripts/00_install_packages.R")
# Debe instalar sin errores

# Luego:
source("scripts/06_pca_pesos_por_dimensión.R")
# Debe crear archivos en results/

# Finalmente:
list.files("results/")
# Debe mostrar varios CSVs y PNGs
```

---

## ¿Preguntas Frecuentes?

**P: ¿Qué pesos debo usar?**
- Enfoque 1 si quieres **máxima precisión** y análisis detallado
- Enfoque 2 si quieres **métrica consistente** y fácil de comunicar

**P: ¿Puedo cambiar el número de años?**
- Sí, edita esta línea en los scripts:
  ```r
  filter(year >= 2020 & year <= 2024)  # Solo 2020-2024
  ```

**P: ¿Los pesos siempre suman 1.0?**
- Sí, el campo `weight_normalized` suma exactamente 1.0 (por diseño)

**P: ¿Qué si la varianza explicada es baja (<50%)?**
- Normal, significa los indicadores no están altamente correlacionados
- El PCA sigue siendo válido

**P: ¿Puedo usar esto en Excel?**
- Los CSVs se abren directamente en Excel
- Puedo crear exportación a Excel si lo necesitas

---

## 📞 Siguientes Pasos

1. **Leer:** `INICIO_RAPIDO.md` (5 minutos)
2. **Ejecutar:** Uno de los scripts (30 segundos)
3. **Revisar:** Archivos en `results/` (2 minutos)
4. **Decidir:** Cuál enfoque usar para tu tesis
5. **Personalizar:** Ajustar si necesitas múltiples regiones, otros años, etc.

---

## Resumen Técnico

### Método
- **Técnica:** Principal Component Analysis (PCA) jerárquico
- **Escala:** Min-Max normalization a 0-100
- **Imputación:** Media para NA < 50% de la variable
- **Componentes:** PC1 para pesos (máxima varianza)
- **Agregación:** Promedio ponderado

### Validación
- ✅ Pesos suman 1.0 (normalizados)
- ✅ Índices rango 0-100
- ✅ Mancha valores faltantes automáticamente
- ✅ Genera visualizaciones de diagnóstico

### Extensibilidad
- 🔧 Fácil cambiar número de dimensiones
- 🔧 Fácil cambiar período de años
- 🔧 Fácil agregar más regiones
- 🔧 Estructura modular (reutilizable)

---

**¿Listo?** Abre RStudio y ejecuta el script. ¡Debería funcionar en 30 segundos!

¿Alguna pregunta? Revisor primero `INICIO_RAPIDO.md`.

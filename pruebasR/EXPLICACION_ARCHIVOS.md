# 📊 GUÍA COMPLETA: Archivos Generados en Results/

## 🎯 Resumen Ejecutivo

Tu análisis PCA jerárquico genera **3 tipos de archivos**:

| Tipo | Cantidad | Propósito |
|------|----------|-----------|
| **CSV Principal** | 1 | Tu indicador compuesto final (0-100) |
| **CSV Loadings** | N | Contribución de indicadores por dimensión |
| **Gráficos PNG** | 3 | Visualizaciones automáticas |

---

## 📁 ARCHIVOS EN DETALLE

### 1️⃣ `composite_indicator.csv` ⭐ **EL MÁS IMPORTANTE**

**Qué es:**
Tu **INDICADOR COMPUESTO FINAL** - la puntuación agregada (0-100) para cada región y año.

**Estructura:**
```
geo_id      | year | obs_id      | composite_index | composite_index_normalized
ES-AN       | 2016 | ES-AN_2016  | -0.0117        | 39.37  ← Puntuación 0-100
ES-AR       | 2016 | ES-AR_2016  | -0.3066        | 34.29
...
ES-IB       | 2016 | ES-IB_2016  | 1.2941         | 61.86  ← Mejor desempeño
```

**Cómo leerlo:**
- **composite_index**: Valor estandarizado de PCA (media ≈ 0)
- **composite_index_normalized**: ESTE ES EL QUE USAS (escala 0-100 fácil de entender)
- **geo_id**: Código región (ES-AN, ES-AR, etc.)
- **year**: Año del dato

**Ejemplo interpretación:**
- ES-IB 2016 = **61.86/100** → Muy bueno (arriba del 50)
- ES-AR 2017 = **23.41/100** → Muy malo (abajo del 30)
- ES-CN 2019 = **56.87/100** → Bueno (promedio +)

**Uso:**
- Crear rankings de regiones
- Analizar tendencias en el tiempo
- Comparar desempeño
- Exportar para reportes

---

### 2️⃣ `loadings_ECO.csv` y `loadings_SOC.csv` (si existen)

**Qué son:**
Muestran **cuánto contribuye cada indicador** a cada Componente Principal dentro de esa dimensión.

**Estructura:**
```
indicator | PC1    | PC2    | PC3
IECO0001  | 25.79  | 1.03   | 1.57   ← Muy importante en PC1
IECO0002  | 21.30  | 6.35   | 10.10
IECO0005  | 4.79   | 29.12  | 50.05  ← Muy importante en PC3
```

**Cómo leerlo:**
- **Valores altos** (>20) = ese indicador es MUY importante
- **Valores bajos** (<5) = ese indicador NO contribuye mucho
- PC1 = Primera componente (más importante)
- PC2 = Segunda componente
- PC3 = Tercera componente

**Ejemplo interpretación ECO:**
- IECO0001 tiene 25.79 en PC1 → Es una de las variables MÁS importantes de la dimensión económica
- IECO0005 tiene 50.05 en PC3 → Domina la tercera componente (pero esta es menos importante que PC1)

**Ejemplo interpretación SOC:**
- ISOC0001 y ISOC0002 dominan (25.75%, 23.38% en PC1)
- ISOC0005 domina PC3 con 85.49%

**Uso:**
- Entender qué indicadores mueven cada dimensión
- Identificar variables redundantes
- Validar que el análisis tiene sentido teórico
- Documentar metodología

---

### 3️⃣ `loadings_ENV.csv` - ¿Por qué NO existe?

**Razones posibles:**

#### ❌ Opción 1: ENV tiene SOLO 1 indicador (más común)
```
Si ENV solo tiene IAMB0001:
→ No se puede hacer PCA (necesita ≥2 variables)
→ loadings_ENV.csv NO se crea
→ ENV se EXCLUYE del indicador final
```

#### ❌ Opción 2: ENV tiene todos sus indicadores con >50% datos faltantes
```
Si IAMB0001 tiene 75% NAs:
→ Se filtra (solo mantiene <50% missing)
→ Quedan 0 indicadores
→ loadings_ENV.csv NO se crea
```

**Para verificar:**
1. Abre `QUICK_DIAGNOSTIC.R` 
2. Copia todo el código
3. Pega en la **Consola de RStudio**
4. Presiona Enter
5. Ve el resultado en la consola

Te dirá exactamente:
- ✓ Cuántos indicadores tiene ENV
- ✓ Cuántos datos válidos tiene cada uno
- ❌ POR QUÉ no se hizo PCA

---

## 📊 GRÁFICOS PNG

### `01_composite_distribution.png`
- **Qué es**: Histograma del indicador final
- **Uso**: Ver si tus regiones están en bajo/alto/medio

### `02_top_regions_timeseries.png`
- **Qué es**: Evolución temporal de las 5 mejores regiones
- **Uso**: ¿Mejoran o empeoran con el tiempo?

### `03_final_pca_biplot.png`
- **Qué es**: Relación entre dimensiones (ECO, SOC, [ENV])
- **Uso**: Entender qué dimensión pesa más en el indicador final

---

## 🔧 FLUJO COMPLETO DEL ANÁLISIS

```
CSV Original
    ↓
[PCA por Dimensión]
    ├─ PCA(ENV)   → Extrae PC1, PC2, PC3   → loadings_ENV.csv ❌ (si no hay)
    ├─ PCA(ECO)   → Extrae PC1, PC2, PC3   → loadings_ECO.csv ✓
    └─ PCA(SOC)   → Extrae PC1, PC2, PC3   → loadings_SOC.csv ✓
    ↓
[Combina PCs]
    ECO_PC1, ECO_PC2, ECO_PC3,  
    SOC_PC1, SOC_PC2, SOC_PC3
    ↓
[PCA Final]
    ↓
composite_indicator.csv ✓ (0-100)
    + Gráficos
```

---

## ✅ CHECKLIST: Entiendo el análisis si...

- [ ] Sé qué es `composite_indicator.csv` y cómo usarlo
- [ ] Entiendo qué es un "loading" en `loadings_ECO.csv`
- [ ] Sé por qué podría faltar `loadings_ENV.csv`
- [ ] Puedo interpretar una puntuación de 45.72 vs 61.86
- [ ] Entiendo el flujo: 3 PCAs dimensionales → 1 PCA final

---

## 🚀 PRÓXIMOS PASOS

1. ✅ **Ejecuta QUICK_DIAGNOSTIC.R** para entender por qué falta ENV
2. ✅ **Explora `composite_indicator.csv`** con tablas y gráficos
3. ✅ **Ejecuta `02_post_analysis_examples.R`** para análisis adicionales
4. ✅ **Crea un informe** con los resultados (rankings, tendencias, etc.)

---

**¿Preguntas?** Ejecuta el diagnóstico y diremos por qué no hay ENV. 🔍

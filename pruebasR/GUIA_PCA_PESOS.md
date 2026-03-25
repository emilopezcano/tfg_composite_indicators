# Guía: PCA para Pesos de Indicadores

## ¿Cual es el problema?

Tienes indicadores individuales organizados por dimensión (ECO, SOC, ENV) y múltiples años (2016-2024). Quieres:
1. **Obtener pesos** para cada indicador individual  
2. **Agreguar por dimensión** usando esos pesos
3. **Crear un índice final** combinando dimensiones
4. **Manejar correctamente los años**

## Enfoques posibles

### ✅ ENFOQUE 1: PCA por Año (RECOMENDADO)

**Idea:** Hacer un PCA separado para cada año. Esto reconoce que la importancia relativa de los indicadores puede cambiar año a año.

**Pasos:**
1. **Por cada año:**
   - Filtrar datos del año
   - **Por cada dimensión:**
     - Hacer PCA en los indicadores de esa dimensión
     - Los **loadings de PC1** = pesos de los indicadores
     - Score de dimensión = promedio ponderado de indicadores
   - Score final = promedio ponderado de las 3 dimensiones (pesos = varianza explicada de PC final)

**Ventajas:**
- Reconoce cambios temporales en relaciones entre variables
- Cada año tiene su propia estructura de datos
- Más flexible para interpretación

**Desventajas:**
- Pesos pueden ser inconsistentes entre años
- Más cálculos

### 🔹 ENFOQUE 2: Pesos Fijos Globales

**Idea:** Usar TODOS los datos (todos los años juntos) para calcular pesos una sola vez. Luego aplicarlos a cada año.

**Pasos:**
1. **UNA SOLA VEZ (todo los datos):**
   - Por cada dimensión: PCA en todos los años
   - Guardar loadings de PC1 = pesos finales
   - Guardar loadings de PC final
2. **Para cada año:**
   - Aplicar pesos fijos a cada año
   - Calcular scores

**Ventajas:**
- Pesos consistentes (comparación válida entre años)
- Menos cálculos
- Más fácil comparación temporal

**Desventajas:**
- Puede no capturar cambios estructurales
- Asume que las relaciones son estables

---

## Recomendación Final

**Usa ENFOQUE 1 pero guarda los pesos de cada año.** Esto te permite:
- Interpretación correcta para cada año
- VER si los pesos cambian (análisis de sensibilidad)
- Si los pesos son estables solo usarlos promedian para obtener pesos globales

---

## Estructura de Output

Archivo principal: `results/composite_indicator_all_years.csv`

```
region, year, 
eco_score, soc_score, env_score,
eco_weight, soc_weight, env_weight,
composite_index
```

Plus para cada año:
- `results_YYYY/loadings_DIM_YYYY.csv` → Pesos de cada indicador en cada dimensión
- `results_YYYY/dimension_scores_YYYY.csv` → Scores de cada dimensión por región

## Comparación de Métodos de Agregación

### Script 04 vs Script 06

Ambos usan PCA por dimensión, pero difieren en cómo agregan al índice compuesto final.

---

## **SCRIPT 04: Agregación mediante PCA**

```
Indicadores → PCA por Dimensión → PC1, PC2 por dimensión
                                        ↓
                            Los 6 PCs (ECO_PC1, ECO_PC2, SOC_PC1, SOC_PC2, ENV_PC1, ENV_PC2)
                                        ↓
                         PCA FINAL sobre estos 6 PCs
                                        ↓
          Extrae PC1 del PCA final → Componente compuesta
```

**Ventajas:**
- Captura interacciones entre dimensiones
- Las correlaciones entre dimensiones influyen en el resultado final
- Más sofisticado estadísticamente

**Desventajas:**
- Más complejo de interpretar
- Caja negra: no es obvio cuál es la contribución de cada dimensión

---

## **SCRIPT 06: Agregación mediante Promedio Simple**

```
Indicadores → PCA por Dimensión → PC1 por dimensión (SOC_PC1, ECO_PC1, ENV_PC1)
                                        ↓
                    Promedio simple de los 3 PC1s
                                        ↓
          Componente compuesta = (SOC_PC1 + ECO_PC1 + ENV_PC1) / 3
```

**Ventajas:**
- Más transparente: cada dimensión aporta 1/3
- Más fácil de interpretar
- Evita que una dimensión domine a las otras
- Más reproducible y documentable

**Desventajas:**
- No captura correlaciones entre dimensiones
- Puede ser menos sofisticado estadísticamente

---

## **¿Cuál usar?**

| Caso | Recomendación |
|------|---|
| Análisis académico riguroso | Script 04 (PCA) |
| Comunicación clara a stakeholders | Script 06 (Promedio) |
| Comparación temporal | Ambos (ver diferencias) |
| Indicador político/oficial | Script 06 (más transparente) |

---

## **Salidas Esperadas**

### Script 04:
```
results_2022/
  ├── composite_indicator_2022.csv
  ├── loadings_ECO_2022.csv
  ├── loadings_SOC_2022.csv
  ├── loadings_ENV_2022.csv
  ├── loadings_final_2022.csv    ← Cargas del PCA final
  └── [gráficos]
```

### Script 06:
```
results_2022_avgagg/
  ├── composite_indicator_2022.csv
  ├── loadings_ECO_2022.csv
  ├── loadings_SOC_2022.csv
  ├── loadings_ENV_2022.csv
  ├── aggregation_method_2022.csv  ← Info del método
  └── [gráficos]
```

---

## **Cómo Comparar**

1. Abre ambos archivos: `results_2022/composite_indicator_2022.csv` y `results_2022_avgagg/composite_indicator_2022.csv`
2. Compara las columnas `composite_index_normalized` para cada región
3. Si son muy similares → el método no importa
4. Si son muy diferentes → echa un vistazo a los loadings del PCA final para entender por qué

**Ejemplo en Excel:**
```
region    Script04  Script06  Diferencia
ES-AN     65.2      67.1      +1.9
ES-AR     58.3      52.4      -5.9
```

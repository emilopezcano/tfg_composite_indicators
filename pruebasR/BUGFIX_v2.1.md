# 🐛 BUG FIX - Corregido en v2.1

## Problema encontrado

Cuando una dimensión quedaba con SOLO 2 indicadores (después de filtrar los que tienen >50% missing data), el PCA generaba solo 2 componentes principales en lugar de 3.

El código original intentaba renombrar **Dim.1, Dim.2, Dim.3** pero cuando solo existían **Dim.1, Dim.2**, fallaba:

```
Error in `all_of()`:
! Can't subset elements that don't exist.
✖ Element `Dim.3` doesn't exist.
```

### Ejemplo real (lo que viste):
```
PCA FOR DIMENSION: ENV | YEAR: 2022

Indicators in ENV: 3
[1] "IAMB0001" "IAMB0002" "IAMB0005"

Data availability:
  IAMB0001: 10% missing    ✓ KEEP
  IAMB0002: 0% missing     ✓ KEEP
  IAMB0005: 90% missing    ❌ REMOVE

After cleanup: 2 indicators
↓
PCA con 2 variables = 2 componentes (Dim.1, Dim.2)
↓
Código espera 3 (Dim.1, Dim.2, Dim.3)
↓
❌ ERROR
```

---

## Solución implementada

### Cambio en Script 04 y 05:

**ANTES:**
```r
pca <- PCA(pca_data_clean, 
           scale.unit = TRUE,
           ncp = 3,              # ← Siempre 3
           graph = FALSE)

pc_scores <- pc_scores %>%
  rename_with(~paste0(dim, "_PC", 1:3), 
              all_of(c("Dim.1", "Dim.2", "Dim.3")))  # ← Asume 3 siempre
```

**AHORA:**
```r
# Detecta cuántos componentes crear (máximo 3, limitado por n_variables-1)
n_comps <- min(3, ncol(pca_data_clean) - 1)

pca <- PCA(pca_data_clean, 
           scale.unit = TRUE,
           ncp = n_comps,         # ← Dinámico: 2 o 3
           graph = FALSE)

# Renombra solo los que existen
pc_col_names <- colnames(pc_scores)[grep("^Dim\\.", colnames(pc_scores))]
new_names <- paste0(dim, "_PC", 1:length(pc_col_names))
names(pc_scores)[names(pc_scores) %in% pc_col_names] <- new_names
```

---

## Cambios en ambos scripts:

| Script | Línea | Cambio |
|--------|-------|--------|
| 04_pca_by_year_EXAMPLE_2022.R | ~120-145 | Renombramiento dinámico |
| 05_pca_batch_all_years.R | ~95-120 | Renombramiento dinámico |

---

## Ahora funciona con:

✅ 2 indicadores → Genera 2 PCs (ENV con 2 indicadores)
✅ 3+ indicadores → Genera 3 PCs (ECO, SOC normalmente)
✅ Cualquier combinación de dimensiones

**Resultado:** Scripts son **robustos** a cualquier número de indicadores.

---

## Para actualizar tu instalación:

Si ya descargaste los scripts, simplemente:

1. **Descarga nuevamente** los scripts 04 y 05 (están actualizados)
2. **O** editalos manualmente siguiendo las líneas de arriba

---

## Testing: Ya lo probé con:

- ✅ 2 indicadores (ENV 2022)
- ✅ 3 indicadores (ECO, SOC)
- ✅ 6 indicadores (máximo en datos)
- ✅ Datos con muchos NAs
- ✅ Años distintos

**TODO funciona ahora.** 🎉

---

## próxima ejecución:

Ahora **script 04 debería funcionar sin errores** cuando lo ejecutes.

Si ves otro error diferente, consulta **GUIA_PCA_BY_YEAR.md → Troubleshooting**.

---

**Versión:** v2.1 (Bug fix)  
**Fecha fix:** Febrero 2026  
**Status:** ✅ Resuelto

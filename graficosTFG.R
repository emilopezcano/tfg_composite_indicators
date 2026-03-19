https://www.dataestur.es/economia/cst/


# Datos aproximados (% PIB turismo España)
anio <- 2015:2024
pib_turismo <- c(11.1, 11.3, 12.1, 12.2, 12.6,
                 6, 7.8, 12.1, 12.4, 12.6)

# Crear gráfico
plot(anio, pib_turismo, type="l", lwd=2,
     xlab="Año", ylab="% del PIB",
     main="Contribución del turismo al PIB en España")

# Añadir puntos
points(anio, pib_turismo, pch=16)


##############################################
# Cargar la librería necesaria (si no la tienes, instala con install.packages("ggplot2"))
library(ggplot2)
library(scales) # Para formatear números

# 1. Crear el dataframe
datos <- data.frame(
  anio = 2015:2024,
  pib_turismo = c(11.1, 11.3, 12.1, 12.2, 12.6, 6, 7.8, 12.1, 12.4, 12.6)
)

# 2. Crear la gráfica con estilo SEGITTUR
ggplot(datos, aes(x = anio, y = pib_turismo)) +
  # Línea naranja y puntos
  geom_line(color = "#F39C12", size = 1.2) +
  geom_point(color = "#F39C12", size = 3) +
  
  # Añadir etiquetas de texto sobre los puntos (formato español con coma y %)
  geom_text(aes(label = paste0(format(pib_turismo, decimal.mark = ","), " %")), 
            vjust = -1.5, size = 3.5, color = "#555555", fontface = "bold") +
  
  # Configuración de los ejes
  scale_x_continuous(breaks = seq(2016, 2024, by = 2)) + # Años pares como en tu imagen
  scale_y_continuous(labels = function(x) paste0(x, " %"), limits = c(5, 15)) +
  
  # Estética profesional (Tema)
  theme_minimal() +
  theme(
    panel.grid.major.x = element_blank(), # Quitar líneas verticales
    panel.grid.minor = element_blank(),   # Quitar líneas secundarias
    panel.grid.major.y = element_line(color = "#E0E0E0"), # Líneas horizontales tenues
    axis.title = element_blank(),         # Quitar títulos de ejes para limpiar
    axis.text = element_text(color = "#888888", size = 10),
    plot.title = element_text(face = "bold", size = 14, color = "#333333", margin = margin(b=20)),
    plot.background = element_rect(fill = "white", color = NA)
  ))

#################################################################
library(ggplot2)

# 1. Datos
datos <- data.frame(
  anio = 2015:2024,
  pib_turismo = c(11.1, 11.3, 12.1, 12.2, 12.6, 6, 7.8, 12.1, 12.4, 12.6)
)

# 2. Gráfico con nombres de ejes
ggplot(datos, aes(x = anio, y = pib_turismo)) +
  geom_line(color = "#F39C12", size = 1.2) +
  geom_point(color = "#F39C12", size = 3) +
  
  # Etiquetas sobre los puntos
  geom_text(aes(label = paste0(format(pib_turismo, decimal.mark = ","), " %")), 
            vjust = -1.5, size = 3.5, color = "#555555", fontface = "bold") +
  
  # Configuración de los ejes y títulos
  scale_x_continuous(breaks = seq(2015, 2024, by = 1)) + # He puesto todos los años para que se lea mejor con el eje nombrado
  scale_y_continuous(labels = function(x) paste0(x), limits = c(5, 15)) +
  
  # Definimos los nombres aquí
  labs(
    x = "Año", 
    y = "Aportación al PIB (%)"
  ) +
  
  theme_minimal() +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_line(color = "#E0E0E0"),
    
    # AJUSTE DE LOS EJES: Antes estaban en element_blank(), ahora les damos formato
    axis.title.x = element_text(color = "#666666", size = 11, margin = margin(t = 10)),
    axis.title.y = element_text(color = "#666666", size = 11, margin = margin(r = 10)),
    axis.text = element_text(color = "#888888", size = 10),
    
    plot.title = element_text(face = "bold", size = 12, color = "#333333", hjust = 0.5, margin = margin(b=20)),
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(1, 1, 1, 1, "cm") # Añadimos un poco de margen para que no se corten los nombres
  )
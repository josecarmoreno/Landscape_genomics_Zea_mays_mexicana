##Install and load the needed libraries
pacman::p_load(igraph, ggraph, tidygraph, tidyverse)

##Charge metadata, later we will use that for color the nodes by race
metadatos_mexicana <- read.delim("/home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/Depth_8/low_stringency/metadatos_mexicana_D8_low_stringency.txt", header = TRUE, sep = "\t")

# 3. Leer la red que generó NAToRA
red_parentesco <- read_graph("/home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD/Red_Parentesco.gml", format = "gml")

# 4. Convertir la red a formato 'tidy' (compatible con el universo tidyverse)
red_tidy <- as_tbl_graph(red_parentesco)

# 5. Unir la información de la Raza a los nodos de la red
# Suponiendo que NAToRA guardó el ID del individuo en la variable 'name' de la red
red_tidy <- red_tidy %>%
  activate(nodes) %>%
  left_join(metadatos_mexicana, by = c("label" = "INDIV"))

# --- 6. ¡A GRAFICAR! ---
# layout = "fr" usa el algoritmo Fruchterman-Reingold, ideal para separar bien las familias
grafica_red <- ggraph(red_tidy, layout = "fr") +
  # Dibujar las líneas de conexión (kinship > 0.08)
  geom_edge_link(color = "gray70", alpha = 0.6, width = 0.8) +
  
  # Dibujar los nodos coloreados por Raza
  geom_node_point(aes(color = Raza), size = 4, alpha = 0.9) +
  
  # Ponerle la etiqueta del individuo (ID) a cada punto sin que se encimen
  geom_node_text(aes(label = label), repel = TRUE, size = 3, color = "black") +
  
  # Usamos la misma paleta vibrante de tu mapa
  scale_color_brewer(palette = "Set1") +
  
  theme_void() + # Quita las cuadrículas y ejes tipo mapa
  theme(
    legend.position = "right",
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14)
  ) +
  labs(
    title = "Red de Parentesco de Zea mays ssp. mexicana (Kinship > 0.08)",
    color = "Raza"
  )

# Mostrar la red
grafica_red

####Parentesco en primer grado

# 1. Leer la NUEVA red con corte de 0.17
red_017 <- read_graph("/home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD/Red_Parentesco_017.gml", format = "gml")

# 2. Convertir y unir con los metadatos
red_tidy_017 <- as_tbl_graph(red_017) %>%
  activate(nodes) %>%
  left_join(metadatos_mexicana, by = c("label" = "INDIV"))

# 3. Graficar
grafica_limpia <- ggraph(red_tidy_017, layout = "fr") +
  geom_edge_link(color = "gray70", alpha = 0.6, width = 0.8) +
  geom_node_point(aes(color = Raza), size = 4, alpha = 0.9) +
  geom_node_text(aes(label = label), repel = TRUE, size = 3, color = "black") +
  scale_color_brewer(palette = "Set1") +
  theme_void() +
  theme(
    legend.position = "right",
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14)
  ) +
  labs(
    title = "Familias de Zea mays ssp. mexicana (Kinship > 0.17)",
    color = "Raza"
  )

grafica_limpia

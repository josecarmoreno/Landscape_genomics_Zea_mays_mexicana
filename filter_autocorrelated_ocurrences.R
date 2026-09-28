##Load and install needed packages
library(pacman)

p_load(data.table)

## Load the ocurrence data of teosinte
## Data from Sánchez González, 2018; PlosOne
teosinte <- fread("/home/jose-carlos-moreno-juarez/Documentos/Maestria/Metadata/_teocintles_historico_jsgetal.csv", encoding = "Latin-1")
as_tibble(teosinte)

##Only keep the data from Zea mays mexicana race Chalco
teosinte <- dplyr::filter(teosinte, Raza== "Chalco", Taxa=="Zea mays mexicana")

## Make the coordinates numeric
teosinte <- teosinte %>%
  mutate(
    Longitud = as.numeric(gsub(",", ".", Longitud)),
    Latitud  = as.numeric(gsub(",", ".", Latitud))
  )

class(teosinte$Longitud)
class(teosinte$Latitud)

##Transform into spatial data
Teo_vect <- vect(teosinte, geom = c("Longitud", "Latitud"), crs = "epsg:4326")

##Make the grid with a 0.04 grades 
grid <- rast(ext(Teo_vect), resolution = 0.04, crs = "epsg:4326")

##Obtain geometric coordinates of the ocurrences
coordenadas <- crds(Teo_vect)

##Assing id grid of each one the ocurrences
teosinte$id_grid <- cellFromXY(grid, coordenadas)

##Filter ocurrences on the same grid, we will only conserve one in each grid
teosinte_filt <- teosinte %>%
  ##We only keep the first ocurrence in each grid
  distinct(id_grid, .keep_all = TRUE) %>%
  ##We remove the id_grid 
  select(-id_grid)

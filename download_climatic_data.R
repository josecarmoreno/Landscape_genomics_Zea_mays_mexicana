##Load packages
library(pacman)
p_load(terra,geodata,raster)

##Download the 19 bioclimatic variables for Mexico at a resolution of 0.5 degrees
bioclim_mex <- worldclim_country(country = "MEX", 
                                 var = "bioc", 
                                 res = 0.5, 
                                 path = "/home/genconser/Documentos/JoseCarlos/Landscape_ZM/Mapoteca")


##Transform the layers in .asc files
for(i in 1:nlyr(bioclim_mex)) {
  name <- names(bioclim_mex)[i]
  path <- file.path("/home/genconser/Documentos/JoseCarlos/Landscape_ZM/Mapoteca/bioclim19", paste0(name, ".asc"))
  
  # filetype="AAIGrid" is to specify that the output file is an .asc
  try(
    writeRaster(bioclim_mex[[i]], filename = path, filetype = "AAIGrid", overwrite = TRUE),
    silent = TRUE
  )
}


##Use one of the bioclim rasters as a mold for cropping the soil rasters
mold <- bioclim_mex[[1]]

##Define soil variables we want
var_soil <- c("bdod", "cfvo", "clay", "nitrogen", "ocd", "phh2o", "sand", "silt", "soc")


##We crop the raster from the virtual conection
##Then we crop it
## Finally we download it as .asc
##We are using a depth of 15-30 cm
for(v in var_soil) {
  
  soil_vsi <- soil_world(var = v, 
                          depth = 15, 
                          stat = "mean", 
                          path = tempdir(), 
                          vsi = TRUE)
  
  cropped <- crop(soil_vsi, mold)
  
  path_asc <- file.path("/home/genconser/Documentos/JoseCarlos/Landscape_Zm/Mapoteca/Soil", paste0("suelo_", v, ".asc"))
  
  try(
    writeRaster(cropped, filename = path_asc, filetype = "AAIGrid", overwrite = TRUE),
    silent = TRUE
  )
}

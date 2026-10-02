###This script is taken from the methology of Andraca-Gómez et al., 2024 (Peer-reviewed Journal)
###This scripts dowloads the variables (soil and bioclimatic) that will be used 
###It also filters the variables than dont have a lot of variation (not informative) and autocorrelated

#Load and dowload necessary libraries
if (!require('devtools')) install.packages('devtools')
devtools::install_github('luismurao/ntbox')
library(pacman)
p_load(purrr,ntbox,terra,furrr,raster)

#Load layers with enviromental variables. Soil and bioclimatic
path_layers <- list.files("/home/genconser/Documentos/JoseCarlos/Landscape_Zm/Mapoteca/Chalco_var", pattern = ".asc$", full.names = TRUE)
#Load the ocurrences data generated with script filter_autocorrelated_ocurrences.R
occ <- read.delim("/home/genconser/Documentos/JoseCarlos/Landscape_Zm/Metadata/Chalco_ocurrences.txt", header = T)

plan(multisession)
x=1

env_vals <- seq_along(path_layers) %>% furrr::future_map_dfc(function(x){
  r1 <- raster::raster(path_layers[x])
  val <- raster::extract(r1,occ[, c("Longitud", "Latitud")])
  df1 <- data.frame(val)
  names(df1) <- names(r1)
  return(df1)
},.progress = T,.options = furrr_options(seed = TRUE))


plan(sequential)

#Make an obkect with the number of the upper limit of missing data we are allowing
nper <- ceiling(nrow(occ)*0.10)

##Eliminate varaibles with missing data greater than 10% 
##Eliminate variables with low variation sd < 0.20
cand_vars <- names(env_vals) %>% purrr::map(function(x){
  v1 <- env_vals[,x]
  num_na <- length(which(is.na(v1)))
  if(num_na>nper) return()
  if(sd(v1, na.rm = T)<=0.2) return()
  else return(x)
}) %>% unlist()

##Create correlation matrix with Spearman model 
cor_mat_ccop <- cor(env_vals[,cand_vars],method = "spearman",
                    use = "na.or.complete")
##FIlter variables with a spearman correlation higher than 0.7
preds <- ntbox::correlation_finder(cor_mat_ccop,threshold = 0.7,verbose = F)
preds$descriptors
preds$list_cor
d_occs <- data.frame(occ,env_vals[,preds$descriptors])
##Make a list with the names of all variables
capas_names <- list.files("/home/genconser/Documentos/JoseCarlos/Landscape_Zm/Mapoteca/Chalco_var",
                          pattern = ".asc$",
                          full.names = FALSE) %>% gsub(".asc","",.)

##Filter out the .asc files that are correlated and dont have a lot of variables
ids_capas <- which(names(env_vals) %in% preds$descriptors)
pred_paths <- path_layers[ids_capas]



##Load only the maps of the selected variables
plan(multisession)
rs <- seq_along(pred_paths) %>% furrr::future_map(function(x){
  r1 <- raster::raster(pred_paths[x])
  return(r1)
},.progress = TRUE,.options = furrr_options(seed = TRUE))
plan(sequential)

rs <- raster::stack(rs)

##Transform spatial data to a lighter format (SWD=Samples With Data)
opt_swd <- ntbox::swd_format(env_layers=rs,
                             nbg=50000,
                             occs_points =occ,
                             sp_name="Zea_mays_mexicana_Chalco",
                             longitude = "Longitud",
                             latitude  = "Latitud")

dir.create("/home/genconser/Documentos/JoseCarlos/Landscape_Zm/Mapoteca/Chalco")
pred_paths2 <- gsub("Chalco_var", "Chalco", pred_paths)
file.copy(from = pred_paths, to = pred_paths2)

##We will correct the names of the soil files
corrected <- names(env_vals)[ids_capas]
path_c <- file.path("/home/genconser/Documentos/JoseCarlos/Landscape_Zm/Mapoteca/Chalco", paste0(corrected, ".asc"))
file.copy(from = pred_paths, to = path_c, overwrite = TRUE)

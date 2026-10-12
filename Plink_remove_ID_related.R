library(dplyr)

ID_related <- read.delim("/home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD/related_individuals_toRemove.txt", header=F)


# Create column of 0 (family ID)
ID_related <- data.frame(FID = 0, IID = ID_related)

# Guardar en un archivo de texto sin header ni rownames
write.table(
  ID_related, # <-- Escribimos el nuevo data frame
  file = "/home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD/related_ind_to_remove.txt",
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE,
  sep = " " # <-- Aseguramos que el separador sea un espacio
)





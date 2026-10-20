##Load and install necessary packages
library(dplyr)

##Load metadata
Metadatos_Zea <- read.delim("/home/jose-carlos-moreno-juarez/Documentos/Maestria/Metadata/ADN_pasap_4465corregido.txt", header = T)

##Eliminate duplicates
metadatos_mexicana <- Metadatos_Zea %>% filter(Especie == "Zea mays ssp. mexicana") %>%
  dplyr::filter(., Dup!=1)

##We keep only the column with the individual ids
ID_mexicana <- metadatos_mexicana$INDIV  
##Save as text file
write.table(ID_mexicana,
            file = "/home/jose-carlos-moreno-juarez/Documentos/Maestria/Metadata/ID_mexicana.txt",
            quote = FALSE,
            row.names = FALSE,
            col.names = FALSE)


##Now we make it as a format we can use to filter in Plink1.9
#Put a column with only 0s (family id)
plink_ID_file <- data.frame(FID = 0, IID = ID_mexicana)
#Save as text file
write.table(
  plink_ID_file,
  file = "/home/jose-carlos-moreno-juarez/Documentos/Maestria/Metadata/ID_mexicana_plink.txt",
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE,
  sep = " "
)


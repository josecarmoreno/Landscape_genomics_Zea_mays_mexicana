##Load or install necessary packages
library(dplyr)

##Load the individuals list. Is one of the natora's output
ID_related <- read.delim("/home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD/related_individuals_toRemove.txt", header=F)

##Transform it into the plink format for filtering
# Create column of 0s (family ids)
ID_related <- data.frame(FID = 0, IID = ID_related)

##Save as text file
write.table(
  ID_related,
  file = "/home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD/related_ind_to_remove.txt",
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE,
  sep = " "
)





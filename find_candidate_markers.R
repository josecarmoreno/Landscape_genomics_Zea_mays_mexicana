##Install pcadaptand qvalue if necessary
##install.packages("pcadapt")
##BiocManager::install("qvalue")
##Load necessary packages
library(pacman)

p_load(pcadapt,BiocManager,qvalue)

##Load genomic data
##.bed format is the fastest for this version of pcadapt
data <- read.pcadapt("/home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/Depth_8/low_stringency/Z.mexicana_filtered.bed", type = "bed")

##make pca with a large number of principal components
x <- pcadapt(input = data, K = 20) 
##make a scree plot
##We will only use the pc that correspond to population structure (4)
plot(x, option = "screeplot")

##Run the pca with 2 principal components
y <- pcadapt(data, K=4)
##make some plots to visualize the p-values of deviation from the expected distribution of SNPs
plot(y , option = "manhattan")
plot(y , option = "qqplot")


##Using the Benjamini Hochberg method of cutoff of outlier SNPs
padj <- p.adjust(y$pvalues,method="BH")
alpha <- 0.1
outliers <- which(padj < alpha)
length(outliers) ##This list only has the snp position



##To recover the name of the SNPs we need to find those in the .bim file using the positions
bim <- read.table("/home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/Depth_8/low_stringency/Z.mexicana_filtered.bim")
candidates <- bim$V2[outliers]

##Save the outliers in a .txt file for further fitlering in plink
write.table(candidates, 
            file = "/home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/Depth_8/low_stringency/outlier_snps.txt", 
            quote = FALSE, 
            row.names = FALSE, 
            col.names = FALSE)

##Now we see the association between the PC and the outliers
snp_pc <- get.pc(y, outliers)
snp_pc <- data.frame(SNP_ID = candidates, PC_asociado = snp_pc)

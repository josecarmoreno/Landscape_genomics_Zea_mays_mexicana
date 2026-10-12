## Abrí el archivo Teo_phae_1_Zea_GBSv27raw.h5 en Tassel (4,465 individuos, 955,690 SNPs)
## Extraje los individuos de Z. mays mexicana
## Convertí sitios con una profundidad menor a 8x a missing data
## Elimine sitios que tuvieran un 100% de missing data con la opcion Site Minimum Count y específicando 1 (Quedaron 606,243 SNPs)

## Filtre el archivo de metadata para solo quedarme con individuos de Z. mays mexicana y eliminar muestras duplicadas (1,489 individuos)
R Obtain_mexicana_ID.R
## Ese script crea una lista de individuos que luego será usada para filtrar la base de datos genómica con plink Indiv_mexicana_1489.txt

## Lo que seguiría sería eliminar duplicados de base de datos genómica para que sean compatibles las bases de datos
## Además se van a eliminar los sitios que no estén asignados a ningún cromosoma
## Ir al directorio donde están los datos
plink --vcf mexicana_Depth8_missing100.vcf --not-chr 0 --const-fid --keep /home/jose-carlos-moreno-juarez/Documentos/Maestria/Metadata/ID_mexicana_plink.txt --make-bed --out D8_Not_0_chr 
## Nos quedamos con 605,889 sitios (tasa de genotipificado 0.0806728)

## Seguiría eliminar sitios multialélicos 
plink2 --bfile D8_Not_0_chr --max-alleles 2 --make-bed --out D8_No_multiallelic
## No se  eliminaron sitios

## Filtramos por sitios faltantes. Estoy siguiendo un protocolo de baja astringencia
## Quitamos sitios con más de 75% de datos faltantes
plink --bfile D8_No_multiallelic --geno 0.25 --make-bed --out D8_mexicana_ML75
## Nos quedamos con 9,431 sitios

## Eliminamos individuos con 75% de datos faltantes 
plink --bfile D8_mexicana_ML75 --mind 0.25 --make-bed --out D8_mexicana_ind_75miss
## Nos quedamos con 1,234 individuos (tasa de genotipificación 0.911597)

## Eliminamos sitios que esten ligados (r^2 > 0.2) que se encuentren dentro de ventanas moviles de 1000bp con movimiento de 100
plink --bfile D8_mexicana_ind_75miss --indep-pairwise 1000 100 0.2
plink --bfile D8_mexicana_ind_75miss --make-bed --recode --extract plink.prune.in --out D8_mexicana_LD
## Nos quedamos con 7,413 sitios (tasa de genotipificación 0.912044)

## Eliminamos sitios con un maf menor a 0.05
plink --bfile D8_mexicana_LD --maf 0.05 --make-bed --out D8_mexicana_05
## Me quede con 4,964 sitios (tasa de genotipificación 0.912044)
## Hasta aquí me quedo para analisis de estructura genética

## Transformamos a formato vcf
plink --bfile D8_mexicana_05 --recode vcf-iid --out mexicana_D8_ls

###Create a list of related individuals to remove using the algorithm NAToRA
bash Natora.sh
##The result of this script is a list of individual to remove, this list can be used in plink to remove the samples

##Remove related individuals
plink --bfile D8_mexicana_05 --const-fid --remove /home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD/related_ind_to_remove.txt --make-bed --out Z.mexicana_filtered
##645 individuals remained
##Transformar a vcf 
plink --bfile Z.mexicana_filtered --recode vcf-iid --out Z.mexicana_filtered

##Find outlier loci 
R find_candidate_markers.R
##We keep only neutral SNPs
plink --bfile Z.mexicana_filtered --exclude outlier_snps.txt --make-bed --out Z.mexicana_neutral
plink --bfile Z.mexicana_neutral --recode vcf-iid --out Z.mexicana_neutral
##We make another data set only with the outlier markers
plink --bfile Z.mexicana_filtered --extract outlier_snps.txt --make-bed --out Z.mexicana_outlier
plink --bfile Z.mexicana_outlier --recode vcf-iid --out Z.mexicana_outlier


##Find genes with outlier loci
sed '/^[^#]/ s/^/chr/' /home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/Depth_8/low_stringency/Z.mexicana_outlier.vcf > /home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/Depth_8/low_stringency/Z.mexicana_outlier_chr.vcf

bedtools intersect -a /home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/Depth_8/low_stringency/Z.mexicana_outlier.vcf -b /home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/ZmB73_5b.60_FGS.gff3 -wa -wb > /home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/Depth_8/low_stringency/candidate_genes.txt

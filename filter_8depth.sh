##Opened the file Teo_phase_1_Zea_GBSv27raw.h5 in Tassel (4,465 individuals and 955,690 SNPs in the initial dataset)
##Obtain data of individuals of the subspecies Zea mays ssp mexicana (1,548 individuals)
##All sites with a sequencing depth lower than 8x were converted to missing data
##Eliminates sites with a 100% of missing daata with the option Site Minimum Count and specify 1 (606,243 SNPs left)
##We export the file from Tassel to a vcf format (File: "mexicana_Depth8_missing100.vcf")

##Filter metadata so we have only the individuals of Zea mays ssp. mexicana and duplicate samples
R Obtain_mexicana_ID.R
##This script makes a list of the individuals that will be used latter to filter the genomic data (File Indiv_mexicana_1489.txt)

##Move to the directory were we have our data
cd /home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/Depth_8/low_stringency

##Eliminate duplicate individuals from the genomic datset
##We eliminate the sites that are not assigned to any chromosome
plink --vcf mexicana_Depth8_missing100.vcf --not-chr 0 --const-fid --keep /home/jose-carlos-moreno-juarez/Documentos/Maestria/Metadata/ID_mexicana_plink.txt --make-bed --out D8_Not_0_chr 
##After this step we have 605,889 sites (genotyping rate 0.0806728)


##Eliminate multiallelic sites
plink2 --bfile D8_Not_0_chr --max-alleles 2 --make-bed --out D8_No_multiallelic
##No sites eliminated

##We are following a low stringency protocol for the filtering
##Eliminate sites with more than 75% of missing data across all samples
plink --bfile D8_No_multiallelic --geno 0.25 --make-bed --out D8_mexicana_ML75
##We are left with 9,431 sites

##Eliminate individuals with more than 75% of missing data
plink --bfile D8_mexicana_ML75 --mind 0.25 --make-bed --out D8_mexicana_ind_75miss
##We are left with 1,234 individuals (genotyping rate 0.911597)

##Eliminate sites that are under linkage disequilibrium (r^2 > 0.2) in mobile windows of 1000bp with a 100pb sliding
plink --bfile D8_mexicana_ind_75miss --indep-pairwise 1000 100 0.2
plink --bfile D8_mexicana_ind_75miss --make-bed --recode --extract plink.prune.in --out D8_mexicana_LD
##We are left with 7,413 sites (genotyping rate 0.912044)


##We eliminate sites with a minor allele frequency less than 0.05
plink --bfile D8_mexicana_LD --maf 0.05 --make-bed --out D8_mexicana_05
##We are left with 4,964 sites (genotyping rate 0.912044)
##Transform to vcf
plink --bfile D8_mexicana_05 --recode vcf-iid --out mexicana_D8_ls
##Until this point, the resulting data set will be used to calculate genetic diversity metrics


##The next steps are for generate a data set for population structure analysis
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
plink --bfile Z.mexicana_neutral --recode vcf-iid --out Z.mexicana_neutral

##We make another data set only with the outlier markers
plink --bfile Z.mexicana_filtered --extract outlier_snps.txt --make-bed --out Z.mexicana_outlier
plink --bfile Z.mexicana_outlier --recode vcf-iid --out Z.mexicana_outlier


##Optional!!!
##Find genes with outlier loci
sed '/^[^#]/ s/^/chr/' /home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/Depth_8/low_stringency/Z.mexicana_outlier.vcf > /home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/Depth_8/low_stringency/Z.mexicana_outlier_chr.vcf

bedtools intersect -a /home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/Depth_8/low_stringency/Z.mexicana_outlier.vcf -b /home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/ZmB73_5b.60_FGS.gff3 -wa -wb > /home/jose-carlos-moreno-juarez/Documentos/Maestria/Data/Depth_8/low_stringency/candidate_genes.txt

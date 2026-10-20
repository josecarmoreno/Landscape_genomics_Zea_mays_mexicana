# Landscape_genomics_Zea_mays_mexicana

## Filtering
<p>The script <strong>"filter_8depth.sh"</strong> performs the filtering for the genomic data sets and the metadata for downstream analysis. It gives three data sets as a result, 1) with neutral and outliers loci as well with related individuals, this data set will be used for genetic diversity analysis and consists of 1,234 individuals and 4,964 SNPs. 2) a data set with only neutral loci and unrelated individuals for genetic structure analysis, it consists of 645 individuals and 4,927 loci. 3) a data set with only the outlier loci, this will be used to test if there are any adaptive groups, it consists of 645 individuals and 37 SNPs.<br>
For correct functioning of the latter script, the complementary scripts are needed (they are embedded inside <strong>"filter_8depth.sh"</strong>: <strong>"Obtain_mexicana_ID.R"</strong>, <strong>"Natora.sh"</strong>, and <strong>"Plink_remove_ID_related.R"</strong>. 

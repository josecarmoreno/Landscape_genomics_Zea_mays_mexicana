# Landscape_genomics_Zea_mays_mexicana

## Filtering
<p>The script <strong>"filter_8depth.sh"</strong> performs the filtering for the genomic data sets and the metadata for downstream analysis. It gives three data sets as a result, 1) with neutral and outliers loci as well with related individuals, this data set will be used for genetic diversity analysis and consists of 1,234 individuals and 4,964 SNPs. 2) a data set with only neutral loci and unrelated individuals for genetic structure analysis, it consists of 645 individuals and 4,927 loci. 3) a data set with only the outlier loci, this will be used to test if there are any adaptive groups, it consists of 645 individuals and 37 SNPs.<br>
For correct functioning of the latter script, the complementary scripts are needed (they are embedded inside <strong>"filter_8depth.sh"</strong>): <strong>"Obtain_mexicana_ID.R"</strong>, <strong>"Natora.sh"</strong>, <strong>"Plink_remove_ID_related.R"</strong>, and <strong>"find_candidate_markers.R"</strong>.<br>
Also, we used the following scripts that are part of the NaToRA pipeline and are available in Leal, 2022; https://github.com/ldgh/NAToRA_Public. These are: <strong>"Plink2NAToRA.pl"</strong>, <strong>"NAToRA_Public.py"</strong>, and <strong>"createGML.pl"</strong>.</p>

## Genetic structure analysis 

## References
Leal, Thiago Peixoto, et al. "NAToRA, a relatedness-pruning method to minimize the loss of dataset size in genetic and omics analyses." (2022): 1821-1828.<br>

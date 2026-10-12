##This script includes scripts from a algorithm named NAToRA
##NAToRA, a relatedness-pruning method to minimize the loss of dataset size in genetic and omics analyses
##https://doi.org/10.1016/j.csbj.2022.04.009
##https://github.com/ldgh/NAToRA_Public

##Perl and Phyton3 needed

##Install dependency for create enviroments
sudo apt install python3-venv
##Install numpy
pip install numpy
#Create enviroment
python3 -m venv natora_env
source natora_env/bin/activate
#Install dependency network, version 2.5, needed for natora
pip install networkx==2.5
#Create directory for the output
mkdir /home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD 

##Use plink to calculate the Identity by Descent coefficients
plink --bfile D8_mexicana_05 --genome --out /home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD/IBD

##Script from NATORA that converts the IBD output from PLINK to a format accepted by NATORA
perl /home/jose-carlos-moreno-juarez/Documentos/Maestria/bin/Depth_8/Plink2NAToRA.pl -i /home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD/IBD.genome -o /home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD/IBD_Natora.txt

##Script from NATORA that calculates which individuals need to be pruned
##The parameter -c tells you which is the lowest grade of kinship (relatedness/2) you are taking into account
##With the grade of kinship i put im asking the analysis to prune offspring-parents, full siblings, half siblings, and uncles-nieces
python /home/jose-carlos-moreno-juarez/Documentos/Maestria/bin/Depth_8/NAToRA_Public.py --input /home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD/IBD_Natora.txt -o /home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD/related_individuals -c 0.08

##Scirpt from NATORA that creates the adjancy list to make the network in R
perl /home/jose-carlos-moreno-juarez/Documentos/Maestria/bin/Depth_8/createGML.pl -input /home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD/IBD_Natora.txt -corte 0.08 -output /home/jose-carlos-moreno-juarez/Documentos/Maestria/Out/Depth_8/IBD/Red_Parentesco.gml -default

##Graph the network
Redes_parentesco.R

##Make the list with individuals to exclude in a format allowed by PLINK
R Plink_remove_ID_related.R



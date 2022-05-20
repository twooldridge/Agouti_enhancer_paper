
# "A novel enhancer of <i>Agouti</i> contributes to parallel evolution of cryptically colored beach mice"  <br>
(Insert PNAS link here eventually)


<img src="https://github.com/twooldridge/Agouti_enhancer_paper/blob/main/IMG_0728.jpeg" width="200" />


# Summary

In here, you'll find all code used for the analyses in this project. The code is presented primarily as a set of annotated, modular, and hopefully streamlined jupyter notebooks which employ python, R, and bash. There are also a handful of helper scripts. 

If you have questions about code, versions, etc., please contact:<br>
 - Brock Wooldridge <t.brock.wooldridge@gmail.com>
 - Andi Kautt <akautt@g.harvard.edu>

# Contents
## Notebooks
1. `pigmentation_phenotyping.ipynb` - QC & analysis of phenotypic data in _P. p. albifrons_ and other populations
2. `alignment_varcalling.ipynb` - Alignment and variant calling for sequence capture and WGS data
3. `EMMAX.ipynb` - Association analysis between phenotypic data and sequence capture genotype in _P. albifrons_
4. `phylogenetics_saguaro.ipynb` - All phylogenetic analyses performed, including estimation of tree with SNAPP and HMM-classification with _Saguaro_
5. `angsd_PCA.ipynb` - _ANGSD_ based inference of genotypes and genotypic PCA
6. `SMC++.ipynb` - _SMC++_ based inference of population history and divergence time using WGS data from _P. p. leucocephalus_ and _P. p. subgriseus_
7. `haplotype_homozygosity.ipynb` - phasing of both WGS and sequence capture data, and searching for haplotype-based signals of selection using the R package _REHH_
8. `agouti_conservation.ipynb` - retrieval of Agouti sequences from rodent taxa, analyses of conservation with _phyloP_
9. `agouti_population_genetics.ipynb` - querying diversity (e.g. Theta Pi, DXY, FST) around Agouti (as well as genome wide)


## Helper scripts
1. `bamdepth2bed.py` - python script for taking the file produced by _samtools depth_ and creating a site mask
2. `bwa_aln_best_practices.sh` - short-read alignment pipeline, implemented in the `alignment_varcalling.ipynb` notebook

## Other
1. `polionotus_phenotypes.txt` - File containing all phenotypes used in the paper, from both the core _albifrons_ pop. and other beach and mainland populations. For analysis of this dataset, see `pigmentation_phenotyping.ipynb`

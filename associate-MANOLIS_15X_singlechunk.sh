#!/bin/bash



# DATA PATHS
phenotype=$1
pheno_path="/lustre/scratch115/projects/t144_helic_15x/analysis/HA/phenotypes"
#pheno_path="/nfs/t144_helic/kk9/15x_transformed_phenos"
#matrix_bfile="/lustre/scratch114/projects/helic/checkpoints/total_grm/ldpruned.hwe.1-11grm.12-22assoc/tg/gwas.mat/all.gwas.hwe.phenotg"
matrix_bfile=$2
input_bfiles="/lustre/scratch115/projects/t144_helic_15x/analysis/HA/single_point/input/chunks/missing_chunks/missing.regions"

# PROGRAM PATHS
plink=/software/team144/plink-1.9b4/plink


mkdir $phenotype
cd $phenotype

# Build phenotype file
echo "Building phenotype..."

tail -n+2 ${pheno_path}/MANOLIS.${phenotype}.txt | cut -f1,3 | awk 'BEGIN{OFS="\t"}{print $1,$1,$2}' > tmp.phenodata


# Add phenotype data to input data
echo "Building input dataset..."
$plink --memory 2000 --bfile $input_bfiles --pheno tmp.phenodata --out input.$phenotype --make-bed

# Associate
# Here just generate the GEMMA jobs!
echo "Associating..."
/nfs/team144/it3/Software_farm3/gemma-0.94/bin/gemma -bfile input.$phenotype -n 1 -notsnp  -maf 0  -miss 1  -km 1 -k $matrix_bfile -lmm 4 -o out.$phenotype
mv output/*.assoc* .
rm -rf output
rm input.*

cd ..

echo "Finished"


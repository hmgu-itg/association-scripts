#!/bin/bash

## associate_MANOLIS_in_sequence.sh
## gets a single variant and associates it with the selected phenotype in the sequencing data
## 
## SYNTAX
## associate_MANOLIS_in_sequence.sh [TRAIT] [CHR] [POS]

trait=$1
chr=$2
ps=$3
pos=$ps
plink="/software/team144/plink-versions/beta3v/plink"

## get the samples we need
zgrep -m 1 CHROM /nfs/t144_helic/sequencing-data/HP-1x-seq/imputed-secondpass-phased/1.reheaded.vcf.gz | cut -f10- | tr '\t' '\n' > samples
paste samples samples > t
mv t samples

## get variant from seq data

tabix -h /nfs/t144_helic/sequencing-data/HP-1x-seq/recalibration/recalibrated/$chr.recalibrated.vcf.gz $chr:${ps}-$ps | sed -f /nfs/t144_helic/sequencing-data/sample_tables/HP.sed > $chr.$pos.vcf

## plink to bed

$plink --vcf $chr.$pos.vcf --id-delim '.' --double-id --make-bed --pheno /lustre/scratch114/projects/helic/assoc_freeze_Summer2015_POMAK/output/ldprune_indep_50_5_2.hwe.1e-5/$trait/tmp.phenodata --out $chr.$pos --keep /lustre/scratch114/projects/helic/assoc_freeze_Summer2015_POMAK/matrices/ldprune_indep_50_5_2.hwe.1e-5/ldprune_indep_50_5_2.hwe.1e-5.fam


## assoc with previously calculated GRM

/nfs/team144/it3/Software_farm3/gemma-0.94/bin/gemma -bfile $chr.$pos -n 1 -notsnp  -maf 0  -miss 1  -km 1 -k /lustre/scratch114/projects/helic/assoc_freeze_Summer2015_POMAK/matrices/ldprune_indep_50_5_2.hwe.1e-5/output/1xseq.prune.hwe.matrix.cXX.txt -lmm 4 -o $trait.$chr.$ps
cat output/*assoc* 
rm -r output



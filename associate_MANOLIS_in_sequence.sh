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
zgrep -m 1 CHROM /nfs/t144_helic/sequencing-data/HA-4x1x-seq/imputed-secondpass/1.vcf.gz | cut -f10- | tr '\t' '\n' > samples
paste samples samples > t
mv t samples

## get variant from seq data

tabix -h /nfs/t144_helic/sequencing-data/HA-4x1x-seq/VQSR-filtered/$chr.hardfiltered.vcf.gz $chr:${ps}-$ps | sed -f /nfs/t144_helic/sequencing-data/sample_tables/HA.sed | sed -f /nfs/t144_helic/sequencing-data/sample_tables/HA.duplicates.sed > $chr.$pos.vcf

## plink to bed

$plink --vcf $chr.$pos.vcf --make-bed --keep samples --pheno /lustre/scratch114/projects/helic/assoc_freeze_Summer2015/output/ldprune_indep_50_5_2.hwe.1e-5/$trait/tmp.phenodata --out $chr.$pos


## assoc with previously calculated GRM

/nfs/team144/it3/Software_farm3/gemma-0.94/bin/gemma -bfile $chr.$pos -n 1 -notsnp  -maf 0  -miss 1  -km 1 -k /lustre/scratch114/projects/helic/assoc_freeze_Summer2015/matrices/ldprune_indep_50_5_2.hwe.1e-5/output/4x1xseq.nomono.pruned.hwe.matrix.cXX.txt -lmm 4 -o $trait.$chr.$ps
cat output/*assoc* 
rm -r output



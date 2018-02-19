#!/bin/bash

chr=$1
ps=$2
trait=$3
otherps=$4

mkdir conditional; cd conditional
zcat /lustre/scratch114/projects/helic/meta_freeze_Summer2015/$trait/*gz | awk -v c=$chr -v ps=$ps 'NR==1 || ($2==c && $3>ps-500000 && $3<ps+500000)' > reduc.peak
~/association-scripts-git/plotpeaks.sh 1e-7 reduc.peak chr ps MARKER p-value reference_allele other_allele eaf /lustre/scratch114/projects/helic/assoc_freeze_Summer2015/matrices/general_input/4x1xseq,/lustre/scratch114/projects/helic/assoc_freeze_Summer2015_POMAK/matrices/general_input/1xseq
/software/team144/plink-versions/beta3v/plink --bfile merged --pheno <(cat /lustre/scratch114/projects/helic/assoc_freeze_Summer2015/output/ldprune_indep_50_5_2.hwe.1e-5/$trait/tmp.phenodata /lustre/scratch114/projects/helic/assoc_freeze_Summer2015_POMAK/output/ldprune_indep_50_5_2.hwe.1e-5/$trait/tmp.phenodata) --recode oxford --out oxford
peaksnp=$(ls *.assoc | sed 's/.peak.*//;s/\./:/;s/^/chr/')
peakps=$(ls *.assoc | sed 's/.peak.*//;s/.*\.//')
/software/team144/snptest-latest/snptest -data oxford.gen oxford.sample -o test -frequentist 1 -range ${peakps}-$peakps  -method em -pheno phenotype 2>&1 >/dev/null
tail -n1 test

/software/team144/snptest-latest/snptest -data oxford.gen oxford.sample  -o test -frequentist 1 -range ${peakps}-$peakps -method em -pheno phenotype -condition_on chr$chr:$otherps add 2>&1 >/dev/null
tail -n1 test

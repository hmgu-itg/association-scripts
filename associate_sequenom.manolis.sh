#!/bin/bash
name=$1
trait=$2

/software/team144/plink-versions/beta3.26/plink --bfile sequenom.loz.manolisvar --allow-no-sex --pheno /lustre/scratch114/projects/helic/assoc_freeze_Summer2015/output/ldprune_indep_50_5_2.hwe.1e-5/$trait/tmp.phenodata --from $name --to $name --keep /lustre/scratch114/projects/helic/assoc_freeze_Summer2015/input/1.nomono.fam --out $name.$trait.sequenom.pheno --recode 2>&1 >/dev/null
comm -3 -1 <(cut -d' ' -f1 sequenom.loz.manolisvar.fam | sort) <(cut -f1 -d' ' /lustre/scratch114/projects/helic/assoc_freeze_Summer2015/input/1.nomono.fam | sort) | awk '{print $1, $1, "0", "0", "1", "-9", "0", "0"}' >> $name.$trait.sequenom.pheno.ped
/software/team144/plink-versions/beta3.26/plink --file $name.$trait.sequenom.pheno --make-bed --out $name.$trait.sequenom.pheno 2>&1 >/dev/null
/nfs/team144/it3/Software_farm3/gemma-0.94/bin/gemma -bfile $name.$trait.sequenom.pheno -n 1 -notsnp  -maf 0  -miss 1  -km 1 -k /lustre/scratch114/projects/helic/assoc_freeze_Summer2015/matrices/ldprune_indep_50_5_2.hwe.1e-5/output/4x1xseq.nomono.pruned.hwe.matrix.cXX.txt -lmm 4 -o $name.$trait.sequenom.pheno
echo
echo
echo
echo ====================================================
echo
echo 
echo
cat output/$name.$trait.sequenom.pheno*assoc*

#!/bin/bash

# DATA PATHS
phenotype=$1
pheno_path="/nfs/t144_helic/Phenotypes/Arthur/source_file/HA/Residuals-Plots"
matrix_bfile="/lustre/scratch114/projects/helic/assoc_freeze_Summer2015/matrices/ldprune_indep_50_5_2.hwe.1e-5/output/4x1xseq.nomono.pruned.hwe.matrix.cXX.txt"
input_bfiles="/lustre/scratch114/projects/helic/assoc_freeze_Summer2015/input/assoc_chunks"

# PROGRAM PATHS
plink="/software/team144/plink-versions/beta3r/plink"

mkdir $phenotype
cd $phenotype

# Build phenotype file
echo "Building phenotype..."

tail -n+2 ${pheno_path}/${phenotype}_HA.WGS.UK10K_stand_residuals.txt | cut -f1,3 | awk 'BEGIN{OFS="\t"}{print $1,$1,$2}' > tmp.phenodata


# Add phenotype data to input data
echo "Building input dataset..."
mkdir input
for file in `ls $input_bfiles/*.fam | sed 's/.fam//'`
do
    file=$(basename $file)
    echo $plink --memory 2000 --bfile $input_bfiles/$file --pheno tmp.phenodata --out input/$file --make-bed
done | ~/array 2g rph > phenotypize.command
chmod +x phenotypize.command
jobid=$(./phenotypize.command | sed 's/Job <//;s/> is.*//')
sleep 10
echo "Watching for preparation job array $jobid to finish..."
njobs=$(bjobs | grep -w $jobid | wc -l)

while [ $njobs -gt 0  ]
do
    njobs=$(bjobs | grep -w $jobid | wc -l)
    sleep 5
done

xitstatus=$(grep xited rph*.o)
xited=$(grep xited rph*.o | wc -l)
if [ $xited -gt 0 ]
then
    echo "Some phenotyping jobs have failed:"
    echo $xitstatus
    exit
fi
rm rph*[eo]

# Associate
# Here just generate the GEMMA jobs!
echo "Associating..."
for i in `ls input/*.fam | sed 's/input.//;s/.fam//'`
do
    echo /nfs/team144/it3/Software_farm3/gemma-0.94/bin/gemma -bfile input/$i -n 1 -notsnp  -maf 0  -miss 1  -km 1 -k $matrix_bfile -lmm 4 -o $i
done | ~/array 5g asc > assoc.command
chmod +x assoc.command
jobid=$(./assoc.command | sed 's/Job <//;s/> is.*//')

echo "Watching for association job array $jobid to finish..."
sleep 5
njobs=$(bjobs | grep -w $jobid | wc -l)

while [ $njobs -gt 0  ]
do
    njobs=$(bjobs | grep -w $jobid | wc -l)
    sleep 5
done

xitstatus=$(grep xited asc*.o )
xited=$(grep xited asc*.o | wc -l)
if [ $xited -gt 0 ]
then
    echo "Some phenotyping jobs have failed:"
    echo $xitstatus
    exit
fi
rm asc*[eo]

echo "Concatenating..."

head -n1 $(ls output/*.assoc.txt | head -n1) > MANOLIS.$phenotype.assoc.txt
for i in {1..22}
do
    for j in `ls output/$i.*.assoc.txt`
    do
	tail -n+2 $j
    done | sort -k3,3n
done >> MANOLIS.$phenotype.assoc.txt

echo "Building graphs.."
export CF9_R_LIBS="/software/team144/cf9/lib/my_R"
hsub 10g -I -q yesterday ~/man_qq_annotate --chr-col chr --pos-col ps --auto-label --pval-col p_score --title "MANOLIS-$phenotype" --sig-thresh 1e-08 --sig-thresh-line 1e-08 MANOLIS.$phenotype.assoc.txt MANOLIS.$phenotype.assoc

awk '$7>0.001' MANOLIS.$phenotype.assoc.txt > MANOLIS.$phenotype.maf0.001.assoc.txt
gzip MANOLIS.$phenotype.assoc.txt

hsub 10g -I -q yesterday ~/man_qq_annotate --chr-col chr --pos-col ps --auto-label --pval-col p_score --title "MANOLIS-$phenotype-MAF0.001" --sig-thresh 1e-08 --sig-thresh-line 1e-08 MANOLIS.$phenotype.maf0.001.assoc.txt MANOLIS.$phenotype.maf0.001.assoc

rm -r input output


gzip MANOLIS.$phenotype.maf0.001.assoc.txt

cd ..

echo "Finished"

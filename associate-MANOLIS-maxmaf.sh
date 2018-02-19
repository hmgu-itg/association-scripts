#!/bin/bash

# DATA PATHS
phenotype=$1
pheno_path="/nfs/t144_helic/Phenotypes/DataExtracts/WGS/HELIC_HA_WGS_Phenotypes.txt"
matrix_bfile="/lustre/scratch114/projects/helic/checkpoints/total_grm/ldpruned.hwe.1-11grm.12-22assoc/tg/gwas.mat/all.gwas.hwe.phenotg"
input_bfiles="/lustre/scratch114/projects/helic/checkpoints/total_grm/input/unfiltered/chunks"

# PROGRAM PATHS
plink="/software/team144/plink-dev-0909/plink"


# Build phenotype file
echo "Building phenotype..."
column=$(head -n1 $pheno_path | tr '\t' '\n' | grep -w -n $phenotype| sed 's/\:.*//')

if [ -z $column ]
then
echo "Phenotype $phenotype not found."
exit
fi

tail -n+2 $pheno_path | cut -f1,$column | awk 'BEGIN{OFS="\t"}{print $1,$1,$2}' > tmp.phenodata

if false; then
# Add phenotype data to matrix
echo "Generating GRM..."
hsub 5g -I $plink --memory 5000 --bfile $matrix_bfile --pheno tmp.phenodata --out matrixinput.$phenotype --make-bed --hwe 1e-4
hsub 10g -I /nfs/team144/it3/Software_farm3/gemma-0.94/bin/gemma -bfile matrixinput.$phenotype -gk 1 -n 1 -o matrix.$phenotype
if [ ! -f output/matrix.$phenotype.cXX.txt  ]
then
echo "The matrix generation step has failed."
exit
fi
mv output matrix

fi

# Add phenotype data to input data
echo "Building input dataset..."
mkdir input
for file in `ls $input_bfiles/*.fam | sed 's/.fam//'`
do
    file=$(basename $file)
    echo $plink --memory 2000 --bfile $input_bfiles/$file --pheno tmp.phenodata --out input/$file --make-bed -mac $2 --max-maf 0.1
done | ~/array 2g rph > phenotypize.command
chmod +x phenotypize.command
jobid=$(./phenotypize.command | sed 's/Job <//;s/> is.*//')
sleep 5
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
    echo /nfs/team144/it3/Software_farm3/gemma-0.94/bin/gemma -bfile input/$i -n 1 -notsnp  -maf 0  -miss 1  -km 1 -k /lustre/scratch114/projects/helic/checkpoints/assoc_test/phenotypes/BMI/matrix/matrix.BMI.cXX.txt -lmm 4 -o $i
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
hsub 10g -I -q yesterday ~/man_qq_annotate --chr-col chr --pos-col ps --auto-label --pval-col p_score --title "MANOLIS-$phenotype" MANOLIS.$phenotype.assoc.txt MANOLIS.$phenotype.assoc

echo "Finished"

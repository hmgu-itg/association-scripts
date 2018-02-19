#!/bin/bash



# DATA PATHS
phenotype=$1
pheno_path="/lustre/scratch115/projects/t144_helic_15x/analysis/HA/phenotypes"
#pheno_path="/nfs/t144_helic/kk9/15x_transformed_phenos"
#matrix_bfile="/lustre/scratch114/projects/helic/checkpoints/total_grm/ldpruned.hwe.1-11grm.12-22assoc/tg/gwas.mat/all.gwas.hwe.phenotg"
matrix_bfile=$2
input_bfiles="/lustre/scratch115/projects/t144_helic_15x/analysis/HA/single_point/input/chunks"

# PROGRAM PATHS
plink=plink


mkdir $phenotype
cd $phenotype

# Build phenotype file
echo "Building phenotype..."

tail -n+2 ${pheno_path}/MANOLIS.${phenotype}.txt | cut -f1,3 | awk 'BEGIN{OFS="\t"}{print $1,$1,$2}' > tmp.phenodata


# Add phenotype data to input data
echo "Building input dataset..."
mkdir input
for file in `ls $input_bfiles/*.fam | sed 's/.fam//'`
do
    file=$(basename $file)
    echo $plink --memory 2000 --bfile $input_bfiles/$file --pheno tmp.phenodata --out input/$file --make-bed
done | ~ag15/array 2g rph | sed 's/red/green/'> phenotypize.command
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
done | ~ag15/array 5g asc | sed 's/red/green/'> assoc.command
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
    echo "Some association jobs have failed:"
    echo $xitstatus
    exit
fi
rm asc*[eo]


echo "Concatenating..."

head -n1 $(ls output/*.assoc.txt | head -n1) > MANOLIS.$phenotype.assoc.txt
for i in {1..22}
do
    for j in `ls output/chunk.${i}\:*.assoc.txt`
    do
	tail -n+2 $j
    done | sort -k3,3n
done >> MANOLIS.$phenotype.assoc.txt


echo "Building graphs.."
export CF9_R_LIBS="/software/team144/cf9/lib/my_R"
gsub 10g -I -q yesterday ~ag15/scripts/man_qq_annotate --chr-col chr --pos-col ps --auto-label --pval-col p_score --title "MANOLIS-$phenotype" --sig-thresh 1e-08 --sig-thresh-line 1e-08 MANOLIS.$phenotype.assoc.txt MANOLIS.$phenotype.assoc

awk '$7>0.001' MANOLIS.$phenotype.assoc.txt > MANOLIS.$phenotype.maf0.001.assoc.txt
gzip MANOLIS.$phenotype.assoc.txt

gsub 10g -I -q yesterday ~ag15/scripts/man_qq_annotate --chr-col chr --pos-col ps --auto-label --pval-col p_score --title "MANOLIS-$phenotype-MAF0.001" --sig-thresh 1e-08 --sig-thresh-line 1e-08 MANOLIS.$phenotype.maf0.001.assoc.txt MANOLIS.$phenotype.maf0.001.assoc

# rm -r input output


gzip MANOLIS.$phenotype.maf0.001.assoc.txt

cd ..

echo "Finished"

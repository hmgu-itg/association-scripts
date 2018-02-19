#!/bin/bash



# DATA PATHS
cohort=INTERVAL
phenotype=$1
pheno_path=/lustre/scratch115/realdata/mdt0/projects/t144_helic_15x/analysis/INTERVAL/phenotypes/transformed

matrix_bfile=/lustre/scratch115/realdata/mdt0/projects/t144_helic_15x/analysis/INTERVAL/byChr/relmat/output/merge.cXX.txt
input_bfiles=/lustre/scratch115/projects/t144_helic_15x/analysis/INTERVAL/single_point/input

# PROGRAM PATHS
plink=plink
tabix=tabix

# Exports
export CF9_R_LIBS="/software/team144/cf9/lib/my_R"
export PATH=/nfs/users/nfs_a/ag15/local_programs:$PATH
export LSB_DEFAULTGROUP=helic
export R_LIBS=/nfs/users/nfs_k/kh7/rpack:/nfs/users/nfs_a/ag15/R/x86_64-unknown-linux-gnu-library/3.0:/software/R-3.0.0/lib/R/library


mkdir -p $phenotype
cd $phenotype
#if false; then
# Build phenotype file
echo "Building phenotype..."

tail -n+2 ${pheno_path}/$cohort.${phenotype}.txt | cut -f1,3 | awk 'BEGIN{OFS="\t"}{print $1,$1,$2}' > tmp.phenodata


# Add phenotype data to input data
echo "Building input dataset..."
mkdir input
for file in `ls $input_bfiles/*.fam | sed 's/.fam//'`
do
    file=$(basename $file)
    echo $plink --memory 10000 --bfile $input_bfiles/$file --pheno tmp.phenodata --out input/$file --make-bed
done | ~ag15/array 10g rph | sed 's/red/green/'> phenotypize.command
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
done | ~ag15/array 10g asc | sed 's/red/green/'> assoc.command
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
#fi

echo "Concatenating..."

head -n1 $(ls output/*.assoc.txt | head -n1) > $cohort.$phenotype.assoc.txt
for i in {1..22}
do
    for j in `ls output/*.chr$i.*.assoc.txt`
    do
	tail -n+2 $j
    done | sort -k3,3n
done >> $cohort.$phenotype.assoc.txt


echo "Building graphs.."

bgzip $cohort.$phenotype.assoc.txt
tabix -s 1 -b 3 -e 3 -S 1 $cohort.$phenotype.assoc.txt.gz
gsub 10g -I -q yesterday ~ag15/scripts/man_qq_annotate --chr-col chr --pos-col ps --auto-label --pval-col p_score --title "${cohort}-$phenotype" --sig-thresh 1e-08 --sig-thresh-line 1e-08 $cohort.$phenotype.assoc.txt.gz $cohort.$phenotype.assoc

#zcat $cohort.$phenotype.assoc.txt.gz | awk '$7>0.001'  | bgzip > $cohort.$phenotype.maf0.001.assoc.txt.gz
#tabix -s 1 -b 3 -e 3 -S 1 $cohort.$phenotype.maf0.001.assoc.txt.gz
#gsub 10g -I -q yesterday ~ag15/scripts/man_qq_annotate --chr-col chr --pos-col ps --auto-label --pval-col p_score --title "${cohort}-$phenotype-MAF0.001" --sig-thresh 1e-08 --sig-thresh-line 1e-08 $cohort.$phenotype.maf0.001.assoc.txt.gz $cohort.$phenotype.maf0.001.assoc

#rm -r input output


cd ..

echo "Finished"

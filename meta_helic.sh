#!/bin/bash

pheno=$1
export CF9_R_LIBS="/software/team144/cf9/lib/my_R"
baseha=/lustre/scratch114/projects/helic/assoc_freeze_Summer2015/output/ldprune_indep_50_5_2.hwe.1e-5
basehp=/lustre/scratch114/projects/helic/assoc_freeze_Summer2015_POMAK/output/ldprune_indep_50_5_2.hwe.1e-5
mkdir -p /lustre/scratch114/projects/helic/meta_freeze_Summer2015/$pheno
cd /lustre/scratch114/projects/helic/meta_freeze_Summer2015/$pheno
echo -e "\n\nUncompressing and formatting input from MANOLIS...\n============================================\n\n"
zcat $baseha/$pheno/*maf0.001.assoc.txt.gz | awk 'OFS="\t"{if(NR==1){print "MARKER", "EA", "NEA", "BETA", "SE", "N", "EAF"}else{print $2, $5, $6, $8, $9, 1239-$4, $7}}' > manolis.in
echo "Uncompressing and formatting input from POMAK..."
zcat $basehp/$pheno/*maf0.001.assoc.txt.gz | awk 'OFS="\t"{if(NR==1){print "MARKER", "EA", "NEA", "BETA", "SE", "N", "EAF"}else{print $2, $5, $6, $8, $9, 1239-$4, $7}}' > pomak.in
echo -e "manolis.in\npomak.in" > gwama.in
echo -e "\n\nRunning GWAMA...\n===============\n\n"
/lustre/scratch114/projects/helic/meta_freeze_Summer2015/gwama2.1/GWAMA -o $pheno.HELIC -gc -qt
echo -e "\n\nSaving space...\n===============\n\n"

# rm pomak.in manolis.in

echo -e "\n\nFetching positions for plot...\n=============================\n\n"
zcat $baseha/$pheno/*maf0.001.assoc.txt.gz |awk 'OFS="\t"{print $2, $1, $3}' > chrpos
cat <(paste <(echo -e "MARKER\tchr\tps") <(head -n1 $pheno.HELIC.out | cut -f2-) ) <(join -j1 <(sort -k1,1 chrpos) <(sort -k1,1 $pheno.HELIC.out)) | tr ' ' '\t'> $pheno.HELIC.formatted.out
rm $pheno.HELIC.out
echo -e "\n\nPlotting...\n===========\n\n"
~ag15/man_qq_annotate --chr-col chr --pos-col ps --auto-label --pval-col "p-value" --title "$pheno.MANOLIS+POMAK" --sig-thresh 1e-08 --sig-thresh-line 1e-08 $pheno.HELIC.formatted.out $pheno.HELIC
echo -e "\n\nSaving space...\n==============\n\n"
gzip $pheno.HELIC.formatted.out 
cd -

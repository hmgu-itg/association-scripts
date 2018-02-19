#!/bin/bash
export CF9_R_LIBS="/software/team144/cf9/lib/my_R"
gunzip $1
unz=$(echo $1 | sed 's/.gz//')
/software/bin/Rscript --vanilla /nfs/users/nfs_a/ag15/association-scripts/gccorrect_smart.R $unz
gzip $unz
gunzip $unz.gccorrect.gz
~/man_qq_annotate --chr-col chr --pos-col ps --auto-label --pval-col gc_score_smart --title "gc-corrected" --sig-thresh 1e-08 --sig-thresh-line 1e-08 $unz.gccorrect.smart $unz.gccorrect.smart
gzip $unz.gccorrect.smart

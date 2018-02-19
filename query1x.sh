#!/bin/bash
trait=$1
chr=$2
ps=$3
zcat /lustre/scratch114/projects/helic/assoc_freeze_Summer2015/output/ldprune_indep_50_5_2.hwe.1e-5/$trait/*gcco*gz |awk -v c=$chr -v p=$ps '$1==c && $3==p' | head -n1
zcat /lustre/scratch114/projects/helic/meta_freeze_Summer2015/$trait/*.formatted.out.gz | awk -v c=$chr -v p=$ps '$2==c && $3==p' | head -n1
zcat /lustre/scratch114/projects/helic/assoc_freeze_Summer2015_POMAK/output/ldprune_indep_50_5_2.hwe.1e-5/$trait/*gcco*gz |awk -v c=$chr -v p=$ps '$1==c && $3==p' | head -n1

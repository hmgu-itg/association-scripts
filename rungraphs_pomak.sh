#!/bin/bash

cd $1

~/association-scripts/plotpeaks.sh 5e-7 *smart*.gz chr ps rs gc_score_smart allele1 allele0 af /lustre/scratch114/projects/helic/assoc_freeze_Summer2015_POMAK/matrices/general_input/1xseq

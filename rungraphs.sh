#!/bin/bash

cd $1

~/association-scripts/plotpeaks.sh 5e-7 *gcco*.gz chr ps rs gc_score allele1 allele0 af /lustre/scratch114/projects/helic/assoc_freeze_Summer2015/matrices/general_input/4x1xseq

#!/bin/bash

/nfs/team144/software/locuszoom-1.3/locuszoom/bin/locuszoom --metal $1 --refsnp $2 --markercol $3 --pvalcol $4 --db $5 --prefix $6 --plotonly showAnnot=T showRefsnpAnnot=T annotPch="21,24,24,25,22,22,8,7" rfrows=20 geneFontSize=.4 --ld $7 --start=$8 --end=$9 --chr=${10} showRecomb=T --delim ' '
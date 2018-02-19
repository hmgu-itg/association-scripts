#!/bin/bash

vcf=$1
chr=$2
ps=$3

qualstring=$(tabix $vcf $chr:$ps-$ps | cut -f6,7)
count=$(tabix $vcf $chr:$ps-$ps | cut -f10- |tr '\t' '\n' | sed 's/\:.*//' | tr '\n' '\t' | perl -ne 'my $c = () = $_ =~ /1/g;print $c')

echo $qualstring $count

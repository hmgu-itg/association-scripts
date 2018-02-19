library(data.table)
d=fread("peakdata")
t=table(d$gc_score)
t=t[t!=1]

d=d[!(d$gc_score %in% head(as.numeric(names(sort(t, decreasing=T))), 10)),]

write.table(d, "peakdata.cleaned", sep=" ", row.names=F, col.names=T, quote=F)

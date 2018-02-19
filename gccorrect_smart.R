args <- commandArgs(trailingOnly = TRUE)
library(data.table)
d=fread(args[1])
psmart=0
psmart[d$af<0.05]=d$p_lrt[d$af<0.05]
psmart[d$af>=0.05]=d$p_score[d$af>=0.05]
d$p_smart=psmart
lambda=round(median(qchisq(d$p_smart,df=1,lower.tail=FALSE),na.rm=TRUE)/qchisq(0.5,1),3)
d$gc_score_smart=pchisq(qchisq(d$p_smart,1, lower.tail=F)/lambda,1, lower.tail=F)
write.table(d, paste(args[1], ".gccorrect.smart", sep=""), row.names=F, quote=F, col.names=T, sep="\t")


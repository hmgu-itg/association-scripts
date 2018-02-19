
# Standardizes a vector of data (normal data please)
stand=function(x){return((x-mean(x, na.rm=T))/sd(x, na.rm=T))}

# Stratifies by a binomial variable and standardizes data (mixture of normals please)
stratu=function(x,s){m=mean(x, na.rm=T);x1=x[s==1];x2=x[s!=1];x1=(x1-mean(x1, na.rm=T))/sd(x1, na.rm=T);x2=(x2-mean(x2, na.rm=T))/sd(x2, na.rm=T);y=0;y[s==1]=x1;y[s!=1]=x2;return(y+m)}
	

# Finds the best log transformation of the form log(x+e) where e <=10
bestlog=function(x, tol=0.01){
		v<<-x
		o=function(y){return(shapiro.test(stand(log(v+y, base=10)))$p.value)}
		 upper=max(log(unlist(lapply(seq(-min(v, na.rm=T)+tol, 10, by=tol), FUN=o)), base=10))
		 m=seq(-min(v, na.rm=T)+tol, 10, by=tol)[log(unlist(lapply(seq(-min(v, na.rm=T)+tol, 10, by=tol), FUN=o)), base=10)==upper]
		 diff=abs(upper-o(0))/abs(m)
		 plot(x=seq(-min(v, na.rm=T)+tol, 10, by=tol), y=log((unlist(lapply(seq(-min(v, na.rm=T)+tol, 10, by=tol), FUN=o))), base=10),main=m)
		 abline(v=0)
		 abline(v=m)
		 return(list(offset=m, best_shapiro_log=upper, best_shapiro=exp(upper*log(10)), differential=diff))

	}

# tests for sex dependency
	sex.dep=function(x,s){return(wilcox.test(x[s==1], x[s!=1])$p.value)}
# test for quantitative variable dependency
	var.dep=function(x,y){return(list(kendall=cor.test(x,y, method="kendall")$p.value, spearman=cor.test(x,y, method="spearman")$p.value, hoeffding=hoeffd(x,y)$P[1,2]))}

# tests a few usual power functions
usualfunc = function (x){
	v<<-x
	powers=c(-2, -1, -0.5, 1, 0.5, 2, 3);
	o=function(y){return(shapiro.test(stand(v^y))$p.value)}
	l=t(as.matrix(unlist(lapply(powers, FUN=o))))
	colnames(l)=powers
	return(list(best_power=powers[l==max(l)], best_power_shapiro=max(l), allvalues=l))
}

# applies the function f on x stratified by s (I think)
strat.trans=function(x, s, f){
	x1=x[s==1 & !is.na(s)];
	x2=x[s==2 & !is.na(s)];
	x1=f(x1)
	x2=f(x2)
	x1=(x1-mean(x1, na.rm=T))/sd(x1, na.rm=T);
	x2=(x2-mean(x2, na.rm=T))/sd(x2, na.rm=T);
	y=0;
	y[s==1 & !is.na(s)]=x1;
	y[s==2 & !is.na(s)]=x2;
	y[is.na(s)]=NA;
	return(y)
}

# the same, but only for the values where c is true
strat.trans.cond=function(x, c, s, f){
	x1=x[s==1 & !is.na(s)];
	x2=x[s==2 & !is.na(s)];
	x1=f(x1)
	x2=f(x2)
	x1=(x1-mean(x1, na.rm=T))/sd(x1, na.rm=T);
	x2=(x2-mean(x2, na.rm=T))/sd(x2, na.rm=T);
	y=0;
	y[s==1 & !is.na(s)]=x1;
	y[s==2 & !is.na(s)]=x2;
	y[is.na(s)]=NA;
	y[!c]=NA
	return(y)
}

# regresses x against c stratifying by s
strat.lm=function(x, s, c){
	t=s[!is.na(s) & !is.na(x) & !is.na(c)]
	z=x[!is.na(s) & !is.na(x) & !is.na(c)]
	d=c[!is.na(s) & !is.na(x) & !is.na(c)]

	x1=z[t==1];
	x2=z[t!=1];
	x1=lm(x1~d[t==1])$residuals
	x2=lm(x2~d[t!=1])$residuals
	y=0;
	y[t==1]=x1;
	y[t!=1]=x2;
	return(y)
}


### The following functions test for the Box-Cox transformation from ^-5 to ^5
## Call through boxit(x)

boxcox=function(y, lambda){
	if(lambda==0){return(log(0))}
	else{return((y^lambda-1)/lambda)}
}

normaldistance=function(y){
	q=qqnorm((y-mean(y))/sd(y), plot.it=F);
	return(mean(abs(q$x-q$y)/sqrt(2)));
}

bogusoptim=function(lambda, y){
	return(normaldistance(boxcox(y, lambda)));
}

boxit=function(y, tolerance=0.1){
	return(optimise(bogusoptim, c(-5,5), tol=tolerance, y));
}


### Inverse normal transform (last resort)
rankit=function(y, c=3/8){
	return(qnorm( (rank(y)-c)/(length(y)-2*c+1)   ))
}


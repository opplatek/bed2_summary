#!/usr/bin/env Rscript
library(parallel)
Args=commandArgs()
#print(Args)
# help----
if(length(Args)<7){
	stop(paste("usage:\n\t",substr(Args[4],8,100)," CPU prefix1 [prefix2_to_compare_with_prefix1]\n",sep=""))
}

#Args<-c(1,2,3,4,5, "1", "/home/joppelt/projects/pirna_mouse/analysis/pirna-clusters/results/mmu.sRNASeq.MiwiIP.MiwiHet.P24.1/piPipes/bed2_summary/reads.1.adtrim.20-23nt.transposon")

# function----
fun_zscore=function(x){
	x_HkGene=x[c(1:9,11:30)]
	x_treat=x[10]
	z=(x_treat-mean(x_HkGene))/sd(x_HkGene)
	return(z)
}
fun_plot_lendis=function(x1, x2, m){
	par(mar=c(0,2,2,0.5))
	barplot(x1,space=0,border="white",col="#e41a1c",ylim=c(0,max(x1,x2)),xaxt="n")
	mtext(m,3,font=2)
	par(mar=c(2,2,0,0.5))
	barplot(-x2,space=0,border="white",col="#377eb8",ylim=c(-max(x1,x2),0),xaxt="n")
	axis(1,1:21-0.5,label=15:35,lwd=0,padj=-0.3)
}
fun_plot_pp=function(x){
	par(mar=c(3,3,3,1),cex=0.65)
	barplot(x,space=0,border="white",col="black",ylim=c(0,max(x)),xaxt="n")
	axis(1,c(1,10,20,30)-0.5,label=c(1,10,20,30),lwd=0)
	zs=round((x[10]-mean(x[c(1:9,11:30)]))/sd(x[c(1:9,11:30)]),2)
	text(10,max(x)*9/10,label=paste("z-score=",zs,sep=""),col="#e41a1c",font=2,pos=4,cex=1.2)
}
fun_plot_bucket=function(x){
	m=max(c(x[,3],-x[,4])); h=signif(m/4,1)
	par(mar=c(0,2,2,0.5))
	barplot(as.vector(x[,3]),col="#fcbba1",border="#fcbba1",xaxt="n",space=0,yaxt="n",ylim=c(0,m))
	barplot(as.vector(x[,5]),col="#a50f15",border="#a50f15",xaxt="n",space=0,yaxt="n",add=T)
	axis(2,h*(0:4),label=h*(0:4))
	legend(dim(x)[1]/3,m*1.1,legend=c("uniqReads","allReads"),fill=c("#a50f15","#fcbba1"),xpd=T,ncol=2,bty="n")
	par(mar=c(2,2,0,0.5))
	barplot(as.vector(x[,4]),col="#9ecae1",border="#9ecae1",xaxt="n",space=0,yaxt="n",ylim=c(-m,0))
	barplot(as.vector(x[,6]),col="#08519c",border="#08519c",xaxt="n",space=0,yaxt="n",add=T)
	axis(2,-h*(0:4),label=c("",-h*(1:4)))
	axis(1,c(1,floor(dim(x)[1]/4*(1:4)))-0.5,label=c(1,x[dim(x)[1]/4*(1:4),2]))
}
fun_plot_lendis2=function(x1, x2, y1, y2, m){
	par(mar=c(0,2,2,0.5))
	barplot(x1,space=0,border="white",col="#e41a1c",ylim=c(0,max(x1,x2,y1,y2)),xaxt="n")
	mtext(m,3,font=2)
	par(mar=c(2,2,0,0.5))
	barplot(-x2,space=0,border="white",col="#377eb8",ylim=c(-max(x1,x2,y1,y2),0),xaxt="n")
	axis(1,1:21-0.5,label=15:35,lwd=0,padj=-0.3)
	par(mar=c(0,2,2,0.5))
	barplot(y1,space=0,border="white",col="#e41a1c",ylim=c(0,max(x1,x2,y1,y2)),xaxt="n")
	par(mar=c(2,2,0,0.5))
	barplot(-y2,space=0,border="white",col="#377eb8",ylim=c(-max(x1,x2,y1,y2),0),xaxt="n")
	axis(1,1:21-0.5,label=15:35,lwd=0,padj=-0.3)
}
fun_plot_pp2=function(x, y){
	par(mar=c(3,3,3,1),cex=0.65)
	barplot(x,space=0,border="white",col="black",ylim=c(0,max(x, y)),xaxt="n")
	axis(1,c(1,10,20,30)-0.5,label=c(1,10,20,30),lwd=0)
	zs=round((x[10]-mean(x[c(1:9,11:30)]))/sd(x[c(1:9,11:30)]),2)
	text(10,max(x,y)*9/10,label=paste("z-score=",zs,sep=""),col="#e41a1c",font=2,pos=4,cex=1.2)
	par(mar=c(3,3,3,1),cex=0.65)
	barplot(y,space=0,border="white",col="black",ylim=c(0,max(x,y)),xaxt="n")
	axis(1,c(1,10,20,30)-0.5,label=c(1,10,20,30),lwd=0)
	zs=round((y[10]-mean(y[c(1:9,11:30)]))/sd(y[c(1:9,11:30)]),2)
	text(10,max(x,y)*9/10,label=paste("z-score=",zs,sep=""),col="#e41a1c",font=2,pos=4,cex=1.2)
}
fun_plot_bucket2=function(x, y){
	m=max(c(x[,3],-x[,4],y[,3],-y[,4])); h=signif(m/4,1)
	par(mar=c(0,2,2,0.5))
	barplot(as.vector(x[,3]),col="#fcbba1",border="#fcbba1",xaxt="n",space=0,yaxt="n",ylim=c(0,m))
	barplot(as.vector(x[,5]),col="#a50f15",border="#a50f15",xaxt="n",space=0,yaxt="n",add=T)
	axis(2,h*(0:4),label=h*(0:4))
	legend(dim(x)[1]/3,m*1.1,legend=c("uniqReads","allReads"),fill=c("#a50f15","#fcbba1"),xpd=T,ncol=2,bty="n")
	par(mar=c(2,2,0,0.5))
	barplot(as.vector(x[,4]),col="#9ecae1",border="#9ecae1",xaxt="n",space=0,yaxt="n",ylim=c(-m,0))
	barplot(as.vector(x[,6]),col="#08519c",border="#08519c",xaxt="n",space=0,yaxt="n",add=T)
	axis(2,-h*(0:4),label=c("",-h*(1:4)))
	axis(1,c(1,floor(dim(x)[1]/4*(1:4)))-0.5,label=c(1,x[dim(x)[1]/4*(1:4),2]))
	par(mar=c(0,2,2,0.5))
	barplot(as.vector(y[,3]),col="#fcbba1",border="#fcbba1",xaxt="n",space=0,yaxt="n",ylim=c(0,m))
	barplot(as.vector(y[,5]),col="#a50f15",border="#a50f15",xaxt="n",space=0,yaxt="n",add=T)
	axis(2,h*(0:4),label=h*(0:4))
	par(mar=c(2,2,0,0.5))
	barplot(as.vector(y[,4]),col="#9ecae1",border="#9ecae1",xaxt="n",space=0,yaxt="n",ylim=c(-m,0))
	barplot(as.vector(y[,6]),col="#08519c",border="#08519c",xaxt="n",space=0,yaxt="n",add=T)
	axis(2,-h*(0:4),label=c("",-h*(1:4)))
	axis(1,c(1,floor(dim(y)[1]/4*(1:4)))-0.5,label=c(1,y[dim(y)[1]/4*(1:4),2]))
}
fun_plot_scatter2=function(x, y, n1, n2, m){
	par(mar=c(4,4,4,2))
	lb=expression(10^0,10^1,10^2,10^3,10^4,10^5)
	cl=rep("black",length(x))
	cl[which((x+1)/(y+1)>2)]="#377eb8"
	cl[which((x+1)/(y+1)<1/2)]="#e41a1c"
	i1=log10(x+1); i2=log10(y+1)
	plot(-100,xlim=c(0,max(i1,i2)),ylim=c(0,max(i1,i2)),main=m,xaxt="n",yaxt="n",
	     xlab=paste(n1," + 1",sep=""),ylab=paste(n2," + 1",sep=""))
	abline(0,1); abline(log10(2),1,lty=2); abline(-log10(2),1,lty=2)
	if(length(cl)<2000){
		points(i1,i2,pch=21,col="white",bg=cl)
	}else{
		points(i1,i2,pch=20,col=cl,cex=0.3)
	}
	if(length(imp_pi_dm3)==2){
		points(i1[imp_pi_dm3],i2[imp_pi_dm3],pch=1,cex=1.1)
		text(i1[imp_pi_dm3],i2[imp_pi_dm3],label=c("42AB","flam"),pos=1,font=2)
	}
	pv=signif(wilcox.test(i1,i2,paired=T)$p.value,2)
	text(0,max(i1,i2)*9/10,pos=4,label=paste("p-value = ",pv,sep=""),font=2)
	axis(1,0:5,label=lb)
	axis(2,0:5,label=lb)
}
fun_plot_scatter2_for_pp=function(x, y, n1, n2){
	x=x[,9]; y=y[,9]
	par(mar=c(4,4,4,2))
	cl=rep("black",length(x))
	cl[which((x+2)/(y+2)>2)]="#377eb8"
	cl[which((x+2)/(y+2)<1/2)]="#e41a1c"
	i1=log2(x+2); i2=log2(y+2)
	plot(-100,xlim=c(0,min(max(i1,i2),9)),ylim=c(0,min(9,max(i1,i2))),xlab=n1,ylab=n2,xaxt="n",yaxt="n",main="ping-pong zscore")
	axis(1,0:10,label=c(2^(0:10)-2))
	axis(2,0:10,label=c(2^(0:10)-2))
	abline(0,1); abline(1,1,lty=2); abline(-1,1,lty=2)
	if(length(cl)<2000){
		points(i1,i2,pch=21,col="white",bg=cl)
	}else{
		points(i1,i2,pch=20,col=cl,cex=0.5)
	}
	if(length(imp_pi_dm3)==2){
		points(i1[imp_pi_dm3],i2[imp_pi_dm3],pch=1,cex=1.1)
		text(i1[imp_pi_dm3],i2[imp_pi_dm3],label=c("42AB","flam"),pos=1,font=2)
	}
	pv=signif(wilcox.test(i1,i2,paired=T)$p.value,2)
	text(0,max(i1,i2)*9/10,pos=4,label=paste("p-value = ",pv,sep=""),font=2)
}
fun_plot_scatter2_for_entropy=function(x, y, n1, n2){
	par(mar=c(4,4,4,2),bty="n")
	lb=expression(10^0,10^1,10^2,10^3,10^4,10^5)
	boxplot(log10(x[,1]+1),log10(y[,1]+1),log10(x[,2]+1),log10(y[,2]+1),at=c(1,2,4,5),staplewex=0,lty=1,
		col=c("#e41a1c","white","#377eb8","white"),border=c("black","#e41a1c","black","#377eb8"),
		ylab="RPM + 1",xaxt="n",main="uniqMappers",yaxt="n")
	axis(1,at=c(1.5,4.5),label=c("sense","antisense"),lwd=0)
	axis(2,0:5,label=lb)
	pv1=signif(wilcox.test(x[,1],y[,1],paired=T)$p.value,2)
	pv2=signif(wilcox.test(x[,2],y[,2],paired=T)$p.value,2)
	text(c(1.5,4.5),c(max(c(log10(x[,1]+1)),c(log10(y[,1]+1)))*8.5/10,
			  max(c(log10(x[,2]+1)),c(log10(y[,2]+1)))*8.5/10),label=c(pv1,pv2),srt=90)
	boxplot(log10(x[,3]+1),log10(y[,3]+1),log10(x[,4]+1),log10(y[,4]+1),at=c(1,2,4,5),staplewex=0,lty=1,
		col=c("#e41a1c","white","#377eb8","white"),border=c("black","#e41a1c","black","#377eb8"),
		ylab="log10 ( RPM + 1 )",xaxt="n",main="allMappers")
	axis(1,at=c(1.5,4.5),label=c("sense","antisense"),lwd=0)
	pv1=signif(wilcox.test(x[,3],y[,3],paired=T)$p.value,2)
	pv2=signif(wilcox.test(x[,4],y[,4],paired=T)$p.value,2)
	text(c(1.5,4.5),c(max(c(log10(x[,3]+1)),c(log10(y[,3]+1)))*8.5/10,
			  max(c(log10(x[,4]+1)),c(log10(y[,4]+1)))*8.5/10),label=c(pv1,pv2),srt=90)
	par(xpd=T)
	plot.new()
	legend("center",fill=c("black","white"),legend=c(n1,n2),y.intersp=1.5)
}

fun_plot_single_mode=function(i){
	ii=fun_sub(i)
	pdf(paste(pre,".",appendix,".temp.body.",ii,".pdf", sep=""), width=21, height=5*7/13, useDingbats=F)
	laymat=matrix(1,7,7)
	laymat[2:4,1]=2; laymat[5:7,1]=2
	laymat[2:4,2]=3; laymat[5:7,2]=4;
	laymat[2:4,3:4]=5; laymat[5:7,3:4]=6;
	for(k in 5:7){laymat[2:4,k]=k*2-3}
	for(k in 5:7){laymat[5:7,k]=k*2-2}
	layout(laymat)
	par(cex=0.5,tcl=0.3)
	par(mar=c(0,0,0,0),cex=1)
	plot.new()
	text(0,0.5,label=i,font=2,cex=1,pos=4)
	fun_plot_pp(pp[,i])
	fun_plot_lendis(all_reads_sense_lendis[,i],all_reads_anti_lendis[,i],"allMap reads")
	x=cov[which(cov[,1]==i),]
	fun_plot_bucket(x)
	fun_plot_lendis(uniq_reads_sense_lendis[,i],uniq_reads_anti_lendis[,i],"uniqMap reads")
	fun_plot_lendis(all_species_sense_lendis[,i],all_species_anti_lendis[,i],"allMap species")
	fun_plot_lendis(uniq_species_sense_lendis[,i],uniq_species_anti_lendis[,i],"uniqMap species")
	dev.off()
}

fun_plot_comparison_mode=function(i){
	ii=fun_sub(i)
	pdf(paste(pre,"_vs_",sn2,".",appendix,".temp.body.",ii,".pdf", sep=""), width=21, height=5, useDingbats=F)
	laymat=matrix(1,13,8)
	laymat[2:7,1]=2; laymat[8:13,1]=3; laymat[2:7,2]=4; laymat[8:13,2]=5
	laymat[2:4,3]=6; laymat[5:7,3]=7; laymat[8:10,3]=8; laymat[11:13,3]=9 
	laymat[2:4,4:5]=10; laymat[5:7,4:5]=11; laymat[8:10,4:5]=12; laymat[11:13,4:5]=13 
	for(k in 6:8){laymat[2:4,k]=k*4-10}
	for(k in 6:8){laymat[5:7,k]=k*4-9}
	for(k in 6:8){laymat[8:10,k]=k*4-8}
	for(k in 6:8){laymat[11:13,k]=k*4-7}
	layout(laymat)
	par(cex=0.5,tcl=0.3)
	par(mar=c(0,0,0,0),cex=1)
	plot.new()
	text(0,0.5,label=i,font=2,cex=1,pos=4)
	plot.new()
	text(0.5,0.5,label=sn1,font=2,cex=0.8,srt=45)
	plot.new()
	text(0.5,0.5,label=sn2,font=2,cex=0.8,srt=45)
	fun_plot_pp2(pp1[,i],pp2[,i])
	fun_plot_lendis2(all_reads_sense_lendis1[,i],all_reads_anti_lendis1[,i],all_reads_sense_lendis2[,i],all_reads_anti_lendis2[,i],"allMap reads")
	x=cov1[which(cov1[,1]==i),]; y=cov2[which(cov2[,1]==i),]
	fun_plot_bucket2(x,y)
	fun_plot_lendis2(uniq_reads_sense_lendis1[,i],uniq_reads_anti_lendis1[,i],uniq_reads_sense_lendis2[,i],uniq_reads_anti_lendis2[,i],"uniqMap reads")
	fun_plot_lendis2(all_species_sense_lendis1[,i],all_species_anti_lendis1[,i],all_species_sense_lendis2[,i],all_species_anti_lendis2[,i],"allMap species")
	fun_plot_lendis2(uniq_species_sense_lendis1[,i],uniq_species_anti_lendis1[,i],uniq_species_sense_lendis2[,i],uniq_species_anti_lendis2[,i],"uniqMap species")
	dev.off()
}

fun_sub=function(x){
	x=gsub("(",".",x,fixed=T)
	x=gsub(")",".",x,fixed=T)
	x=gsub("'",".",x,fixed=T)
	return(x)
}

# runs here----
# judge mode (single or comparison)
system("echo0 2 \"....read files and pre-plot\"")
#print(Args)
if(length(Args)==7){
	# single mode
	pre=paste(strsplit(Args[7],".",fixed=T)[[1]][1:(length(strsplit(Args[7],".",fixed=T)[[1]])-2)],collapse=".")
	sn=strsplit(Args[7],"/")[[1]][length(strsplit(Args[7],"/")[[1]])]
	appendix=paste(strsplit(sn,".",fixed=T)[[1]][(length(strsplit(sn,".",fixed=T)[[1]])-1):length(strsplit(sn,".",fixed=T)[[1]])],collapse=".")
	sn=paste(strsplit(sn,".",fixed=T)[[1]][1:(length(strsplit(sn,".",fixed=T)[[1]])-2)],collapse=".")
	# read files
	uniq_reads_sense_lendis=read.table(paste(Args[7],".uniq.reads.sense.lendis",sep=""),header=T,row.names=1,check.names=F)
	uniq_reads_anti_lendis=read.table(paste(Args[7],".uniq.reads.antisense.lendis",sep=""),header=T,row.names=1,check.names=F)
	uniq_species_sense_lendis=read.table(paste(Args[7],".uniq.species.sense.lendis",sep=""),header=T,row.names=1,check.names=F)
	uniq_species_anti_lendis=read.table(paste(Args[7],".uniq.species.antisense.lendis",sep=""),header=T,row.names=1,check.names=F)
	all_reads_sense_lendis=read.table(paste(Args[7],".all.reads.sense.lendis",sep=""),header=T,row.names=1,check.names=F)
	all_reads_anti_lendis=read.table(paste(Args[7],".all.reads.antisense.lendis",sep=""),header=T,row.names=1,check.names=F)
	all_species_sense_lendis=read.table(paste(Args[7],".all.species.sense.lendis",sep=""),header=T,row.names=1,check.names=F)
	all_species_anti_lendis=read.table(paste(Args[7],".all.species.antisense.lendis",sep=""),header=T,row.names=1,check.names=F)
	pp=read.table(paste(Args[7],".pp",sep=""),header=T,row.names=1,check.names=F)
	cov=read.table(paste(Args[7],".cov",sep=""),header=F,row.names=NULL,check.names=F)
	summary1=read.table(paste(Args[7],".summary",sep=""),header=T,row.names=1)
	rn=row.names(summary1)
	imp_pi_dm3=c(which(rn=="42AB"),which(rn=="flam"))
	# plot
	pdf(paste(pre,".",appendix,".temp.head.pdf", sep=""), width=21, height=5*7/13, useDingbats=F)
  	# plot overall summary first
  	laymat=matrix(1,7,7)
  	laymat[2:4,1]=2; laymat[5:7,1]=2
  	laymat[2:4,2]=3; laymat[5:7,2]=4;
  	laymat[2:4,3:4]=5; laymat[5:7,3:4]=6;
  	for(i in 5:7){laymat[2:4,i]=i*2-3}
  	for(i in 5:7){laymat[5:7,i]=i*2-2}
  	layout(laymat)
  	par(cex=0.5,tcl=0.3)
  	par(mar=c(0,0,0,0),cex=1)
  	plot.new()
  	text(0,0.5,label="overall summary",font=2,cex=1,pos=4)
  	fun_plot_pp(apply(pp,1,sum))
  	fun_plot_lendis(apply(all_reads_sense_lendis,1,sum),apply(all_reads_anti_lendis,1,sum),"allMap reads")
  	for(i in 1:2){plot.new()}
  	fun_plot_lendis(apply(uniq_reads_sense_lendis,1,sum),apply(uniq_reads_anti_lendis,1,sum),"uniqMap reads")
  	fun_plot_lendis(apply(all_species_sense_lendis,1,sum),apply(all_species_anti_lendis,1,sum),"allMap species")
  	fun_plot_lendis(apply(uniq_species_sense_lendis,1,sum),apply(uniq_species_anti_lendis,1,sum),"uniqMap species")
	dev.off()
	# plot buckets for each genes parallely
	cl=makeCluster(as.numeric(Args[6]))
	clusterExport(cl=cl,varlist=c("sn","uniq_reads_sense_lendis","uniq_reads_anti_lendis","uniq_species_sense_lendis","uniq_species_anti_lendis","all_reads_sense_lendis","all_reads_anti_lendis","all_species_sense_lendis",
	                              "all_species_anti_lendis","pp","cov","fun_plot_pp","fun_plot_lendis","fun_plot_bucket","pre","appendix","Args","fun_sub"),envir=environment())
	system("echo0 2 \"....plot buckets for each element\"")
	parLapply(cl,rn,fun_plot_single_mode)
	# merge pdfs
	system("echo0 2 \"....merge pdfs\"")
	# if(length(rn)>500){
	# 	fun_merge=function(in_pdfs){
	# 		system(paste("gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dNumRenderingThreads=",as.numeric(Args[6])," -sOutputFile=",pre,".",appendix,".pdf ",pre,".",appendix,".temp.head.pdf ",in_pdfs,sep=""))
	# 	}
	# 	system(paste("mkdir ",pre,".",appendix,"_pdf",sep=""))
	# 	trn=sort(rn)
	# 	l_in_pdfs=c()
	# 	for(i in 1:ceiling(length(trn)/500)){
	# 		tlist=trn[((i-1)*500+1):min(i*500,length(trn))]
	# 		in_pdfs=paste(pre,".",appendix,"_pdf/",trn[((i-1)*500+1)],"---",trn[min(i*500,length(trn))],".pdf ",pre,".",appendix,".temp.head.pdf",sep="")
	# 		for(i in tlist){
	# 			in_pdfs=paste(in_pdfs," ",pre,".",appendix,".temp.body.",i,".pdf",sep="")
	# 		}
	# 		in_pdfs=fun_sub(in_pdfs)
	# 		l_in_pdfs=c(l_in_pdfs,in_pdfs)
	# 	}
	# 	print("Merging")
	# 	parLapply(cl,l_in_pdfs,fun_merge)
	# 	system(paste("rm ",pre,".",appendix,".temp.*.pdf",sep=""))
	# }else{
		system(paste("gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dNumRenderingThreads=",as.numeric(Args[6])," -sOutputFile=",pre,".",appendix,".pdf ",pre,".",appendix,".temp.head.pdf ",pre,".",appendix,".temp.body.*.pdf && rm ",pre,".",appendix,".temp.*.pdf",sep=""))
	# }
}else{
	# comparison mode
	pre=paste(strsplit(Args[7],".",fixed=T)[[1]][1:(length(strsplit(Args[7],".",fixed=T)[[1]])-2)],collapse=".")
	sn1=strsplit(Args[7],"/")[[1]][length(strsplit(Args[7],"/")[[1]])]
	appendix=paste(strsplit(sn1,".",fixed=T)[[1]][(length(strsplit(sn1,".",fixed=T)[[1]])-1):length(strsplit(sn1,".",fixed=T)[[1]])],collapse=".")
	sn1=paste(strsplit(sn1,".",fixed=T)[[1]][1:(length(strsplit(sn1,".",fixed=T)[[1]])-2)],collapse=".")
	sn2=strsplit(Args[8],"/")[[1]][length(strsplit(Args[8],"/")[[1]])]
	sn2=paste(strsplit(sn2,".",fixed=T)[[1]][1:(length(strsplit(sn2,".",fixed=T)[[1]])-2)],collapse=".")
	# read files
	uniq_reads_sense_lendis1=read.table(paste(Args[7],".uniq.reads.sense.lendis",sep=""),header=T,row.names=1,check.names=F)
	uniq_reads_anti_lendis1=read.table(paste(Args[7],".uniq.reads.antisense.lendis",sep=""),header=T,row.names=1,check.names=F)
	uniq_species_sense_lendis1=read.table(paste(Args[7],".uniq.species.sense.lendis",sep=""),header=T,row.names=1,check.names=F)
	uniq_species_anti_lendis1=read.table(paste(Args[7],".uniq.species.antisense.lendis",sep=""),header=T,row.names=1,check.names=F)
	all_reads_sense_lendis1=read.table(paste(Args[7],".all.reads.sense.lendis",sep=""),header=T,row.names=1,check.names=F)
	all_reads_anti_lendis1=read.table(paste(Args[7],".all.reads.antisense.lendis",sep=""),header=T,row.names=1,check.names=F)
	all_species_sense_lendis1=read.table(paste(Args[7],".all.species.sense.lendis",sep=""),header=T,row.names=1,check.names=F)
	all_species_anti_lendis1=read.table(paste(Args[7],".all.species.antisense.lendis",sep=""),header=T,row.names=1,check.names=F)
	pp1=read.table(paste(Args[7],".pp",sep=""),header=T,row.names=1,check.names=F)
	cov1=read.table(paste(Args[7],".cov",sep=""),header=F,row.names=NULL,check.names=F)
	summary1=read.table(paste(Args[7],".summary",sep=""),header=T,row.names=1)
	uniq_reads_sense_lendis2=read.table(paste(Args[8],".uniq.reads.sense.lendis",sep=""),header=T,row.names=1,check.names=F)
	uniq_reads_anti_lendis2=read.table(paste(Args[8],".uniq.reads.antisense.lendis",sep=""),header=T,row.names=1,check.names=F)
	uniq_species_sense_lendis2=read.table(paste(Args[8],".uniq.species.sense.lendis",sep=""),header=T,row.names=1,check.names=F)
	uniq_species_anti_lendis2=read.table(paste(Args[8],".uniq.species.antisense.lendis",sep=""),header=T,row.names=1,check.names=F)
	all_reads_sense_lendis2=read.table(paste(Args[8],".all.reads.sense.lendis",sep=""),header=T,row.names=1,check.names=F)
	all_reads_anti_lendis2=read.table(paste(Args[8],".all.reads.antisense.lendis",sep=""),header=T,row.names=1,check.names=F)
	all_species_sense_lendis2=read.table(paste(Args[8],".all.species.sense.lendis",sep=""),header=T,row.names=1,check.names=F)
	all_species_anti_lendis2=read.table(paste(Args[8],".all.species.antisense.lendis",sep=""),header=T,row.names=1,check.names=F)
	pp2=read.table(paste(Args[8],".pp",sep=""),header=T,row.names=1,check.names=F)
	cov2=read.table(paste(Args[8],".cov",sep=""),header=F,row.names=NULL,check.names=F)
	summary2=read.table(paste(Args[8],".summary",sep=""),header=T,row.names=1)
	rn=row.names(summary1)
	imp_pi_dm3=c(which(rn=="42AB"),which(rn=="flam"))
	# plot
	# add scatterplot for comparing sample1 and sample2
	pdf(paste(pre,"_vs_",sn2,".",appendix,".scatter.pdf", sep=""), width=14, height=6, useDingbats=F)
	layout(matrix(c(1:9,9),2,5))
	par(tcl=0.3,bty="n")
	fun_plot_scatter2(summary1[,1]+summary1[,2],summary2[,1]+summary2[,2],
			  sn1,sn2,"uniqMap reads")
	fun_plot_scatter2(summary1[,3]+summary1[,4],summary2[,3]+summary2[,4],
			  sn1,sn2,"allMap reads")
	fun_plot_scatter2(summary1[,5]+summary1[,6],summary2[,5]+summary2[,6],
			  sn1,sn2,"uniqMap species")
	fun_plot_scatter2(summary1[,7]+summary1[,8],summary2[,7]+summary2[,8],
			  sn1,sn2,"allMap species")
	fun_plot_scatter2(summary1[,10],summary2[,10],
			  sn1,sn2,"10nt overlap")
	fun_plot_scatter2_for_pp(summary1,summary2,sn1,sn2)
	fun_plot_scatter2_for_entropy(summary1,summary2,sn1,sn2)
	dev.off()
	# bucket plot
	# plot overall summary first
	pdf(paste(pre,"_vs_",sn2,".",appendix,".temp.head.pdf", sep=""), width=21, height=5, useDingbats=F)
	laymat=matrix(1,13,8)
	laymat[2:7,1]=2; laymat[8:13,1]=3; laymat[2:7,2]=4; laymat[8:13,2]=5
	laymat[2:4,3]=6; laymat[5:7,3]=7; laymat[8:10,3]=8; laymat[11:13,3]=9 
	laymat[2:4,4:5]=10; laymat[5:7,4:5]=11; laymat[8:10,4:5]=12; laymat[11:13,4:5]=13 
	for(i in 6:8){laymat[2:4,i]=i*4-10}
	for(i in 6:8){laymat[5:7,i]=i*4-9}
	for(i in 6:8){laymat[8:10,i]=i*4-8}
	for(i in 6:8){laymat[11:13,i]=i*4-7}
	layout(laymat)
	par(cex=0.5,tcl=0.3) #,xpd=F)
	par(mar=c(0,0,0,0),cex=1)
	plot.new()
	text(0,0.5,label="overall summary",font=2,cex=1,pos=4)
	plot.new()
	text(0.5,0.5,label=sn1,font=2,cex=0.8,srt=45)
	plot.new()
	text(0.5,0.5,label=sn2,font=2,cex=0.8,srt=45)
	fun_plot_pp2(apply(pp1,1,sum),apply(pp2,1,sum))
	fun_plot_lendis2(apply(all_reads_sense_lendis1,1,sum),apply(all_reads_anti_lendis1,1,sum),apply(all_reads_sense_lendis2,1,sum),apply(all_reads_anti_lendis2,1,sum),"allMap reads")
	for(i in 1:4){plot.new()}
	fun_plot_lendis2(apply(uniq_reads_sense_lendis1,1,sum),apply(uniq_reads_anti_lendis1,1,sum),apply(uniq_reads_sense_lendis2,1,sum),apply(uniq_reads_anti_lendis2,1,sum),"uniqMap reads")
	fun_plot_lendis2(apply(all_species_sense_lendis1,1,sum),apply(all_species_anti_lendis1,1,sum),apply(all_species_sense_lendis2,1,sum),apply(all_species_anti_lendis2,1,sum),"allMap species")
	fun_plot_lendis2(apply(uniq_species_sense_lendis1,1,sum),apply(uniq_species_anti_lendis1,1,sum),apply(uniq_species_sense_lendis2,1,sum),apply(uniq_species_anti_lendis2,1,sum),"uniqMap species")
	dev.off()
	# plot buckets for each genes parallely
	cl=makeCluster(as.numeric(Args[6]))
	clusterExport(cl=cl,varlist=c("sn1","sn2","uniq_reads_sense_lendis1","uniq_reads_anti_lendis1","uniq_species_sense_lendis1","uniq_species_anti_lendis1","all_reads_sense_lendis1","all_reads_anti_lendis1","all_species_sense_lendis1","all_species_anti_lendis1","pp1","cov1","uniq_reads_sense_lendis2","uniq_reads_anti_lendis2","uniq_species_sense_lendis2","uniq_species_anti_lendis2","all_reads_sense_lendis2","all_reads_anti_lendis2","all_species_sense_lendis2","all_species_anti_lendis2","pp2","cov2","fun_plot_pp2","fun_plot_lendis2","fun_plot_bucket2","pre","appendix","Args","fun_sub"),envir=environment())
	system("echo0 2 \"....plot buckets for each element\"")
	parLapply(cl,rn,fun_plot_comparison_mode)
	# merge pdfs
	system("echo0 2 \"....merge pdfs\"")
#	if(length(rn)>500){
#		fun_merge=function(in_pdfs){
#			command=paste("gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dNumRenderingThreads=",as.numeric(Args[6])," -sOutputFile=",in_pdfs,sep="")
#			write.table(command,"ss",row.names=F,col.names=F,sep="\t",quote=F)
#			system(command)
#		}
#		system(paste("mkdir ",pre,"_vs_",sn2,".",appendix,".pdf",sep=""))
#		trn=sort(rn)
#		l_in_pdfs=c()
#		for(i in 1:ceiling(length(trn)/500)){
#			tlist=trn[((i-1)*500+1):min(i*500,length(trn))]
#			in_pdfs=paste(pre,"_vs_",sn2,".",appendix,".pdf/",trn[((i-1)*500+1)],"---",trn[min(i*500,length(trn))],".pdf ",pre,"_vs_",sn2,".",appendix,".temp.head.pdf",sep="")
#			for(i in tlist){
#				in_pdfs=paste(in_pdfs," ",pre,"_vs_",sn2,".",appendix,".temp.body.",i,".pdf",sep="")
#			}
#			in_pdfs=fun_sub(in_pdfs)
#			l_in_pdfs=c(l_in_pdfs,in_pdfs)
#		}
#		parLapply(cl,l_in_pdfs,fun_merge)
#		system(paste("rm ",pre,"_vs_",sn2,".",appendix,".temp.*.pdf",sep=""))
#	}else{
		system(paste("gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dNumRenderingThreads=",as.numeric(Args[6])," -sOutputFile=",pre,"_vs_",sn2,".",appendix,".pdf ",pre,"_vs_",sn2,".",appendix,".temp.head.pdf ",pre,"_vs_",sn2,".",appendix,".temp.body.*.pdf && rm ",pre,"_vs_",sn2,".",appendix,".temp.*.pdf",sep=""))
#	}
}
stopCluster(cl)

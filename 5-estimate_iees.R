## this script estimates IEEs and creates plots analogous to Figures 2 and 3 in the manuscript ##

## load posterior samples from causal models ##
load('Y0_postsamples.RData')

## make one matrix of all posterior predictive samples of missing Y(0) values (combined across TCs) ##
all_Y0psamp<-Reduce(cbind,Y0_psamp_list)

## get the observed Y(1) values and pop sizes for each TC/treated county ##
load('panel_list.RData')
Y1<-NULL
pop<-NULL
iee_base<-NULL
tc_ids<-NULL
for (i in 1:length(panel_list)){
  Y1<-c(Y1,panel_list[[i]]$Y1_obs)
  pop<-c(pop,panel_list[[i]]$pop_size_trt)
  tc_ids<-c(tc_ids,rep(i,length(panel_list[[i]]$county_id_trt)))
  iee_base<-rbind(iee_base,data.frame('tc'=rep(paste0('tc ',i),length(panel_list[[i]]$county_id_trt)),
                                      'county_id'=panel_list[[i]]$county_id_trt))
}
Y1<-matrix(rep(Y1,nrow(all_Y0psamp)),nrow=nrow(all_Y0psamp),ncol=ncol(all_Y0psamp),byrow=T)
pop<-matrix(rep(pop,nrow(all_Y0psamp)),nrow=nrow(all_Y0psamp),ncol=ncol(all_Y0psamp),byrow=T)

## get posterior samples of iees (event and rate variants) and save ##
iee_psamp<-Y1-all_Y0psamp
iee_rate_psamp<-(Y1-all_Y0psamp)/pop

save(iee_psamp,iee_rate_psamp,file='iee_postsamples.RData')

## compute iee estimates and the rate variant and add to iee_base dataframe ##
iees<-data.frame(iee_base,'iee'=colMeans(iee_psamp),'iee_rate'=colMeans(iee_rate_psamp))

## merge in the predictors with the iee estimates ##
load('pred.RData')

iees<-merge(iees,pred,by=c('tc','county_id'))

## save this data frame ##
save(iees,file='iee_estimates.RData')

iees$x1_cat<-cut(iees$x1,breaks=c(quantile(iees$x1,c(0,.2,.4,.6,.8)),max(iees$x1)+.01),right=F)

## order storms by median iee ##
temp<-tapply(iees$iee_rate,iees$tc,median)
iees$tc<-factor(iees$tc,levels = names(temp)[order(temp)])

## make plot of the iees corresponding to figure 2 ##
p <- ggplot(iees, aes(x = tc, y = iee_rate, colour = x1_cat))+
  geom_boxplot(outlier.shape = NA, alpha = 0.5,color='black') + 
  geom_quasirandom(size = 0.5) + 
  theme_bw()+
  theme(text=element_text(colour='black',size=14),
        axis.text.x = element_text(angle = 90, hjust = 1,vjust=0.5)) + 
  scale_color_brewer(palette='Spectral',direction=-1)+
  #coord_cartesian(ylim = c(ll[i],ul[i])) + 
  geom_hline(yintercept = 0) +
  xlab("")+
  ylab('County-specific excess event rate')+
  labs(colour='X1')+
  guides(color = guide_legend(override.aes = list(size = 3) ) )

pdf('figure_2.pdf')
print(p)
dev.off()


  
## compute storm-specific excess events ##
Y1_list<-lapply(1:length(panel_list),function(i) Y1[,which(tc_ids==i)])
ss_ee_psamp<-lapply(mapply('-',Y1_list,Y0_psamp_list,SIMPLIFY = F),FUN=rowSums)
ss_ees<-data.frame('tc'=paste('tc',1:3),'est'=sapply(ss_ee_psamp,FUN=mean),
                   'll'=sapply(ss_ee_psamp,FUN=quantile,.025),'ul'=sapply(ss_ee_psamp,FUN=quantile,.975))

## order storms by excess event estimates ##
ss_ees$tc<-factor(ss_ees$tc,levels=ss_ees$tc[order(ss_ees$est)])

p <- ggplot(ss_ees, aes(x=tc,y=est)) +
  geom_point() + 
  geom_errorbar(aes(ymin =ll, ymax =ul)) + 
  theme_bw()+
  theme(text=element_text(color='black',size=14),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5)) + 
  xlab('')+
  ylab('TC-specific excess events')+
  geom_hline(yintercept = 0)

pdf('figure_3.pdf')
print(p)
dev.off()
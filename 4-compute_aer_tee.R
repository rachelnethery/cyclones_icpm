
############################################################
## compute total excess events across all counties/storms ##
############################################################

## load posterior samples from causal models ##
load('Y0_postsamples.RData')

## make one matrix of all posterior predictive samples of missing Y(0) values (combined across TCs) ##
all_Y0psamp<-Reduce(cbind,Y0_psamp_list)

## get the observed Y(1) values for each TC/treated county ##
load('panel_list.RData')
Y1<-NULL
for (i in 1:length(panel_list)){
  Y1<-c(Y1,panel_list[[i]]$Y1_obs)
}
Y1<-matrix(rep(Y1,nrow(all_Y0psamp)),nrow=nrow(all_Y0psamp),ncol=ncol(all_Y0psamp),byrow=T)

## compute posterior samples of the TEE ##
## compute Y(1)-Y(0) for each Y(0) posterior sample, and sum across all TC/counties ##
tee_psamp<-rowSums(Y1-all_Y0psamp)
## take mean and percentiles of TEE posterior samples ##
print(paste0('TEE: ',round(mean(tee_psamp),2),' (',round(quantile(tee_psamp,.025),2),',',round(quantile(tee_psamp,.975),2),')'))

############################################################
## compute average excess rate across all counties/storms ##
############################################################

## get population sizes for each treated county ##
pop<-NULL
for (i in 1:length(panel_list)){
  pop<-c(pop,panel_list[[i]]$pop_size_trt)
}
pop<-matrix(rep(pop,nrow(all_Y0psamp)),nrow=nrow(all_Y0psamp),ncol=ncol(all_Y0psamp),byrow=T)

## compute posterior samples of the AER ##
## compute Y(1)-Y(0)/P for each Y(0) posterior sample, and take average across all TC/counties ##
aer_psamp<-rowMeans((Y1-all_Y0psamp)/pop)
## take mean and percentiles of AER posterior samples ##
print(paste0('AER: ',round(mean(aer_psamp),4),' (',round(quantile(aer_psamp,.025),4),',',round(quantile(aer_psamp,.975),4),')'))


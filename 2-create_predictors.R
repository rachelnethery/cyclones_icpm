## this script creates synthetic predictor data ##

## read in the panel data ##
load('panel_list.RData')

## extract the causal effects for each impacted county in each panel data matrix and the corresponding TC and county id ##
iee<-NULL
pred_base<-NULL
for (i in 1:length(panel_list)){
  iee<-c(iee,panel_list[[i]]$iee_rate)
  pred_base<-rbind(pred_base,data.frame('tc'=rep(paste0('tc ',i),length(panel_list[[i]]$county_id_trt)),
                                        'county_id'=panel_list[[i]]$county_id_trt))
}

Ntotal<-length(iee)

## make predictors associated with the iees ##
x1<-rnorm(Ntotal,mean=rcspline.eval(iee,nk=3,inclx = T)%*%c(1,2),sd=.005)
x2<-rnorm(Ntotal,mean=scale(iee)-scale(x1),sd=1)

## make a data frame of predictors ##
pred<-data.frame(pred_base,x1,x2)

## save predictor data frame ##
save(pred,file='pred.RData')
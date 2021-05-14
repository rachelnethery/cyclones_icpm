## this script makes Figure 4 and Table S.5 from the predictive model output ##

## read in the predictive model dataset ##
load('iee_estimates.RData')

## read in the posterior samples of coefficients from predictive model ##
load('predmod_postsamples.RData')

## make table S.5 with estimate and CI for each parameter ##
tab<-data.frame('est'=round(colMeans(betas),4),
                'll'=round(apply(betas,2,quantile,.025),4),
                'ul'=round(apply(betas,2,quantile,.975),4))

## export to a csv file ##
write.csv(tab,file='table_S5.csv',row.names = T)
  

## at windspeed values in observed range, predict value for each outcome (do this for each posterior sample)
x1_range<-seq(min(iees$x1),max(iees$x1),length.out = 100)

pred_spl<-NULL
for (j in x1_range){
  ## get spline for that windspeed value ##
  ws_new<-(as.numeric(rcspline.eval(j,
                                    knots=attributes(rcspline.eval(iees$x1,inclx = T,nk=n_knots))$knots,inclx = T)))
  
  other_covs<-c(mean(iees$x2))
  
  hh<-matrix(rep(c(1,ws_new,other_covs),nrow(betas)),nrow=nrow(betas),byrow=T)
  post_pred<-rowSums(hh*betas)
  pred_spl<-rbind(pred_spl,c(j,mean(post_pred),quantile(post_pred,c(.025,.975))))
}

pred_spl<-as.data.frame(pred_spl)
names(pred_spl)<-c('x1','est','ll','ul')


## make plots of x1 splines plus CIs ##
m<-data.frame('x1'=iees$x1,'y'=min(pred_spl$est)-.025)
h <- ggplot()+
  geom_ribbon(data=pred_spl,aes(x=x1,ymin = ll, ymax = ul), fill = "grey70") +
  geom_line(data=pred_spl,aes(x=x1,y = est))+
  geom_point(data=m,aes(x=x1,y=y),shape='|',size=2)+
  theme_bw()+
  theme(text=element_text(colour='black',size=14))+
  geom_hline(yintercept = 0,colour='red')+
  labs(x='X1',y='IEE')


pdf('figure_4.pdf')
print(h)
dev.off()
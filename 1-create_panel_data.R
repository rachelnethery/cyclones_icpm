## this script generates synthetic panel data matrices ##

# number of counties ##
n <- 40 
# m corresponds to T in our notation (number of time points) ##
m <- 10 
# number of latent factors ##
k <- 4 
# number of 'treated' counties ##
n_miss<-15 

## store panel data matrices in a list ##
panel_list<-list()
for (i in 1:nTCs){
  ## factor loadings ##
  L<-matrix(rnorm(m*k,sd=.5),nrow=m,ncol=k)
  ## factors ##
  FS<-matrix(rnorm(n*k,sd=.2),nrow=n,ncol=k)
  ## global intercept ##
  alpha<-(-4)
  ## county-specific intercepts ##
  gamma_i<-rnorm(n,sd=1)
  ## time-specific intercepts ##
  psi_t<-rnorm(m,sd=.25)
  ## population size "offset" ##
  ps<-rpois(n,lambda=1000)
  ## mean structure ##
  mean_struct<-exp(alpha+
                     matrix(rep(gamma_i,m),nrow=n)+
                     matrix(rep(psi_t,n),nrow=n,byrow = T)+
                     FS%*%t(L)+
                     matrix(rep(log(ps),m),nrow=n))
  
  ## generate the "true" Y(0) matrix with no missingness ##
  Y0_full<-Y0_obs<-matrix(rpois(m*n,lambda=c(mean_struct)),nrow=n,ncol=m)
  
  ## insert missingness into the Y(0) matrix to correspond to the observed Y(0) ##
  Y0_obs[(n-n_miss+1):n,m]<-NA
  
  ## generate the Y(1) ##
  Y1_obs<-Y0_full[(n-n_miss+1):n,m]+round(rnorm(n_miss,mean=sample(1:10,1),sd=2))
  
  ## causal effects ##
  iee<-Y1_obs-Y0_full[(n-n_miss+1):n,m]
  iee_rate<-iee/ps[(n-n_miss+1):n]
  
  ## generate a fake county id variable ##
  county_id<-sample(1:50000,size=n)
  
  ## save all relevant info ##
  panel_list[[i]]<-list('county_id'=county_id,'county_id_trt'=county_id[(n-n_miss+1):n],
                        'Y0_obs'=Y0_obs,'Y0_full'=Y0_full,'Y1_obs'=Y1_obs,
                        'iee'=iee,'iee_rate'=iee_rate,
                        'pop_size'=ps,'pop_size_trt'=ps[(n-n_miss+1):n])
}

names(panel_list)<-paste0('tc_',1:3)

save(panel_list,file='panel_list.RData')


# number of latent factors ##
k <- 4 

## load the stan model ##
m_mod <- stan_model("functions/MC_neg_binom.stan",auto_write=T)

## load the full list of panel data matrices for all TCs
load('panel_list.RData')

## list to store posterior samples ##
Y0_psamp_list<-list()

## loop through and fit causal model for each TC ##
for (i in 1:length(panel_list)){
  
  ###########################
  ## extract and prep data ##
  ###########################
  
    ## pull out data for the individual TC ##
    dat<-panel_list[[i]]
      
    ## stan doesn't allow missing values so we put a numeric "placeholder" in the missings
    Y0_obs<-dat$Y0_obs
    Y0_obs[is.na(Y0_obs)]<-(99999)
    
    ## set up the list of data for stan call ##
    stan_in <- list(k = k, ## k is user-specified number of factors ##
                    m = ncol(dat$Y0_obs), # m corresponds to T in our notation (number of time points) ##
                    n = nrow(dat$Y0_obs), # n is number of counties ##
                    y_miss=is.na(dat$Y0_obs[,ncol(dat$Y0_obs)]), ## y_miss is n-length indicator of exposure (missingness in Y(0)) at time m ##
                    y=Y0_obs, ## y is the observed Y(0) matrix ##
                    offs=dat$pop_size ## offs is n-length vector of population size offsets for each county ##
    )
    
    
    ########################
    ## run the stan model ##
    ########################
    rstan_options(auto_write = TRUE)
    options(mc.cores = parallel::detectCores())  
    fit1 <- sampling(object = m_mod, data = stan_in, chains = 1, iter = 2000, 
                     pars = c('Y_pred'), init_r = .1)
    
    #######################################################################
    ## process and save the posterior predictive samples of missing Y(0) ##
    #######################################################################
    
    ext_psamp<-extract(fit1,permuted=F)
    dim(ext_psamp)<-dim(ext_psamp)[c(1,3)]
    Y0_psamp_list[[i]]<-ext_psamp[,1:(ncol(ext_psamp)-1)]

}

save(Y0_psamp_list,file='Y0_postsamples.RData')


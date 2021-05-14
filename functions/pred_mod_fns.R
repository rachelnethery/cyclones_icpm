## this script contains the function used to fit the linear predictive models ##

##########################################################################################
## function to fit a bayesian linear model with imputed outcomes with zellner's g prior ##
##########################################################################################

lm_zellg<-function(y,X,nu0=1,s20=.5,seed=1){
  
  set.seed(seed)
  
  ## y is a matrix with each row containing a posterior sample of the outcomes for the linear model ##
  ## X is a matrix of predictors for the linear model ##
  
  n<-ncol(y)
  p<-ncol(X)
  g<-n
  s2save<-NULL
  betasave<-NULL
  nsamp<-nrow(y)
  for (i in 1:nsamp){
    Hg=(g/(g+1))*X%*%solve(t(X)%*%X)%*%t(X)
    SSRg=t(y[i,])%*%(diag(1,nrow=n)-Hg)%*%y[i,]
    s2=1/rgamma(1,(nu0+n)/2,(nu0*s20+SSRg)/2)
    s2save<-c(s2save,s2)
    
    Vb=g*solve(t(X)%*%X)/(g+1)
    Eb=Vb%*%t(X)%*%y[i,]
    E=matrix(rnorm(p,0,sqrt(s2)),1,p)
    beta=t(t(E%*%chol(Vb))+c(Eb))
    betasave<-rbind(betasave,beta)
  }
  
  return(list(betasave,s2save))
  
}



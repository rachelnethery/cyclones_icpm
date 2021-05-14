## this script fits the predictive linear model (with spline) using the full set of causal model posterior samples ##

## number of knots in restricted cubic spline ##
n_knots<-3

## load in function to fit predictive model ##
source('functions/pred_mod_fns.R')

## load in the full posterior samples of the iees ##
load('iee_postsamples.RData')

## load in the predictor data (the ordering of the TC/counties in row of predictor matrix aligns with ordering of TC/counties in columns of matrix of posterior samples) ##
load('pred.RData')

## create restricted cubic spline basis (4 knots) for variable x1 ##
x1_basis<-as.data.frame(rcspline.eval(pred$x1,inclx = F,nk=n_knots))
names(x1_basis)<-paste0('x1_rcs',1:(n_knots-2))
pred<-data.frame(pred,x1_basis)

## create predictor matrix ##
fmla<-as.formula(paste0(c('~x1',paste0('x1_rcs',1:(n_knots-2)),'x2'),collapse = '+'))
pred_vars <- model.matrix(fmla, data = pred)

## draw posterior samples of predictive model parameters from a linear model with zellner's g prior and imputed rate outcomes ##
post<-lm_zellg(## y is the matrix of posterior samples of the iees, with samples in rows and individual TC/counties in columns
               y=iee_rate_psamp,
               ## X is the predictor matrix (TC/counties in rows and predictors in columns) including an intercept and any spline bases needed ##
               X=pred_vars,s20=var(colMeans(iee_rate_psamp)),seed=1)

## discard the first half of samples as burnin ##
betas <- as.data.frame(post[[1]][((nrow(post[[1]])/2)+1):nrow(post[[1]]),])

## save the posterior samples of the predictive model coefficients ##
save(betas,file='predmod_postsamples.RData')

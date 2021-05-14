############################################################################################
## Integrated causal-predictive machine learning models for tropical cyclone epidemiology ##
## Master script for synthetic data generation/analysis                                   ##
############################################################################################

## load necessary packages ##
library(rstan)
library(Hmisc)
library(ggplot2)
library(ggbeeswarm)
library(RColorBrewer)

## set seed for reproducibility
set.seed(1)
## number of synthetic tropical cyclones ##
nTCs<-3

###########################################################################
## 1. generate 'nTCs' synthetic panel data matrices for causal inference ##
##    output: panel_list.RData                                           ##
##    approx run time: <1 sec                                            ##
###########################################################################

source('1-create_panel_data.R')

##########################################
## 2. generate synthetic predictor data ##
##    output: pred.RData                ##
##    approx run time: <1 sec           ##
##########################################

source('2-create_predictors.R')

#####################################################################
## 3. run causal models and save posterior samples of missing Y(0) ##
##    output: Y0_postsamples.RData                                 ##
##    approx run time: 10 mins                                     ##
#####################################################################

source('3-causal_model.R')

##########################################
## 4. estimate AER and TEE, and 95% CIs ##
##    output: printed to console        ##
##    approx run time: <1 sec           ##
##########################################

source('4-compute_aer_tee.R')

#######################################################################################
## 5. estimate TC- and county-specific excess events and make plots                  ##
##    output: iee_postsamples.RData, iee_estimates.RData, figure_2.pdf, figure_3.pdf ##
##    approx run time: <1 sec                                                        ##
#######################################################################################

source('5-estimate_iees.R')

##############################################################
## 6. run predictive model and save posterior distributions ##
##    output: predmod_postsamples.RData                     ##
##    approx run time: 1 sec                                ##
##############################################################

source('6-predictive_model.R')

##################################################################
## 7. make table of predictive model estimates and spline plots ##
##    output: table_S5.csv, figure_4.pdf                        ##
##    approx run time: <1 sec                                   ##
##################################################################

source('7-predmodel_compile_results.R')

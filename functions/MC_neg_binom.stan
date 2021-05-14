data {
  int<lower = 0> m; // number of time points (T in the paper notation)
  int<lower = 0> k; // number of latent factors
  int<lower = 0> n; // number of counties
  int<lower=0, upper=1> y_miss[n]; //indicator of missingness in the final col of Y
  int<lower=0> y[n,m]; //Y(0) matrix with counties in rows and times in columns
  int<lower=0> offs[n]; //offset (population size)
}

transformed data {
  int<lower = 1> nmiss; //number of missings

  nmiss=sum(y_miss);
}

parameters {
  real alpha; //Global intercept
  vector[n] d0; //County deviations from global intercept
  row_vector[m] c0; //time-specific deviations from global intercept
  matrix[n,k] FS; //Factor scores matrix (U in the grant notation)
  matrix[m, k] L; //factor loadings matrix (V in the grant notation)
  real<lower=0> phi; //neg binomial scale parameter
}

transformed parameters {
  matrix[n,m] Ups; //intermediate predictor
  row_vector<lower=0>[m] Mu[n]; //negative binomial mean
  
  // latent predictors
  Ups = FS * L';
  // mean structure
  for(i in 1:n) Mu[i] = exp(alpha + d0[i] + c0 + Ups[i] + log(offs)[i]);
  
}

model {

  for(i in 1:n){
    if (1-y_miss[i]) y[i] ~ neg_binomial_2(Mu[i],phi); //Likelihood contribution for control counties
    else y[i,1:(m-1)] ~ neg_binomial_2(Mu[i,1:(m-1)],phi); //Likelihood contribution for treated counties
  }

}

generated quantities{
  int<lower=0> Y_pred[nmiss]; //Compute the predictions for treated units at treated times
  {
    int idy=0;
    for (i in 1:n){
      if (y_miss[i]){
        Y_pred[idy+1]=neg_binomial_2_rng(Mu[i,m],phi);
        idy=idy+1;
      }
    }
  }
}

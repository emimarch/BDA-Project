
data {
  int<lower=0> M; //number of countries
  int<lower=0> N;//max number of obs across all the countries
  
  vector[M] month[N];//vector of months
  vector[M] pop_den[N];//population density
  vector[M] cases[N];
  
}

parameters {
  vector[M] mu;
  vector[M] beta_month;
  vector[M] beta_pop;
  vector[M] beta_month_pop;
  real<lower=0>sigma;
  real<lower=0> tau;
  real hyper_mu;
  real hyper_beta_month;
  real hyper_beta_pop;
  real hyper_beta_month_pop;
  real <lower=0>hyper_tau_month;
  real <lower=0>hyper_tau_pop; 
  real <lower=0>hyper_tau_month_pop;
}

model {
  
  tau ~ gamma(10000,1);

  sigma ~ gamma(100,0.001);

  hyper_mu ~ normal(1000, 10000);
  hyper_beta_pop ~ normal(60,10000);
  hyper_beta_month ~ normal(0,10000);
  hyper_beta_month_pop ~ normal(0,10000);
  hyper_tau_pop ~ normal(10000,100000);
  hyper_tau_month ~ normal(10000,10000);
  hyper_tau_month_pop ~ normal(10000,10000);


  
  for (j in 1:M){
    mu[j] ~ normal(hyper_mu, tau);
    beta_month[j] ~ normal(hyper_beta_month, hyper_tau_month);
    beta_pop[j] ~ normal(hyper_beta_pop, hyper_tau_pop);
    beta_month_pop[j] ~ normal(hyper_beta_month_pop, hyper_tau_month_pop);
  
  
    for (n in 1:N){
      cases[n,j] ~ normal(mu[j] + beta_month[j]*month[n,j] + beta_pop[j]*pop_den[n,j] + beta_month_pop[j]*month[n,j]*pop_den[n,j], sigma);
    }
  }
}

generated quantities {
  vector[M] ypred[N];
  vector[M] log_lik[N];
  
  for (j in 1:M){
    for(i in 1:N){
      log_lik[i,j] = normal_lpdf(cases[i,j] | mu[j] + beta_month[j]*month[i,j] + beta_pop[j]*pop_den[i,j] + beta_month_pop[j]*month[i,j]*pop_den[i,j], sigma);
      ypred[i,j] = normal_rng(mu[j] + beta_month[j]*month[i,j] + beta_pop[j]*pop_den[i,j] +
beta_month_pop[j]*month[i,j]*pop_den[i,j], sigma);
    }
  }
}



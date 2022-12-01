data {
  int<lower=0> N; // number of observations
  vector[N] month; //vector of months_diff
  vector[N] pop_den; //population density
  vector[N] cases;
}

parameters {
  real mu;
  real beta_month;
  real beta_pop;
  real beta_month_pop;
  real<lower=0> sigma;
}

model {

  // Priors
  mu ~ normal(0, 100000);
  beta_month ~ normal(0, 10000);
  beta_pop ~ normal(60, 10000);
  beta_month_pop ~ normal(0,10000);
  sigma ~ gamma(100, 0.001);
  

  for (i in 1:N){
    cases[i] ~ normal(mu + beta_month*month[i] + beta_pop*pop_den[i] + beta_month_pop*month[i]*pop_den[i], sigma);
  }
}

generated quantities {
  real ypred;
  vector[N] log_lik;
  
  ypred = normal_rng(mu, sigma); // pooled predictive distribution 
  
  for(i in 1:N)
    {
      log_lik[i] = normal_lpdf(cases[i] | mu + beta_month*month[i] + beta_pop*pop_den[i] + beta_month_pop*month[i]*pop_den[i], sigma);
   }

}

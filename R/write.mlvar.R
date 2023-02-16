# Write Mplus syntax of multilevel VAR models. Based on examples 9.30-9.33 and 
# 9.37 in Mplus manual.

# ML-VAR model syntax

write.mlvar <- function(y, x = NULL, time = NULL, w = NULL, z = NULL, data, 
                        lags = 1, lag.at.0 = NULL, 
                        random.effets = list(lagged = TRUE,
                                             slopes = TRUE,
                                             rvar   = TRUE) ){
  
  # Create syntax of the multilevel VAR model.
  # Using as many lags for the y variables as indicated with the argument lag.
  # Some of these lagged effects might be set at 0 with the argument lag.at.0.
  # Within level covariates with contemporaneous effects might be added with x.
  # Linear trends can be added with time.
  # Between level covariates might be added with w.
  # Between level dependent variables might be added with z.
  # Lagged effects, slopes, and residual variances can be defined as random 
  # effects with random effects.
  
}


# 9.30
# one variable y with random intercept, slopes, and variance. And between level
# predictors.
# FSCOMPARISON
# 9.31
# add random slope for within level covariate.Wihtin level covariates are 
# centered with groupmean
# 9.32
# bivariate ar model, Standardized cluster option.
# random residual variances and covariances.
# The covariance is created as a factor and the variance of the factor is 
# estimated.
# logv1 | y1;
# logv2 | y2;
# f BY y1@1 y2@1;
# logvf | f;

# 9.33
# add measurement error to mlVAR model. Based on Noemi's work.

# 9.37
# linear trend.






# ouput tech1, tech8, fscomparison, standardized (cluster)

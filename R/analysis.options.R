# Mplus Analysis Options
# See Chapter 16: Analysis Command of the Mplus User's Guide Manual

# ANALYSIS: 
# ESTIMATOR = BAYES; 
# PROCESSORS = 2; 
# BITERATIONS = (2000); 
# MODEL: y ON y&1; 
# OUTPUT: TECH1 TECH8; 
# PLOT: TYPE = PLOT3;

analysis.options <- function() {
  
  
  "TYPE = TWOLEVEL"
  "Estimator = BAYES"
  "CHAINS = 2"
  "BSEED = 0"
  "PROCESSORS"
  "POINT" # MEDIAN MEAN MODE
  "STVALUES" # UNPERTURBED, PERTURBED, ML
  "PREDICTOR" # LATENT or OBSERVED
  "ALGORITHM" # GIBBS(PX1) GIBBS(PX2) GIBBS(PX3) GIBBS(RW) MH
  "BCONVERGENCE = .05"
  "BITERATIONS" # max(min) 50000(2000)
  "THIN"
  "MDITERATIONS"
  "KOLMOGOROV"
  "PRIOR"
  
    
  
  
}

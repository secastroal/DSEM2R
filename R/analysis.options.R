# Mplus Analysis Options
# See Chapter 16: Analysis Command of the Mplus User's Guide Manual

# ANALYSIS: 
# ESTIMATOR = BAYES; 
# PROCESSORS = 2; 
# BITERATIONS = (2000); 
# MODEL: y ON y&1; 
# OUTPUT: TECH1 TECH8; 
# PLOT: TYPE = PLOT3;

analysis.options <- function(type         = NULL,
                             chains       = 2,
                             processors   = chains,
                             biterations.min = 2000,
                             biterations.max = 50000,
                             bseed        = NULL,
                             thin         = NULL,
                             point        = NULL,
                             stvalues     = NULL,
                             predictor    = NULL,
                             algorithm    = NULL,
                             bconvergence = NULL,
                             mditerations = NULL,
                             kolmogorov   = NULL,
                             prior        = NULL
                             ) {
  if (!is.null(type)) {
    type_syntax <- paste0("TYPE = ", type, ";")
  } else {
    type_syntax = ""
  }
  
  chains_syntax      <- paste0("CHAINS = ", chains, ";")
  processors_syntax  <- paste0("PROCESSORS = ", processors, ";")
  
  if (biterations.max < biterations.min) {
    biterations.max <- 5 * biterations.min
    warning("'biterations.max' was lower than 'biterations.min',", 
            "'biterations.max' has been set to ", 
            5 * biterations.min, ".")
  }
  biterations_syntax <- paste0("BITERATIONS = ", biterations.max,
                               " (", biterations.min, ");")
  
  if (!is.null(bseed)) {
    bseed_syntax <- paste0("BSEED = ", bseed, ";")
  } else {
    bseed_syntax = ""
  }
  
  if (!is.null(thin)) {
    thin_syntax <- paste0("THIN = ", thin, ";")
  } else {
    thin_syntax = ""
  }
  
  if (!is.null(point)) {
    point_syntax <- paste0("POINT = ", point, ";")
  } else {
    point_syntax = ""
  }
  
  if (!is.null(stvalues)) {
    stvalues_syntax <- paste0("STVALUES = ", stvalues, ";")
  } else {
    stvalues_syntax = ""
  }
  
  if (!is.null(predictor)) {
    predictor_syntax <- paste0("PREDICTOR = ", predictor, ";")
  } else {
    predictor_syntax = ""
  }
  
  if (!is.null(algorithm)) {
    algorithm_syntax <- paste0("ALGORITHM = ", algorithm, ";")
  } else {
    algorithm_syntax = ""
  }
  
  if (!is.null(bconvergence)) {
    bconvergence_syntax <- paste0("BCONVERGENCE = ", bconvergence, ";")
  } else {
    bconvergence_syntax = ""
  }
  
  if (!is.null(mditerations)) {
    mditerations_syntax <- paste0("MDITERATIONS = ", mditerations, ";")
  } else {
    mditerations_syntax = ""
  }
  
  if (!is.null(kolmogorov)) {
    kolmogorov_syntax <- paste0("KOLMOGOROV = ", kolmogorov, ";")
  } else {
    kolmogorov_syntax = ""
  }
  
  if (!is.null(prior)) {
    prior_syntax <- paste0("PRIOR = ", prior, ";")
  } else {
    prior_syntax = ""
  }
  
  analysis_syntax <- paste("ANALYSIS:",
                           type_syntax,
                           "\nESTIMATOR = BAYES;",
                           biterations_syntax,
                           chains_syntax,
                           processors_syntax,
                           bseed_syntax,
                           thin_syntax,
                           point_syntax,
                           stvalues_syntax,
                           predictor_syntax,
                           algorithm_syntax,
                           bconvergence_syntax,
                           mditerations_syntax,
                           kolmogorov_syntax,
                           prior_syntax,
                           sep = "\n")
  analysis_syntax <- gsub("\n{2,}", "\n", analysis_syntax)
  
  return(analysis_syntax)
}



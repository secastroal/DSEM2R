# Write Mplus syntax of multilevel VAR models. Based on examples 9.30-9.33 and 
# 9.37 in Mplus manual.

# ML-VAR model syntax

write.mlvar <- function(y, x = NULL, time = NULL, w = NULL, z = NULL, data, 
                        lags = 1, lag.at.0 = NULL, 
                        random.effects = list(lagged = TRUE,
                                              slopes = TRUE,
                                              trend  = TRUE,
                                              rvar   = TRUE)){
  
  # Create syntax of the multilevel VAR model.
  # Using as many lags for the y variables as indicated with the argument lag.
  # Some of these lagged effects might be set at 0 with the argument lag.at.0.
  # Within level covariates with contemporaneous effects might be added with x.
  # Linear trends can be added with time.
  # Between level covariates might be added with w. By default, all random effects 
  # are regressed on each w.
  # Between level dependent variables might be added with z. By default, every z
  # are regressed on each random effect.
  # Lagged effects, slopes, and residual variances can be defined as random 
  # effects with random effects.
  
  lagged_effects <- paste0(y, "&", rep(1:lags, each = length(y)))
  
  if (!is.null(lag.at.0)) {
    if (is.vector(lag.at.0)) {
      lag.at.0 <- t(as.matrix(lag.at.0))
    }
    
    if (nrow(lag.at.0) != length(y) | ncol(lag.at.0) != lags) {
      if (length(y == 1L)) {
        stop("Argument 'lag.at.0' must be a logical vector of length ",
             lags, "L.")
      } else {
        stop("Argument 'lag.at.0' must be a logical matrix with ",
             length(y), " rows and ", lags, " columns.")
      }
    }
    
    lagged_effects[c(lag.at.0) == TRUE] <- paste0(
      lagged_effects[c(lag.at.0) == TRUE], 
      "@0"
    )
  }
  
  if (!is.null(x)) {
    within_cov_effects <- x
  } else {
    within_cov_effects <- NULL
  }
  
  if (!is.null(time)) {
    time_effect <- time
  } else {
    time_effect <- NULL
  }
  
  if (!is.null(w)) {
    between_cov_effects <- w
  } else {
    between_cov_effects <- NULL
  }
  
  if (!is.null(z)) {
    between_dependent <- z
  } else {
    between_dependent <- NULL
  }
  
  # Vector to store the syntax for the within level model.
  within_syntax <- rep(NA, length(y) * lags * length(y))
  # Vector to store the name of the random effects.
  rand_effects <- c()
  
  if (random.effects$lagged) {
    
    if (lags == 1) {
      rand_lags <- paste0("s",
                          rep(1:length(y), each = length(y)),
                          rep(1:length(y), times = length(y))
                          )
    } else {
      rand_lags <- paste0("s",
                          rep(1:length(y), each = length(y)),
                          rep(1:length(y), times = length(y)),
                          rep(c("", paste0("_", 2:lags)), 
                              times = c(length(y) * length(y),
                                        length(y) * length(y) * (lags - 1))
                              )
      )
    }
    
    lagged_effects <- paste0(rep(rep(y, each = length(y)), lags), " ON ", 
                             unlist(rep(split(lagged_effects, 
                                              rep(1:lags, each = length(y))), 
                                        each = lags)),
                             ";")
    
    if (!is.null(lag.at.0)) {
      rand_lags[grep("@0", lagged_effects)] <- ""
    }
    
    within_syntax <- paste0(rand_lags, " | ", lagged_effects)
    
    within_syntax[grep("^ ", within_syntax)] <- gsub("^( .|)", "", 
                                                     within_syntax[grep("^ ", within_syntax)])
    
    within_syntax[grep("^ ", within_syntax)] <- gsub("^( )", "", 
                                                     within_syntax[grep("^ ", within_syntax)])
    
    if (!is.null(lag.at.0)) {
      rand_effects <- c(rand_effects, rand_lags[-grep("@0", lagged_effects)])
    } else {
      rand_effects <- c(rand_effects, rand_lags)
    }
    
    rm(rand_lags)
    
  } else {
    within_syntax <- paste0(rep(y, each = length(y) * lags), 
                            " ON ", 
                            lagged_effects, ";")
  }
  
  if (!is.null(x)) {
    if (random.effects$slopes) {
      rand_slo <- paste0("sx",
                         rep(1:length(y), each = length(x)),
                         rep(1:length(x), times = length(y)))
      
      within_cov_effects <- paste0(rand_slo, " | ",
                                   rep(y, each = length(x)), 
                                   " ON ", within_cov_effects, ";")
      
      within_syntax <- c(within_syntax, "\n", within_cov_effects)
      
      rand_effects <- c(rand_effects, rand_slo)
      
      rm(rand_slo)
    } else {
      within_syntax <- c(within_syntax,  "\n", 
                         paste0(rep(y, each = length(x)), 
                                " ON ", within_cov_effects, ";"))
    }
  }
  
  if (!is.null(time)) {
    if (random.effects$trend) {
      rand_time <- paste0("st", 1:length(y))
      
      time_effect <-  paste0(rand_time, " | ", y, " ON ", time_effect, ";")
      
      within_syntax <- c(within_syntax, "\n", time_effect)
      
      rand_effects <- c(rand_effects, rand_time)
      
      rm(rand_time)
    } else {
      within_syntax <-  c(within_syntax, "\n",
                          paste0(y, " ON ", time_effect, ";"))
    }
  }
  
  if (random.effects$rvar) {
    if (length(y) == 1L) {
      rand_var <- "logv"
      
      within_syntax <- c(within_syntax, "\n", paste0(rand_var, " | ", y, ";"))
      
      rand_effects <- c(rand_effects, rand_var)
      
      rm(rand_var)
    } else {
      rand_var <- paste0("logv", 1:length(y))
      
      var_syntax <- paste0(rand_var, " | ", y, ";")
      
      cov_index <- which(upper.tri(diag(length(y))), arr.ind = TRUE)
      
      rand_cov <- paste0("logv", apply(cov_index, 1, paste0, collapse = ""))
      
      cov_syntax <- c()
      
      for (i in 1:nrow(cov_index)) {
        tmp_cov_syntax <- paste0("f", cov_index[i, 1], cov_index[i, 2], 
                                 " BY ", y[cov_index[i, 1]], "@1 ", 
                                 y[cov_index[i, 2]], "@1;")
        tmp_cov_syntax <- c(tmp_cov_syntax, 
                            paste0(rand_cov[i],  " | ", "f", 
                                   cov_index[i, 1], 
                                   cov_index[i, 2], ";"))
        cov_syntax <- c(cov_syntax, tmp_cov_syntax)
      }
      rm(i, tmp_cov_syntax)
      
      within_syntax <- c(within_syntax, "\n", var_syntax, "\n", cov_syntax)
      
      rand_effects <- c(rand_effects, rand_var, rand_cov)
      
      rm(rand_var, rand_cov, cov_index)
    }
  }
  
  # The full variance-covariance matrix among the random effects at the 
  # between-level is estimated by default.
  
  between_syntax <- c()
  
  if (!is.null(w)) {
    between_cov_effects <- paste0(rand_effects, " ON ",
                                  paste(between_cov_effects, collapse = " "), ";")
    
    between_syntax <- c(between_syntax, between_cov_effects)
  }
  
  if (!is.null(z)) {
    between_dependent <- paste0(between_dependent, " ON ",
                                paste(rand_effects, collapse = " "), ";")
    between_syntax <- c(between_syntax, "\n", between_dependent)
  }
  
  between_var_cov_syntax <- paste0(paste(c(y, rand_effects), collapse = " "), " WITH ",
                                   paste(c(y, rand_effects), collapse = " "), ";")
  
  between_syntax <- c(between_syntax, "\n", between_var_cov_syntax)
  
  # Put within and between syntax together
  
  syntax <- c("%WITHIN%", within_syntax, "\n", "%BETWEEN%", between_syntax)
  
  # Reduce line length to 85 characters or less.
  syntax <- paste(strwrap(syntax, width = 85, exdent = 5), collapse = "\n")
  
  # Delete spaces before ;
  syntax <- gsub(" ;", ";", syntax)
  
  # Complete model syntax:
  syntax <- paste0("MODEL:\n", syntax)
  
  return(syntax)
  
}

#cat(paste(within_syntax, collapse = "\n"))

# 9.30
# one variable y with random intercept, slopes, and variance. And between level
# predictors.
# FSCOMPARISON
# 9.31
# add random slope for within level covariate. Within level covariates are 
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

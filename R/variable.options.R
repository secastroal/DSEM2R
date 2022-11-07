# Mplus variable options

variable.options <- function(usevar    = NULL,
                             within    = NULL,
                             between   = NULL,
                             cluster   = NULL,
                             lagged    = NULL,
                             lags      = NULL,
                             timevar   = NULL,
                             tinterval = NULL) {
  if (!is.null(usevar)) {
    usevar_syntax <- paste0("USEVARIABLES = ",
                            paste(usevar, collapse = " "),
                            ";")
  } else {
    usevar_syntax <- ""
  }
  
  if (!is.null(within)) {
    within_syntax <- paste0("WITHIN = ",
                            paste(within, collapse = " "),
                            ";")
  } else {
    within_syntax <- ""
  }
  
  if (!is.null(between)) {
    between_syntax <- paste0("BETWEEN = ",
                            paste(between, collapse = " "),
                            ";")
  } else {
    between_syntax <- ""
  }
  
  if (!is.null(cluster)) {
    cluster_syntax <- paste0("CLUSTER = ", cluster, ";")
  } else {
    cluster_syntax <- ""
  }
  
  if (!is.null(lagged)) {
    if (length(lagged) != length(lags) & length(lags) != 1L) {
      stop("Indicate one number of 'lags' for all the 'lagged' variables ",
           "or as many numbers of 'lags' as there are 'lagged' variables.")
    }
    
    lagged_syntax <- paste0("LAGGED = ",
                            paste(lagged, "(", lags, ")", 
                                  sep = "", collapse = " "),
                            ";")
  } else {
    lagged_syntax <- ""
  }
  
  if (!is.null(timevar)) {
    
    if (is.null(tinterval)) {
      tinterval <- 1
      message("'tinterval' has been set to 1.")
    }
    
    timevar_syntax <- paste0("TINTERVAL = ", timevar, "(", tinterval, ");")
  } else {
    
    if (!is.null(tinterval)) {
      message("'tinterval' have been ignored given that ",  
              "'timevar' was not specified.")
    }
    
    timevar_syntax <- ""
  }
  
  variable_syntax <- c(usevar_syntax,
                       within_syntax,
                       between_syntax,
                       cluster_syntax,
                       lagged_syntax,
                       timevar_syntax)
  
  variable_syntax <- paste(strwrap(variable_syntax, width = 85, exdent = 5), 
                           collapse = "\n")
  
  variable_syntax <- gsub("\n{2,}", "\n", variable_syntax)
  variable_syntax <- gsub("^\n", "", variable_syntax)
  
  return(variable_syntax)
}

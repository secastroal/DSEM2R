# Write Mplus syntax of AR models. Based on examples 6.23 and 6.24 of the 
# Mplus Manual.

# VAR model syntax

write.var <- function(y, x = NULL, data, lags = 1, 
                     lag.at.0 = NULL, beta.at.0 = NULL){
  # check if 'data' argument has been specified
  
  if (missing(data))
    data <- NULL
  
  no.data <- is.null(data)
  
  if (no.data) {
    data <- sys.frame(sys.parent())
  } else {
    if (!is.data.frame(data))
      data <- data.frame(data)
  }
  
  # Check y in in the data 
  
  if (is.null(y))
    stop("Argument 'y' must be specified.")
  
  if (!(is.character(y) | is.numeric(y)))
    stop("Argument 'y' must either be a character or a numeric vector.")
  
  if (is.character(y)) {
    y.pos <- lapply(y, function(yy) {
        pos <- charmatch(yy, names(data))
        if (is.na(pos))
          stop("Variable '", yy, "' not found in the data frame.", call. = FALSE)
        if (pos == 0L)
          stop("Multiple matches for variable '", yy, "' in the data frame.", call.=FALSE)
    })
  } else {
    pos <- unique(round(y))
    if (min(pos) < 1 | max(pos) > ncol(data))
      stop("Variable positions must be between 1 and ", ncol(data), ".")
    y <- names(data)[pos]
  }
  
  if (!is.null(x)) {
    if (!(is.character(x) | is.numeric(x)))
      stop("Argument 'x' must either be a character or a numeric vector.")
    
    if (is.character(x)) {
      x.pos <- lapply(x, function(xx) {
        pos <- charmatch(xx, names(data))
        if (is.na(pos))
          stop("Variable '", xx, "' not found in the data frame.", call. = FALSE)
        if (pos == 0L)
          stop("Multiple matches for variable '", xx, "' in the data frame.", call.=FALSE)
        return(pos)
      })
    } else {
      pos <- unique(round(x))
      if (min(pos) < 1 | max(pos) > ncol(data))
        stop("Variable positions must be between 1 and ", ncol(data), ".")
      x <- names(data)[pos]
    }
  }
  
  # Create syntax of the VAR model
  # Using as many lags for the y variables as indicated with the argument lag.
  # Using contemporaneous and one lagged effect for each covariate.
  # Some of these effects might be set at 0 with the arguments lag.at.0 and 
  # beta.at.0.
  
  lagged_effects <- paste0(rep(y, each = lags), "&", 1:lags)
  lagged_effects[c(t(lag.at.0)) == 1] <- paste0(
    lagged_effects[c(t(lag.at.0)) == 1], 
    "@0"
    )
  covariate_effects <- c(rbind(x, paste0(x, "&", 1)))
  covariate_effects[c(t(beta.at.0)) == 1] <- paste0(
    covariate_effects[c(t(beta.at.0)) == 1], 
    "@0"
    )
  
  syntax <- rep(NA, length(y))
  
  for (i in 1:length(y)) {
    syntax[i] <- paste0(y[i], " ON ", 
                        paste(lagged_effects, collapse = " "), " ",
                        paste(covariate_effects, collapse = " "), ";")
  }
  rm(i)
  
  #!# Make a check to warn that some lines are longer that 80 characters or
  #!# modify the syntax somehow to include breaks in those lines.
  
  syntax <- paste(syntax, collapse = "\n")
  
  return(syntax)
}

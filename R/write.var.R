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
    
    lagged_effects[c(t(lag.at.0)) == TRUE] <- paste0(
      lagged_effects[c(t(lag.at.0)) == TRUE], 
      "@0"
      )
  }
  
  if (!is.null(x)) {
    covariate_effects <- c(rbind(x, paste0(x, "&", 1)))
    if (!is.null(beta.at.0)) {
      
      if (is.vector(beta.at.0)) {
        beta.at.0 <- t(as.matrix(beta.at.0))
      }
      
      if (nrow(beta.at.0) != length(x) | ncol(beta.at.0) != 2) {
        if (length(x == 1L)) {
          stop("Argument 'beta.at.0' must be a logical vector of length 2L.")
        } else {
          stop("Argument 'beta.at.0' must be a logical matrix with ",
               length(x), " rows and 2 columns.")
        }
      }
      
      covariate_effects[c(t(beta.at.0)) == TRUE] <- paste0(
        covariate_effects[c(t(beta.at.0)) == TRUE], 
        "@0"
      )
    }
  } else {
    covariate_effects <- NULL
  }
  
  syntax <- rep(NA, length(y))
  
  for (i in 1:length(y)) {
    syntax[i] <- paste0(y[i], " ON ", 
                        paste(lagged_effects, collapse = " "), " ",
                        paste(covariate_effects, collapse = " "), ";")
  }
  rm(i)
  
  # Reduce line length to 85 characters or less.
  syntax <- paste(strwrap(syntax, width = 85, exdent = 5), collapse = "\n")
  
  # Delete spaces before ;
  syntax <- gsub(" ;", ";", syntax)
  
  # Complete model syntax:
  syntax <- paste0("MODEL:\n", syntax)
  
  return(syntax)
}

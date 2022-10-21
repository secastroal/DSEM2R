# Write Mplus syntax of AR models. Based on examples 6.23 and 6.24 of the 
# Mplus Manual.

# AR model syntax

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
  
  
  return(c(y, x))
  
  
}

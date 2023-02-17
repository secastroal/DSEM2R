# Function to prepare data and write a complete syntax of a VAR model in Mplus

var2Mplus <- function(y, x = NULL, time = NULL, data, lags = 1, 
                      lag.at.0 = NULL, beta.at.0 = NULL,
                      variable_options,
                      analysis_options,
                      output_options,
                      filename = NULL, 
                      inpfile = TRUE,
                      runmodel = TRUE, ...) {
  
  require(MplusAutomation)
  
  # Save filename
  origfilename <- filename
  
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
  
  # Check if variables y, x, and time are in in the data 
  
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
  
  if (!is.null(time)) {
    if (!(is.character(time) | is.numeric(time)))
      stop("Argument 'time' must either be a character or a numeric vector.")
    
    if (is.character(time)) {
      time.pos <- lapply(time, function(xx) {
        pos <- charmatch(xx, names(data))
        if (is.na(pos))
          stop("Variable '", xx, "' not found in the data frame.", call. = FALSE)
        if (pos == 0L)
          stop("Multiple matches for variable '", xx, "' in the data frame.", call.=FALSE)
        return(pos)
      })
    } else {
      pos <- unique(round(time))
      if (min(pos) < 1 | max(pos) > ncol(data))
        stop("Variable positions must be between 1 and ", ncol(data), ".")
      time <- names(data)[pos]
    }
  }
  
  # Look for variables of class Date or POSIXct
  
  var.classes <- unlist(lapply(data, class))
  var.classes <- var.classes[var.classes != "POSIXt"]
  names(var.classes) <- names(data)
  
  if (!all(var.classes %in% c("numeric", "integer", "logical",
                              "character", "factor", "Date", "POSIXct"))) {
    error.class <- var.classes[!(var.classes %in% c("numeric", "integer", 
                                                    "logical", "character", 
                                                    "factor", "Date", "POSIXct"))]
    error.class <- unique(error.class)
    stop("Currently only variables of class:\n",
         "numeric, interger, logical, character, factor, Date, or POSIXct\n",
         "are allowed but found additional class types including:\n",
         error.class, "\n\nto see which variables are problematic, try:\n",
         "str(yourdata)")
  }
  
  if (any(var.classes == "Date") | any(var.classes == "POSIXct")) {
    dates.ind         <- which(var.classes == "Date" | var.classes == "POSIXct")
    
    for (i in 1:length(dates.ind)) {
      data[, dates.ind[i]] <- as.numeric(data[, dates.ind[i]] - 
                                           min(data[, dates.ind[i]]) + 1) 
    }
    rm(i)
    
    if (missing(variable_options)) {
      message("Variables: ", paste0(names(data)[dates.ind], sep = ", "), 
              "are of class 'Date' or 'POSIXct'. These variables were ",
              "coerced to numeric with 'as.numeric'.")
    } else {
      if (!is.null(variable_options$timevar)) {
        if (var.classes[variable_options$timevar] == "Date") {
          message("Variables: ", paste0(names(data)[dates.ind], sep = ", "), 
                  "are of class 'Date' or 'POSIXct'. These variables were ",
                  "coerced to numeric with 'as.numeric'.\n'timevar' in ",
                  "variable_options has been specified.\nNote, that a ",
                  "'tinterval' = ", 
                  ifelse(is.null(variable_options$tinterval), 1, 
                         variable_options$tinterval), " means that the time ",
                  "between consecutive observations is ", 
                  ifelse(is.null(variable_options$tinterval), 1, 
                         variable_options$tinterval), " day(s).") 
        } else {
          message("Variables: ", paste0(names(data)[dates.ind], sep = ", "), 
                  "are of class 'Date' or 'POSIXct'. These variables were ",
                  "coerced to numeric with 'as.numeric'.\n'timevar' in ",
                  "variable_options has been specified.\nNote, that a ",
                  "'tinterval' = ", 
                  ifelse(is.null(variable_options$tinterval), 1, 
                         variable_options$tinterval), " means that the time ",
                  "between consecutive observations is ", 
                  ifelse(is.null(variable_options$tinterval), 1, 
                         variable_options$tinterval), " second(s).")
        }
      } else {
        message("Variables: ", paste0(names(data)[dates.ind], sep = ", "), 
                "are of class 'Date' or 'POSIXct'. These variables were ",
                "coerced to numeric with 'as.numeric'.")
      }
    }
    
  }
  
  if (max(nchar(names(data))) > 8) {
    warn.names <- names(data)[which(nchar(names(data)) > 8)]
    warning("Variables names must be up to 8 characters in length.\n",
            "The following variables have names with 9 or more characters:\n",
            warn.names,
            "\n\nThis might result in errors when running the model in Mplus."
            )
  }
  
  suppressWarnings(prepareMplusData(data, filename = filename, 
                                    inpfile = inpfile, ...))
  
  if (missing(variable_options)) {
    variable_syntax <- variable.options(usevar = c(y, x, time),
                                        lagged = c(y, x), 
                                        lags = rep(c(lags, 1), 
                                                   times = c(length(y), 
                                                             length(x))))
  } else {
    variable_syntax <- do.call(variable.options, 
                               c(list(usevar = unique(c(y, x, time, 
                                                        variable_options$timevar)),
                                      lagged = c(y, x),
                                      lags = rep(c(lags, 1),
                                                 times = c(length(y), 
                                                           length(x)))),
                                 variable_options))
  }
  
  if (missing(analysis_options)) {
    analysis_syntax <- analysis.options()
  } else {
    analysis_syntax <- do.call(analysis.options, c(analysis_options))
  }
  
  model_syntax <- write.var(y = y, x = x, time = time, data = data, lags = lags, 
                            lag.at.0 = lag.at.0, beta.at.0 = beta.at.0)
  
  if (missing(output_options)) {
    output_syntax <- output.options(
      save = list(
        bparameters = gsub("(.*)\\..*$", "\\1_samples.dat", origfilename)
        )
      )
  } else {
    output_syntax <- do.call(output.options, c(output_options))
  }
  
  
  if (is.logical(inpfile) && inpfile) {
    inpfile <- gsub("(.*)\\..*$", "\\1.inp", origfilename)
  }
  
  write(paste0(variable_syntax, "\n"), inpfile, append = TRUE)
  write(paste0(analysis_syntax, "\n"), inpfile, append = TRUE)
  write(paste0(model_syntax, "\n"), inpfile, append = TRUE)
  write(paste0(output_syntax, "\n"), inpfile, append = TRUE)
  
  writeLines(readLines(inpfile))
  
  if (runmodel) {
    runModels(inpfile)
  }
  
  Mplusoutput <- readModels(gsub("(.*)\\..*$", "\\1.out", origfilename))
  
  return(Mplusoutput)
}

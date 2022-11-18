# Funtion to preare data and write a complete syntax of a VAR model in Mplus

var2Mplus <- function(y, x = NULL, data, lags = 1, 
                      lag.at.0 = NULL, beta.at.0 = NULL,
                      variable_options,
                      analysis_options,
                      output_options,
                      filename = NULL, 
                      inpfile = TRUE, ...) {
  
  require(MplusAutomation)
  
  # Look for variables of class Date or POSIXct
  
  var.classes <- unlist(lapply(data, class))
  var.classes <- var.classes[var.classes != "POSIXt"]
  
  if (any(var.classes == "Date") | any(var.classes == "POSIXct")) {
    dates.ind         <- which(var.classes == "Date" | var.classes == "POSIXct")
    data[, dates.ind] <-  as.numeric(data[, dates.ind])
    
    if (missing(variable_options)) {
      message("Variables ", paste0(names(data)[dates.ind], sep = ", "), 
              " are of class 'Date' or 'POSIXct'. These variables were ",
              "coerced to numeric with 'as.numeric'.")
    } else {
      if (!is.null(variable_options$timevar)) {
        if (class(variable_options$timevar) == "Date") {
          message("Variables ", paste0(names(data)[dates.ind], sep = ", "), 
                  " are of class 'Date' or 'POSIXct'. These variables were ",
                  "coerced to numeric with 'as.numeric'.\n 'timevar' in ",
                  "variable_options has been specified. Note, that a ",
                  "'tinterval' = ", 
                  ifelse(is.null(variable_options$tinterval), 1, 
                         variable_options$tinterval), " means that the time ",
                  "between consecutive observations is", 
                  ifelse(is.null(variable_options$tinterval), 1, 
                         variable_options$tinterval), " day(s).") 
        } else {
          message("Variables ", paste0(names(data)[dates.ind], sep = ", "), 
                  " are of class 'Date' or 'POSIXct'. These variables were ",
                  "coerced to numeric with 'as.numeric'.\n 'timevar' in ",
                  "variable_options has been specified. Note, that a ",
                  "'tinterval' = ", 
                  ifelse(is.null(variable_options$tinterval), 1, 
                         variable_options$tinterval), " means that the time ",
                  "between consecutive observations is", 
                  ifelse(is.null(variable_options$tinterval), 1, 
                         variable_options$tinterval), " second(s).")
        }
      } else {
        message("Variables ", paste0(names(data)[dates.ind], sep = ", "), 
                " are of class 'Date' or 'POSIXct'. These variables were ",
                "coerced to numeric with 'as.numeric'.")
      }
    }
    
  }
  
  prepareMplusData(data, filename = filename, inpfile = inpfile, ...)
  
  if (missing(variable_options)) {
    variable_syntax <- variable.options(usevar = c(y, x),
                                        lagged = c(y, x), 
                                        lags = rep(c(lags, 1), 
                                                   times = c(length(y), 
                                                             length(x))))
  } else {
    variable_syntax <- do.call(variable.options, 
                               c(list(usevar = c(y, x, timevar),
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
  
  model_syntax <- write.var(y = y, x = x, data = data, lags = lags, 
                            lag.at.0 = lag.at.0, beta.at.0 = beta.at.0)
  
  if (missing(output_options)) {
    output_syntax <- output.options()
  } else {
    output_syntax <- do.call(output.options, c(output_options))
  }
  
  origfilename <- filename
  
  if (is.logical(inpfile) && inpfile) {
    inpfile <- gsub("(.*)\\..*$", "\\1.inp", origfilename)
  }
  
  write(paste0(variable_syntax, "\n"), inpfile, append = TRUE)
  write(paste0(analysis_syntax, "\n"), inpfile, append = TRUE)
  write(paste0(model_syntax, "\n"), inpfile, append = TRUE)
  write(paste0(output_syntax, "\n"), inpfile, append = TRUE)
  
  writeLines(readLines(inpfile))
}

# Funtion to preare data and write a complete syntax of a VAR model in Mplus

var2Mplus <- function(y, x = NULL, data, lags = 1, 
                      lag.at.0 = NULL, beta.at.0 = NULL,
                      variable_options,
                      analysis_options,
                      output_options,
                      filename = NULL, 
                      inpfile = TRUE, ...) {
  
  require(MplusAutomation)
  
  prepareMplusData(data, filename = filename, inpfile = inpfile, ...)
  
  if (missing(variable_options)) {
    variable.options(lagged = c(y, x), lags = rep(c(lags, 1), 
                                                  times = c(length(y), length(x))))
  } else {
    do.call(variable.options, c(list(lagged = c(y, x), 
                                     lags = rep(c(lags, 1), 
                                                times = c(length(y), length(x))))),
            variable_options)
  }
  
  if (missing(analysis.options)) {} else {}
  
  if (missing(output.options)) {} else {}
}
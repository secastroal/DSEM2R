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
    variable_syntax <- variable.options(usevar = c(y, x),
                                        lagged = c(y, x), 
                                        lags = rep(c(lags, 1), 
                                                   times = c(length(y), 
                                                             length(x))))
  } else {
    variable_syntax <- do.call(variable.options, 
                               c(list(usevar = c(y, x),
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

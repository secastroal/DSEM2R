# Mplus output options.

output.options <- function (tech         = c(1, 8),
                            standardized = FALSE,
                            fcomparison  = FALSE,
                            save = list(bparameters = NULL,
                                        fscores     = NULL)) {
  if (standardized) {
    standardized_syntax <- "STANDARDIZED (CLUSTER)"
  } else {
    standardized_syntax <- ""
  }
  
  if (fcomparison) {
    fcomparison_syntax <- "FCOMPARISON"
  } else {
    fcomparison_syntax <- ""
  }
  
  output_syntax <- paste0(paste("OUTPUT:",
                          paste(paste0("TECH", tech), collapse = " "),
                          standardized_syntax,
                          fcomparison_syntax), ";")
  output_syntax <- gsub(" {1,};", ";", output_syntax)
  output_syntax <- paste(strwrap(output_syntax, width = 85, exdent = 5), 
                         collapse = "\n")
  
  if (any(unlist(save))) {
    
    if (!is.null(bparameters)) {
      bparameters_syntax <- paste0("BPARAMETERS = ", bparameters, ";")
    } else {
      bparameters_sytax <- ""
    }
    
    if (!is.null(fscores)) {
      fscores_syntax <- paste0("FILE is ", fscores, 
                               ";\nSAVE = FSCORES (100, 10);")
    } else {
      fscores_syntax <- ""
    }
    
    savedata_syntax <- paste("SAVEDATA:",
                             bparameters_syntax,
                             fscores_syntax,
                             sep = "\n")
    savedata_syntax <- gsub("\n{2,}", "\n", savedata_syntax)
  } else {
    savedata_syntax <- ""
  }
  
  syntax <- paste(savedata_syntax, output_syntax, sep = "\n")
  syntax <- gsub("\n{2,}", "\n", syntax)
  
  return(syntax)
}

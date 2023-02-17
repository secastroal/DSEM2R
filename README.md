# DSEM2R

This repository includes a set of functions that allow to easily run DSEM analyses within the R environment. In particular, with these functions one can run (V)AR and multilevel (V)AR models. The functions allow writing the syntax and exporting the data to Mplus, run the model in Mplus, and read the output of the analysis.

## To Do

- [] Include syntax line to allow for within level covariates when TINTERVAL is defined. Trick Mplus into thinking the covariate is a dependent variable. For example: `x ON x&1\@0`.
- [] Group center within-level covariates in mlvar2Mplus.


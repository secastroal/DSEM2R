
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DSEM2R

<!-- badges: start -->

<!-- badges: end -->

# DSEM2R

This repository includes a set of functions that allow to easily run
DSEM analyses within the R environment. In particular, with these
functions one can run (V)AR and multilevel (V)AR models. The functions
allow writing the syntax and exporting the data to Mplus, run the model
in Mplus, and read the output of the analysis.

**Note that you need to have Mplus installed to make use of the
functions available in this repository as well as the R package
[MplusAutomation](https://cran.r-project.org/web/packages/MplusAutomation/index.html).**

There are two main functions: `var2Mplus` and `mlvar2Mplus`. `var2Mplus`
is used to run
![N=1](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;N%3D1
"N=1") DSEM models and `mlvar2Mplus` is used to run multilevel DSEM
models.

## How to Use It

At the moment, the best way to make use of these functions is to
download all the files in the folder [R](R/) and `source` the functions
to your R environment. In the future, we plan to structure this
repository as an R package so users can simply install the package via
`remotes::install_github("secastroal/DSEM2R")`.

### Example: var2Mplus

Here, we present some example on how to use the function `var2DSEM`.

Let us first simulate time series data with two variables and 100 time
points based on a VAR(1) process:

``` r
vardata <- freqdom::rar(100)
vardata <- data.frame(vardata)
names(vardata) <- c("y1", "y2")
```

Now, with the simulated data, we can simply fit an AR(1) model for
variable `y1`. To do this, three arguments are needed: `y` to indicate
the name of the dependent variable (`y1`), `data` to indicate the
data.frame where the data is stored, and `filename` to indicate the name
for the data and input files that are required to run the analysis in
Mplus.

``` r
exvar01 <- var2Mplus(
  y        = "y1",
  data     = vardata,
  filename = "exvar01.dat")
#> Loading required package: MplusAutomation
#> Version:  1.1.0
#> We work hard to write this free software. Please help us get credit by citing: 
#> 
#> Hallquist, M. N. & Wiley, J. F. (2018). MplusAutomation: An R Package for Facilitating Large-Scale Latent Variable Analyses in Mplus. Structural Equation Modeling, 25, 621-638. doi: 10.1080/10705511.2017.1402334.
#> 
#> -- see citation("MplusAutomation").
#> TITLE: Your title goes here
#> DATA: FILE = "exvar01.dat";
#> VARIABLE: 
#> NAMES = y1 y2; 
#> MISSING=.;
#> USEVARIABLES = y1;
#> LAGGED = y1(1);
#> 
#> 
#> ANALYSIS:
#> ESTIMATOR = BAYES;
#> BITERATIONS = 50000 (2000);
#> CHAINS = 2;
#> PROCESSORS = 2;
#> 
#> 
#> MODEL:
#> y1 ON y1&1;
#> 
#> SAVEDATA:
#> BPARAMETERS = exvar01_samples.dat;
#> OUTPUT: TECH1 TECH8;
```

``` r
exvar02 <- var2Mplus(
  y        = "y1",
  x        = "y2",
  data     = vardata,
  filename = "exvar02.dat")
#> TITLE: Your title goes here
#> DATA: FILE = "exvar02.dat";
#> VARIABLE: 
#> NAMES = y1 y2; 
#> MISSING=.;
#> USEVARIABLES = y1 y2;
#> LAGGED = y1(1) y2(1);
#> 
#> 
#> ANALYSIS:
#> ESTIMATOR = BAYES;
#> BITERATIONS = 50000 (2000);
#> CHAINS = 2;
#> PROCESSORS = 2;
#> 
#> 
#> MODEL:
#> y1 ON y1&1 y2 y2&1;
#> 
#> SAVEDATA:
#> BPARAMETERS = exvar02_samples.dat;
#> OUTPUT: TECH1 TECH8;
```

``` r
exvar03 <- var2Mplus(
  y        = c("y1", "y2"),
  data     = vardata,
  filename = "exvar03.dat")
#> TITLE: Your title goes here
#> DATA: FILE = "exvar03.dat";
#> VARIABLE: 
#> NAMES = y1 y2; 
#> MISSING=.;
#> USEVARIABLES = y1 y2;
#> LAGGED = y1(1) y2(1);
#> 
#> 
#> ANALYSIS:
#> ESTIMATOR = BAYES;
#> BITERATIONS = 50000 (2000);
#> CHAINS = 2;
#> PROCESSORS = 2;
#> 
#> 
#> MODEL:
#> y1 ON y1&1 y2&1;
#> y2 ON y1&1 y2&1;
#> 
#> SAVEDATA:
#> BPARAMETERS = exvar03_samples.dat;
#> OUTPUT: TECH1 TECH8;
```

``` r
exvar04 <- var2Mplus(
  y        = c("y1", "y2"),
  data     = vardata,
  filename = "exvar04.dat",
  analysis_options = list(chains = 4,
                          biterations.min = 2000,
                          biterations.max = 10000,
                          thin = 10),
  output_options = list(save = list(bparameters = "exvar04_samples.dat")))
#> TITLE: Your title goes here
#> DATA: FILE = "exvar04.dat";
#> VARIABLE: 
#> NAMES = y1 y2; 
#> MISSING=.;
#> USEVARIABLES = y1 y2;
#> LAGGED = y1(1) y2(1);
#> 
#> 
#> ANALYSIS:
#> ESTIMATOR = BAYES;
#> BITERATIONS = 10000 (2000);
#> CHAINS = 4;
#> PROCESSORS = 4;
#> THIN = 10;
#> 
#> 
#> MODEL:
#> y1 ON y1&1 y2&1;
#> y2 ON y1&1 y2&1;
#> 
#> SAVEDATA:
#> BPARAMETERS = exvar04_samples.dat;
#> OUTPUT: TECH1 TECH8;
```

### Example: mlvar2Mplus

## To Do

  - [ ] Write package Description and documentation.
  - [ ] Test installing the package via `devtools`.
  - [ ] Allow for contemporaneous effects among dependent variables
    ![y](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;y
    "y") in both `var2Mplus` and `mlvar2Mplus`.
  - [ ] Include syntax line to allow for within level covariates when
    TINTERVAL is defined. Trick Mplus into thinking the covariate is a
    dependent variable. For example: `x ON x&1\@0`.
  - [ ] Group center within-level covariates in mlvar2Mplus.
  - [ ] Test whether mlvar2DSEM works when only specifying some of the
    random.effects.
  - [ ] Include time in the between var-cov structure when using time
    for a time trend.
  - [ ] Maybe extend to allow for latent variables.
  - [ ] Facilitate the exploration of output.

<!-- You'll still need to render `README.Rmd` regularly, to keep `README.md` up-to-date. `devtools::build_readme()` is handy for this. You could also use GitHub Actions to re-render `README.Rmd` every time you push. An example workflow can be found here: <https://github.com/r-lib/actions/tree/v1/examples>. -->

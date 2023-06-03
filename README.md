
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

Here, we present some examples on how to use the function `var2DSEM`.

Let us first simulate time series data with two variables and 100 time
points based on a VAR(1) process:

``` r
vardata <- freqdom::rar(100)
vardata <- data.frame(vardata)
names(vardata) <- c("y1", "y2")
```

#### AR model.

Now, with the simulated data, we can simply fit an AR(1) model for
variable `y1`. To do this, three arguments are needed: `y` to indicate
the name of the dependent variable (`y1`), `data` to indicate the
data.frame where the data is stored, and `filename` to indicate the name
for the data and input files that are required to run the analysis in
Mplus. When running the function, it prints the Mplus syntax of the
model in the console and at the same time it has run the model and read
the results into R. By default, the function also saves the MCMC samples
into a *.dat* file and uses as default output the options *TECH1* and
*TECH8* from Mplus.

``` r
exvar01 <- var2Mplus(
  y        = "y1",
  data     = vardata,
  filename = "exvar01.dat")
#> The file(s)
#>  'exvar01.dat' 
#> currently exist(s) and will be overwritten
#> The file 'exvar01.inp' currently exists and will be overwritten
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

The final object `exvar01` is an *“mplus.model”* object as defined in
`MplusAutomation`, which includes all the available output of the model.
For example, we can use the following code to access the parameter
estimates:

``` r
exvar01$summaries
#>   Mplus.version                Title AnalysisType   DataType Estimator
#> 1           8.7 Your title goes here      GENERAL INDIVIDUAL     BAYES
#>   Observations NGroups NDependentVars NIndependentVars NContinuousLatentVars
#> 1          100       1              1                1                     0
#>   Parameters     DIC    pD    Filename
#> 1          3 307.363 3.294 exvar01.out
```

Also, we can extract the MCMC samples. the following command extracts
the first 6 samples of the first chain:

``` r
head(exvar01$bparameters$valid_draw$'1')
#> Markov Chain Monte Carlo (MCMC) output:
#> Start = 1 
#> End = 7 
#> Thinning interval = 1 
#>      Chain.number Iteration.number Parameter.1_MEAN.Y1 Parameter.2_Y1.ON.Y1&1
#> 1001            1             1001            -0.04705                0.55833
#> 1002            1             1002             0.23396                0.55816
#> 1003            1             1003             0.00100                0.34887
#> 1004            1             1004            -0.19786                0.56805
#> 1005            1             1005             0.01342                0.49099
#> 1006            1             1006            -0.24715                0.46083
#> 1007            1             1007             0.11888                0.37603
#>      Parameter.3_Y1
#> 1001        1.20930
#> 1002        1.02483
#> 1003        2.27527
#> 1004        1.26915
#> 1005        1.02224
#> 1006        1.14204
#> 1007        1.08247
```

#### AR model with one covariate.

Now, we can also fit an AR model on variable `y1` but adding `y2` as a
covariate. By default, when adding covariates, the function includes the
contemporaneous and the lagged effect of the covariate on the dependent
variable. This behavior can be modified with the argument `beta.at.0`.
More information about this will be available in the documentation. For
now, if the model is defined as:

  
![&#10;y\_{1,t} = \\alpha + \\phi{y\_{1,t-1}} + \\beta\_{0}{y\_{2,t}} +
\\beta\_{1}{y\_{2,t - 1}} +
\\varepsilon\_{t},&#10;](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;%0Ay_%7B1%2Ct%7D%20%3D%20%5Calpha%20%2B%20%5Cphi%7By_%7B1%2Ct-1%7D%7D%20%2B%20%5Cbeta_%7B0%7D%7By_%7B2%2Ct%7D%7D%20%2B%20%5Cbeta_%7B1%7D%7By_%7B2%2Ct%20-%201%7D%7D%20%2B%20%5Cvarepsilon_%7Bt%7D%2C%0A
"
y_{1,t} = \\alpha + \\phi{y_{1,t-1}} + \\beta_{0}{y_{2,t}} + \\beta_{1}{y_{2,t - 1}} + \\varepsilon_{t},
")  
then, the syntax to run the model is Mplus is as follows:

``` r
exvar02 <- var2Mplus(
  y        = "y1",
  x        = "y2",
  data     = vardata,
  filename = "exvar02.dat")
#> The file(s)
#>  'exvar02.dat' 
#> currently exist(s) and will be overwritten
#> The file 'exvar02.inp' currently exists and will be overwritten
```

#### VAR model.

In this example, we use `y2` as a dependent variable instead of as a
covariate.Therefore, we fit a bivariate VAR model. We can specify this
model with the following command:

``` r
exvar03 <- var2Mplus(
  y        = c("y1", "y2"),
  data     = vardata,
  filename = "exvar03.dat")
#> The file(s)
#>  'exvar03.dat' 
#> currently exist(s) and will be overwritten
#> The file 'exvar03.inp' currently exists and will be overwritten
```

#### Additional options.

With the function `var2Mplus`, we can further customize the analyses in
Mplus. For example, we can specify a time variable to use with the
*TINTERVAL* option, modify the settings of the MCMC algorithm, or save
the factor scores of the latent variables of interest. The example
bellow shows how to modify the setting of the MCMC algorithm:

``` r
exvar04 <- var2Mplus(
  y        = c("y1", "y2"),
  data     = vardata,
  filename = "exvar04.dat",
  analysis_options = list(chains = 4,
                          biterations.min = 2000,
                          biterations.max = 10000,
                          thin = 10))
#> The file(s)
#>  'exvar04.dat' 
#> currently exist(s) and will be overwritten
#> The file 'exvar04.inp' currently exists and will be overwritten
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

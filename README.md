
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DSEM2R

<!-- badges: start -->

<!-- badges: end -->

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

Here, we present some examples on how to use the function `var2Mplus`.

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
exvar01$parameters$unstandardized
#>          paramHeader param    est posterior_sd pval lower_2.5ci upper_2.5ci
#> 1              Y1.ON  Y1&1  0.374        0.092 0.00       0.179       0.546
#> 2         Intercepts    Y1 -0.106        0.106 0.15      -0.322       0.106
#> 3 Residual.Variances    Y1  1.064        0.157 0.00       0.821       1.428
#>     sig
#> 1  TRUE
#> 2 FALSE
#> 3  TRUE
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
#> 1001            1             1001            -0.10326                0.49491
#> 1002            1             1002             0.16172                0.49713
#> 1003            1             1003            -0.05777                0.27952
#> 1004            1             1004            -0.24690                0.48796
#> 1005            1             1005            -0.04686                0.43457
#> 1006            1             1006            -0.28934                0.38274
#> 1007            1             1007             0.05235                0.30124
#>      Parameter.3_Y1
#> 1001        1.03359
#> 1002        0.90186
#> 1003        1.95126
#> 1004        1.09602
#> 1005        0.86404
#> 1006        0.97758
#> 1007        0.94505
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

#### VAR model.

In this example, we use `y2` as a dependent variable instead of as a
covariate.Therefore, we fit a bivariate VAR model. We can specify this
model with the following command:

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

In contrast, the function `mlvar2Mplus` is used to fit multilevel VAR
models.

Again, let us first simulate a data set with 50 participants, 3
variables, and 100 time points:

``` r
mlvardata <- mlVAR::mlVARsim(nPerson = 50, 
                             nNode   = 3, 
                             nTime   = 100)
mlvardata <- mlvardata$Data
names(mlvardata) <- c("y1", "y2", "y3", "id")
```

#### ML-AR model

Using `mlvar2Mplus` is very similar to using `var2Mplus` but there are
much more options to accommodate for the multilevel structure (occasions
nested in individuals). This function allows adding within-level
covariates, between-level covariates, and between-level dependent
variables. Also, by default, lagged coefficients, regression slopes,
linear time trends, and residual variances are allowed to vary randomly
across individuals.

In this first example, we simply fit a multilevel AR model for one
variable:

``` r
exmlvar01 <- mlvar2Mplus(
  y    = "y1",
  id   = "id",
  data = mlvardata,
  filename = "exmlvar01.dat")
#> TITLE: Your title goes here
#> DATA: FILE = "exmlvar01.dat";
#> VARIABLE: 
#> NAMES = y1 y2 y3 id; 
#> MISSING=.;
#> USEVARIABLES = y1 id;
#> CLUSTER = id;
#> LAGGED = y1(1);
#> 
#> 
#> ANALYSIS:
#> TYPE = TWOLEVEL RANDOM;
#> ESTIMATOR = BAYES;
#> BITERATIONS = 50000 (2000);
#> CHAINS = 2;
#> PROCESSORS = 2;
#> 
#> 
#> MODEL:
#> %WITHIN%
#> s11 | y1 ON y1&1;
#> 
#> logv | y1;
#> 
#> %BETWEEN%
#> 
#> y1 s11 logv WITH y1 s11 logv;
#> 
#> SAVEDATA:
#> BPARAMETERS = exmlvar01_samples.dat;
#> FILE is exmlvar01_fscores.dat;
#> SAVE = FSCORES (100, 10);
#> OUTPUT: TECH1 TECH8;
```

Just as with `var2Mplus`, the object `exmlvar01` is an *“mplus.model”*
object. Hence, we can look at the estimated parameters like this:

``` r
exmlvar01$parameters$unstandardized
#>   paramHeader param   est posterior_sd  pval lower_2.5ci upper_2.5ci   sig
#> 1     Y1.WITH   S11 0.029        0.041 0.220      -0.048       0.116 FALSE
#> 2     Y1.WITH  LOGV 0.108        0.098 0.105      -0.073       0.320 FALSE
#> 3    S11.WITH  LOGV 0.025        0.023 0.111      -0.018       0.076 FALSE
#> 4       Means    Y1 0.228        0.153 0.072      -0.080       0.537 FALSE
#> 5       Means   S11 0.187        0.035 0.000       0.118       0.256  TRUE
#> 6       Means  LOGV 0.057        0.082 0.235      -0.104       0.219 FALSE
#> 7   Variances    Y1 1.005        0.238 0.000       0.650       1.582  TRUE
#> 8   Variances   S11 0.050        0.014 0.000       0.030       0.085  TRUE
#> 9   Variances  LOGV 0.312        0.077 0.000       0.209       0.495  TRUE
#>   BetweenWithin
#> 1       Between
#> 2       Between
#> 3       Between
#> 4       Between
#> 5       Between
#> 6       Between
#> 7       Between
#> 8       Between
#> 9       Between
```

And, we can look at the MCMC samples like this:

``` r
head(exmlvar01$bparameters$valid_draw$'1')
#> Markov Chain Monte Carlo (MCMC) output:
#> Start = 1 
#> End = 7 
#> Thinning interval = 1 
#>      Chain.number Iteration.number Parameter.1_%BETWEEN%:.MEAN.S11
#> 1001            1             1001                         0.15933
#> 1002            1             1002                         0.20492
#> 1003            1             1003                         0.14948
#> 1004            1             1004                         0.19868
#> 1005            1             1005                         0.18964
#> 1006            1             1006                         0.19147
#> 1007            1             1007                         0.13469
#>      Parameter.2_%BETWEEN%:.MEAN.LOGV Parameter.3_%BETWEEN%:.MEAN.Y1
#> 1001                         -0.00678                        0.21906
#> 1002                          0.12045                        0.25457
#> 1003                          0.06721                        0.15694
#> 1004                         -0.02911                        0.12533
#> 1005                         -0.07290                        0.17537
#> 1006                          0.19249                        0.46879
#> 1007                          0.22654                        0.51575
#>      Parameter.4_%BETWEEN%:.S11 Parameter.5_%BETWEEN%:.LOGV.WITH.S11
#> 1001                    0.04726                             -0.01191
#> 1002                    0.05355                              0.03446
#> 1003                    0.04530                              0.05927
#> 1004                    0.05921                              0.00680
#> 1005                    0.04817                              0.00921
#> 1006                    0.05868                              0.03304
#> 1007                    0.04695                              0.01031
#>      Parameter.6_%BETWEEN%:.LOGV Parameter.7_%BETWEEN%:.Y1.WITH.S11
#> 1001                     0.27693                           -0.07461
#> 1002                     0.35574                           -0.03336
#> 1003                     0.42673                            0.00391
#> 1004                     0.32269                            0.01755
#> 1005                     0.40075                            0.03449
#> 1006                     0.31490                           -0.01928
#> 1007                     0.33107                           -0.01380
#>      Parameter.8_%BETWEEN%:.Y1.WITH.LOGV Parameter.9_%BETWEEN%:.Y1
#> 1001                             0.18478                   1.24078
#> 1002                             0.13636                   1.10491
#> 1003                             0.10073                   1.02230
#> 1004                             0.16083                   0.72806
#> 1005                             0.28921                   1.28713
#> 1006                             0.12440                   0.95590
#> 1007                             0.13782                   0.77866
```

#### ML-VAR(1)

We can fit a multilevel VAR to the three simulated variables. However,
in this case, we won’t alow the residual variances to vary randomly
across participants:

``` r
exmlvar02 <- mlvar2Mplus(
  y    = c("y1", "y2", "y3"),
  id   = "id",
  data = mlvardata,
  random.effects = list(lagged = TRUE, rvar = FALSE),
  filename = "exmlvar02.dat")
#> TITLE: Your title goes here
#> DATA: FILE = "exmlvar02.dat";
#> VARIABLE: 
#> NAMES = y1 y2 y3 id; 
#> MISSING=.;
#> USEVARIABLES = y1 y2 y3 id;
#> CLUSTER = id;
#> LAGGED = y1(1) y2(1) y3(1);
#> 
#> 
#> ANALYSIS:
#> TYPE = TWOLEVEL RANDOM;
#> ESTIMATOR = BAYES;
#> BITERATIONS = 50000 (2000);
#> CHAINS = 2;
#> PROCESSORS = 2;
#> 
#> 
#> MODEL:
#> %WITHIN%
#> s11 | y1 ON y1&1;
#> s12 | y1 ON y2&1;
#> s13 | y1 ON y3&1;
#> s21 | y2 ON y1&1;
#> s22 | y2 ON y2&1;
#> s23 | y2 ON y3&1;
#> s31 | y3 ON y1&1;
#> s32 | y3 ON y2&1;
#> s33 | y3 ON y3&1;
#> 
#> %BETWEEN%
#> 
#> y1 y2 y3 s11 s12 s13 s21 s22 s23 s31 s32 s33 WITH y1 y2 y3 s11 s12 s13 s21 s22 s23
#>      s31 s32 s33;
#> 
#> SAVEDATA:
#> BPARAMETERS = exmlvar02_samples.dat;
#> FILE is exmlvar02_fscores.dat;
#> SAVE = FSCORES (100, 10);
#> OUTPUT: TECH1 TECH8;
```

#### ML-VAR(2)

The order of the lagged effects can also be modified:

``` r
exmlvar03 <- mlvar2Mplus(
  y    = c("y1", "y2"),
  id   = "id",
  data = mlvardata,
  lags = 2,
  random.effects = list(lagged = TRUE, rvar = FALSE),
  filename = "exmlvar03.dat")
#> TITLE: Your title goes here
#> DATA: FILE = "exmlvar03.dat";
#> VARIABLE: 
#> NAMES = y1 y2 y3 id; 
#> MISSING=.;
#> USEVARIABLES = y1 y2 id;
#> CLUSTER = id;
#> LAGGED = y1(2) y2(2);
#> 
#> 
#> ANALYSIS:
#> TYPE = TWOLEVEL RANDOM;
#> ESTIMATOR = BAYES;
#> BITERATIONS = 50000 (2000);
#> CHAINS = 2;
#> PROCESSORS = 2;
#> 
#> 
#> MODEL:
#> %WITHIN%
#> s11 | y1 ON y1&1;
#> s12 | y1 ON y2&1;
#> s21 | y2 ON y1&1;
#> s22 | y2 ON y2&1;
#> s11_2 | y1 ON y1&2;
#> s12_2 | y1 ON y2&2;
#> s21_2 | y2 ON y1&2;
#> s22_2 | y2 ON y2&2;
#> 
#> %BETWEEN%
#> 
#> y1 y2 s11 s12 s21 s22 s11_2 s12_2 s21_2 s22_2 WITH y1 y2 s11 s12 s21 s22 s11_2 s12_2
#>      s21_2 s22_2;
#> 
#> SAVEDATA:
#> BPARAMETERS = exmlvar03_samples.dat;
#> FILE is exmlvar03_fscores.dat;
#> SAVE = FSCORES (100, 10);
#> OUTPUT: TECH1 TECH8;
```

#### Additional options.

In `mlvar2Mplus`, we can also further change the settings of the
analysis in Mplus, just as with `var2Mplus`.

``` r
exmlvar04 <- mlvar2Mplus(
  y    = c("y1", "y2"),
  id   = "id",
  data = mlvardata,
  lags = 1,
  random.effects = list(lagged = TRUE, rvar = FALSE),
  filename = "exmlvar04.dat",
  analysis_options = list(chains = 4,
                          biterations.min = 5000,
                          biterations.max = 20000,
                          thin = 5))
#> TITLE: Your title goes here
#> DATA: FILE = "exmlvar04.dat";
#> VARIABLE: 
#> NAMES = y1 y2 y3 id; 
#> MISSING=.;
#> USEVARIABLES = y1 y2 id;
#> CLUSTER = id;
#> LAGGED = y1(1) y2(1);
#> 
#> 
#> ANALYSIS:
#> TYPE = TWOLEVEL RANDOM;
#> ESTIMATOR = BAYES;
#> BITERATIONS = 20000 (5000);
#> CHAINS = 4;
#> PROCESSORS = 4;
#> THIN = 5;
#> 
#> 
#> MODEL:
#> %WITHIN%
#> s11 | y1 ON y1&1;
#> s12 | y1 ON y2&1;
#> s21 | y2 ON y1&1;
#> s22 | y2 ON y2&1;
#> 
#> %BETWEEN%
#> 
#> y1 y2 s11 s12 s21 s22 WITH y1 y2 s11 s12 s21 s22;
#> 
#> SAVEDATA:
#> BPARAMETERS = exmlvar04_samples.dat;
#> FILE is exmlvar04_fscores.dat;
#> SAVE = FSCORES (100, 10);
#> OUTPUT: TECH1 TECH8;
```

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

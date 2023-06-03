
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
#>          paramHeader param   est posterior_sd  pval lower_2.5ci upper_2.5ci
#> 1              Y1.ON  Y1&1 0.483        0.088 0.000       0.297       0.648
#> 2         Intercepts    Y1 0.098        0.124 0.212      -0.157       0.344
#> 3 Residual.Variances    Y1 1.456        0.215 0.000       1.124       1.955
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
#> 1001            1             1001             0.09951                0.59416
#> 1002            1             1002             0.40880                0.53611
#> 1003            1             1003             0.15206                0.38070
#> 1004            1             1004            -0.06791                0.62625
#> 1005            1             1005             0.16713                0.52109
#> 1006            1             1006            -0.11832                0.53446
#> 1007            1             1007             0.28069                0.37958
#>      Parameter.3_Y1
#> 1001        1.41687
#> 1002        1.22071
#> 1003        2.67324
#> 1004        1.49237
#> 1005        1.19253
#> 1006        1.34014
#> 1007        1.28200
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
#>   paramHeader param    est posterior_sd  pval lower_2.5ci upper_2.5ci   sig
#> 1     Y1.WITH   S11  0.059        0.034 0.021       0.002       0.136  TRUE
#> 2     Y1.WITH  LOGV  0.296        0.146 0.009       0.046       0.622  TRUE
#> 3    S11.WITH  LOGV  0.028        0.031 0.149      -0.028       0.095 FALSE
#> 4       Means    Y1 -0.537        0.141 0.000      -0.819      -0.264  TRUE
#> 5       Means   S11  0.042        0.029 0.076      -0.015       0.100 FALSE
#> 6       Means  LOGV  0.527        0.126 0.001       0.274       0.769  TRUE
#> 7   Variances    Y1  0.869        0.206 0.000       0.574       1.371  TRUE
#> 8   Variances   S11  0.032        0.010 0.000       0.018       0.056  TRUE
#> 9   Variances  LOGV  0.773        0.179 0.000       0.533       1.204  TRUE
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
#> 1001            1             1001                         0.02494
#> 1002            1             1002                         0.06005
#> 1003            1             1003                         0.00998
#> 1004            1             1004                         0.05042
#> 1005            1             1005                         0.05002
#> 1006            1             1006                         0.03922
#> 1007            1             1007                        -0.00631
#>      Parameter.2_%BETWEEN%:.MEAN.LOGV Parameter.3_%BETWEEN%:.MEAN.Y1
#> 1001                          0.39894                       -0.61831
#> 1002                          0.61293                       -0.50335
#> 1003                          0.56073                       -0.63643
#> 1004                          0.41175                       -0.63651
#> 1005                          0.34009                       -0.60844
#> 1006                          0.72627                       -0.26265
#> 1007                          0.76917                       -0.28899
#>      Parameter.4_%BETWEEN%:.S11 Parameter.5_%BETWEEN%:.LOGV.WITH.S11
#> 1001                    0.03047                              0.00772
#> 1002                    0.04382                              0.06400
#> 1003                    0.03525                              0.04985
#> 1004                    0.04651                              0.02174
#> 1005                    0.03137                              0.00414
#> 1006                    0.03415                              0.02399
#> 1007                    0.03441                              0.02120
#>      Parameter.6_%BETWEEN%:.LOGV Parameter.7_%BETWEEN%:.Y1.WITH.S11
#> 1001                     0.62657                            0.00075
#> 1002                     0.80413                            0.01314
#> 1003                     0.95176                            0.03622
#> 1004                     0.75533                            0.05484
#> 1005                     0.96919                            0.05612
#> 1006                     0.72698                            0.03776
#> 1007                     0.80628                            0.03240
#>      Parameter.8_%BETWEEN%:.Y1.WITH.LOGV Parameter.9_%BETWEEN%:.Y1
#> 1001                             0.35238                   0.76641
#> 1002                             0.31831                   0.76981
#> 1003                             0.32781                   0.85714
#> 1004                             0.33889                   0.67709
#> 1005                             0.56733                   1.24474
#> 1006                             0.30250                   0.79180
#> 1007                             0.30270                   0.71371
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
  lags = 2,
  random.effects = list(lagged = TRUE, rvar = FALSE),
  filename = "exmlvar04.dat",
  analysis_options = list(chains = 4,
                          biterations.min = 5000,
                          biterations.max = 20000,
                          thin = 10))
#> TITLE: Your title goes here
#> DATA: FILE = "exmlvar04.dat";
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
#> BITERATIONS = 20000 (5000);
#> CHAINS = 4;
#> PROCESSORS = 4;
#> THIN = 10;
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

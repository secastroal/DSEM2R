# Testing data for VAR model.
library(MplusAutomation)
invisible(lapply(list.files("R/", full.names = TRUE), source))

set.seed(2022)

nT   <- 200 # Number of time points
M    <- 2   # Number of dependent variables
C    <- 2   # Number of covariates
y       <- matrix(NA, nT, M)  # Matrix to store dependent variables
y[1, ]  <- rnorm(M)           # First observation of dependent variables
x       <- replicate(C, rnorm(nT)) # Random normal covariates
t.trend <- FALSE                   # Include time as a linear trend

# Generate dates between 2020 and 2021
day <- seq(as.Date("2020/09/01"), as.Date("2021/08/31"), by = "day")
day <- sort(sample(day, nT))

beeps <- seq(as.POSIXct("2020-09-01 08:00:00"), by = "90 min", length.out = 200)

# Generate regression coefficients between -5 and 5
# Including the intercept, the autoregressive effect, 2 effects for
# each covariate, and an effect for time.
alpha    <- sample(-5:5, M)/10   # Intercept
t.effect <- sample(-5:5, M)/1000 # Linear effect of time.
lagged <- matrix(sample(0:5, M * M, replace = TRUE)/10, M, M)          # (Cross)-Lagged effects
betas  <- matrix(sample(-5:5, C * 2 * M, replace = TRUE)/10, M, C * 2) # Effects Covariates


# Generate y for time >= 2

for (t in 2:nT) {
  y[t, ] <- alpha + 
            lagged %*% y[t - 1, ] + 
            ifelse(C == 0, 0, betas[, 1:C] %*% as.matrix(x[t - 1, ])) +
            ifelse(C == 0, 0, betas[, (C + 1):(2 * C)] %*% as.matrix(x[t, ])) +
            ifelse(t.trend, t.effect %*% as.matrix(day[t] - day[1]), 0) +
            rnorm(M)
}
rm(t)

if (C == 0) {
  ardata <- data.frame(day, beeps, y)
  names(ardata) <- c("day", "beep", paste0("y", 1:M)) 
} else {
  ardata <- data.frame(day, beeps, y, x)
  names(ardata) <- c("day", "beep", paste0("y", 1:M), paste0("x", 1:C))
}

rm(y, x, C, nT, M, day, beeps, t.trend)

# Example 6.23 in Mplus user's guide.
var2Mplus(y = "y1", data = ardata, filename = "ex6.23.dat")
runModels("ex6.23.inp")

# Example 6.23b in Mplus user's guide.
var2Mplus(y = "y1", data = ardata, lags = 2, filename = "ex6.23b.dat")
runModels("ex6.23b.inp")

# Example 6.23c in Mplus user's guide.
var2Mplus(y = "y1", data = ardata, lags = 2, 
          lag.at.0 = c(TRUE, FALSE), filename = "ex6.23c.dat")
runModels("ex6.23c.inp")

# Example 6.24 in Mplus user's guide.
var2Mplus(y = "y1", x = "x1", data = ardata, filename = "ex6.24.dat")
runModels("ex6.24.inp")

# Example 6.25 in Mplus user's guide.
var2Mplus(y = c("y1", "y2"), data = ardata, filename = "ex6.25.dat")
runModels("ex6.25.inp")

# Example 6.25 in Mplus user's guide including tinterval option using variable day
var2Mplus(y = c("y1", "y2"), data = ardata, filename = "ex6.25b.dat",
          variable_options = list(timevar = "day"))
runModels("ex6.25b.inp")

# Example 6.25 in Mplus user's guide including tinterval option using variable beep
var2Mplus(y = c("y1", "y2"), data = ardata, filename = "ex6.25c.dat",
          variable_options = list(timevar = "beep", tinterval = 3600))
runModels("ex6.25c.inp")

# Example 6.25 in Mplus user's guide with day as a linear trend
var2Mplus(y = c("y1", "y2"), time = "day", data = ardata, 
          filename = "ex6.25d.dat")
runModels("ex6.25d.inp")

# Example 6.25 in Mplus user's guide changing MCMC options
var2Mplus(y = c("y1", "y2"), data = ardata, filename = "ex6.25e.dat",
          analysis_options = list(chains = 4, biterations.min = 2000,
                                  biterations.max = 10000, thin = 10))
runModels("ex6.25e.inp")

# Example 6.25 in Mplus user's guide saving MCMC samples
var2Mplus(y = c("y1", "y2"), data = ardata, filename = "ex6.25f.dat",
          output_options = list(save = list(bparameters = "ex6.25f_samples.dat")))
runModels("ex6.25f.inp")

# Example 6.25 in Mplus user's guide using column number instead of column name
var2Mplus(y = 3:4, data = ardata, filename = "ex6.25g.dat")
runModels("ex6.25g.inp")

# Repeat analysis with mlVAR
library("mlVAR")
ardata$sub <- rep(1, nrow(ardata))

mlVAR(ardata, vars = "y1", idvar = "sub", lags = 1, temporal = "fixed", 
      contemporaneous = "fixed")
mlVAR(ardata, vars = "y1",lags = 1, temporal = "fixed")


# Simulate data:
Model <- mlVARsim(nPerson = 50, nNode = 3, nTime = 50, lag=1)
Model$Data$beep <- c(replicate(50, sort(sample(1:90, 50))))

# Estimate using correlated random effects:
fit0 <- mlVAR(Model$Data, vars = Model$vars, idvar = Model$idvar, 
              lags = 1, temporal = "correlated", contemporaneous = "fixed")
# Print some pointers:
print(fit0)
# Summary of all parameter estimates:
summary(fit0)

# Estimate using correlated random effects:
fit1 <- mlVAR(Model$Data, vars = Model$vars, idvar = Model$idvar, 
              lags = 1, temporal = "correlated", contemporaneous = "fixed",
              estimator = "Mplus", MplusName = "fit1")
# Print some pointers:
print(fit1)
# Summary of all parameter estimates:
summary(fit1)

fit1output <- readModels("fit1.out")

fit1samples <- fit1output$bparameters$valid_draw

mean(fit1samples[, "Parameter.7_%BETWEEN%:.MEAN.PAR1"])



fit2 <- mlVAR(Model$Data, vars = Model$vars, idvar = Model$idvar, beepvar = "beep", 
              lags = 1, temporal = "correlated", contemporaneous = "fixed",
              estimator = "Mplus", MplusName = "fit2")
# Print some pointers:
print(fit2)
# Summary of all parameter estimates:
summary(fit2)




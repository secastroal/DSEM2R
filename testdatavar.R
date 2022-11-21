# Testing data for VAR model.
library(MplusAutomation)
invisible(lapply(list.files("R/", full.names = TRUE), source))

set.seed(2022)

nT   <- 200 # Number of time points
M    <- 2   # Number of depedent variables
C    <- 2   # Number of covariates
y      <- matrix(NA, nT, M)  # Matrix to store dependent variables
y[1, ] <- rnorm(M)           # First observation of dependent variables
x  <- replicate(C, rnorm(nT)) # Random normal covariates

# Generate regression coefficients between -5 and 5
# The betas include the intercept, the autoregressive effect, and 2 effects for
# each covariate.
alpha  <- sample(-5:5, M)/10                    # Intercept
lagged <- matrix(sample(0:5, M * M, replace = TRUE)/10, M, M)          # (Cross)-Lagged effects
betas  <- matrix(sample(-5:5, C * 2 * M, replace = TRUE)/10, M, C * 2) # Effects Covariates

# Generate y for time >= 2

for (t in 2:nT) {
  y[t, ] <- alpha + 
            lagged %*% y[t - 1, ] + 
            betas[, 1:C] %*% as.matrix(x[t - 1, ]) +
            betas[, (C + 1):(2 * C)] %*% as.matrix(x[t, ]) + 
            rnorm(M)
}
rm(t)

# Generate dates between 2020 and 2021
day <- seq(as.Date("2020/09/01"), as.Date("2021/08/31"), by = "day")
day <- sort(sample(day, nT))

beeps <- seq(as.POSIXct("2020-09-01 08:00:00"), by = "90 min", length.out = 200)

ardata <- data.frame(day, beeps, y, x)
names(ardata) <- c("day", "beep", paste0("y", 1:2), paste0("x", 1:C))
rm(y, x, C, nT, day, beeps)


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

# Example 6.25 in Mplus user's guide including tinterval option
var2Mplus(y = c("y1", "y2"), data = ardata, filename = "ex6.25b.dat",
          variable_options = list(timevar = "day"))
runModels("ex6.25b.inp")


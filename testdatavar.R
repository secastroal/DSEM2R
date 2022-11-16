# Testing data for VAR model.
library(MplusAutomation)
invisible(lapply(list.files("R/", full.names = TRUE), source))

set.seed(2022)

nT   <- 200 # Number of time points
C    <- 2   # Number of covariates
y      <- matrix(NA, nT, 2)  # Matrix to store dependent variables
y[1, ] <- rnorm(2)           # First observation of dependent variables
x  <- replicate(C, rnorm(nT)) # Random normal covariates

# Generate regression coefficients between -5 and 5
# The betas include the intercept, the autoregressive effect, and 2 effects for
# each covariate.
alpha  <- sample(-5:5, 2)/10                     # Intercept
lagged <- matrix(sample(-5:5, 2 * 2)/10, 2, 2)   # (Cross)-Lagged effects
betas  <- matrix(sample(-5:5, C * 2 * 2, replace = TRUE)/10, 2, C * 2) # Effects Covariates

# Generate y for time >= 2

for (t in 2:nT) {
  y[t, ] <- alpha + lagged %*% y[t - 1, ] + betas[, 1:C] %*% x[t - 1, ] +
    betas[, (C + 1):(2 * C)] %*% x[t, ] + rnorm(2)
}
rm(t)

# Generate dates between 2020 and 2021
day <- seq(as.Date("2020/09/01"), as.Date("2021/08/31"), by = "day")
day <- sort(sample(day, nT))

beeps <- seq(as.POSIXct("2020-09-01 08:00:00"), by = "90 min", length.out = 200)

ardata <- data.frame(day, beeps, y, x)
names(ardata) <- c("day", "beep", paste0("y", 1:2), paste0("x", 1:C))
rm(y, x, C, nT, day, beeps)


ardata$int     <- sample(1:5, 200, replace = TRUE)
ardata$logical <- as.logical(rbinom(200, 1, 0.7))
ardata$gender  <- ifelse(rbinom(200, 1, 0.6) == 1, "male", "female")

MplusAutomation::prepareMplusData(ardata[, -(1:2)], filename = "test.dat", inpfile = TRUE)

# Example write AR(1) Mplus syntax.
var2Mplus(y = "y1", data = ardata, filename = "test1.dat")

# Example write VAR(1) Mplus syntax. 
var2Mplus(y = c("y1", "y2"), data = ardata, filename = "test2.dat")

# Run models

runModels("test1.inp")
runModels("test2.inp")

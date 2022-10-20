# Testing data for AR model.

set.seed(2022)

nT   <- 200          # Number of time points
C    <- 2            # Number of covariates
y    <- rep(NA, nT)  # Vector to store dependent variable
y[1] <- rnorm(1)     # First observation of dependent variable
x  <- replicate(C, rnorm(nT)) # Random normal covariates

# Generate regression coefficients between -5 and 5
# The betas include the intercept, the autoregressive effect, and 2 effects for
# each covariate.
betas <- sample(-5:5, C * 2 + 2, replace = TRUE)/10

# Generate y for time >= 2

for (t in 2:nT) {
  y[t] <- betas[1] + betas[2] * y[t - 1] + sum(betas[3:(2 + C)] * x[t, ]) + 
    sum(betas[(3 + C):(2 * C + 2)] * x[t - 1, ]) + rnorm(1)
}
rm(t)

ardata <- data.frame(y, x)
names(ardata) <- c("y", paste0("x", 1:C))
rm(y, x, C, nT)


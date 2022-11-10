# Testing data for VAR model.
lapply(list.files("R/", full.names = TRUE), source)

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

ardata <- data.frame(y, x)
names(ardata) <- c(paste0("y", 1:2), paste0("x", 1:C))
rm(y, x, C, nT)

# Example write AR(1) Mplus syntax.
var2Mplus(y = "y1", data = ardata, filename = "test1.dat")

# Example write VAR(1) Mplus syntax. 
var2Mplus(y = c("y1", "y2"), data = ardata, filename = "test2.dat")

# Run models

runModels("test1.inp")
runModels("test2.inp")

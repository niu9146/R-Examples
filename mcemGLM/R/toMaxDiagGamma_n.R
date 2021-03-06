# This function is used with optim to maximize the Q function.
# The paraters in 'pars' are: beta and sigma.
# df:         kL dimensional vector of degrees of freedom.
# u:          Matrix of MCMC ouput for the random effects.
# sigmaType:  Type of each covariance matrix:
#             0 - Diagonal
#             1 - Exchangeable
#             2 - AR(1)
# sigmaDim:   Dimensions of the sigma matrices.
# kKi:        Dimension of each variance component vector. Length equal to kR.
# kLh:        Number of subvariance components within each variance components. The
#             subvariance components share a covariance matrix. Length equal to kR.
# KLhi:       Number of random effects in each subvariance component.
# kY, kX, kZ: Data and design matrices.
toMaxDiagGamma_n <- function(pars, u, sigmaType, kKi, kLh, kLhi, kY, kX, kZ) {
  kP <- ncol(kX)    # Number of fixed coefficients
  kR <- length(kKi) # Number of variance components, this is the number of sigma matrices
  kK <- ncol(kZ)    # Number of random effects
  kL <- sum(kLh)    # Number of subvariance components
  
  beta <- pars[1:kP]
  alpha <- pars[kP + 1]
  s0 <- length(pars[-(1:(kP + 1))]) # Number of variance parameters
  
  if (alpha <= 0) {
    return(list(value = -Inf, gradient = rep(0, length(pars)), hessian = matrix(0, length(pars), length(pars))))
  }
  
  # We call ovSigma the overall covariance matrix.
  ovSigma <- constructSigma(pars = pars[-(1:(kP + 1))], sigmaType = sigmaType, kK = kK, kR = kR, kLh = kLh, kLhi = kLhi)
  
  if (min(eigen(ovSigma)$values) <= 0) {
    return(list(value = -Inf, gradient = rep(0, length(pars)), hessian = matrix(0, length(pars), length(pars))))
  }
  
  return(qFunctionDiagGammaCpp_n(beta = beta, sigma = ovSigma, alpha = alpha, kKi = kKi, u = u, kY = kY, kX = kX, kZ = kZ))
}
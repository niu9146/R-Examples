#----------------------------------------------------------------------------------#
# Package: camel                                                                   #
# camel.slim.sqrt(): Regression with Square Root Lasso()                           #
# Author: Xingguo Li                                                               #
# Email: <xingguo.leo@gmail.com>                                                   #
# Date: Aug 23th, 2013                                                             #
# Version: 0.1.0                                                                   #
#----------------------------------------------------------------------------------#

camel.slim.sqrt.mfista <- function(Y, X, lambda, nlambda, n, d, maxdf, mu, max.ite, prec,intercept,verbose)
{
  if(verbose==TRUE)
    cat("SQRT Lasso regression via MFISTA.\n")
  XX = t(X)%*%X
  L = eigen(XX)$values[1]
  beta = array(0,dim=c(d,nlambda))
  ite.ext.init = rep(0,nlambda)
  ite.ext.ex = rep(0,nlambda)
  ite.ext.in = rep(0,nlambda)
  if(intercept) intercept=1
  else intercept=0
  str=.C("slim_sqrt_mfista", as.double(Y), as.double(X), 
         as.double(beta), as.integer(n), as.integer(d), as.double(mu),
         as.integer(ite.ext.init), as.integer(ite.ext.ex), 
         as.integer(ite.ext.in), as.double(lambda), as.integer(nlambda),
         as.integer(max.ite), as.double(prec), as.double(L), 
         as.integer(intercept),PACKAGE="camel")
  
  beta.list = vector("list", nlambda)
  ite.ext.init = matrix(unlist(str[7]), byrow = FALSE, ncol = nlambda)
  ite.ext.ex = matrix(unlist(str[8]), byrow = FALSE, ncol = nlambda)
  ite.ext.in = matrix(unlist(str[9]), byrow = FALSE, ncol = nlambda)
  ite.ext = vector("list", 3)
  ite.ext[[1]] = ite.ext.init
  ite.ext[[2]] = ite.ext.ex
  ite.ext[[3]] = ite.ext.in
  for(i in 1:nlambda){
    beta.i = unlist(str[3])[((i-1)*d+1):(i*d)]
    beta.list[[i]] = beta.i
  }
  
  return(list(beta=beta.list, ite=ite.ext))
}

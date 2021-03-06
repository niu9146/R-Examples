fmodelpcm <-
function(zeta, y, bpar, prior = dnorm, ...) {
	if (is.vector(y)) y <- matrix(y, 1, length(y))
	m <- nrow(bpar)
	r <- ncol(bpar) + 1 
	prob <- matrix(0, m, r)
  storage.mode(y) <- "integer"
  storage.mode(bpar) <- "double"
	storage.mode(prob) <- "double"
  tmp <- .Fortran("fmodelpcm", zeta = as.double(zeta), y = y,
    m = as.integer(m), r = as.integer(r), s = as.integer(nrow(y)), 
    bpar = bpar, 
  	loglik = as.double(0), prob = prob)
  return(list(post = tmp$loglik + log(prior(zeta, ...)), prob = tmp$prob))
}

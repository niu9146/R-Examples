parLoadModule <-
function(cl, name, path, quiet = FALSE) 
{
    ## stop if rjags not found
    requireNamespace("rjags")
    clusterEvalQ(cl, requireNamespace("rjags"))
    if (missing(path)) {
        path <- clusterEvalQ(cl,  getOption("jags.moddir"))
        if (any(sapply(path, is.null))) {
            stop("option jags.moddir is not set")
        }
    } else {
        if (!(length(path)  %in% c(1, length(cl))))
            stop("invalid path length")
        if (length(path) == 1)
            path <- rep(path, length(cl))
    }
    fun <- function(path, name, quiet)
        rjags::load.module(name, path, quiet)
    parLapply(cl, path, fun, name=name, quiet=quiet)
}

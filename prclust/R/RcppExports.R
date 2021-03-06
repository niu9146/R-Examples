# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

distance_2 <- function(data, ndim, j) {
    .Call('prclust_distance_2', PACKAGE = 'prclust', data, ndim, j)
}

distance_umu <- function(u, data, ndim, i, j, uj) {
    .Call('prclust_distance_umu', PACKAGE = 'prclust', u, data, ndim, i, j, uj)
}

residual_mu <- function(mu1, mu, ndim, numbers) {
    .Call('prclust_residual_mu', PACKAGE = 'prclust', mu1, mu, ndim, numbers)
}

is_zero_theta <- function(theta, j, ndim) {
    .Call('prclust_is_zero_theta', PACKAGE = 'prclust', theta, j, ndim)
}

stopping_criteria <- function(mu, mu1, ndim, numbers, count) {
    .Call('prclust_stopping_criteria', PACKAGE = 'prclust', mu, mu1, ndim, numbers, count)
}

PRclustADMM <- function(data, rho, lambda2, tau, mumethod = 0L, methods = 0L) {
    .Call('prclust_PRclustADMM', PACKAGE = 'prclust', data, rho, lambda2, tau, mumethod, methods)
}

clusterStat <- function(trueGroup, group) {
    .Call('prclust_clusterStat', PACKAGE = 'prclust', trueGroup, group)
}

distance_mu <- function(data, ndim, i, j) {
    .Call('prclust_distance_mu', PACKAGE = 'prclust', data, ndim, i, j)
}

cal_S <- function(data, mu, theta, lambda1, lambda2, tau, ndim, numbers, methods) {
    .Call('prclust_cal_S', PACKAGE = 'prclust', data, mu, theta, lambda1, lambda2, tau, ndim, numbers, methods)
}

judge_iteration <- function(data, mu, theta, mu1, theta1, lambda1, lambda2, tau, ndim, numbers, count, methods) {
    .Call('prclust_judge_iteration', PACKAGE = 'prclust', data, mu, theta, mu1, theta1, lambda1, lambda2, tau, ndim, numbers, count, methods)
}

PRclustOriginal <- function(data, lambda1, lambda2, tau, mumethod = 0L, methods = 0L) {
    .Call('prclust_PRclustOriginal', PACKAGE = 'prclust', data, lambda1, lambda2, tau, mumethod, methods)
}



clusterStat <- function(trueGroup, group) {
    x = as.vector(trueGroup)
    y = as.vector(group)
    if (length(x) != length(y))
    stop("arguments must be vectors of the same length")
    tab <- table(x, y)
    if (all(dim(tab) == c(1, 1)))
    ARI <- 1
    a <- sum(choose(tab, 2))
    b <- sum(choose(rowSums(tab), 2)) - a
    c <- sum(choose(colSums(tab), 2)) - a
    d <- choose(sum(tab), 2) - a - b - c
    ARI <- (a - (a + b) * (a + c)/(a + b + c + d))/((a + b +
    a + c)/2 - (a + b) * (a + c)/(a + b + c + d))
    
    tempres <- .Call('prclust_clusterStat', PACKAGE = 'prclust', x, y)
    RAND <- (tempres$a + tempres$b) /(tempres$a + tempres$b + tempres$c + tempres$d)
    Jaccard <- (tempres$a) /(tempres$a + tempres$c + tempres$d)
    
    
    out = list()
    #out["TrueGroup"] <- trueGroup
    #out["EstimatedGroup"] <- group
    out["Rand"] <- RAND
    out["AdjustedRand"] <- ARI
    out["Jaccard"] <- Jaccard
    class(out) <- "clusterStat"
    out
}



PRclust <- function(data, lambda1, lambda2, tau, loss.method = c("quadratic","lasso"),group.method = c("gtlp","lasso","SCAD","MCP"), algorithm = c("ADMM","Quadratic"),epsilon = 0.001) {
    ## judge for different situation
    mumethods = switch(match.arg(loss.method), `quadratic` = 0,lasso = 1)
    methods = switch(match.arg(group.method), `gtlp` = 0,lasso = 1, MCP = 2, SCAD = 3)
    nalgorithm = switch(match.arg(algorithm), `ADMM` = 1,Quadratic = 2)
    
    if(is.character(lambda1))
    stop("lambda1 must be a number")
    if(is.character(lambda2))
    stop("lambda2 must be a number")
    if(is.character(tau))
    stop("tau must be a number")
    if(lambda1<0 | is.na(lambda1))
    stop("lambda1 must be a postive number, you can use GCV to choose the 'best' tunning parameter.")
    if(lambda2<0 | is.na(lambda2))
    stop("lambda2 must be a postive number, you can use GCV to choose the 'best' tunning parameter.")
    if(tau<0 | is.na(tau))
    stop("tau must be a postive number, you can use GCV to choose the 'best' tunning parameter.")
    data = as.matrix(data)
    if(sum(is.na(data)))
    stop("Clustering data contains NA or character value. The current version does not support missing data situation.")
    
    if( nalgorithm ==1){
        rho = lambda1
        res = .Call('prclust_PRclustADMM', PACKAGE = 'prclust', data, rho, lambda2, tau,mumethods, methods,epsilon)
    } else {
        if (mumethods!= 0 || methods >=2)
        {
            stop("Quadtraic penalty based algorithm cannot deal with the selected objective function. You can try ADMM instead.")
        }
        res = .Call('prclust_PRclustOriginal', PACKAGE = 'prclust', data, lambda1, lambda2, tau, mumethods,methods)
    }
    
    out = list(mu = res$mu,count = res$count,group = res$group,
    theta = res$theta,lambda1 = lambda1, lambda2 = lambda2,tau = tau, method = methods, algorithm = nalgorithm)
    class(res) = "prclust"
    res
}

print.clusterStat <-function(x, ...) {
    cat("External evaluation of cluster results:\n")
    cat(paste("The Rand index: ",x$Rand,"\n",sep = ""))
    cat(paste("The adjusted rand index: ",x$AdjustedRand,"\n",sep = ""))
    cat(paste("The Jaccard index: ", x$Jaccard,"\n",sep = ""))
}

print.prclust <- function(x, ...) {
    temp.group = x$group
    max.groupnum = max(temp.group)
    cat(paste("Penalized regression-based clustering (prclust) with ",max.groupnum," clusters.\n",sep = ""))
    cat(paste("The iteration time is ",x$count,".\n",sep = ""))
    
    cat("\nThe centroids of observations:\n")
    print(x$mu)
    
    cat("\nClustering vector:\n")
    print(x$group)
    invisible(x)
}

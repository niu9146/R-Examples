reorder.parafac2 <-
  function(x, neworder, ...){
    # Reorder Factors of fit Parafac2 model
    # Nathaniel E. Helwig (helwig@umn.edu)
    # last updated: August 19, 2015    
    
    # check neworder
    neworder <- as.integer(neworder)
    nfac <- ncol(x$B)
    if(length(neworder)!=nfac) stop("Incorrect input for 'neworder'. Must have length equal to number of factors.")
    if(!identical(seq(1L,nfac),sort(neworder))) stop(paste("Incorrect input for 'neworder'. Must be unique integers in range of 1 to",nfac))
    
    # reorder factors
    x$A$G <- x$A$G[,neworder]
    x$B <- x$B[,neworder]
    x$C <- x$C[,neworder]
    if(!is.null(x$D)) x$D <- x$D[,neworder]
    return(x)
    
  }
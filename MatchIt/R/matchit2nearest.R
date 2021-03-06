matchit2nearest <-  function(treat, X, data, distance, discarded,
                             ratio=1, replace = FALSE, m.order = "largest",  
                             caliper = 0, calclosest = FALSE,
                             mahvars = NULL, exact = NULL,
                             subclass=NULL, verbose=FALSE, sub.by=NULL,
                             is.full.mahalanobis,...){  

 if(verbose)
    cat("Nearest neighbor matching... \n")

  #replace
  if(!(identical(replace,TRUE) | identical(replace,FALSE))){
    warning("replace=",replace," is invalid; used replace=FALSE instead",call.=FALSE);replace=FALSE}
  #m.order
  if(!(identical(m.order,"largest") | identical(m.order,"smallest") |
       identical(m.order,"random"))){
    warning("m.order=",m.order," is invalid; used m.order='largest' instead",call.=FALSE);m.order="largest"}
  #ratio
  ratio <- round(ratio)
  if(!is.numeric(ratio) | ratio[1]<1 | !identical(round(length(ratio)),1)){
    warning("ratio=",ratio," is invalid; used ratio=1 instead",call.=FALSE);ratio=1}
  #caliper
  if(!is.vector(caliper) | !identical(round(length(caliper)),1)){
    warning("caliper=",caliper," is invalid; Caliper matching not done",call.=FALSE);caliper=0}
  if(caliper<0){
    warning("caliper=",caliper," is less than 0; Caliper matching not done",call.=FALSE);caliper=0}
  #calclosest
  if(!(identical(calclosest,TRUE)| identical(calclosest,FALSE))){
    warning("calclosest=",calclosest," is invalid; used calclosest=FALSE instead",call.=FALSE)
    calclosest=FALSE}
  #mahvars & caliper
  if (!is.null(mahvars) & caliper[1]==0){
    warning("No caliper size specified for Mahalanobis matching.  Caliper=.25 used.",call. = FALSE);caliper=.25}
 #when mahalanobis distance is used for all covars
 if(is.full.mahalanobis){
   mahvars <- X
   Sigma <- var(X)
   ## Note: caliper irrelevant, but triggers mahalanobis matching
   caliper <- .25
   ## no subclass with full mahalanobis
   if(!is.null(subclass)){
     warning("No subclassification with pure Mahalanobis distance.",call. = FALSE)
     subclass <- NULL
   }
 }
 
  # Sample sizes, labels
  n <- length(treat)
  n0 <- length(treat[treat==0])
  n1 <- length(treat[treat==1])
  d1 <- distance[treat==1]
  d0 <- distance[treat==0]
  
  if(is.null(names(treat)))
    names(treat) <- 1:n
  labels <- names(treat)
  tlabels <- names(treat[treat==1])
  clabels <- names(treat[treat==0])
  in.sample <- !discarded
  names(in.sample) <- labels

  ## 10/1/07: Warning for if fewer control than ratio*treated and matching without replacement
  if (n0 < ratio*n1 & replace==FALSE) {
	if (ratio > 1)  warning(paste("Not enough control units for ", ratio, " matches for each treated unit when matching without replacement.  Not all treated units will receive", ratio, "matches"))
	else warning(paste("Fewer control than treated units and matching without replacement.  Not all treated units will receive a match.  Treated units will be matched in the order specified by m.order:", m.order))
  }

  ## Generating match matrix
  match.matrix <- matrix(0, nrow=n1, ncol=ratio, dimnames=list(tlabels, 1:ratio))
  
  ## Vectors of whether unit has been matched:
  ## = 0 if not matched (unit # of match if matched)
  ## = -1 if can't be matched (if in.sample=0)
  matchedc <- rep(0,length(d0))
  names(matchedc) <- clabels
  
  ## These are the units that are ineligible because of discard
  ## (in.sample==0) 
  matchedc[in.sample[clabels]==0] <- -1
  match.matrix[in.sample[tlabels]==0,] <- -1
  matchedt <- match.matrix[,1] 
  names(matchedt) <- tlabels
  
  ## total number of matches (including ratios) = ratio * n1
  tr <- length(match.matrix[match.matrix!=-1])
  r <- 1
  
  ## Caliper for matching (=0 if caliper matching not done)
  sd.cal <- caliper*sqrt(var(distance[in.sample==1]))
  
  ## Var-covar matrix for Mahalanobis (currently set for full sample)
  if (!is.null(mahvars) & !is.full.mahalanobis) {
    if(!sum(mahvars%in%names(data))==length(mahvars)) {
	    warning("Mahvars not contained in data.  Mahalanobis matching not done.",call.=FALSE)
	    mahvars=NULL
	}
    else {  ww <- mahvars%in%dimnames(X)[[2]]
    nw <- length(mahvars)
    mahvars <- data[,mahvars,drop=F]
    Sigma <- var(mahvars)
    if(sum(ww)!=nw){
      X <- cbind(X,mahvars[!ww])
    }
    mahvars <- as.matrix(mahvars)
    }
  }
  
  ## Now for exact matching within nearest neighbor
  ## exact should not equal T for this type of matching--that would get sent to matchit2exact
  if (!is.null(exact)){
    if(!sum(exact%in%names(data))==length(exact)) {
	    warning("Exact variables not contained in data. Exact matching not done.",call.=FALSE)
	    exact=NULL
	}
    else {
    ww <- exact%in%dimnames(X)[[2]]
    nw <- length(exact)
    exact <- data[,exact,drop=F]
    if(sum(ww)!=nw){
      X <- cbind(X,exact[!ww])
    }
   }
  }
 
  ## Looping through nearest neighbour matching for all treatment units
  ## Only do matching for units with in.sample==1 (matched!=-1)
  if(verbose){
    trseq <- floor(seq(tr/10,tr,tr/10))
    cat("Matching Treated: ")
  }
  
  for(i in 1:tr){
    ## Make new matchedc column to be used for exact matching
    ## Will only be 0 (eligible for matching) if it's an exact match
    if(verbose) {if(i%in%trseq){cat(10*which(trseq==i),"%...",sep="")}}  # a counter
    matchedc2 <- matchedc
    ##in cases there's no replacement and all controls have been used up
    if(!0%in%matchedc2){  
      match.matrix[match.matrix[,r]==0 & !is.na(match.matrix[,r]),r] <- NA
      if(r<ratio){match.matrix[,(r+1):ratio] <- NA}
      break
    }
    
    ##in case there's replacement, but all units have been used in
    ##previous ratios
    if(sum(!is.na(match.matrix[,r]))==0){
      if(r<ratio){match.matrix[,(r+1):ratio] <- NA}
      break
    }
    
    ## Which ratio we're on
    if(r!=ceiling(i/(tr/ratio))) {r <- r+1; matchedt <- match.matrix[,r]}
    
    if(m.order=="largest") {iterd1 <- max(d1[matchedt==0],na.rm=T)}
    if(m.order=="smallest") {iterd1 <- min(d1[matchedt==0],na.rm=T)}
    if(m.order=="random") {iterd1 <- sample(d1[matchedt==0][!is.na(d1[matchedt==0])],1)}
    
    ## The treatment unit for this iteration, again resolving ties randomly
    itert <- as.vector(na.omit(tlabels[iterd1==d1 & matchedt==0]))
    if(length(itert)>1){itert <- sample(itert,1)}
    
    ## Calculating all the absolute deviations in propensity scores
    ## Calculate only for those eligible to be matched (matchedc==0)
    ## this first if statement only applies to replacement ratio
    ## matching, so that each treatment unit is matched to a different
    ## control unit than from the previous round
    
    ## match number = NA if no units within caliper
    
    ## Set things up for exact matching
    ## Make matchedc2==-2 if it isn't an exact match
    ## There might be a more efficient way to do this, but I couldn't figure
    ## out another way to compare a vector with the matrix
    if (!is.null(exact)) {
      for (k in 1:dim(exact)[2]) matchedc2[exact[itert,k]!=exact[clabels,k]] <- -2
    }
    
    ## Need to add a check in case there aren't any eligible matches left...
    if(replace & r!=1) {
      if (sum(!clabels%in%match.matrix[itert,(1:r-1)] & matchedc2==0)==0) { 
        deviation <- NULL 
        mindev <- NA
      }
      else
        deviation <- abs(d0[!clabels%in%match.matrix[itert,(1:r-1)] & matchedc2==0]-iterd1)
    }
    else { 
      if (sum(matchedc2==0)==0) { 
        deviation <- NULL
        mindev <- NA
      }
      else deviation <- abs(d0[matchedc2==0]-iterd1)
    }
    
    if (caliper!=0 & (!is.null(deviation))) {
      if(replace & r!=1)
        pool <- clabels[!clabels%in%match.matrix[itert,(1:r-1)]
                        & matchedc2==0][deviation <= sd.cal]
      else
        pool <- clabels[matchedc2==0][deviation <= sd.cal]
      if(length(pool)==0) { 
        if (calclosest==FALSE) mindev <- NA
        else { 
          if (replace & r!= 1){ 
            mindev <- clabels[!clabels%in%match.matrix[itert,(1:r-1)]][min(deviation)==deviation]
          } else{mindev <- clabels[matchedc2==0][min(deviation)==deviation]}
        }
      }
      else if (length(pool)==1) mindev <- pool[1]
      else if (is.null(mahvars)) mindev <- sample(pool, 1)
      else {
        ## This has the important vars for the C's within the caliper
        poolvarsC <- mahvars[pool,,drop=F]
        ## Sigma is the full group var/covar matrix of Mahalvars
        mahal <- mahalanobis(poolvarsC, mahvars[itert,],Sigma)
        mindev <- pool[mahal==min(mahal)]
      }
    }
    else if(!is.null(deviation)) { 
      if (replace & r!=1){ 
        mindev <- clabels[!clabels%in%match.matrix[itert,(1:r-1)] & matchedc2==0][min(deviation)==deviation]
      } else {mindev <- clabels[matchedc2==0][min(deviation)==deviation]}
    }
    
    ## Resolving ties in minimum deviation by random draw
    if(length(mindev)>1){goodmatch <- sample(mindev,1)} else goodmatch <- mindev
    
    ## Storing which treatment unit has been matched to control, and
    ## vice versa
    matchedt[itert==tlabels] <- goodmatch
    matchedc[goodmatch==clabels] <- itert
    
    ## instead of the in.sample, we now have an index with dimensions n1 by # of
    ## matches (ratio)
    match.matrix[which(itert==tlabels),r] <- goodmatch
    
    ## If matching with replacement, set matchedc back to 0 so it can be reused
    if (replace) matchedc[goodmatch==clabels] <- 0
    
  }
  if(verbose){cat("Done\n")}
  
  x <- as.matrix(match.matrix)
  x[x==-1] <- NA

  ## Calculate weights and return the results
  res <- list(match.matrix = match.matrix, weights =
              weights.matrix(match.matrix, treat, discarded), X=X)

  ## Subclassifying
  if(!is.null(subclass)){
    if(is.null(sub.by)) sub.by="treat"
    psres <- matchit2subclass(treat,X,data,distance,discarded,
                              match.matrix=match.matrix,
                              subclass=subclass,
                              verbose=verbose, sub.by=sub.by, ...)
    res$subclass <- psres$subclass
    res$q.cut <- psres$q.cut
    class(res) <- c("matchit.subclass", "matchit")
  } else{
    class(res) <- "matchit"
  }
  return(res)
}

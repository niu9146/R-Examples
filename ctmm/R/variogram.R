# variogram class
new.variogram <- methods::setClass("variogram",representation(info="list"),contains="data.frame")

# extend subset method
subset.variogram <- function(x,...)
{
  info <- attr(x,"info")
  x <- subset.data.frame(x,...)
  x < - droplevels(x)
  new.variogram(x,info=info)
}


# variogram funcion wrapper
variogram <- function(data,dt=NULL,fast=TRUE,CI="Markov")
{
  if(length(dt)<2) { return(variogram.dt(data,dt=dt,fast=fast,CI=CI)) }
  
  # calculate a variograms at each dt
  vars <- lapply(dt, function(DT) { variogram.dt(data,dt=DT,fast=fast,CI=CI) } )
  
  # subset each variogram to relevant range of lags
  dt <- c(dt,Inf)
  lag <- vars[[1]]$lag
  vars[[1]] <- vars[[1]][lag<=dt[2],]
  for(i in 1:(length(dt)-1))
  {
    lag <- vars[[i]]$lag
    vars[[i]] <- vars[[i]][(dt[i]<lag)&(lag<=dt[i+1]),]
  }
  
  # coalate
  var <- vars[[1]]
  for(i in 2:(length(dt)-1)) { var <- rbind(var,vars[[i]]) }

  var <- new.variogram(var,info=attr(data,"info"))
    
  return(var)
} 
  

# wrapper for fast and slow variogram codes, for a specified dt
variogram.dt <- function(data,dt=NULL,fast=NULL,CI="Markov")
{
  # intelligently select algorithm
  if(is.null(fast))
  {
    if(length(data$t)<1000) { fast <- FALSE }
    else { fast <- TRUE }
  }
  
  if(fast)
  { SVF <- variogram.fast(data=data,dt=dt,CI=CI) }
  else
  { SVF <- variogram.slow(data=data,dt=dt,CI=CI) }
  
  # skip missing data
  SVF <- SVF[where(SVF$DOF>0),]
  SVF <- stats::na.omit(SVF)
  SVF <- new.variogram(SVF,info=attr(data,"info"))
  return(SVF)
}

############################
# best initial time for a uniform grid
grid.init <- function(t,dt=stats::median(diff(t)),W=rep(1,length(t)))
{
  cost <- function(t0)
  { 
    grid <- (t-t0)/dt
    return( sum(W*(grid-round(grid))^2) )
  }

  t0 <- stats::optimize(cost,t[1]+c(-1,1)*dt/2)$minimum
  
  return(t0)   
}

############################
# smear data across a uniform grid
gridder <- function(t,x,y,dt)
{
  n <- length(t)
  
  # time lags
  DT <- diff(t)
  
  # default time step
  if(is.null(dt))
  { dt <- stats::median(DT) }
  
  # gap weights to prevent oversampling with coarse dt
  W <- clamp(c(DT[1],DT)/dt) # left weights
  W <- W + clamp(c(DT,DT[n-1])/dt) # + right weights
  W <- W/2 # average left and right
  
  # choose best grid alignment
  t <- t - grid.init(t,dt,W)
  
  # fractional grid index -- starts at >=1
  index <- t/dt
  while(index[1]<1) { index <- index + 1 }
  while(index[1]>=2) { index <- index - 1 }
  
  # uniform lag grid
  n <- ceiling(max(index))
  lag <- seq(0,n-1)*dt
  
  # continuously distribute times over uniform grid
  W.grid <- rep(0,n)
  X.grid <- rep(0,n)
  Y.grid <- rep(0,n)
  for(i in 1:length(t))
  {
    j <- index[i]
    
    if(floor(j)==ceiling(j))
    { # trivial case
      J <- round(j)
      w <- W[i] # total weight
      W.grid[J] <- W.grid[J] + w
      X.grid[J] <- X.grid[J] + w*x[i]
      Y.grid[J] <- Y.grid[J] + w*y[i]
    }
    else
    { # distribution information between adjacent grids
      
      # left grid portion
      J <- floor(j)
      w <- W[i]*(1-(j-J))
      W.grid[J] <- W.grid[J] + w
      X.grid[J] <- X.grid[J] + w*x[i]
      Y.grid[J] <- Y.grid[J] + w*y[i]
      
      # right grid portion
      J <- ceiling(j)
      w <- W[i]*(1-(J-j))
      W.grid[J] <- W.grid[J] + w
      X.grid[J] <- X.grid[J] + w*x[i]
      Y.grid[J] <- Y.grid[J] + w*y[i]
    }
  }
  
  # normalize distributed information
  for(i in 1:n)
  {
    if(W.grid[i]>0)
    {
      X.grid[i] <- X.grid[i]/W.grid[i]
      Y.grid[i] <- Y.grid[i]/W.grid[i]
    }
  }
  # continuous weights eff up the FFT numerics so discretize weights
  W <- sum(W) # now total DOF
  W.grid <- sign(W.grid) # discrete weights
  
  return(list(w=W.grid,x=X.grid,y=Y.grid,lag=lag,dt=dt))
}


############################
# FFT VARIOGRAM
variogram.fast <- function(data,dt=NULL,CI="Markov")
{
  t <- data$t
  x <- data$x
  y <- data$y
  
  # smear the data over an evenly spaced time grid
  GRID <- gridder(t,x,y,dt)
  W.grid <- GRID$w
  X.grid <- GRID$x
  Y.grid <- GRID$y
  lag <- GRID$lag
  
  n <- length(lag)
  
  W.grid <- Conj(FFT(pad(W.grid,2*n)))
  XX.grid <- FFT(pad(X.grid^2,2*n))
  YY.grid <- FFT(pad(Y.grid^2,2*n))
  X.grid <- FFT(pad(X.grid,2*n))
  Y.grid <- FFT(pad(Y.grid,2*n))

  # pair number. one for x and y data
  DOF <- round(Re(2*IFFT(abs(W.grid)^2)[1:n]))
  # SVF un-normalized
  SVF <- Re(IFFT(Re(W.grid*(XX.grid+YY.grid))-(abs(X.grid)^2+abs(Y.grid)^2))[1:n])
  
  # delete missing lags
  SVF <- data.frame(SVF=SVF,DOF=DOF,lag=lag)
  SVF <- subset(SVF,DOF>0)
  lag <- SVF$lag
  DOF <- SVF$DOF
  SVF <- SVF$SVF
  
  # normalize SVF
  SVF <- SVF/DOF
  
  # only count non-overlapping lags... not perfect
  if(CI=="Markov")
  {
    dof <- 2*(last(t)-t[1])/lag
    dof[1] <- 2*length(t)
  
    for(i in 1:length(lag))
    {
      if(dof[i]<DOF[i]) {DOF[i] <- dof[i] }
    }
  }
  else if(CI=="IID") # fix initial and total DOF
  {
    DOF[1] <- 2*length(t)
    DOF[-1] <- DOF[-1]/sum(DOF[-1])*(length(t)^2-length(t))
  }
  
  result <- data.frame(SVF=SVF,DOF=DOF,lag=lag)
  return(result)
}

##################################
# LAG-WEIGHTED VARIOGRAM
variogram.slow <- function(data,dt=NULL,CI="Markov")
{
  t <- data$t
  x <- data$x
  y <- data$y

  n <- length(t)
  
  # time lags
  DT <- diff(t)
  DT.L <- c(DT[1],DT)
  DT.R <- c(DT,DT[n-1])
  
  # default time step
  if(is.null(dt))
  { dt <- stats::median(DT) }

  # where we will store stuff
  lag <- seq(0,ceiling((t[n]-t[1])/dt))*dt
  SVF <- rep(0,length(lag))
  DOF <- rep(0,length(lag))
  DOF2 <- rep(0,length(lag))
  
  pb <- utils::txtProgressBar(style=3)
  for(i in 1:n)
  { 
    for(j in i:n)
    {
      tau <- t[j] - t[i]
      var <- ((x[j]-x[i])^2 + (y[j]-y[i])^2)/4
      
      # gap weight
      if(tau==0) { w <- 1 }
      else { w <- (clamp(DT.L[j]/tau)+clamp(DT.R[j]/tau))*(clamp(DT.L[i]/tau)+clamp(DT.R[i]/tau)) }
      
      # fractional index
      k <- tau/dt + 1
      
      if(floor(k)==ceiling(k))
      { # even sampling
        # lag index
        K <- round(k)
        # total weight
        W <- w
        # accumulate
        SVF[K] <- SVF[K] + W*var
        DOF[K] <- DOF[K] + W
        DOF2[K] <- DOF2[K] + W^2
      }
      else
      { # account for drift by distributing semi-variance
        
        # left index
        K <- floor(k)
        # left weight
        W <- w*(1-(k-K))
        # accumulate left portion
        SVF[K] <- SVF[K] + W*var
        DOF[K] <- DOF[K] + W
        DOF2[K] <- DOF2[K] + W^2
        
        # right index
        K <- ceiling(k)
        # right weight
        W <- w*(1-(K-k))
        # accumulate right portion
        SVF[K] <- SVF[K] + W*var
        DOF[K] <- DOF[K] + W
        DOF2[K] <- DOF2[K] + W^2
      }
    }
    utils::setTxtProgressBar(pb,(i*(2*n-i))/(n^2))
  }
  
  # delete missing lags
  SVF <- data.frame(SVF=SVF,DOF=DOF,DOF2=DOF2,lag=lag)
  SVF <- subset(SVF,DOF>0)
  lag <- SVF$lag
  DOF <- SVF$DOF
  DOF2 <- SVF$DOF2
  SVF <- SVF$SVF
  
  # normalize SVF
  SVF <- SVF/DOF
  # effective DOF from weights, one for x and y
  DOF <- 2*DOF^2/DOF2
  
  # only count non-overlapping lags... still not perfect
  if(CI=="Markov")
  {
    dof <- 2*length(t)
    if(dof<DOF[1]) { DOF[1] <- dof  }
    
    for(i in 2:length(lag))
    { # large gaps are missing data
      dof <- 2*sum(DT[DT<=lag[i]])/lag[i]
      if(dof<DOF[i]) { DOF[i] <- dof }
      
      utils::setTxtProgressBar(pb,i/length(lag))
    }
  }
  else if(CI=="IID") # fix initial and total DOF
  {
    DOF[1] <- 2*length(t)
    DOF[-1] <- DOF[-1]/sum(DOF[-1])*(length(t)^2-length(t))
  }
  
  close(pb)
  
  result <- data.frame(SVF=SVF,DOF=DOF,lag=lag)
  return(result)
}


#########
# update to moment/cumulant with non-stationary mean
svf.func <- function(CTMM,moment=FALSE)
{
  # pull out relevant model parameters
  tau <- CTMM$tau

  # trace variance
  sigma <- mean(diag(CTMM$sigma)) # now AM.sigma
  ecc <- CTMM$sigma@par[2]
  
  CPF <- CTMM$CPF
  circle <- CTMM$circle

  if(length(tau)>0 && tau[1]==Inf) { range <- FALSE } else { range <- TRUE }
  tau <- tau[tau>0]
  tau <- tau[tau<Inf]
  K <- length(tau)
  
  # parameter covariances
  # default to no error considered
  COV <- CTMM$COV
  if(is.null(COV)) { COV <- diag(0,K+1+(if(circle){1}else{0})) }
  
  # FIRST CONSTRUCT STANDARD ACF AND ITS PARAMTER GRADIENTS
  if(CPF) # Central place foraging
  {
    nu <- 2*pi/tau[1]
    f <- 1/tau[2]
    acf <- function(t){ (cos(nu*t)+f/nu*sin(nu*t))*exp(-f*t) }
    acf.grad <- function(t) { -c(2*pi,1)/tau^2 * c( (-(t+f/nu^2)*sin(nu*t)+f/nu*t*cos(nu*t))*exp(-f*t) , -t*acf(t) + 1/nu*sin(nu*t)*exp(-f*t) ) }
  }
  else if(K==0 && range) # Bivariate Gaussian
  { 
    acf <- function(t){ if(t==0) {1} else {0} }
    acf.grad <- function(t){ NULL }
  }
  else if(K==0) # Brownian motion
  {
    acf <- function(t){ 1-t }
    acf.grad <- function(t){ NULL }
  }
  else if(K==1 && range) # OU motion
  {
    acf <- function(t){ exp(-t/tau) }
    acf.grad <- function(t){ t/tau^2*acf(t) }
  }
  else if(K==1) # IOU motion
  {
    acf <- function(t) { 1-(t-tau*(1-exp(-t/tau))) }
    acf.grad <- function(t){ 1-(1+t/tau)*exp(-t/tau) }
  }
  else if(K==2) # OUF motion
  { 
    acf <- function(t){ diff(tau*exp(-t/tau))/diff(tau) } 
    acf.grad <- function(t) { c(1,-1)*((1+t/tau)*exp(-t/tau)-acf(t))/diff(tau) }
  }
  
  # finish off svf function including circulation if present
  if(!circle)
  {
    svf <- function(t) { sigma*(1-acf(t)) }
    grad <- function(t) { c(svf(t)*cosh(ecc)/sigma, -sigma*acf.grad(t)) }
  }
  else
  {
    f <- 2*pi/circle
    svf <- function(t) { sigma*(1-cos(f*t)*acf(t)) }
    grad <- function(t) { c(svf(t)*cosh(ecc)/sigma, -sigma*cos(f*t)*acf.grad(t), -(f/circle)*sigma*t*sin(f*t)*acf(t)) }
  }
  
  MEAN <- svf.mean(CTMM)
  SVF <- function(t) { svf(t) + MEAN$svf(t) }
  
  # variance of SVF
  VAR <- function(t)
  {
    g <- grad(t)
    return( g %*% COV %*% g + MEAN$VAR(t) )
  }
  
  # chi-square effective degrees of freedom
  DOF <- function(t) { return( 2*SVF(t)^2/VAR(t) ) }
  
  return(list(svf=SVF,VAR=VAR,DOF=DOF))
}


##########
plot.svf <- function(lag,CTMM,alpha=0.05,col="red",type="l",...)
{
  SVF <- svf.func(CTMM)
  svf <- SVF$svf
  DOF <- SVF$DOF
  
  # point estimate plot
  SVF <- Vectorize(function(t){svf(t)})
  graphics::curve(SVF,from=0,to=lag,n=1000,add=TRUE,col=col,type=type,...)
  
  # confidence intervals if COV provided
  if(any(diag(CTMM$COV)>0))
  {
    Lags <- seq(0,lag,lag/1000)
    
    for(j in 1:length(alpha))
    {
      svf.lower <- Vectorize(function(t){ svf(t) * CI.lower(DOF(t),alpha[j]) })
      svf.upper <- Vectorize(function(t){ svf(t) * CI.upper(DOF(t),alpha[j]) })
      
      graphics::polygon(c(Lags,rev(Lags)),c(svf.lower(Lags),rev(svf.upper(Lags))),col=scales::alpha(col,0.1/length(alpha)),border=NA,...)
    }
  }
  
}

###########################################################
# PLOT VARIOGRAM
###########################################################
plot.variogram <- function(x, CTMM=NULL, level=0.95, fraction=0.5, col="black", col.CTMM="red", ...)
{  
  alpha <- 1-level
  
  # number of variograms
  if(class(x)=="variogram" || class(x)=="data.frame") { x <- list(x) }
  n <- length(x)
  
  # maximum lag in data
  max.lag <- sapply(x, function(v){ last(v$lag) } )
  max.lag <- max(max.lag)
  # subset fraction of data
  max.lag <- fraction*max.lag
  
  # subset all data to fraction of total period
  x <- lapply(x, function(v) { subset.data.frame(v, lag <= max.lag) })

  # maximum CI on SVF
  max.SVF <- max(sapply(x, function(v){ max(v$SVF * CI.upper(v$DOF,min(alpha))) } ))
  # limit plot range to twice max SVF point estimate (otherwise hard to see)
  max.cap <- 2*max(sapply(x, function(v){ max(v$SVF) } ))
  if(max.SVF>max.cap) { max.SVF <- max.cap }
  
  # choose SVF units
  SVF.scale <- unit(max.SVF,"area")
  SVF.name <- SVF.scale$name
  SVF.scale <- SVF.scale$scale
  
  # choose lag units
  lag.scale <- unit(max.lag,"time",2)
  lag.name <- lag.scale$name
  lag.scale <- lag.scale$scale
  
  xlab <- paste("Time-lag ", "(", lag.name, ")", sep="")
  ylab <- paste("Semi-variance ", "(", SVF.name, ")", sep="")
  
  # fix base plot layer
  plot(c(0,max.lag/lag.scale),c(0,max.SVF/SVF.scale), xlab=xlab, ylab=ylab, col=grDevices::rgb(1,1,1,0), ...)
  
  # color array for plots
  col <- array(col,n)
  
  for(i in 1:n)
  {
    lag <- x[[i]]$lag/lag.scale
    SVF <- x[[i]]$SVF/SVF.scale
    DOF <- x[[i]]$DOF
        
    # make sure plot looks nice and appropriate for data resolution
    type <- "l"
    if(length(lag) < 100) { type <- "p" }
    
    graphics::points(lag, SVF, type=type, col=col[[i]])
    
    for(j in 1:length(alpha))
    {
      SVF.lower <- SVF * CI.lower(DOF,alpha[j])
      SVF.upper <- SVF * CI.upper(DOF,alpha[j])
      
      graphics::polygon(c(lag,rev(lag)),c(SVF.lower,rev(SVF.upper)),col=scales::alpha(col[[i]],alpha=0.1),border=NA)
    }
  }
  
  # NOW PLOT THE MODELS
  if(!is.null(CTMM))
  {
    if(class(CTMM)=="ctmm") { CTMM <- list(CTMM) }
    n <- length(CTMM) 
    
    # color array for plots
    col <- array(col.CTMM,n)
    type <- "l"
    
    for(i in 1:n)
    {
      # units conversion
      CTMM[[i]]$sigma <- CTMM[[i]]$sigma/SVF.scale
      CTMM[[i]]$mu <- CTMM[[i]]$mu/sqrt(SVF.scale)
      if(length(CTMM[[i]]$tau)>0){ CTMM[[i]]$tau <- CTMM[[i]]$tau/lag.scale }
      CTMM[[i]]$circle <- CTMM[[i]]$circle/lag.scale
      
      if(CTMM[[i]]$mean=="periodic")
      { attr(CTMM[[i]]$mean,"par")$P <- attr(CTMM[[i]]$mean,"par")$P/lag.scale }
      
      scale <- SVF.scale
      # variance -> diffusion adjustment
      if(length(CTMM[[i]]$tau)>0 && max(CTMM[[i]]$tau)==Inf)
      {
        CTMM[[i]]$sigma <- CTMM[[i]]$sigma*lag.scale
        scale[1] <- scale[1]/lag.scale
      }
      
      # unit convert uncertainties
      if(!is.null(CTMM[[i]]$COV))
      {
        CTMM[[i]]$COV.mu <- CTMM[[i]]$COV.mu/SVF.scale
        
        P <- nrow(CTMM[[i]]$COV)
        if(P>1){ scale <- c(scale,rep(lag.scale,P-1)) }
      
        scale <- diag(1/scale,length(scale))
        dimnames(scale) <- dimnames(CTMM[[i]]$COV)
        CTMM[[i]]$COV <- scale %*% CTMM[[i]]$COV %*% scale
      }
      
      plot.svf(max.lag/lag.scale,CTMM[[i]],alpha=alpha,type=type,col=col[[i]])
    }
  }
  
}
# PLOT.VARIOGRAM METHODS
#methods::setMethod("plot",signature(x="variogram",y="missing"), function(x,y,...) plot.variogram(x,...))
#methods::setMethod("plot",signature(x="variogram",y="variogram"), function(x,y,...) plot.variogram(list(x,y),...))
#methods::setMethod("plot",signature(x="variogram",y="ctmm"), function(x,y,...) plot.variogram(x,model=y,...))
#methods::setMethod("plot",signature(x="variogram"), function(x,...) plot.variogram(x,...))


#######################################
# plot a variogram with zoom slider
#######################################
zoom.variogram <- function(x, fraction=0.5, ...)
{
  # R CHECK CRAN BUG WORKAROUND
  z <- NULL
  
  # number of variograms
  n <- 1
  if(class(x)=="list") { n <- length(x) }
  else {x <- list(x) } # promote to list of one
  
  # maximum lag in data
  max.lag <- sapply(x, function(v){ last(v$lag) } )
  max.lag <- max(max.lag)
  
  min.lag <- sapply(x, function(v){ v$lag[2] } )
  min.lag <- min(min.lag)
  
  b <- 4
  min.step <- min(fraction,10*min.lag/max.lag)
  manipulate::manipulate( { plot.variogram(x, fraction=b^(z-1), ...) }, z=manipulate::slider(1+log(min.step,b),1,initial=1+log(fraction,b),label="zoom") )
}
#methods::setMethod("zoom",signature(x="variogram",y="missing"), function(x,y,...) zoom.variogram(x,...))
#methods::setMethod("zoom",signature(x="variogram",y="variogram"), function(x,y,...) zoom.variogram(list(x,y),...))
#methods::setMethod("zoom",signature(x="variogram",y="ctmm"), function(x,y,...) zoom.variogram(x,model=y,...))
#methods::setMethod("zoom",signature(x="variogram"), function(x,...) zoom.variogram(x,...))


####################################
# guess variogram model parameters #
####################################
variogram.guess <- function(variogram,CTMM=ctmm())
{
  # guess at some missing parameters
  if(is.null(CTMM$tau) || is.null(CTMM$sigma))
  {
    n <- length(variogram$lag)
    
    # variance estimate
    sigma <- mean(variogram$SVF[2:n])
    
    # peak curvature estimate
    # should occur at short lags
    v2 <- 2*max((variogram$SVF/variogram$lag^2)[2:n])
    
    # free frequency
    Omega2 <- v2/sigma
    Omega <- sqrt(Omega2)
    
    # peak diffusion rate estimate
    # should occur at intermediate lags
    # diffusion parameters
    D <- (variogram$SVF/variogram$lag)[2:n]
    # index of max diffusion
    tauD <- which.max(D)
    # max diffusion
    D <- D[tauD]
    # time lag of max diffusion
    tauD <- variogram$lag[tauD]
    
    # average f-rate
    f <- -log(D/(sigma*Omega))/tauD
    
    CPF <- CTMM$CPF
    if(CPF) # frequency, rate esitmate
    {
      omega2 <- Omega2 - f^2
      if(f>0 && omega2>0)
      { tau <- c(2*pi/sqrt(omega2),1/f) }
      else # bad backup estimate
      {
        tau <- sqrt(2)/Omega   
        tau <- c(2*pi*tau , tau)
      }
    }
    else # position, velocity timescale estimate
    { tau <- c(sigma/D,D/v2)}
    
    if(!CTMM$range) { sigma <- D ; tau[1] <- Inf }
    
    if(length(CTMM$tau)==0) { CTMM$tau <- tau }
    
    # preserve orientation and eccentricity if available
    if(is.null(CTMM$sigma))
    { CTMM$sigma <- sigma }
    else
    {
      CTMM$sigma <- CTMM$sigma@par
      CTMM$sigma[1] <- sigma / cosh(CTMM$sigma[2]/2)
    }
  }

  # don't overwrite or lose ctmm parameters not considered here
  model <- as.list(CTMM) # getDataPart deletes names()
  model <- c(model,list(info=attr(variogram,"info")))
  model <- do.call("ctmm",model)
  return(model)
}


######################################################################
# visual fit of the variogram
######################################################################
variogram.fit <- function(variogram,CTMM=ctmm(),name="GUESS",fraction=0.5,interactive=TRUE,...)
{
  if(interactive && !manipulate::isAvailable()) { interactive <- FALSE }
  envir <- .GlobalEnv
  
  # R CHECK CRAN BUG WORKAROUNDS
  z <- NULL
  tau1 <- 1
  tau2 <- 0
  store <- NULL ; rm(store)
  
  m <- 2 # slider length relative to point guestimate
  n <- length(variogram$lag)
  
  # fill in missing parameters non-destructively
  CTMM <- variogram.guess(variogram,CTMM)
  if(!interactive) { return(CTMM) }
  
  # parameters for logarithmic slider
  b <- 4
  min.step <- 10*variogram$lag[2]/variogram$lag[n]
  
  # manipulation controls
  manlist <- list(z = manipulate::slider(1+log(min.step,b),1,initial=1+log(fraction,b),label="zoom"))

  range <- CTMM$range
  sigma <- mean(diag(CTMM$sigma))
  if(range)
  {
    sigma.unit <- unit(sigma,"area",concise=TRUE)
    sigma <- sigma / sigma.unit$scale
    label <- paste("sigma variance (",sigma.unit$name,")",sep="")
    manlist <- c(manlist, list(sigma = manipulate::slider(0,m*sigma,initial=sigma,label=label)))
  }
  else
  {
    sigma.unit <- unit(sigma,"diffusion",concise=TRUE)
    sigma <- sigma / sigma.unit$scale
    label <- paste("sigma diffusion (",sigma.unit$name,")",sep="")
    manlist <- c(manlist, list(sigma = manipulate::slider(0,m*sigma,initial=sigma,label=label)))
  }

  CPF <- CTMM$CPF
  tau <- CTMM$tau
  tau1.unit <- unit(tau[1],"time",2,concise=TRUE)
  tau2.unit <- unit(tau[2],"time",2,concise=TRUE)
  tau[1] <- tau[1] / tau1.unit$scale
  tau[2] <- tau[2] / tau2.unit$scale
  if(CPF)
  {
    label <- paste("tau period (",tau1.unit$name,")",sep="")
    manlist <- c(manlist, list(tau1 = manipulate::slider(0,m*tau[1],initial=tau[1],label=label)))

    label <- paste("tau decay (",tau2.unit$name,")",sep="")
    manlist <- c(manlist, list(tau2 = manipulate::slider(0,m*tau[2],initial=tau[2],label=label)))

    tau2 <- NULL # not sure why necessary
  }
  else
  { 
    label <- paste("tau position (",tau1.unit$name,")",sep="")
    manlist <- c(manlist, list(tau1 = manipulate::slider(0,m*tau[1],initial=tau[1],label=label)))

    label <- paste("tau velocity (",tau2.unit$name,")",sep="")
    manlist <- c(manlist, list(tau2 = manipulate::slider(0,m*tau[2],initial=tau[2],label=label)))
  }
  
  circle <- CTMM$circle
  if(circle)
  {
    circle.unit <- unit(circle,"time",concise=TRUE)
    circle <- circle / circle.unit$scale
    label <- paste("circulation (",circle.unit$name,")",sep="")
    c1 <- min(0,m*circle)
    c2 <- max(0,m*circle)
    manlist <- c(manlist, list(circle = manipulate::slider(c1,c2,initial=circle,label=label)))
  }
  
  manlist <- c(manlist, list(store = manipulate::button(paste("Save to",name))))
  
  if(!range)
  {
    manlist$tau1 <- NULL
    tau1 <- Inf
  }
  
  # non-destructive parameter overwrite
  manipulate::manipulate(
    {
      # store trace, but preserve angle & eccentricity
      CTMM$sigma <- CTMM$sigma@par
      CTMM$sigma[1] <- sigma * sigma.unit$scale / cosh(CTMM$sigma[2]/2)

      CTMM$tau <- c(tau1*tau1.unit$scale, tau2*tau2.unit$scale)
      if(circle) { CTMM$circle <- circle * circle.unit$scale }
      
      CTMM <- as.list(CTMM)
      CTMM <- c(CTMM,list(info=attr(variogram,"info")))
      CTMM <- do.call("ctmm",CTMM)
      fraction <- b^(z-1)
      if(store) { assign(name,CTMM,envir=envir) }
      plot.variogram(variogram,CTMM=CTMM,fraction=fraction,...)
    },
    manlist
  )
}


# AVERAGE VARIOGRAMS
mean.variogram <- function(x,...)
{
  x <- c(x,list(...))
  IDS <- length(x)
  
  # assemble observed lag range
  lag.min <- rep(0,IDS) # this will be dt
  lag.max <- rep(0,IDS)
  for(id in 1:IDS)
  { 
    n <- length(x[[id]]$lag)
    lag.max[id] <- x[[id]]$lag[n]
    lag.min[id] <- x[[id]]$lag[2]
  }
  lag.max <- max(lag.max)
  lag.min <- min(lag.min)
  lag <- seq(0,ceiling(lag.max/lag.min))*lag.min
  
  # where we will store everything
  n <- length(lag)
  SVF <- rep(0,n)
  DOF <- rep(0,n)
  
  # accumulate semivariance
  for(id in 1:IDS)
  {
   for(i in 1:length(x[[id]]$lag))
   {
    # lag index
    j <- 1 + round(x[[id]]$lag[i]/lag.min)
    # number weighted accumulation
    DOF[j] <- DOF[j] + x[[id]]$DOF[i]
    SVF[j] <- SVF[j] + x[[id]]$DOF[i]*x[[id]]$SVF[i]
   }
  }
  
  # delete missing lags
  variogram <- data.frame(SVF=SVF,DOF=DOF,lag=lag)
  variogram <- subset(variogram,DOF>0)

  # normalize SVF
  variogram$SVF <- variogram$SVF / variogram$DOF
  
  # drop unused levels
  variogram <- droplevels(variogram)
  
  variogram <- new.variogram(variogram, info=mean.info(x))

  return(variogram)
}
#methods::setMethod("mean",signature(x="variogram"), function(x,...) mean.variogram(x,...))


# consolodate info attributes from multiple datasets
mean.info <- function(x)
{
  # mean identity
  identity <- sapply(x , function(v) { attr(v,"info")$identity } )
  identity <- unique(identity) # why did I do this?
  identity <- paste(identity,collapse=" ")
  
  info=attr(x[[1]],"info")
  info$identity <- identity
  
  return(info)
  }

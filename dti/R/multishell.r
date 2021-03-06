
sphtrarea1 <- function(g1,g2,g3){
  ##  Compute area of sherical triangle spanned by vectors 
  ##  g1,g2,g3 on unit sphere
  ##  use absolute values to identify opposite directions with each other
  c12 <- abs(g1%*%g2)
  c13 <- abs(g1%*%g3)
  c23 <- abs(g2%*%g3)
  s12 <- sqrt(1-c12^2)
  s13 <- sqrt(1-c13^2)
  s23 <- sqrt(1-c23^2)
  a12 <- acos(c12)
  a23 <- acos(c23)
  a13 <- acos(c13)
  ## observed b1, b2, b3 outside [-1,1] due to numerics
  b1 <- min(max(1+(c23-cos(a12-a13))/s12/s13,-1),1)
  b2 <- min(max(1+(c13-cos(a12-a23))/s12/s23,-1),1)
  b3 <- min(max(1+(c12-cos(a13-a23))/s13/s23,-1),1)
  acos(b1)+acos(b2)+acos(b3)-pi
}


getsphwghts <- function(g,g1,g2,g3){
  ##
  ##   compute weights for linear interpolation in g using g1,g2,g3
  ##
  ierr <- 0
  w <- numeric(3)
  w0 <- sphtrarea1(g1,g2,g3)
  w[1] <- sphtrarea1(g,g2,g3)
  w[2] <- sphtrarea1(g,g1,g3)
  w[3] <- sphtrarea1(g,g1,g2)
  if(w0 < sum(w) - 1e-6){ 
    #cat("gradient does not belong to triangle")
    #print(g)
    #print(cbind(g1,g2,g3))
    #cat("w0",w0,"w",w,"alt",w[1]+w[2]-w[3],"\n")
    ierr <- 1
  }
  list(w=w/sum(w),ierr=ierr) 
}

unifybvals <- function(bval,dbv=51){
   nbv <- length(bval)
   nbval <- bval
   obval <- numeric(nbv)
   while(any(nbval!=obval)){
      obval <- nbval
      sbv <- sort(obval)
      dsbv <- (1:(nbv-1))[diff(sbv)<dbv]
      sbv[dsbv+1] <- sbv[dsbv]
      obv <- order(obval)
      nbval[obv] <- sbv
   }
   for(bv in unique(nbval)) nbval[nbval==bv] <- trunc(mean(bval[nbval==bv]))
   nbval
}

getnext3g <- function(grad,bv){
  ##
  ##  calculate next neighbors on the sphere and weights for interpolation
  ##
  binomial <- function(a,b) prod(1:a)/prod(1:(a-b))/prod(1:b)
  ##
  grad <- grad[,bv>0]
  ng <- dim(grad)[2]
  ng2 <- max(4,ng/6)
  perm <- matrix(1,(ng2-2)*(ng2-1)*ng2/6,3)
  l <- 1
  for(k in 1:(ng2-2)){
    for(j in (k+1):(ng2-1)){
      for(i in (j+1):ng2){
        perm[l,] <- c(k,j,i)
        l <- l+1
      }
    }
  }
  dperm <- l-1
  perm <- perm[2:dperm,]
  #  thats all ordered triples from (1:ng2), without (1,2,3)
  bv <- unifybvals(bv[bv>0]) # identifies b-values that differ by less than dbv=51
  ubv <- sort(unique(bv[bv>max(bv)/50]))
  nbv <- length(ubv)
  ind <- array(0,c(3,nbv,ng))
  w <- array(0,c(3,nbv,ng))
  for(i in 1:nbv){
    indb <- (1:ng)[bv==ubv[i]]
    ind[1,i,indb] <- indb
    ind[2,i,indb] <- indb
    ind[3,i,indb] <- indb
    w[1,i,indb] <- 1
    w[2,i,indb] <- 0
    w[3,i,indb] <- 0
    for(j in (1:nbv)[-i]){
      indbk <- (1:ng)[bv==ubv[j]]
      perm0 <- perm
      if(length(indbk)<ng2){
         indp <- apply(perm < length(indbk),1,all)
         perm0 <- perm0[indp,]
      }
      dperm <- dim(perm0)[1]+1
      for(k in indb){
        d <- abs(t(grad[,k])%*%grad[,indbk])
        od <- order(d,decreasing = TRUE)
        ijk0 <- (1:length(indbk))[od]
        ijk <- indbk[od]
        #         cat("k",k,"d",d[od][1:8],"ijk",ijk[1:8],"\n")
        ind[,j,k] <- ijk[1:3]
        if(max(d)>1-1e-6){
          w[,j,k] <- c(1,0,0)
        } else {
          z <- getsphwghts(grad[,k],grad[,ijk[1]],grad[,ijk[2]],grad[,ijk[3]])
          l <- 1
          if(z$ierr==1){
            #  order triplets in perm according
            dd <- numeric(dperm-1)
            d <- acos(pmin(1,d))
            for(l in 1:(dperm-1)){
              ijk1 <- ijk0[perm0[l,]]
              dd[l] <- d[ijk1[1]]+d[ijk1[2]]+d[ijk1[3]]
            }
            odd <- order(dd)
            l <- 1
          }
          while(z$ierr==1&&l<dperm){
            ijk1 <- ijk[perm0[odd[l],]]
            z <- getsphwghts(grad[,k],grad[,ijk1[1]],grad[,ijk1[2]],grad[,ijk1[3]])
            ind[,j,k] <- ijk1[1:3]
            l<-l+1
          }
##    if we were running out of options use ijk[1:3]
          if(z$ierr==1){
             ind[,j,k] <- ijk[1:3]
             z <- getsphwghts(grad[,k],grad[,ijk[1]],grad[,ijk[2]],grad[,ijk[3]])
          }
          w[,j,k] <- z$w
        }
      }
    }
  }   
  #   spheres identified by bvalues in ubv
  #   ind[j,k,] contains indices of gradients to be used in spherical interpolation 
  #             on shell i for gradient k
  #   w[j,k,]   contains the corresponding weights
  list(ind=ind, w=w, ubv = ubv, nbv = nbv, bv=bv)
}

interpolatesphere <- function(theta,n3g){
  ##  interpolate estimated thetas to get values on all spheres
  ##  n3g  generated by function  getnext3g
  ##  dim(theta) = c(n1,n2,n3,ngrad)
  dtheta <- dim(theta)
  mstheta <- array(0,c(n3g$nbv,dtheta))
  dim(theta) <- c(prod(dtheta[1:3]),dtheta[4])
  for(i in 1:n3g$nbv){
    for(j in 1:dim(theta)[2]){
      mstheta[i,,,,j] <- theta[,n3g$ind[,i,j]]%*%n3g$w[,i,j] 
    }
  }
  mstheta
}


lkfullse3msh <- function(h,kappa,gradstats,vext,n){
  nbv <- gradstats$nbv
  dist <- gradstats$dist
  ngrad <- gradstats$ngrad
  bvind <- gradstats$bvind
  ind <- matrix(0,5,n)
  w <- numeric(n)
  nn <- 0
  dist <- 4
  for(i in 1:nbv){
    gshell <- list(k456=gradstats$k456[[i]],bghat=gradstats$bghat[[i]],dist=dist) 
    z <- lkfullse3(h[bvind[[i]]],kappa[bvind[[i]]],gshell,vext,n)
    ind[1:3,nn+1:z$nind] <- z$ind[1:3,]
    ind[4:5,nn+1:z$nind] <- matrix(bvind[[i]][z$ind[4:5,]],2, z$nind)
    #
    #  convert indeces on selected shell to total indeces
    #
    w[nn+1:z$nind] <- z$w
    nn <- nn + z$nind
  }  
  list(h=h,kappa=kappa,ind=ind[,1:nn],w=w[1:nn],nind=nn)
}

gethseqfullse3msh <- function (kstar, gradstats, kappa, vext = c(1, 1)) 
{
  #
  #  generate information on local bandwidths and variance reduction
  #  for smoothing on multiple shells
  #
  nbv <- gradstats$nbv
  ngrad <- gradstats$ngrad
  h <- vr <- matrix(1,ngrad,kstar+1)
  n <- 0
  dist <- 4
  for(i in 1:nbv){
    gshell <- list(k456=gradstats$k456[[i]],bghat=gradstats$bghat[[i]],dist=dist)
    z <- gethseqfullse3(kstar, gshell, kappa=kappa, vext=vext)
    h[gradstats$bvind[[i]],-1] <- z$h
    vr[gradstats$bvind[[i]],-1] <- z$vred
    vr[gradstats$bvind[[i]],1] <- vr[gradstats$bvind[[i]],2]/1.25
    n <- n+z$n
  }
  cat("\n total number of positive weights:",n,"mean maximal bandwidth",signif(mean(h[,kstar]),3), "\n")
  list(h=h,vred=vr,n=n)
}


getkappasmsh <- function(grad, msstructure, trace = 0, dist = 1){
  ngrad <- dim(grad)[2]
  nbv <- msstructure$nbv
  bv <- msstructure$bv
  ubv <- msstructure$ubv
  bvind <- k456 <- bghat <- list(NULL)
  for(i in 1:nbv){
    #
    #   collect information for spherical distances on each schell separately
    #
    ind <- (1:ngrad)[bv==ubv[i]]
    z <- getkappas(grad[,ind], trace = trace, dist = dist)
    bvind[[i]] <- ind
    k456[[i]] <- z$k456
    bghat[[i]] <- z$bghat
  }
  list(k456 = k456, bghat = bghat, bvind = bvind, dist=dist, nbv = nbv, ngrad = ngrad)
}


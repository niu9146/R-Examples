`mudiff.mblacc.equalvar` <-
function(len,alpha,beta,level=0.95,m=10000,mcs=3)
{
  min.for.possible.return <- 2^ceiling(1.5*mcs)

  # If we always allow a return, there is a risk of making bad steps
  # when we are close to the answer.
  # Thus, we should not allow any return once some arbitrary 'step' (which is
  # 'min.for.possible.return') is reached.

  #vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  #**************************************************************************
  # Define initial step
  # (as a function of any frequentist sample size estimate)

  step <- ceiling(log(mudiff.acc.equalvar(len,alpha,beta,1,1,level)[1])/log(2))

  # Also define the threshold to cross for the quantity under study (the
  # length or the coverage probability of an HPD region)

  threshold <- level

  # and define a factor, which is +/- 1, depending on if the quantity under
  # study is (almost) surely too large or too small when making no
  # observations [-1 if the quantity to measure is DEcreasing with n
  #               +1 if the quantity to measure is INcreasing with n]
  #
  # [ -1 if threshold_len, +1 if thresold_level ]

  factor <- +1

  #**************************************************************************
  #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  quantity.to.measure <- ifelse(factor == +1,0,2*threshold)

  step <- 2^step

  history.ns <- 0
  history.steps <- 0
  # history.cons.steps_0

  n1 <- 0

  max.cons.steps.same.dir <- mcs
  found.upper.bound <- FALSE
  possible.to.move.back <- TRUE
  cons.steps.same.dir <- 0
  direction <- +1

  while(step>=1)
  {
    while(sign(factor*(threshold-quantity.to.measure)) == direction && step >= 1)
    {
      step[found.upper.bound] <- max(1,step/2)
      possible.to.move.back[step < min.for.possible.return &&
                            found.upper.bound] <- FALSE

      n1 <- n1+direction*step
      if(n1 <= 2) {
        found.lower.bound <- TRUE
        n1 <- 2
      }

      cons.steps.same.dir <- cons.steps.same.dir+1

      history.ns <- c(n1,history.ns)
      history.steps <- c(step*direction,history.steps)

      #vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
      #************************************************************************
      # Let sp=ns21+ns22

      sp <- rgg(m,alpha,2*beta,n1-1)

      quantity.to.measure <- 2*mean(pt(len/2*sqrt(n1*(n1-1)/sp),2*(n1-1)))-1

      #************************************************************************
      #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

      if(found.upper.bound &&
         cons.steps.same.dir == max.cons.steps.same.dir+1 &&
         possible.to.move.back)
      {

        if(sign(factor*(threshold-quantity.to.measure)) == direction)
        {
          # There was (most likely) a mistake, look for n's in the other direction
          at.n <- seq(along=history.ns)[history.ns == n1 ]
          hs.an <- history.steps[at.n]

          step <- abs(hs.an[sign(hs.an) != direction][1])

          cons.steps.same.dir <- 0

          # and if there has never been a step coming from the other direction

          step[is.na(step)] <- max(abs(hs.an))
        }
        else
        {
          # There was (most likely) no mistake; keep looking around the same n's

          direction <- -direction
          cons.steps.same.dir <- 0
        }
      }

      if(found.upper.bound &&
         cons.steps.same.dir==max.cons.steps.same.dir &&
         sign(factor*(threshold-quantity.to.measure))==direction &&
         possible.to.move.back)
      {
        step <- 2*step
      }

    }

    found.upper.bound <- TRUE

    direction <- -direction
    cons.steps.same.dir <- 0
    step[step==1] <- 0

  }

  direction[n1==0] <- 0

  n1[direction==+1] <- n1+1

  # Return

  c(n1,n1)
}


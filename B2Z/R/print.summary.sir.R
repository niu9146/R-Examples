######################################
#It prints the posterior summaries   #
#for an object of class summary.sir  #
######################################

print.summary.sir <- function(x, digits = max(options()$digits - 4, 3),...){
   cat("\nPosterior Summaries: \n")
   print(x$summary, digits = digits)

   cat("\nNote: GSD is the geometric standard deviation, i.e., GSD(x) = exp(sqrt(x))\n\n")
 
   cat("\nPosterior Covariance Matrix: \n")
   print(x$PostCovMat, digits = digits)

   cat("\nDeviance Information Criterion: ")

   cat("\npD: ")
   dput(round(x$pD,digits))

   cat("Dbar: ")
   dput(round(x$Dbar,digits))

   cat("DIC: ")
   dput(round(x$DIC,digits))

   cat("\n\nSampler used: SIR")
   cat("\n-----------------\n")
   cat("\nEffective Sample Size (ESS):")
   dput(round(x$ESS,digits))

   cat("\nMaximum importance weight: ")
   dput(x$maxw)

   cat("\nProportion of unique points sampled: ")
   dput(x$prop)
}


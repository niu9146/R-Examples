print.boot.regcor <-
function(x, ...)
{
test <- !is.null(x$Null)
hist(x$Boot.values,breaks=20,xlab=paste("bootstrap",x$Statistic),
  main=paste("Histogram of bootstrap ",x$Statistic,"s",sep=""))
abline(v=x$Observed,col="2")
abline(v=x$Mean,col="3")
abline(v=c(x$Confidence.limits),col="4")
if (test) abline(v=x$Null,col="5")
leg.text <- if (test) expression(Observed,Mean.boots,Confidence.interval,Null.value)
  else expression(Observed,Mean.boots,Confidence.interval)
legend("topright",leg.text,col=2:5,lwd=2,cex=.6)
cat("\n\n",x$Header,"\n\n")
if (x$cor.ana)
 print(data.frame(SUMMARY="STATISTICS",Variable.1=x$Variable.1,
 Variable.2=x$Variable.2,n=x$n,Statistic=x$Statistic,Observed=x$Observed),
 row.names=FALSE)
else
 print(data.frame(SUMMARY="STATISTICS",Predictor=x$Variable.1,
 Response=x$Variable.2,n=x$n,Statistic=x$Statistic,Observed=x$Observed),
 row.names=FALSE)
cat("\n")
print(data.frame(BOOTSTRAP="SUMMARY",Replications=x$Replications,Mean=x$Mean,
 SE=x$SE,Bias=x$Bias,Percent.bias=x$Percent.bias),row.names=FALSE)
cat("\n")
if (test) print(data.frame(HYPOTHESIS="TEST",Null=x$Null,
  Alternative=x$Alternative,P.value=x$P.value),row.names=FALSE)
if (test) cat("\n")
if (!is.null(x$Type))
  print(data.frame(CONFIDENCE="INTERVAL",Level=x$Level, Type=x$Type,
   Confidence.interval=x$Confidence.interval),row.names=FALSE)
else
  print(data.frame(CONFIDENCE="INTERVAL",Level=x$Level,
   Confidence.interval=x$Confidence.interval),row.names=FALSE)
cat("\n\n")
}

scaleNumCol <- function(tabCol, IQR_bias, compare=FALSE) {
	## for "auto" scales, choose between "lin" and "log" based on IQR_bias
	if (tabCol$scale_init=="auto") {
		if (compare) {
			quant <- quantile(tabCol$mean.diff, na.rm=TRUE)
		} else {
			quant <- quantile(tabCol$mean, na.rm=TRUE)
		}
		
		if (all(is.na(quant))) {
			tabCol$scale_final <- "lin"
		} else {
			IQR <- quant[4] - quant[2]
			
			## simple test to determine whether scale is lin or log
			tabCol$scale_final <- 
				ifelse(((quant[5]>0 && quant[5] > quant[4] + IQR_bias * IQR) || 
							(quant[1]<0 && quant[1] < quant[2] - IQR_bias * IQR)), 
										 "log", "lin")
		}
	} else {
		tabCol$scale_final <- tabCol$scale_init
	}
	
	## apply transformation
	if (tabCol$scale_final=="log") {
		if (compare) {
			tabCol$mean.diff.scaled <- getLog(tabCol$mean.diff)
			tabCol$sd.diff.scaled <- getLog(tabCol$sd.diff)
		} else {
			tabCol$mean.scaled <- getLog(tabCol$mean)
			tabCol$sd.scaled <- getLog(tabCol$sd)
		}
	} else {
		if (compare) {
			tabCol$mean.diff.scaled <- tabCol$mean.diff
			tabCol$sd.diff.scaled <- tabCol$sd.diff
		} else {
			tabCol$mean.scaled <- tabCol$mean
			tabCol$sd.scaled <- tabCol$sd
		}
	}
	if (compare) {
		tabCol$mean.diff.rel.scaled <- tabCol$mean.diff.rel
		tabCol$sd.diff.rel.scaled <- tabCol$sd.diff.rel
	}
	tabCol
}

## function to apply logaritmhic transformation
getLog <- function(x) {
	logx <- numeric(length(x))
	logx[is.na(x)] <- NA
	neg <- x < 0 & !is.na(x)
	notneg <- x >= 0 & !is.na(x)
	logx[notneg] <- log10(x[notneg]+1)
	logx[neg] <- -log10(abs(x[neg])+1)
	return(logx)
}
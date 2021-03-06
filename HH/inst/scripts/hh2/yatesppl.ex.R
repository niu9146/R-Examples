
### a. The whole plot column space is defined by the
###       plots %in% blocks
### dummy variables generated by the
       ## alternate residuals formula: orthogonal contrasts are critical
       data(yatesppl)
       yatesppl.resida.aov <- aov(y ~ blocks/plots,
                                  data=yatesppl, x=TRUE,
                                  contrasts=list(blocks=contr.helmert,
                                                 plots=contr.helmert))
       summary(yatesppl.resida.aov)
       t(yatesppl.resida.aov$x)
###
### b. This is the same column space defined by the
###       variety + blocks:variety
### dummy variables generated by the
       ## computational shortcut
       yatesppl.short.aov <-
         aov(terms(y ~ blocks + variety + blocks*variety +
                   nitrogen + variety*nitrogen,
                   keep.order=TRUE),  ## try it without keep.order=TRUE
             data=yatesppl, x=TRUE)
       summary(yatesppl.short.aov)
       t(yatesppl.short.aov$x)
###
### c. We illustrate this by regressing the response variable y on
### the  variety + blocks:variety dummy variables
       ## project y onto blocks/plots dummy variables
       plots.aov <- lm(y ~ yatesppl.resida.aov$x[,7:18], data=yatesppl)
       summary.aov(plots.aov)
       y.bp <- predict(plots.aov)
       variety.aov <- aov(y.bp ~ blocks*variety, data=yatesppl)
       summary(variety.aov)
### and seeing that we reproduce the plots %in% blocks
### stratum of the ANOVA table
###     Error: plots %in% blocks
###               Df Sum of Sq  Mean Sq F Value     Pr(F)
###       variety  2  1786.361 893.1806 1.48534 0.2723869
###     Residuals 10  6013.306 601.3306
### obtained from the complete five-factor specification.
###
       ## split plot analysis
       yatesppl.anova <- aov(y ~ variety*nitrogen +
                                 Error(blocks/plots/subplots),
                             data=yatesppl)
       summary(yatesppl.anova)
###

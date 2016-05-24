setwd("~/Github/phenotypes2genotypes/tests/1k")
library(pheno2geno)
set.seed(1234)
founders_groups <- c(0,0,0,0,0,0,1,1,1,1,1,1,1,1)
population <- read.population(founders_groups=founders_groups, populationType="riself", read_mode="HT", verbose=TRUE, debugMode=2, sliceSize=10000, transformations="nothing",threshold=0.01)
populationN <- generate.biomarkers(population, threshold= 1.0e-09, overlapInd = 15, margin=45, p.prob=0.8, verbose=T, debug=2)
populationN <- scan.qtls(populationN)
crossN <- cross.saturate(populationN,  flagged="remove", verbose=T,threshold=15)
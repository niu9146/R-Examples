# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

DistKd <- function(Rx, Ry, RPointWeight, RWeight, RDist, RIsReferenceType, RIsNeighborType) {
    invisible(.Call('dbmss_DistKd', PACKAGE = 'dbmss', Rx, Ry, RPointWeight, RWeight, RDist, RIsReferenceType, RIsNeighborType))
}

CountNbdKd <- function(Rr, Rx, Ry, RWeight, RNbd, RIsReferenceType, RIsNeighborType) {
    invisible(.Call('dbmss_CountNbdKd', PACKAGE = 'dbmss', Rr, Rx, Ry, RWeight, RNbd, RIsReferenceType, RIsNeighborType))
}

parallelCountNbd <- function(r, x, y, Weight, IsReferenceType, IsNeighborType) {
    .Call('dbmss_parallelCountNbd', PACKAGE = 'dbmss', r, x, y, Weight, IsReferenceType, IsNeighborType)
}

parallelCountNbdCC <- function(r, x, y, Weight, IsReferenceType, IsNeighborType) {
    .Call('dbmss_parallelCountNbdCC', PACKAGE = 'dbmss', r, x, y, Weight, IsReferenceType, IsNeighborType)
}

parallelCountNbdm <- function(x, y, ReferencePoints) {
    .Call('dbmss_parallelCountNbdm', PACKAGE = 'dbmss', x, y, ReferencePoints)
}


# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

CalcLikelihoodC <- function(dtm, phi, theta) {
    .Call('textmineR_CalcLikelihoodC', PACKAGE = 'textmineR', dtm, phi, theta)
}

CalcSumSquares <- function(dtm, phi, theta, ybar) {
    .Call('textmineR_CalcSumSquares', PACKAGE = 'textmineR', dtm, phi, theta, ybar)
}

Dtm2DocsC <- function(dtm, vocab) {
    .Call('textmineR_Dtm2DocsC', PACKAGE = 'textmineR', dtm, vocab)
}

Hellinger_cpp <- function(p, q) {
    .Call('textmineR_Hellinger_cpp', PACKAGE = 'textmineR', p, q)
}

HellingerMat <- function(A) {
    .Call('textmineR_HellingerMat', PACKAGE = 'textmineR', A)
}

JSD_cpp <- function(p, q) {
    .Call('textmineR_JSD_cpp', PACKAGE = 'textmineR', p, q)
}

JSDmat <- function(A) {
    .Call('textmineR_JSDmat', PACKAGE = 'textmineR', A)
}


# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

Crtnorm <- function(a, muf, sigf, lowf, upf, boolowf, booupf) {
    .Call('NHMM_Crtnorm', PACKAGE = 'NHMM', a, muf, sigf, lowf, upf, boolowf, booupf)
}

rcpp_3d <- function(jf, kf, lf, Jf, Kf, Lf) {
    .Call('NHMM_rcpp_3d', PACKAGE = 'NHMM', jf, kf, lf, Jf, Kf, Lf)
}

rcpp_arraytomat <- function(arr3d, c, A, B, C) {
    .Call('NHMM_rcpp_arraytomat', PACKAGE = 'NHMM', arr3d, c, A, B, C)
}

rcpp_dgamma <- function(a, b, c) {
    .Call('NHMM_rcpp_dgamma', PACKAGE = 'NHMM', a, b, c)
}

rcpp_dmvnorm <- function(dataf, meanf, Siginvf, detf) {
    .Call('NHMM_rcpp_dmvnorm', PACKAGE = 'NHMM', dataf, meanf, Siginvf, detf)
}

rcpp_dnorm <- function(a, b, c) {
    .Call('NHMM_rcpp_dnorm', PACKAGE = 'NHMM', a, b, c)
}

rcpp_dot <- function(c, d) {
    .Call('NHMM_rcpp_dot', PACKAGE = 'NHMM', c, d)
}

rcpp_dpois <- function(a, b) {
    .Call('NHMM_rcpp_dpois', PACKAGE = 'NHMM', a, b)
}

rcpp_getdenzity <- function(A, Wbin, psi, gamy, fam, K, mixes, delt, y, ppp, theta1, theta2) {
    .Call('NHMM_rcpp_getdenzity', PACKAGE = 'NHMM', A, Wbin, psi, gamy, fam, K, mixes, delt, y, ppp, theta1, theta2)
}

rcpp_getdenzityMVN <- function(A, Wbin, psi, K, y, thetainv, detS) {
    .Call('NHMM_rcpp_getdenzityMVN', PACKAGE = 'NHMM', A, Wbin, psi, K, y, thetainv, detS)
}

rcpp_getNQQ <- function(beta, XX) {
    .Call('NHMM_rcpp_getNQQ', PACKAGE = 'NHMM', beta, XX)
}

rcpp_getppp <- function(gamy, mus) {
    .Call('NHMM_rcpp_getppp', PACKAGE = 'NHMM', gamy, mus)
}

rcpp_getQQ <- function(K, z, dirprior, subseqy) {
    .Call('NHMM_rcpp_getQQ', PACKAGE = 'NHMM', K, z, dirprior, subseqy)
}

rcpp_getsumz1 <- function(Kf, Jf, Tf, zf, Sigmainvf, in2f) {
    .Call('NHMM_rcpp_getsumz1', PACKAGE = 'NHMM', Kf, Jf, Tf, zf, Sigmainvf, in2f)
}

rcpp_getsumz2 <- function(llf, LLf, Kf, Jf, Tf, zf, Sigmainvf, in2f, yf, betaemf, betaem0f) {
    .Call('NHMM_rcpp_getsumz2', PACKAGE = 'NHMM', llf, LLf, Kf, Jf, Tf, zf, Sigmainvf, in2f, yf, betaemf, betaem0f)
}

rcpp_getvvv <- function(fam, K, mixes, delt, y, ppp, theta1, theta2, z) {
    .Call('NHMM_rcpp_getvvv', PACKAGE = 'NHMM', fam, K, mixes, delt, y, ppp, theta1, theta2, z)
}

rcpp_getWbin <- function(z, K, J) {
    .Call('NHMM_rcpp_getWbin', PACKAGE = 'NHMM', z, K, J)
}

rcpp_getymiss <- function(fam, K, z, ppp, theta1, theta2, mixes, delt, J) {
    .Call('NHMM_rcpp_getymiss', PACKAGE = 'NHMM', fam, K, z, ppp, theta1, theta2, mixes, delt, J)
}

rcpp_getz <- function(zf, QQf, denzity, subseqy) {
    invisible(.Call('NHMM_rcpp_getz', PACKAGE = 'NHMM', zf, QQf, denzity, subseqy))
}

rcpp_pnorm <- function(a) {
    .Call('NHMM_rcpp_pnorm', PACKAGE = 'NHMM', a)
}

rcpp_prod <- function(A) {
    .Call('NHMM_rcpp_prod', PACKAGE = 'NHMM', A)
}

rcpp_rdirichlet <- function(B) {
    .Call('NHMM_rcpp_rdirichlet', PACKAGE = 'NHMM', B)
}

rcpp_dmix0 <- function(fam, y, ppp, par1, par2) {
    .Call('NHMM_rcpp_dmix0', PACKAGE = 'NHMM', fam, y, ppp, par1, par2)
}

rcpp_rmix0 <- function(fam, ppp, par1, par2) {
    .Call('NHMM_rcpp_rmix0', PACKAGE = 'NHMM', fam, ppp, par1, par2)
}

rcpp_dmix <- function(fam, y, ppp, par1, par2) {
    .Call('NHMM_rcpp_dmix', PACKAGE = 'NHMM', fam, y, ppp, par1, par2)
}

rcpp_rmix <- function(fam, ppp, par1, par2) {
    .Call('NHMM_rcpp_rmix', PACKAGE = 'NHMM', fam, ppp, par1, par2)
}

rcpp_resetX <- function(XXf, zbinf) {
    .Call('NHMM_rcpp_resetX', PACKAGE = 'NHMM', XXf, zbinf)
}

rcpp_rgamma <- function(a, b, c) {
    .Call('NHMM_rcpp_rgamma', PACKAGE = 'NHMM', a, b, c)
}

rcpp_rmultinom <- function(probs) {
    .Call('NHMM_rcpp_rmultinom', PACKAGE = 'NHMM', probs)
}

rcpp_rnorm <- function(a, b, c) {
    .Call('NHMM_rcpp_rnorm', PACKAGE = 'NHMM', a, b, c)
}

rcpp_rpois <- function(a, b) {
    .Call('NHMM_rcpp_rpois', PACKAGE = 'NHMM', a, b)
}

rcpp_summ <- function(A) {
    .Call('NHMM_rcpp_summ', PACKAGE = 'NHMM', A)
}

rcpp_sumv <- function(A) {
    .Call('NHMM_rcpp_sumv', PACKAGE = 'NHMM', A)
}


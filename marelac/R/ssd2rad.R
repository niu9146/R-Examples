## -----------------------------------------------------------------------------
## Global Radiation from Measured Sunshine Duration Time
## -----------------------------------------------------------------------------

ssd2rad <- function(S, doy, a = 0.25, b = 0.5, rho = 50.29) {
  xi <- 0.0172 * doy - 1.39
  S0 <- 12.3 + sin(xi) * (4.3 + (rho - 51))/6
  Rex <- 245 * (9.9 + 7.08 * sin(xi) + 0.18 * (rho - 51) * (sin(xi) - 1))
  Rex * (a + b * S/S0) *1e4/24/3600
}


#
#   funxy.R
#
#   Class of functions of x,y location with a spatial domain
#
#   $Revision: 1.11 $   $Date: 2016/02/25 06:32:43 $
#

spatstat.xy.coords <- function(x,y) {
  if(missing(y) || is.null(y)) {
    xy <- if(is.ppp(x) || is.lpp(x)) coords(x) else
          if(checkfields(x, c("x", "y"))) x else 
          stop("Argument y is missing", call.=FALSE)
    x <- xy$x
    y <- xy$y
  }
  xy.coords(x,y)[c("x","y")]
}

funxy <- function(f, W=NULL) {
  stopifnot(is.function(f))
  stopifnot(is.owin(W))
  if(!identical(names(formals(f))[1:2], c("x", "y")))
    stop("The first two arguments of f should be named x and y", call.=FALSE)
  # copy 'f' including formals, environment, attributes
  h <- f
  # make new body: paste body of 'f' into last line of 'spatstat.xy.coords'
  g <- spatstat.xy.coords
  nx <- length(body(g)) - 1  # omit last line
  nf <- length(body(f)) - 1 # omit first brace
  body(g)[nx + seq_len(nf)] <- body(f)[-1]
  # transplant the body 
  body(h) <- body(g)
  # reinstate attributes
  attributes(h) <- attributes(f)
  # stamp it
  class(h) <- c("funxy", class(h))
  attr(h, "W") <- W
  attr(h, "f") <- f
  return(h)  
}

print.funxy <- function(x, ...) {
  nama <- names(formals(x))
  splat(paste0("function", paren(paste(nama,collapse=","))),
        "of class", sQuote("funxy"))
  print(as.owin(x))
  splat("\nOriginal function definition:")
  print(attr(x, "f"))
}

summary.funxy <- function(object, ...) { print(object, ...) }

as.owin.funxy <- function(W, ..., fatal=TRUE) {
  W <- attr(W, "W")
  as.owin(W, ..., fatal=fatal)
}

domain.funxy <- Window.funxy <- function(X, ...) { as.owin(X) }

#   Note that 'distfun' (and other classes inheriting from funxy)
#   has a method for as.owin that takes precedence over as.owin.funxy
#   and this will affect the behaviour of the following plot methods
#   because 'distfun' does not have its own plot method.

plot.funxy <- function(x, ...) {
  xname <- short.deparse(substitute(x))
  W <- as.owin(x)
  do.call(do.as.im,
          resolve.defaults(list(x, action="plot"),
                           list(...),
                           list(main=xname, W=W)))
  invisible(NULL)
}

contour.funxy <- function(x, ...) {
  xname <- deparse(substitute(x))
  W <- as.owin(x)
  do.call(do.as.im,
          resolve.defaults(list(x, action="contour"),
                           list(...),
                           list(main=xname, W=W)))
  invisible(NULL)
}

persp.funxy <- function(x, ...) {
  xname <- deparse(substitute(x))
  W <- as.rectangle(as.owin(x))
  do.call(do.as.im,
          resolve.defaults(list(x, action="persp"),
                           list(...),
                           list(main=xname, W=W)))
  invisible(NULL)
}


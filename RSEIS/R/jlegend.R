`jlegend` <-
function (x, y, legend, fill, col = "black", lty, lwd, pch, angle = NULL,
    density = NULL, bty = "o", bg = par("bg"), pt.bg = NA, cex = 1,
    xjust = 0, yjust = 1, x.intersp = 1, y.intersp = 1, adj = 0,
    text.width = NULL, merge = do.lines && has.pch, trace = FALSE,
    ncol = 1, horiz = FALSE, plot=TRUE)
{
    if (is.list(x)) {
        if (!missing(y)) {
            if (!missing(legend))
                stop("`y' and `legend' when `x' is list (need no `y')")
            legend <- y
        }
        y <- x$y
        x <- x$x
    }
    else if (missing(y))
        stop("missing y")
    if (!is.numeric(x) || !is.numeric(y))
        stop("non-numeric coordinates")
    if ((nx <- length(x)) <= 0 || nx != length(y) || nx > 2)
        stop("invalid coordinate lengths")
    xlog <- par("xlog")
    ylog <- par("ylog")
    rect2 <- function(left, top, dx, dy, angle, ...) {
        r <- left + dx
        if (xlog) {
            left <- 10^left
            r <- 10^r
        }
        b <- top - dy
        if (ylog) {
            top <- 10^top
            b <- 10^b
        }
        rect(left, top, r, b, angle = angle, density = density,
            ...)
    }
    segments2 <- function(x1, y1, dx, dy, ...) {
        x2 <- x1 + dx
        if (xlog) {
            x1 <- 10^x1
            x2 <- 10^x2
        }
        y2 <- y1 + dy
        if (ylog) {
            y1 <- 10^y1
            y2 <- 10^y2
        }
        segments(x1, y1, x2, y2, ...)
    }
    points2 <- function(x, y, ...) {
        if (xlog)
            x <- 10^x
        if (ylog)
            y <- 10^y
        points(x, y, ...)
    }
    text2 <- function(x, y, ...) {
        if (xlog)
            x <- 10^x
        if (ylog)
            y <- 10^y
        text(x, y, ...)
    }
    if (trace)
        catn <- function(...) do.call("cat", c(lapply(list(...),
            formatC), list("\n")))
    cin <- par("cin")
    Cex <- cex * par("cex")
    if (is.null(text.width))
        text.width <- max(strwidth(legend, units = "user", cex = cex))
    else if (!is.numeric(text.width) || text.width < 0)
        stop("text.width must be numeric, >= 0")
    xc <- Cex * xinch(cin[1], warn.log = FALSE)
    yc <- Cex * yinch(cin[2], warn.log = FALSE)
    xchar <- xc
    yextra <- yc * (y.intersp - 1)
    ymax <- max(yc, strheight(legend, units = "user", cex = cex))
    ychar <- yextra + ymax
    if (trace)
        catn("  xchar=", xchar, "; (yextra,ychar)=", c(yextra,
            ychar))
    if (!missing(fill)) {
        xbox <- xc * 0.8
        ybox <- yc * 0.5
        dx.fill <- xbox
    }
    do.lines <- (!missing(lty) && (is.character(lty) || any(lty >
        0))) || !missing(lwd)
    n.leg <- length(legend)
    n.legpercol <- if (horiz) {
        if (ncol != 1)
            warning("horizontal specification overrides: Number of columns := ",
                n.leg)
        ncol <- n.leg
        1
    }
    else ceiling(n.leg/ncol)
    if (has.pch <- !missing(pch)) {
        if (is.character(pch) && nchar(pch[1]) > 1) {
            if (length(pch) > 1)
                warning("Not using pch[2..] since pch[1] has multiple chars")
            np <- nchar(pch[1])
            pch <- substr(rep(pch[1], np), 1:np, 1:np)
        }
        if (!merge)
            dx.pch <- x.intersp/2 * xchar
    }
    x.off <- if (merge)
        -0.7
    else 0
    if (xlog)
        x <- log10(x)
    if (ylog)
        y <- log10(y)
    if (nx == 2) {
        x <- sort(x)
        y <- sort(y)
        left <- x[1]
        top <- y[2]
        w <- diff(x)
        h <- diff(y)
        w0 <- w/ncol
        x <- mean(x)
        y <- mean(y)
        if (missing(xjust))
            xjust <- 0.5
        if (missing(yjust))
            yjust <- 0.5
    }
    else {
        h <- n.legpercol * ychar + yc
        w0 <- text.width + (x.intersp + 1) * xchar
        if (!missing(fill))
            w0 <- w0 + dx.fill
        if (has.pch && !merge)
            w0 <- w0 + dx.pch
        if (do.lines)
            w0 <- w0 + (2 + x.off) * xchar
        w <- ncol * w0 + 0.5 * xchar
        left <- x - xjust * w
        top <- y + (1 - yjust) * h
    }
    if (bty != "n") {
        if (trace)
            catn("  rect2(", left, ",", top, ", w=", w, ", h=",
                h, "...)", sep = "")
        rect2(left, top, dx = w, dy = h, col = bg, angle = NULL)
    }
    xt <- left + xchar + (w0 * rep(0:(ncol - 1), rep(n.legpercol,
        ncol)))[1:n.leg]
    yt <- top - (rep(1:n.legpercol, ncol)[1:n.leg] - 1) * ychar -
        0.5 * yextra - ymax
    if (!missing(fill)) {
        fill <- rep(fill, length.out = n.leg)
        rect2(left = xt, top = yt + ybox/2, dx = xbox, dy = ybox,
            col = fill, angle = angle)
        xt <- xt + dx.fill
    }
    if (has.pch || do.lines)
        col <- rep(col, length.out = n.leg)
    if (do.lines) {
        seg.len <- 2
        if (missing(lty))
            lty <- 1
        ok.l <- is.character(lty) | lty > 0
        if (missing(lwd))
            lwd <- par("lwd")
        lty <- rep(lty, length.out = n.leg)
        lwd <- rep(lwd, length.out = n.leg)
        if (trace)
            catn("  segments2(", xt[ok.l] + x.off * xchar, ",",
                yt[ok.l], ", dx=", seg.len * xchar, ", dy=0, ...)",
                sep = "")
        segments2(xt[ok.l] + x.off * xchar, yt[ok.l], dx = seg.len *
            xchar, dy = 0, lty = lty[ok.l], lwd = lwd[ok.l],
            col = col[ok.l])
        xt <- xt + (seg.len + x.off) * xchar
    }
    if (has.pch) {
        pch <- rep(pch, length.out = n.leg)
        pt.bg <- rep(pt.bg, length.out = n.leg)
        ok <- is.character(pch) | pch >= 0
        x1 <- (if (merge)
            xt - (seg.len/2) * xchar
        else xt)[ok]
        y1 <- yt[ok]
        if (trace)
            catn("  points2(", x1, ",", y1, ", pch=", pch[ok],
                "...)")
        points2(x1, y1, pch = pch[ok], col = col[ok], cex = cex,
            bg = pt.bg[ok])
        if (!merge)
            xt <- xt + dx.pch
    }
    xt <- xt + x.intersp * xchar
    text2(xt, yt, labels = legend, adj = adj, cex = cex)
    invisible(list(rect = list(w = w, h = h, left = left, top = top),
        text = list(x = xt, y = yt)))
}


## ----init,echo=FALSE-----------------------------------------------------
knitr::opts_chunk$set(warning=FALSE, message=FALSE, cache=FALSE, 
               comment=NA, verbose=TRUE, fig.width=4, fig.height=4,dev='jpeg')

## ----fig.width=4, fig.height=6,message=FALSE,dev='jpeg'------------------
library(imager)
plot(boats)

## ------------------------------------------------------------------------
class(boats)

## ------------------------------------------------------------------------
boats

## ------------------------------------------------------------------------
grayscale(boats)

## ------------------------------------------------------------------------
dim(boats)

## ------------------------------------------------------------------------
log(boats)+3*sqrt(boats)
mean(boats)
sd(boats)

## ------------------------------------------------------------------------
fpath <- system.file('extdata/parrots.png',package='imager')

## ------------------------------------------------------------------------
parrots <- load.image(fpath)
plot(parrots)

## ----fig.width=4, fig.height=2.2-----------------------------------------
grayscale(boats) %>% hist(main="Luminance values in boats picture")

## ----fig.width=4, fig.height=2.2-----------------------------------------
R(boats) %>% hist(main="Red channel values in boats picture")
#Equivalently:
#channel(boats,1) %>% hist(main="Red channel values in boats picture")

## ----fig.width=4, fig.height=2.2-----------------------------------------
library(ggplot2)
bdf <- as.data.frame(boats)
head(bdf,3)
bdf <- plyr::mutate(bdf,channel=factor(cc,labels=c('R','G','B')))
ggplot(bdf,aes(value,col=channel))+geom_histogram(bins=30)+facet_wrap(~ channel)

## ----fig.width=4, fig.height=2.2-----------------------------------------
x <- rnorm(100)
layout(t(1:2))
hist(x,main="Histogram of x")
f <- ecdf(x)
hist(f(x),main="Histogram of ecdf(x)")


## ----fig.width=4, fig.height=2.2-----------------------------------------
boats.g <- grayscale(boats)
f <- ecdf(boats.g)
plot(f,main="Empirical CDF of luminance values")

## ----fig.width=4, fig.height=2.2-----------------------------------------
f(boats.g) %>% hist(main="Transformed luminance values")

## ------------------------------------------------------------------------
f(boats.g) %>% str

## ----fig.width=4, fig.height=6-------------------------------------------
f(boats.g) %>% as.cimg(dim=dim(boats.g)) %>% plot(main="With histogram equalisation")

## ----fig.width=4, fig.height=6-------------------------------------------
#Hist. equalisation for grayscale
hist.eq <- function(im) as.cimg(ecdf(im)(im),dim=dim(im))

#Split across colour channels, 
cn <- imsplit(boats,"c")
cn #we now have a list of images
cn.eq <- llply(cn,hist.eq) #run hist.eq on each
imappend(cn.eq,"c") %>% plot(main="All channels equalised") #recombine and plot

## ------------------------------------------------------------------------
iiply(boats,"c",hist.eq) 

## ----fig.width=4, fig.height=2.3-----------------------------------------
iiply(boats,"c",hist.eq) %>% as.data.frame %>% ggplot(aes(value))+geom_histogram(bins=30)+facet_wrap(~ cc)

## ------------------------------------------------------------------------
layout(t(1:2))
imgradient(boats.g,"x") %>% plot(main="Gradient along x")
imgradient(boats.g,"y") %>% plot(main="Gradient along y")

## ------------------------------------------------------------------------
dx <- imgradient(boats.g,"x")
dy <- imgradient(boats.g,"y")
grad.mag <- sqrt(dx^2+dy^2)
plot(grad.mag,main="Gradient magnitude")

## ------------------------------------------------------------------------
imgradient(boats.g,"xy") %>% enorm %>% plot(main="Gradient magnitude (again)")

## ------------------------------------------------------------------------
l <- imgradient(boats.g,"xy")
str(l)

## ------------------------------------------------------------------------
enorm(list(3,2))
sqrt(3^2+2^2)

## ------------------------------------------------------------------------
df <- grayscale(boats) %>% as.data.frame
p <- ggplot(df,aes(x,y))+geom_raster(aes(fill=value))
p

## ------------------------------------------------------------------------
p + scale_y_continuous(trans=scales::reverse_trans())

## ------------------------------------------------------------------------
p <- p+scale_x_continuous(expand=c(0,0))+scale_y_continuous(expand=c(0,0),trans=scales::reverse_trans())
p

## ------------------------------------------------------------------------
p+scale_fill_gradient(low="black",high="white")

## ------------------------------------------------------------------------
df <- as.data.frame(boats) 
p <- ggplot(df,aes(x,y))+geom_raster(aes(fill=value))+facet_wrap(~ cc)
p+scale_y_reverse()

## ------------------------------------------------------------------------
as.data.frame(boats,wide="c") %>% head

## ------------------------------------------------------------------------
df <- as.data.frame(boats,wide="c") %>% mutate(rgb.val=rgb(c.1/255,c.2/255,c.3/255))
head(df,3)

## ------------------------------------------------------------------------
p <- ggplot(df,aes(x,y))+geom_raster(aes(fill=rgb.val))+scale_fill_identity()
p+scale_y_reverse()

## ------------------------------------------------------------------------
hub <- load.example("hubble") %>% grayscale
plot(hub,main="Hubble Deep Field")

## ----fig.width=8,fig.height=4--------------------------------------------
layout(t(1:2))
set.seed(2)
points <- rbinom(100*100,1,.001) %>% as.cimg
blobs <- isoblur(points,5)
plot(points,main="Random points")
plot(blobs,main="Blobs")

## ----warning=TRUE--------------------------------------------------------
rbinom(100*100,1,.001) %>% as.cimg

## ------------------------------------------------------------------------
rbinom(100*100,1,.001) %>% as.cimg(x=100,y=100)

## ------------------------------------------------------------------------
imhessian(blobs)

## ------------------------------------------------------------------------
Hdet <- with(imhessian(blobs),(xx*yy - xy^2))
plot(Hdet,main="Determinant of Hessian")

## ------------------------------------------------------------------------
threshold(Hdet,"99%") %>% plot(main="Determinant: 1% highest values")

## ------------------------------------------------------------------------
lab <- threshold(Hdet,"99%") %>% label
plot(lab,main="Labelled regions")

## ------------------------------------------------------------------------
df <- as.data.frame(lab) %>% subset(value>0)
head(df,3)
unique(df$value) #10 regions

## ------------------------------------------------------------------------
centers <- ddply(df,.(value),summarise,mx=mean(x),my=mean(y))
centers <- dplyr::group_by(df,value) %>% dplyr::summarise(mx=mean(x),my=mean(y))

## ------------------------------------------------------------------------
plot(blobs)
with(centers,points(mx,my,col="red"))

## ------------------------------------------------------------------------
nblobs <- blobs+.001*imnoise(dim=dim(blobs))
plot(nblobs,main="Noisy blobs")

## ------------------------------------------------------------------------

get.centers <- function(im,thr="99%")
{
    dt <- imhessian(im) %$% { xx*yy - xy^2 } %>% threshold(thr) %>% label
    as.data.frame(dt) %>% subset(value>0) %>% dplyr::group_by(value) %>% dplyr::summarise(mx=mean(x),my=mean(y))
}

plot(nblobs)
get.centers(nblobs,"99%") %$% points(mx,my,col="red")

## ------------------------------------------------------------------------
nblobs.denoised <- isoblur(nblobs,2)
plot(nblobs.denoised)
get.centers(nblobs.denoised,"99%") %$% points(mx,my,col="red")


## ------------------------------------------------------------------------
plot(hub)
get.centers(hub,"99.8%") %$% points(mx,my,col="red")


## ------------------------------------------------------------------------
plot(hub)
isoblur(hub,5) %>% get.centers("99.8%") %$% points(mx,my,col="red")


## ------------------------------------------------------------------------
 #Compute determinant at scale "scale". 
hessdet <- function(im,scale=1) isoblur(im,scale) %>% imhessian %$% { scale^2*(xx*yy - xy^2) }
#Note the scaling (scale^2) factor in the determinant
plot(hessdet(hub,1),main="Determinant of the Hessian at scale 1")

## ----fig.width=7---------------------------------------------------------
#Get a data.frame with results at scale 2, 3 and 4
dat <- ldply(c(2,3,4),function(scale) hessdet(hub,scale) %>% as.data.frame %>% mutate(scale=scale))
p <- ggplot(dat,aes(x,y))+geom_raster(aes(fill=value))+facet_wrap(~ scale)
p+scale_x_continuous(expand=c(0,0))+scale_y_continuous(expand=c(0,0),trans=scales::reverse_trans())

## ------------------------------------------------------------------------
scales <- seq(2,20,l=10)

d.max <- llply(scales,function(scale) hessdet(hub,scale)) %>% parmax
plot(d.max,main="Point-wise maximum across scales")

## ------------------------------------------------------------------------
i.max <- llply(scales,function(scale) hessdet(hub,scale)) %>% which.parmax
plot(i.max,main="Index of the point-wise maximum across scales")

## ----fig.height=7,fig.width=8--------------------------------------------
#Get a data.frame of labelled regions
labs <- d.max %>% threshold("96%") %>% label %>% as.data.frame
#Add scale indices
labs <- mutate(labs,index=as.data.frame(i.max)$value)
regs <- dplyr::group_by(labs,value) %>% dplyr::summarise(mx=mean(x),my=mean(y),scale.index=mean(index))
p <- ggplot(as.data.frame(hub),aes(x,y))+geom_raster(aes(fill=value))+geom_point(data=regs,aes(mx,my,size=scale.index),pch=2,col="red")
p+scale_fill_gradient(low="black",high="white")+scale_x_continuous(expand=c(0,0))+scale_y_continuous(expand=c(0,0),trans=scales::reverse_trans())

## ----dim_gray------------------------------------------------------------
parrots <- load.example("parrots")
gray.parrots <- grayscale(parrots)
dim(gray.parrots)

## ----dim_colour----------------------------------------------------------
dim(parrots)

## ------------------------------------------------------------------------
im <- imfill(10,10) 
dim(im)
im[,1] <- 1:10 #Change the first *row* in the image - dimensions are x,y,z,c
im[,1,1,1] <- 1:10 #Same thing, more verbose
plot(im)

## ----error=TRUE----------------------------------------------------------
as.cimg(1:9) #Guesses you want a 3x3 image
as.cimg(1:10) #Ambiguous, issues an error
as.cimg(array(1,c(10,10))) #Assumes it's a grayscale image you want
as.cimg(array(1:9,c(10,10,3))) #Assumes it's a colour image (last dimension 3)
as.cimg(array(1:9,c(10,10,4))) #Assumes it's a grayscale video with 4 frames (last dimension != 3)


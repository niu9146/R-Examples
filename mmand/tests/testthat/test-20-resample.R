context("Image resampling and rescaling")

test_that("image resampling operations work", {
    expect_that(resample(c(0,0,1,0,0),seq(0.75,5.25,0.5),boxKernel()), equals(c(0,0,0,0,1,1,0,0,0,0)))
    expect_that(resample(c(0,0,1,0,0),seq(0.75,5.25,0.5),triangleKernel()), equals(c(0,0,0,0.25,0.75,0.75,0.25,0,0,0)))
    
    data <- matrix(1:9, nrow=3, ncol=3)
    point <- matrix(c(1.5,2.5), nrow=1)
    expect_that(resample(data,point,boxKernel()), equals(8))
    expect_that(resample(data,point,triangleKernel()), equals(6))
    expect_that(resample(data,point,mitchellNetravaliKernel()), equals(6.100671,tolerance=1e-4))
    
    grid <- list(c(1.5,2.5),c(1.5,2.5))
    expect_that(resample(data,grid,boxKernel()), equals(matrix(c(5,6,8,9),2,2)))
    expect_that(resample(data,grid,triangleKernel()), equals(matrix(c(3,4,6,7),2,2)))
    
    expect_that(rescale(c(0,0,1,0,0),2,boxKernel()), equals(c(0,0,0,0,1,1,0,0,0,0)))
    expect_that(rescale(c(0,0,1,0,0),2,triangleKernel()), equals(c(0,0,0,0.25,0.75,0.75,0.25,0,0,0)))
})

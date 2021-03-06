#
#   Copyright 2007-2016 The OpenMx Project
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
# 
#        http://www.apache.org/licenses/LICENSE-2.0
# 
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


# -----------------------------------------------------------------------------
# Program: OneFactorMatrixDemo.R  
# Author: Steve Boker
# Date: 2009.08.01 
#
# ModelType: Factor
# DataType: Continuous
# Field: None
#
# Purpose: 
#      OpenMx one factor matrix model demo from front page of website
# 
# RevisionHistory:
#      Hermine Maes -- 2009.10.08	updated & reformatted
#      Ross Gore -- 2011.06.06	added Model, Data & Field metadata
#      Mike Hunter -- 2013.09.16	Identified model by fixing variance to 1.0
#      Tim Bates -- 2014.10.12	reformatted
# -----------------------------------------------------------------------------

require(OpenMx)
# Load Library
# -----------------------------------------------------------------------------

data(demoOneFactor)
# Prepare Data
# -----------------------------------------------------------------------------

factorModel <- mxModel(name ="One Factor",
    mxMatrix(type="Full", nrow=5, ncol=1, free=TRUE, values=0.2, name="A"),
    mxMatrix(type="Symm", nrow=1, ncol=1, free=FALSE, values=1, name="L"),
    mxMatrix(type="Diag", nrow=5, ncol=5, free=TRUE, values=1, name="U"),
    mxAlgebra(expression=A %*% L %*% t(A) + U, name="R"),
    mxFitFunctionML(),mxExpectationNormal(covariance="R", dimnames=names(demoOneFactor)),
    mxData(observed=cov(demoOneFactor), type="cov", numObs=500)
)
# Create an MxModel object
# -----------------------------------------------------------------------------

factorFit <- mxRun(factorModel)
# Fit the model to the observed covariances with mxRun
# -----------------------------------------------------------------------------

summary(factorFit)
# Print a summary of the results
# -----------------------------------------------------------------------------

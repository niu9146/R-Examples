# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

GetIndivMatrixElements <- function(bigMatAddr, col, row) {
    .Call('bigmemory_GetIndivMatrixElements', PACKAGE = 'bigmemory', bigMatAddr, col, row)
}

ReorderRIntMatrix <- function(matrixVector, nrow, ncol, orderVec) {
    invisible(.Call('bigmemory_ReorderRIntMatrix', PACKAGE = 'bigmemory', matrixVector, nrow, ncol, orderVec))
}

ReorderRNumericMatrix <- function(matrixVector, nrow, ncol, orderVec) {
    invisible(.Call('bigmemory_ReorderRNumericMatrix', PACKAGE = 'bigmemory', matrixVector, nrow, ncol, orderVec))
}

ReorderBigMatrix <- function(address, orderVec) {
    invisible(.Call('bigmemory_ReorderBigMatrix', PACKAGE = 'bigmemory', address, orderVec))
}

ReorderRIntMatrixCols <- function(matrixVector, nrow, ncol, orderVec) {
    invisible(.Call('bigmemory_ReorderRIntMatrixCols', PACKAGE = 'bigmemory', matrixVector, nrow, ncol, orderVec))
}

ReorderRNumericMatrixCols <- function(matrixVector, nrow, ncol, orderVec) {
    invisible(.Call('bigmemory_ReorderRNumericMatrixCols', PACKAGE = 'bigmemory', matrixVector, nrow, ncol, orderVec))
}

ReorderBigMatrixCols <- function(address, orderVec) {
    invisible(.Call('bigmemory_ReorderBigMatrixCols', PACKAGE = 'bigmemory', address, orderVec))
}

OrderRIntMatrix <- function(matrixVector, nrow, columns, naLast, decreasing) {
    .Call('bigmemory_OrderRIntMatrix', PACKAGE = 'bigmemory', matrixVector, nrow, columns, naLast, decreasing)
}

OrderRNumericMatrix <- function(matrixVector, nrow, columns, naLast, decreasing) {
    .Call('bigmemory_OrderRNumericMatrix', PACKAGE = 'bigmemory', matrixVector, nrow, columns, naLast, decreasing)
}

OrderBigMatrix <- function(address, columns, naLast, decreasing) {
    .Call('bigmemory_OrderBigMatrix', PACKAGE = 'bigmemory', address, columns, naLast, decreasing)
}

OrderRIntMatrixCols <- function(matrixVector, nrow, ncol, rows, naLast, decreasing) {
    .Call('bigmemory_OrderRIntMatrixCols', PACKAGE = 'bigmemory', matrixVector, nrow, ncol, rows, naLast, decreasing)
}

OrderRNumericMatrixCols <- function(matrixVector, nrow, ncol, rows, naLast, decreasing) {
    .Call('bigmemory_OrderRNumericMatrixCols', PACKAGE = 'bigmemory', matrixVector, nrow, ncol, rows, naLast, decreasing)
}

OrderBigMatrixCols <- function(address, rows, naLast, decreasing) {
    .Call('bigmemory_OrderBigMatrixCols', PACKAGE = 'bigmemory', address, rows, naLast, decreasing)
}

CCleanIndices <- function(indices, rc) {
    .Call('bigmemory_CCleanIndices', PACKAGE = 'bigmemory', indices, rc)
}

HasRowColNames <- function(address) {
    .Call('bigmemory_HasRowColNames', PACKAGE = 'bigmemory', address)
}

GetIndexRowNames <- function(address, indices_) {
    .Call('bigmemory_GetIndexRowNames', PACKAGE = 'bigmemory', address, indices_)
}

GetIndexColNames <- function(address, indices_) {
    .Call('bigmemory_GetIndexColNames', PACKAGE = 'bigmemory', address, indices_)
}

GetColumnNamesBM <- function(address) {
    .Call('bigmemory_GetColumnNamesBM', PACKAGE = 'bigmemory', address)
}

GetRowNamesBM <- function(address) {
    .Call('bigmemory_GetRowNamesBM', PACKAGE = 'bigmemory', address)
}

SetColumnNames <- function(address, columnNames) {
    invisible(.Call('bigmemory_SetColumnNames', PACKAGE = 'bigmemory', address, columnNames))
}

SetRowNames <- function(address, rowNames) {
    invisible(.Call('bigmemory_SetRowNames', PACKAGE = 'bigmemory', address, rowNames))
}

IsReadOnly <- function(bigMatAddr) {
    .Call('bigmemory_IsReadOnly', PACKAGE = 'bigmemory', bigMatAddr)
}

CIsSubMatrix <- function(bigMatAddr) {
    .Call('bigmemory_CIsSubMatrix', PACKAGE = 'bigmemory', bigMatAddr)
}

CGetNrow <- function(bigMatAddr) {
    .Call('bigmemory_CGetNrow', PACKAGE = 'bigmemory', bigMatAddr)
}

CGetNcol <- function(bigMatAddr) {
    .Call('bigmemory_CGetNcol', PACKAGE = 'bigmemory', bigMatAddr)
}

CGetType <- function(bigMatAddr) {
    .Call('bigmemory_CGetType', PACKAGE = 'bigmemory', bigMatAddr)
}

IsSharedMemoryBigMatrix <- function(bigMatAddr) {
    .Call('bigmemory_IsSharedMemoryBigMatrix', PACKAGE = 'bigmemory', bigMatAddr)
}

IsFileBackedBigMatrix <- function(bigMatAddr) {
    .Call('bigmemory_IsFileBackedBigMatrix', PACKAGE = 'bigmemory', bigMatAddr)
}

IsSeparated <- function(bigMatAddr) {
    .Call('bigmemory_IsSeparated', PACKAGE = 'bigmemory', bigMatAddr)
}

SetRowOffsetInfo <- function(bigMatAddr, rowOffset, numRows) {
    invisible(.Call('bigmemory_SetRowOffsetInfo', PACKAGE = 'bigmemory', bigMatAddr, rowOffset, numRows))
}

SetColumnOffsetInfo <- function(bigMatAddr, colOffset, numCols) {
    invisible(.Call('bigmemory_SetColumnOffsetInfo', PACKAGE = 'bigmemory', bigMatAddr, colOffset, numCols))
}

GetRowOffset <- function(bigMatAddr) {
    .Call('bigmemory_GetRowOffset', PACKAGE = 'bigmemory', bigMatAddr)
}

GetColOffset <- function(bigMatAddr) {
    .Call('bigmemory_GetColOffset', PACKAGE = 'bigmemory', bigMatAddr)
}

GetTotalColumns <- function(bigMatAddr) {
    .Call('bigmemory_GetTotalColumns', PACKAGE = 'bigmemory', bigMatAddr)
}

GetTotalRows <- function(bigMatAddr) {
    .Call('bigmemory_GetTotalRows', PACKAGE = 'bigmemory', bigMatAddr)
}

GetTypeString <- function(bigMatAddr) {
    .Call('bigmemory_GetTypeString', PACKAGE = 'bigmemory', bigMatAddr)
}

#' @title big.matrix size
#' @description Returns the size of the created matrix in bytes
#' @param bigMat a \code{big.matrix} object
#' @export
GetMatrixSize <- function(bigMat) {
    .Call('bigmemory_GetMatrixSize', PACKAGE = 'bigmemory', bigMat)
}

MWhichBigMatrix <- function(bigMatAddr, selectColumn, minVal, maxVal, chkMin, chkMax, opVal) {
    .Call('bigmemory_MWhichBigMatrix', PACKAGE = 'bigmemory', bigMatAddr, selectColumn, minVal, maxVal, chkMin, chkMax, opVal)
}

MWhichRIntMatrix <- function(matrixVector, nrow, selectColumn, minVal, maxVal, chkMin, chkMax, opVal) {
    .Call('bigmemory_MWhichRIntMatrix', PACKAGE = 'bigmemory', matrixVector, nrow, selectColumn, minVal, maxVal, chkMin, chkMax, opVal)
}

MWhichRNumericMatrix <- function(matrixVector, nrow, selectColumn, minVal, maxVal, chkMin, chkMax, opVal) {
    .Call('bigmemory_MWhichRNumericMatrix', PACKAGE = 'bigmemory', matrixVector, nrow, selectColumn, minVal, maxVal, chkMin, chkMax, opVal)
}

CCountLines <- function(fileName) {
    .Call('bigmemory_CCountLines', PACKAGE = 'bigmemory', fileName)
}

ReadMatrix <- function(fileName, bigMatAddr, firstLine, numLines, numCols, separator, hasRowNames, useRowNames) {
    .Call('bigmemory_ReadMatrix', PACKAGE = 'bigmemory', fileName, bigMatAddr, firstLine, numLines, numCols, separator, hasRowNames, useRowNames)
}

WriteMatrix <- function(bigMatAddr, fileName, rowNames, colNames, sep) {
    invisible(.Call('bigmemory_WriteMatrix', PACKAGE = 'bigmemory', bigMatAddr, fileName, rowNames, colNames, sep))
}

GetMatrixElements <- function(bigMatAddr, col, row) {
    .Call('bigmemory_GetMatrixElements', PACKAGE = 'bigmemory', bigMatAddr, col, row)
}

GetMatrixRows <- function(bigMatAddr, row) {
    .Call('bigmemory_GetMatrixRows', PACKAGE = 'bigmemory', bigMatAddr, row)
}

GetMatrixCols <- function(bigMatAddr, col) {
    .Call('bigmemory_GetMatrixCols', PACKAGE = 'bigmemory', bigMatAddr, col)
}

GetMatrixAll <- function(bigMatAddr) {
    .Call('bigmemory_GetMatrixAll', PACKAGE = 'bigmemory', bigMatAddr)
}

SetMatrixElements <- function(bigMatAddr, col, row, values) {
    invisible(.Call('bigmemory_SetMatrixElements', PACKAGE = 'bigmemory', bigMatAddr, col, row, values))
}

SetIndivMatrixElements <- function(bigMatAddr, col, row, values) {
    invisible(.Call('bigmemory_SetIndivMatrixElements', PACKAGE = 'bigmemory', bigMatAddr, col, row, values))
}

SetMatrixAll <- function(bigMatAddr, values) {
    invisible(.Call('bigmemory_SetMatrixAll', PACKAGE = 'bigmemory', bigMatAddr, values))
}

SetMatrixCols <- function(bigMatAddr, col, values) {
    invisible(.Call('bigmemory_SetMatrixCols', PACKAGE = 'bigmemory', bigMatAddr, col, values))
}

SetMatrixRows <- function(bigMatAddr, row, values) {
    invisible(.Call('bigmemory_SetMatrixRows', PACKAGE = 'bigmemory', bigMatAddr, row, values))
}

CreateSharedMatrix <- function(row, col, colnames, rownames, typeLength, ini, separated) {
    .Call('bigmemory_CreateSharedMatrix', PACKAGE = 'bigmemory', row, col, colnames, rownames, typeLength, ini, separated)
}

CreateLocalMatrix <- function(row, col, colnames, rownames, typeLength, ini, separated) {
    .Call('bigmemory_CreateLocalMatrix', PACKAGE = 'bigmemory', row, col, colnames, rownames, typeLength, ini, separated)
}

CreateFileBackedBigMatrix <- function(fileName, filePath, row, col, colnames, rownames, typeLength, ini, separated) {
    .Call('bigmemory_CreateFileBackedBigMatrix', PACKAGE = 'bigmemory', fileName, filePath, row, col, colnames, rownames, typeLength, ini, separated)
}

CAttachSharedBigMatrix <- function(sharedName, rows, cols, rowNames, colNames, typeLength, separated, readOnly) {
    .Call('bigmemory_CAttachSharedBigMatrix', PACKAGE = 'bigmemory', sharedName, rows, cols, rowNames, colNames, typeLength, separated, readOnly)
}

CAttachFileBackedBigMatrix <- function(fileName, filePath, rows, cols, rowNames, colNames, typeLength, separated, readOnly) {
    .Call('bigmemory_CAttachFileBackedBigMatrix', PACKAGE = 'bigmemory', fileName, filePath, rows, cols, rowNames, colNames, typeLength, separated, readOnly)
}

SharedName <- function(address) {
    .Call('bigmemory_SharedName', PACKAGE = 'bigmemory', address)
}

FileName <- function(address) {
    .Call('bigmemory_FileName', PACKAGE = 'bigmemory', address)
}

Flush <- function(address) {
    .Call('bigmemory_Flush', PACKAGE = 'bigmemory', address)
}

IsShared <- function(address) {
    .Call('bigmemory_IsShared', PACKAGE = 'bigmemory', address)
}

isnil <- function(address) {
    .Call('bigmemory_isnil', PACKAGE = 'bigmemory', address)
}

CDeepCopy <- function(inAddr, outAddr, rowInds, colInds, typecast_warning) {
    .Call('bigmemory_CDeepCopy', PACKAGE = 'bigmemory', inAddr, outAddr, rowInds, colInds, typecast_warning)
}


# rosetta utils

#' Convert list of numeric vectors to _SoilData_ Python object
#'
#' @description `SoilDataFromArray`: convert a list of numeric vectors containing soil properties to a `rosetta.rosetta.SoilData` class
#'
#' @param x a list of numeric vectors
#' @return an object reference to a Rosetta _SoilData_ Python object constructed from `x`
#' @export
SoilDataFromArray <- function(x) {
  rosetta_module$SoilData$from_array(x)
}

#' @description `py_to_r(<rosetta.rosetta.SoilData>)`: Wrapper S3 method for SoilData objects to prevent automatic conversion of SoilData (subclass of `"python.builtin.list"`) to an R `"list"`
#' @importFrom reticulate py_to_r
#' @export
#' @rdname SoilDataFromArray
py_to_r.rosetta.rosetta.SoilData <- function(x) {
  # do nothing; fix for https://github.com/ncss-tech/rosettaPTF/issues/8
  x
}

#' Check if Rosetta module is available for import from local Python environment
#' @return _logical_
#' @export
#' @importFrom reticulate py_module_available
rosetta_module_available <- function() {
  reticulate::py_module_available("rosetta")
}

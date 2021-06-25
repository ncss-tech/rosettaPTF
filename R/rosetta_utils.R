# rosetta utils

#' Convert list of numeric vectors to _SoilData_ Python object
#'
#' @param x a list of numeric vectors
#' @return an object reference to a Rosetta _SoilData_ Python object constructed from `x`
#' @export
SoilDataFromArray <- function(x) {
  rosetta_module$SoilData$from_array(x)
}

#
#' Check if Rosetta module is available for import from local Python environment
#' @return _logical_
#' @export
#' @importFrom reticulate py_module_available
rosetta_module_available <- function() {
  reticulate::py_module_available("rosetta")
}

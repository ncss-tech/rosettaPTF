# rosetta utils

#' Convert list of numeric vectors to SoilData python object
#'
#' @param x a list of numeric vectors
#' @return a reference to a Rosetta SoilData python object instance
#' @export
SoilDataFromArray <- function(x) {
  rosetta_module$SoilData$from_array(x)
}

#
#' Check if rosetta module can be found in local python environment
#' @return _logical_
#' @export
#' @importFrom reticulate py_module_available
rosetta_module_available <- function() {
  reticulate::py_module_available("rosetta")
}

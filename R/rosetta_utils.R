# rosetta utils

#' Convert list of numeric vectors to _SoilData_ Python object
#'
#' @description `SoilDataFromArray`: convert a list of numeric vectors containing soil properties to a `rosetta.rosetta.SoilData` class. In `rosetta-soil` >= 0.3, direct list input is preferred.
#'
#' @param x a list of numeric vectors
#' @return an object reference to a Rosetta _SoilData_ Python object constructed from `x`
#' @export
SoilDataFromArray <- function(x) {
  if (rosetta_pkg_version() >= package_version("0.3.0")) {
    .Deprecated(msg = "Direct list input is now supported by rosetta-soil >= 0.3.0. SoilDataFromArray is deprecated.")
    return(x)
  }
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

#' Get rosetta-soil Python package version
#' @return `package_version` object
#' @keywords internal
rosetta_pkg_version <- function() {
  if (rosetta_module_available()) {
    v <- try(rosetta_module$`__version__`, silent = TRUE)
    if (inherits(v, "try-error") || is.null(v)) {
      return(package_version("0.1.0"))
    }
    return(package_version(v))
  }
  package_version("0.0.0")
}

#' Check if Rosetta module is available for import from local Python environment
#' @return _logical_
#' @export
#' @importFrom reticulate py_module_available
rosetta_module_available <- function() {
  reticulate::py_module_available("rosetta")
}

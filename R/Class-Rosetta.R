# TODO: batch methods for heterogeneous input (multiple model codes/ragged `soildata` input list)

#' Make a Rosetta object instance for running `predict()` methods
#'
#' @param rosetta_version Default: `3`
#' @param model_code One of `2`, `3`, `4`, `5`, or `-1`. Corresponding to options described in _Details_.
#' @details
#' ## Explanation of Model Codes
#' - `2`: 	sand, silt, clay ("SSC")
#' - `3`: 	sand, silt, clay + bulk density ("BD")
#' - `4`: 	sand, silt, clay + bulk density + field capacity water content (1/3 bar or 33 kPa tension)
#' - `5`: 	sand, silt, clay + bulk density + field capacity water content + wilting point water content (15 bar or 1500 kPa tension)
#' - `-1`: 	no result returned, inadequate or erroneous data
#'
#' @return an instance of the `Rosetta` class defined by the Python module; suitable for running `predict` or `ann_predict` methods.
#' @rdname Rosetta-class
#' @export
Rosetta <- function(rosetta_version = 3, model_code = 3) {
  object <- rosetta_module$Rosetta(rosetta_version, model_code)
  structure(list(object = object), class = "Rosetta")
}

#' Predict Rosetta Parameter Values and Standard Deviations from a _Rosetta_ instance
#' @param object _Rosetta_ object containing class instance (e.g. from `Rosetta()`)
#' @param soildata A list containing vectors; with number of parameters matching the model type of `object`
#' @param ... not used
#' @importFrom reticulate r_to_py import
#' @method predict Rosetta
#' @export
#' @examples
#' # predict(Rosetta(), list(c(30, 30, 40, 1.5), c(55, 25, 20, 1.1)))
predict.Rosetta <- function(object, soildata, ...) {
  object$object$predict(numpy_module$array(reticulate::r_to_py(soildata),
                                           dtype = "float"))
}

#' Extended _Rosetta_ Predictions, Parameter Distributions and Summary Statistics after Zhang & Schaap (2017)
#' @param object _Rosetta_ object containing class instance (e.g. from `Rosetta()`)
#' @param soildata A list containing vectors; with number of parameters matching the model type of `object`
#' @param sum_data Default: `TRUE`
#' @importFrom reticulate r_to_py import
#' @rdname ann_predict
#' @export
ann_predict <- function(object, soildata, sum_data = TRUE)
  UseMethod("ann_predict", object)

#' @rdname ann_predict
#' @export
ann_predict.default <- function(object, soildata, sum_data = TRUE) {
  message("ann_predict() is defined for objects with class Rosetta; see `Rosetta()` to create a new instance")
  ann_predict.Rosetta(object = object, soildata = soildata, sum_data = sum_data)
}

#' @rdname ann_predict
#' @method ann_predict Rosetta
#' @examples
#' # ann_predict(Rosetta(), list(c(30, 30, 40, 1.5), c(55, 25, 20, 1.1)))
ann_predict.Rosetta <- function(object, soildata, sum_data = TRUE) {
  object$object$ann_predict(numpy_module$array(reticulate::r_to_py(soildata),
                                               dtype = "float"),
                            sum_data = sum_data)
}

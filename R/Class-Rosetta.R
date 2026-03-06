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
  object <- rosetta_module$Rosetta(as.integer(rosetta_version), as.integer(model_code))
  structure(list(object = object), class = "Rosetta")
}

#' Predict Rosetta Parameter Values and Standard Deviations from a _Rosetta_ instance
#' @param object _Rosetta_ object containing class instance (e.g. from `Rosetta()`)
#' @param soildata A list containing vectors; with number of parameters matching the model type of `object`
#' @param ... not used
#' @return A list containing `mean` and `stdev` matrices (one row per sample).
#'
#' For `rosetta-soil` >= 0.3, the columns are: `theta_r`, `theta_s`, `alpha`, `npar`, `ksat`.
#' Note that these parameters are in the scale produced by the underlying model (often log10 for alpha, npar, and ksat).
#' @importFrom reticulate r_to_py import
#' @method predict Rosetta
#' @export
#' @examples
#' # predict(Rosetta(), list(c(30, 30, 40, 1.5), c(55, 25, 20, 1.1)))
predict.Rosetta <- function(object, soildata, ...) {
  if (rosetta_pkg_version() >= package_version("0.3.0")) {
    res <- object$object$predict(numpy_module$array(reticulate::r_to_py(soildata),
                                             dtype = "float"))
    retc_boot <- res[[1]]
    ksat_boot <- res[[2]]

    retc_mean <- numpy_module$mean(retc_boot, axis = 0L)
    retc_std  <- numpy_module$std(retc_boot, axis = 0L)
    ksat_mean <- numpy_module$mean(ksat_boot, axis = 0L)
    ksat_std  <- numpy_module$std(ksat_boot, axis = 0L)

    mean_val <- numpy_module$concatenate(list(retc_mean, ksat_mean), axis = 1L)
    std_val  <- numpy_module$concatenate(list(retc_std, ksat_std), axis = 1L)

    return(list(mean = mean_val, stdev = std_val))

  } else {
    res <- object$object$predict(numpy_module$array(reticulate::r_to_py(soildata),
                                             dtype = "float"))
    names(res) <- c("mean", "stdev")
    return(res)
  }
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
  if (rosetta_pkg_version() >= package_version("0.3.0")) {
    .Deprecated("predict", msg = "ann_predict() is deprecated in rosetta-soil >= 0.3.0. Use predict() instead.")
  } else {
    message("ann_predict() is defined for objects with class Rosetta; see `Rosetta()` to create a new instance")
  }
  ann_predict.Rosetta(object = object, soildata = soildata, sum_data = sum_data)
}

#' @rdname ann_predict
#' @method ann_predict Rosetta
#' @export
#' @importFrom stats predict
#' @examples
#' # ann_predict(Rosetta(), list(c(30, 30, 40, 1.5), c(55, 25, 20, 1.1)))
ann_predict.Rosetta <- function(object, soildata, sum_data = TRUE) {
  if (rosetta_pkg_version() >= package_version("0.3.0")) {
    .Deprecated("predict", msg = "ann_predict() is deprecated in rosetta-soil >= 0.3.0. Use predict() instead.")
    return(predict(object, soildata))
  }
  object$object$ann_predict(numpy_module$array(reticulate::r_to_py(soildata),
                                               dtype = "float"),
                            sum_data = sum_data)
}

#' Make an UnsaturatedK object instance
#'
#' @description `UnsaturatedK`: Create an instance of the `UnsaturatedK` class from `rosetta-soil` >= 0.3. This class is used to predict `K0` and `L` from retention parameters.
#'
#' @return an instance of the `UnsaturatedK` class.
#' @export
UnsaturatedK <- function() {
  if (rosetta_pkg_version() < package_version("0.3.0")) {
    stop("UnsaturatedK requires rosetta-soil >= 0.3.0", call. = FALSE)
  }

  object <- rosetta_module$UnsaturatedK()
  structure(list(object = object), class = "UnsaturatedK")
}

#' Predict K0 and L from retention parameters
#'
#' @param object _UnsaturatedK_ object
#' @param retc_params A list or matrix of retention parameters (theta_r, theta_s, alpha, npar)
#' @param ... not used
#' @return a `data.frame` with `log10_K0_mean`, `lpar_mean`, `log10_K0_sd`, `lpar_sd`
#' @method predict UnsaturatedK
#' @export
predict.UnsaturatedK <- function(object, retc_params, ...) {
  res <- object$object$predict(numpy_module$array(reticulate::r_to_py(retc_params),
                                           dtype = "float"))

  k0l_mean <- numpy_module$mean(res, axis = 0L)
  k0l_std  <- numpy_module$std(res, axis = 0L)

  df <- data.frame(
    log10_K0_mean = k0l_mean[, 1],
    lpar_mean     = k0l_mean[, 2],
    log10_K0_sd   = k0l_std[, 1],
    lpar_sd       = k0l_std[, 2]
  )
  return(df)
}
